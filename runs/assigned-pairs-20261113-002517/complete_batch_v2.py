"""Wait for the primary queue, recover only rejected standard setup checks, audit.

Every original result remains intact. New aggregate files include every assignment.
"""
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
post = batch / 'completion-pass-v2'
post.mkdir(exist_ok=False)
python = '/home/mlkoe/.venvs/se433-swt/bin/python'
sys.path.insert(0, str(project))
from export_prediction import export_prediction


def save(path, value):
    with path.open('x') as stream:
        json.dump(value, stream, indent=2)
        stream.write('\n')


def event(stage, instance=None, **extra):
    record = dict(utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                  stage=stage, instance_id=instance, **extra)
    with (post / 'events.jsonl').open('a') as stream:
        stream.write(json.dumps(record) + '\n')
    print(json.dumps(record), flush=True)


def run(args, log, timeout=3600):
    started = time.monotonic()
    save(log.with_suffix('.command.json'), args)
    with log.open('x') as stream:
        process = subprocess.Popen(args, cwd=project, stdout=stream, stderr=subprocess.STDOUT,
                                   start_new_session=True)
        try:
            code = process.wait(timeout=timeout)
            return {'exit_code': code, 'seconds': time.monotonic() - started, 'timed_out': False}
        except subprocess.TimeoutExpired:
            os.killpg(process.pid, signal.SIGTERM)
            try:
                process.wait(timeout=20)
            except subprocess.TimeoutExpired:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait()
            # Stop only build containers recorded by this retry's own log.
            if log.name == 'retry-setup.console.log':
                for buildlog in log.parent.glob('image_build_logs/**/build_image.log'):
                    identifiers = re.findall(r'Running in ([0-9a-f]{12,64})', buildlog.read_text(errors='replace'))
                    if identifiers:
                        check = subprocess.run(['docker', 'inspect', '--format', '{{.State.Running}}', identifiers[-1]], capture_output=True, text=True)
                        if check.returncode == 0 and check.stdout.strip() == 'true':
                            subprocess.run(['docker', 'stop', '--timeout', '10', identifiers[-1]], stdout=stream, stderr=subprocess.STDOUT, timeout=30)
            # Cleanup only this command's explicitly named agent containers.
            for name in set(re.findall(r'minisweagent-[0-9a-f]+', log.read_text(errors='replace'))):
                subprocess.run(['docker', 'stop', '--timeout', '10', name],
                               stdout=stream, stderr=subprocess.STDOUT, timeout=30)
            return {'exit_code': process.returncode, 'seconds': time.monotonic() - started, 'timed_out': True}


def primary_pid():
    expected = str(batch / 'run_batch.py')
    for directory in Path('/proc').iterdir():
        if not directory.name.isdigit():
            continue
        try:
            args = (directory / 'cmdline').read_bytes().decode().split('\0')
        except (OSError, UnicodeError):
            continue
        if len(args) > 1 and (args[1] == expected or args[1] == str(Path('runs') / batch.name / 'run_batch.py')):
            return int(directory.name)
    return None


