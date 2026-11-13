"""Read-only pair identity audit, with exclusively created verification records."""
import datetime
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

batch = Path(__file__).resolve().parent
project = batch.parent.parent
sys.path.insert(0, str(project))
from controller import load_agent_config

plan = json.loads((batch / 'plan.json').read_text())
final = '--final' in sys.argv
image_cache = {}


def sha(value):
    return hashlib.sha256(value).hexdigest()


def canonical(value):
    return sha(json.dumps(value, sort_keys=True, separators=(',', ':')).encode())


def read(path):
    try:
        return json.loads(path.read_text())
    except (OSError, ValueError):
        return None


def resolve_image(reference):
    if reference not in image_cache:
        try:
            result = subprocess.run(['docker', 'image', 'inspect', reference, '--format', '{{.Id}}'],
                                    capture_output=True, text=True, timeout=30)
            image_cache[reference] = {'image_id': result.stdout.strip() if result.returncode == 0 else None,
                                      'error': result.stderr.strip() if result.returncode else None}
        except (OSError, subprocess.TimeoutExpired) as exc:
            image_cache[reference] = {'image_id': None, 'error': str(exc)}
    return image_cache[reference]


def immutable(reference):
    return bool(re.fullmatch(r'sha256:[0-9a-f]{64}', reference)
                or re.search(r'@sha256:[0-9a-f]{64}$', reference))


entries = plan['assignment']['instances']
completed = read(batch / 'outcomes.json') or {}
outside = {}
for path in sorted((project / 'runs').rglob('manifest.json')):
    if batch in path.parents:
        continue
    manifest = read(path)
    entry = next((e for e in entries if e['instance_id'] == (manifest or {}).get('instance_id')), None)
    if not entry or manifest.get('status') != 'agent_finished' or manifest.get('test_format') != 'unit_test':
        continue
    expected_report = (project / 'data' / entry['report']).read_text(encoding='utf-8').encode()
    if (manifest.get('report_sha256') == sha(expected_report)
            and manifest.get('unit_test_profile_sha256') == plan['workflow_hashes']['profiles/unit_test.yaml']
            and manifest.get('mode') in ('baseline', 'improved')):
        outside[(entry['instance_id'], manifest['mode'])] = path.parent

audit = {'verified_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
         'final': final, 'assigned_instances': len(entries), 'workflow_hash_checks': {},
         'source_report_hash_checks': {}, 'pairs': {}}
for filename, expected in plan['workflow_hashes'].items():
    audit['workflow_hash_checks'][filename] = sha((project / filename).read_bytes()) == expected
