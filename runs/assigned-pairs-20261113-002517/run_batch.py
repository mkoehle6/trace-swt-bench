"""Sequential paired generation with two independent image preparation workers."""
import concurrent.futures
import datetime
import hashlib
import json
import os
import re
import signal
import subprocess
import sys
import time
from pathlib import Path

batch = Path(__file__).resolve().parent
project = batch.parent.parent
plan = json.loads((batch / 'plan.json').read_text())
agent_python = os.environ.get('SWT_AGENT_PYTHON', sys.executable)
harness_python = '/workspace/swt-bench/.venv/bin/python'
sys.path.insert(0, str(project))
from export_prediction import export_prediction


def save(path, value):
    with path.open('x') as stream:
        json.dump(value, stream, indent=2)
        stream.write('\n')


def event(stage, instance=None, **extra):
    data = dict(utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                stage=stage, instance_id=instance, **extra)
    with (batch / 'events.jsonl').open('a') as stream:
        stream.write(json.dumps(data) + '\n')
    print(json.dumps(data), flush=True)


def run(args, log, timeout):
    started = time.monotonic()
    with log.open('x') as stream:
        process = subprocess.Popen(args, cwd=project, stdout=stream, stderr=subprocess.STDOUT,
                                   start_new_session=True)
        try:
            code = process.wait(timeout=timeout)
            return dict(exit_code=code, seconds=time.monotonic() - started, timed_out=False)
        except subprocess.TimeoutExpired:
            # Stop only build containers explicitly identified by this case's own log.
            stopped = []
            if log.name == 'setup.console.log':
                for buildlog in log.parent.glob('image_build_logs/**/build_image.log'):
                    identifiers = re.findall(r'Running in ([0-9a-f]{12,64})', buildlog.read_text(errors='replace'))
                    if identifiers:
                        identifier = identifiers[-1]
                        check = subprocess.run(['docker', 'inspect', '--format', '{{.State.Running}}', identifier],
                                               capture_output=True, text=True)
                        if check.returncode == 0 and check.stdout.strip() == 'true':
                            subprocess.run(['docker', 'stop', '--timeout', '10', identifier],
                                           stdout=stream, stderr=subprocess.STDOUT, timeout=30)
                            stopped.append(identifier)
            if process.poll() is None:
                os.killpg(process.pid, signal.SIGTERM)
                try:
                    process.wait(timeout=20)
                except subprocess.TimeoutExpired:
                    os.killpg(process.pid, signal.SIGKILL)
                    process.wait()
            return dict(exit_code=process.returncode, seconds=time.monotonic() - started,
                        timed_out=True, stopped_own_build_containers=stopped)


def verify_image(case, metadata):
    image = json.loads((case / 'image-identity.json').read_text())['image_id']
    code = ("import subprocess,json,sys; print(json.dumps({'head':"
            "subprocess.check_output(['git','rev-parse','HEAD']).decode().strip(),"
            "'clean':not subprocess.check_output(['git','status','--porcelain']).decode().strip(),"
            "'python':sys.version}))")
    result = subprocess.run(['docker', 'run', '--rm', '-w', '/testbed', '-e', 'BASH_ENV=/root/.bashrc',
                             image, 'bash', '-c', 'python -c ' + __import__('shlex').quote(code)],
                            capture_output=True, text=True, timeout=90)
    save(case / 'verification-command.json', {'exit_code': result.returncode,
                                             'stdout': result.stdout, 'stderr': result.stderr})
    result.check_returncode()
    verification = json.loads(result.stdout)
    assert verification['head'] == metadata['base_commit'] and verification['clean']
    save(case / 'image-verification.json', verification)


def prepare(entry):
    instance = entry['instance_id']
    case = batch / 'instances' / instance
    case.mkdir()
    save(case / 'metadata.json', plan['metadata'][instance])
    event('setup_started', instance)
    try:
        result = run([harness_python, str(batch / 'prepare_image.py'), instance],
                     case / 'setup.console.log', plan['setup_timeout_seconds'])
        save(case / 'setup-timing.json', result)
        if result['exit_code'] != 0 or result['timed_out']:
            raise RuntimeError('Image preparation failed or exceeded setup timeout; see preserved log.')
        verify_image(case, plan['metadata'][instance])
        event('setup_ready', instance)
        return entry, None
    except Exception as exc:
        failure = {'error_type': type(exc).__name__, 'message': str(exc), 'generation_started': False}
        save(case / 'setup-failure.json', failure)
        event('setup_failed', instance, **failure)
        return entry, failure