try:
    pid = primary_pid()
    save(post / 'start.json', {'pid': os.getpid(), 'primary_pid': pid,
                              'created_utc': datetime.datetime.now(datetime.timezone.utc).isoformat()})
    event('waiting_for_primary_batch')
    while True:
        try:
            outcomes = json.loads((batch / 'outcomes.json').read_text())
            done = any(json.loads(line).get('stage') == 'batch_complete'
                       for line in (batch / 'events.jsonl').read_text().splitlines())
            if done and len(outcomes) == len(plan['assignment']['instances']):
                break
        except (OSError, ValueError):
            pass
        if primary_pid() is None:
            raise RuntimeError('Primary batch ended before its complete outcome ledger; preserve and inspect its logs.')
        time.sleep(5)
    event('primary_batch_complete')
    save(post / 'primary-ledger-sha256.json', {'sha256': hashlib.sha256((batch / 'outcomes.json').read_bytes()).hexdigest()})
    (post / 'instances').mkdir()
    recovered = []
    rejected = []
    for entry in plan['assignment']['instances']:
        instance = entry['instance_id']
        old = batch / 'instances' / instance
        failure_file = old / 'setup-failure.json'
        if outcomes[instance]['status'] != 'setup_failed' or not failure_file.exists():
            continue
        failure = json.loads(failure_file.read_text())
        timing = json.loads((old / 'setup-timing.json').read_text())
        rebuild = bool(timing.get('timed_out'))
        if not rebuild and (failure.get('error_type') != 'AssertionError' or not (old / 'image-identity.json').exists()):
            continue
        case = post / 'instances' / instance
        case.mkdir()
        save(case / 'metadata.json', json.loads((old / 'metadata.json').read_text()))
        source_case = old
        if rebuild:
            event('unchanged_recipe_setup_retry_started', instance, setup_timeout_seconds=1800)
            retry = run(['/mnt/c/Users/mlkoe/projects/swt-bench/.venv/bin/python',
                         str(batch / 'retry_prepare_image.py'), str(case), str(old)],
                        case / 'retry-setup.console.log', timeout=1800)
            save(case / 'retry-setup-timing.json', retry)
            if retry['exit_code'] or retry['timed_out']:
                save(case / 'recovery-outcome.json', {'status': 'setup_retry_failed', 'initial_error': failure, 'retry': retry})
                rejected.append(instance)
                event('setup_retry_failed', instance, **retry)
                continue
            source_case = case
        event('prescribed_setup_verification_started', instance)
        result = run([python, str(batch / 'verify_setup_delta.py'), str(source_case), str(case / 'setup-check')],
                     case / 'verification.console.log', timeout=120)
        save(case / 'verification-timing.json', result)
        proof = case / 'setup-check' / 'image-verification.json'
        if result['exit_code'] or not proof.exists() or not json.loads(proof.read_text()).get('accepted'):
            save(case / 'recovery-outcome.json', {'status': 'setup_verification_rejected', 'initial_error': failure})
            rejected.append(instance)
            event('setup_recovery_rejected', instance)
            continue
        save(case / 'image-verification.json', json.loads(proof.read_text()))
        identity = json.loads((source_case / 'image-identity.json').read_text())
        if not (case / 'image-identity.json').exists():
            save(case / 'image-identity.json', identity)
        else:
            assert json.loads((case / 'image-identity.json').read_text()) == identity
        outcome = {'status': 'generation_attempted_after_prescribed_setup_verification', 'runs': {},
                   'initial_setup_error': str(failure_file), 'prescribed_setup_proof': str(proof)}
        for mode in ('baseline', 'improved'):
            event('generation_started', instance, mode=mode)
            result = run([python, str(batch / 'recover_generation.py'), str(case), mode],
                         case / f'{mode}.console.log')
            save(case / f'{mode}-timing.json', result)
            outcome['runs'][mode] = str(case / ('generation-' + mode))
            event('generation_finished', instance, mode=mode, **result)
        save(case / 'recovery-outcome.json', outcome)
        outcomes[instance] = outcome
        recovered.append(instance)
        event('pair_recorded', instance)
    save(post / 'outcomes.json', outcomes)
    (post / 'predictions').mkdir()
    summaries = {}
    totals = {mode: {'assigned': 26, 'setup_errors': 0, 'submitted': 0, 'non_submission_or_generation_error': 0,
                     'empty_predictions': 0, 'fallbacks': 0, 'validated_specifications': 0,
                     'known_agent_cost': 0.0, 'agent_cost_available_runs': 0}
              for mode in ('baseline', 'improved')}
    selected = set()
    for entry in plan['assignment']['instances']:
        instance = entry['instance_id']
        outcome = outcomes[instance]
        summaries[instance] = {'outcome': outcome['status'], 'methods': {}}
        for mode in ('baseline', 'improved'):
            target = post / 'predictions' / f'{instance}-{mode}.jsonl'
            run_path = Path(outcome['runs'][mode]) if outcome.get('runs', {}).get(mode) else None
            manifest = None
            result = None
            if run_path and (run_path / 'manifest.json').exists():
                selected.add(str(run_path.resolve()))
                export_prediction(run_path, target)
                manifest = json.loads((run_path / 'manifest.json').read_text())
                if (run_path / 'agent_result.json').exists():
                    result = json.loads((run_path / 'agent_result.json').read_text())
            else:
                target.write_bytes((batch / 'predictions' / f'{instance}-{mode}.jsonl').read_bytes())
            row = json.loads(target.read_text())
            assert row['instance_id'] == instance
            if manifest:
                expected_patch = result.get('submission', '') if result and result.get('exit_status') == 'Submitted' else ''
                assert row['model_patch'] == expected_patch
            record = {'run': str(run_path) if run_path else None, 'manifest': manifest,
                      'agent_exit_status': result.get('exit_status') if result else None,
                      'prediction_empty': not bool(row['model_patch']),
                      'model_patch_sha256': hashlib.sha256(row['model_patch'].encode()).hexdigest()}
            total = totals[mode]
            if outcome['status'] == 'setup_failed':
                total['setup_errors'] += 1
            elif result and result.get('exit_status') == 'Submitted':
                total['submitted'] += 1
            else:
                total['non_submission_or_generation_error'] += 1
            total['empty_predictions'] += record['prediction_empty']
            if manifest:
                total['fallbacks'] += bool(manifest.get('fallback'))
                total['validated_specifications'] += bool(manifest.get('validated'))
                record['saved_extraction_requests'] = len(list(run_path.glob('extract-*.request.json')))
                record['saved_review_requests'] = len(list(run_path.glob('review-*.request.json')))
                trajectory = run_path / 'agent.traj.json'
                if trajectory.exists():
                    stats = json.loads(trajectory.read_text()).get('info', {}).get('model_stats', {})
                    record['agent_stats'] = stats
                    if isinstance(stats.get('instance_cost'), (int, float)):
                        total['known_agent_cost'] += stats['instance_cost']
                        total['agent_cost_available_runs'] += 1
            summaries[instance]['methods'][mode] = record
    for mode in ('baseline', 'improved'):
        with (post / f'{mode}-predictions.jsonl').open('x') as stream:
            for entry in plan['assignment']['instances']:
                stream.write((post / 'predictions' / f"{entry['instance_id']}-{mode}.jsonl").read_text())
    history = []
    for path in (project / 'runs').rglob('manifest.json'):
        try:
            manifest = json.loads(path.read_text())
        except (OSError, ValueError):
            continue
        if manifest.get('instance_id') not in outcomes:
            continue
        history.append({'run': str(path.parent), 'selected_for_final_prediction': str(path.parent.resolve()) in selected,
                        'mode': manifest.get('mode'), 'test_format': manifest.get('test_format'),
                        'status': manifest.get('status'), 'failure_stage': manifest.get('failure_stage'),
                        'error_type': manifest.get('error_type'), 'fallback': manifest.get('fallback'),
                        'attempts': manifest.get('attempts')})
    save(post / 'historical-generation-attempts.json', history)
    save(post / 'generation-summary.json', {'assigned_instances': 26, 'totals': totals, 'instances': summaries,
                                           'recovered_setup_checks': recovered, 'rejected_setup_recoveries': rejected,
                                           'official_evaluation_run': False,
                                           'cost_note': 'Known agent-only cost; preprocessing cost is additional.'})
    for filename, expected in plan['workflow_hashes'].items():
        assert hashlib.sha256((project / filename).read_bytes()).hexdigest() == expected
    audit = run([python, str(batch / 'verify_pairs_v3.py'), '--final', '--outcomes', str(post / 'outcomes.json')],
                post / 'identity-audit.console.log', timeout=300)
    save(post / 'identity-audit-timing.json', audit)
    if audit['exit_code']:
        raise RuntimeError('Final identity audit needs review; preserved audit output contains details.')
    save(post / 'completion.json', {'completed_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
                                  'assigned_instances': 26, 'totals': totals,
                                  'recovered_setup_checks': recovered, 'remaining_setup_errors': totals['baseline']['setup_errors'],
                                  'workflow_files_unchanged': True, 'official_evaluation_run': False})
    event('completion_pass_finished', assigned_instances=26, totals=totals)
except Exception as exc:
    save(post / 'completion-error.json', {'type': type(exc).__name__, 'message': str(exc)})
    event('completion_pass_error', error_type=type(exc).__name__, message=str(exc))
    raise