for entry in entries:
    instance = entry['instance_id']
    source = project / 'data' / entry['report']
    audit['source_report_hash_checks'][instance] = sha(source.read_bytes()) == entry['report_sha256']
    outcome = completed.get(instance) or read(batch / 'instances' / instance / 'outcome.json')
    if outcome and outcome['status'] == 'setup_failed':
        audit['pairs'][instance] = {'status': 'setup_error_no_generation_pair',
                                    'setup_error': read(batch / 'instances' / instance / 'setup-failure.json')}
        continue
    if outcome:
        paths = {mode: Path(path) for mode, path in outcome['runs'].items()}
    else:
        paths = {mode: outside.get((instance, mode)) for mode in ('baseline', 'improved')}
    if not all(paths.get(mode) for mode in ('baseline', 'improved')):
        audit['pairs'][instance] = {'status': 'pending'}
        continue
    manifests = {mode: read(path / 'manifest.json') for mode, path in paths.items()}
    if not all(manifests.values()):
        audit['pairs'][instance] = {'status': 'generation_error_or_pending',
                                    'runs': {mode: str(path) for mode, path in paths.items()}}
        continue
    reports = {}
    configs = {}
    issues = []
    limitations = []
    runs = {}
    expected_report = source.read_text(encoding='utf-8').encode()
    for mode, path in paths.items():
        manifest = manifests[mode]
        report = path / 'report.txt'
        cfg = read(path / 'effective_config.json')
        if not report.exists() or cfg is None:
            issues.append(f'{mode}: report or effective configuration unavailable')
            continue
        report_bytes = report.read_bytes()
        image = manifest.get('image', '')
        resolved = resolve_image(image)
        checks = {
            'instance_id': manifest.get('instance_id') == instance,
            'mode': manifest.get('mode') == mode,
            'unit_test_format': manifest.get('test_format') == 'unit_test',
            'report_matches_saved_input_after_controller_newline_read': report_bytes == expected_report,
            'report_hash_matches_artifact': manifest.get('report_sha256') == sha(report_bytes),
            'baseline_config_hash': manifest.get('baseline_sha256') == plan['workflow_hashes']['baseline/swt_test.yaml'],
            'baseline_unchanged_flag': manifest.get('baseline_unchanged') is True,
            'unit_test_profile_hash': manifest.get('unit_test_profile_sha256') == plan['workflow_hashes']['profiles/unit_test.yaml'],
            'effective_config_matches_unchanged_loader': cfg == load_agent_config(project / 'baseline/swt_test.yaml', image, 'unit_test'),
            'effective_image_matches_manifest': cfg.get('environment', {}).get('image') == image,
        }
        if resolved['image_id'] is None:
            limitations.append(f'{mode}: current image ID could not be resolved')
        if not immutable(image):
            limitations.append(f'{mode}: launch recorded a mutable tag; current resolution cannot prove historical image identity')
        task = path / 'task.txt'
        if task.exists():
            expected_task = expected_report.decode()
            if mode == 'improved' and manifest.get('validated'):
                spec = read(path / 'bug_spec.json')
                expected_task += '\n\nEvidence-grounded specification (supporting analysis):\n' + json.dumps(spec, indent=2)
            checks['task_matches_recorded_workflow'] = task.read_text() == expected_task
        reports[mode] = sha(report_bytes)
        configs[mode] = canonical(cfg)
        for name, passed in checks.items():
            if not passed:
                issues.append(f'{mode}: {name} mismatch')
        runs[mode] = {'directory': str(path), 'checks': checks, 'report_sha256': sha(report_bytes),
                      'effective_config_sha256_canonical': canonical(cfg), 'image_reference': image,
                      'image_reference_is_immutable': immutable(image), 'currently_resolved_image': resolved,
                      'generation_status': manifest.get('status'), 'fallback': manifest.get('fallback'),
                      'preprocessing_attempts': manifest.get('attempts')}
    paired = {
        'report_identity_matches': len(reports) == 2 and reports['baseline'] == reports['improved'],
        'effective_config_identity_matches': len(configs) == 2 and configs['baseline'] == configs['improved'],
        'baseline_config_identity_matches': manifests['baseline'].get('baseline_sha256') == manifests['improved'].get('baseline_sha256'),
        'profile_identity_matches': manifests['baseline'].get('unit_test_profile_sha256') == manifests['improved'].get('unit_test_profile_sha256'),
    }
    if len(runs) == 2:
        ids = [runs[mode]['currently_resolved_image']['image_id'] for mode in ('baseline', 'improved')]
        paired['current_image_identity_matches'] = ids[0] is not None and ids[0] == ids[1]
        if ids[0] is not None and ids[1] is not None and ids[0] != ids[1]:
            issues.append('resolved image identities differ')
    for name, passed in paired.items():
        if not passed and name != 'current_image_identity_matches':
            issues.append(name)
    audit['pairs'][instance] = {'status': 'mismatch' if issues else ('matched_with_evidence_limitations' if limitations else 'matched'),
                                'paired_checks': paired, 'issues': issues, 'limitations': limitations, 'runs': runs}

counts = {}
for result in audit['pairs'].values():
    counts[result['status']] = counts.get(result['status'], 0) + 1
audit['counts'] = counts
audit['all_recorded_workflow_files_unchanged'] = all(audit['workflow_hash_checks'].values())
audit['all_saved_reports_unchanged'] = all(audit['source_report_hash_checks'].values())
directory = batch / 'verification'
directory.mkdir(exist_ok=True)
stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%d-%H%M%S-%f')
target = directory / ('pair-verification-final.json' if final else f'pair-verification-{stamp}.json')
with target.open('x') as stream:
    json.dump(audit, stream, indent=2)
    stream.write('\n')
print(json.dumps({'report': str(target), 'counts': counts,
                  'workflow_unchanged': audit['all_recorded_workflow_files_unchanged'],
                  'saved_reports_unchanged': audit['all_saved_reports_unchanged']}), flush=True)
if counts.get('mismatch') or not audit['all_recorded_workflow_files_unchanged'] or not audit['all_saved_reports_unchanged']:
    sys.exit(1)
if final and (counts.get('pending') or counts.get('generation_error_or_pending')):
    sys.exit(2)