def prediction(instance, mode, run_path):
    target = batch / 'predictions' / f'{instance}-{mode}.jsonl'
    if run_path and (run_path / 'manifest.json').exists():
        export_prediction(run_path, target)
    else:
        with target.open('x') as stream:
            stream.write(json.dumps({'instance_id': instance, 'model_patch': '',
                                      'model_name_or_path': f'trace-{mode}-unit-test'}) + '\n')


if __name__ == '__main__':
    for filename, expected in plan['workflow_hashes'].items():
        assert hashlib.sha256((project / filename).read_bytes()).hexdigest() == expected
    profile_sha = plan['workflow_hashes']['profiles/unit_test.yaml']
    entries = plan['assignment']['instances']
    for entry in entries:
        assert hashlib.sha256((project / 'data' / entry['report']).read_bytes()).hexdigest() == entry['report_sha256']
    existing = {}
    # Selection reads generation manifests only; no evaluator scores, patches or logs.
    for path in sorted((project / 'runs').rglob('manifest.json')):
        if batch in path.parents:
            continue
        try:
            meta = json.loads(path.read_text())
        except (ValueError, OSError):
            continue
        entry = next((e for e in entries if e['instance_id'] == meta.get('instance_id')), None)
        if (entry and meta.get('status') == 'agent_finished' and meta.get('test_format') == 'unit_test'
                and meta.get('unit_test_profile_sha256') == profile_sha
                and meta.get('report_sha256') == entry['report_sha256']):
            existing[(entry['instance_id'], meta['mode'])] = path.parent
    (batch / 'instances').mkdir()
    (batch / 'predictions').mkdir()
    outcomes = {}
    remaining = []
    for entry in entries:
        instance = entry['instance_id']
        modes = {mode: existing.get((instance, mode)) for mode in ('baseline', 'improved')}
        if all(modes.values()):
            identities = [json.loads((path / 'manifest.json').read_text())['image'] for path in modes.values()]
            assert identities[0] == identities[1], instance
            for mode, path in modes.items():
                prediction(instance, mode, path)
            outcomes[instance] = {'status': 'reused_completed_pair', 'runs': {k: str(v) for k, v in modes.items()}}
            event('existing_pair_preserved', instance)
        else:
            remaining.append(entry)
    # Reuse Django dependencies first; defer the previously slow xarray build to the end.
    remaining.sort(key=lambda e: (e['instance_id'] == 'pydata__xarray-3677', e['repo'] != 'django/django'))
    save(batch / 'execution-order.json', [entry['instance_id'] for entry in remaining])
    with concurrent.futures.ThreadPoolExecutor(max_workers=plan['max_build_workers']) as pool:
        pending = {pool.submit(prepare, entry): entry for entry in remaining[:2]}
        queue = iter(remaining[2:])
        while pending:
            finished, _ = concurrent.futures.wait(pending, return_when=concurrent.futures.FIRST_COMPLETED)
            for future in finished:
                pending.pop(future)
                entry, failure = future.result()
                instance = entry['instance_id']
                case = batch / 'instances' / instance
                outcome = {'status': 'setup_failed' if failure else 'generation_attempted', 'runs': {}}
                if failure:
                    for mode in ('baseline', 'improved'):
                        prediction(instance, mode, None)
                else:
                    for mode in ('baseline', 'improved'):
                        path = existing.get((instance, mode))
                        if path is None:
                            event('generation_started', instance, mode=mode)
                            result = run([agent_python, str(batch / 'generate.py'), instance, mode],
                                         case / f'{mode}.console.log', 3600)
                            save(case / f'{mode}-timing.json', result)
                            path = case / ('generation-' + mode)
                            event('generation_finished', instance, mode=mode, **result)
                        outcome['runs'][mode] = str(path)
                        prediction(instance, mode, path)
                save(case / 'outcome.json', outcome)
                outcomes[instance] = outcome
                event('pair_recorded', instance, status=outcome['status'])
                try:
                    next_entry = next(queue)
                except StopIteration:
                    continue
                pending[pool.submit(prepare, next_entry)] = next_entry
    save(batch / 'outcomes.json', outcomes)
    for mode in ('baseline', 'improved'):
        with (batch / f'{mode}-predictions.jsonl').open('x') as stream:
            for entry in entries:
                stream.write((batch / 'predictions' / f"{entry['instance_id']}-{mode}.jsonl").read_text())
    for filename, expected in plan['workflow_hashes'].items():
        assert hashlib.sha256((project / filename).read_bytes()).hexdigest() == expected
    event('batch_complete', assigned_instances=len(entries), recorded_instances=len(outcomes))
