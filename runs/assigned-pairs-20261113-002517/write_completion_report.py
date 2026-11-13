"""Validate final exports and document outcomes without changing any prediction."""
import hashlib
import json
import sys
from pathlib import Path

batch = Path(__file__).resolve().parent
post = Path(sys.argv[1]).resolve()
plan = json.loads((batch / 'plan.json').read_text())
completion = json.loads((post / 'completion.json').read_text())
outcomes = json.loads((post / 'outcomes.json').read_text())
summary = json.loads((post / 'generation-summary.json').read_text())
audit_path = Path(sys.argv[2]).resolve() if len(sys.argv) > 2 else batch / 'verification' / 'pair-verification-final.json'
audit = json.loads(audit_path.read_text())
expected_ids = [entry['instance_id'] for entry in plan['assignment']['instances']]
assert len(expected_ids) == 26 and len(set(expected_ids)) == 26
assert set(outcomes) == set(expected_ids)
checks = {}
for mode in ('baseline', 'improved'):
    path = post / f'{mode}-predictions.jsonl'
    rows = [json.loads(line) for line in path.read_text().splitlines()]
    assert [row['instance_id'] for row in rows] == expected_ids
    for row in rows:
        assert isinstance(row['model_patch'], str)
        assert row['model_name_or_path'] == f'trace-{mode}-unit-test'
        directory = outcomes[row['instance_id']].get('runs', {}).get(mode)
        if directory and (Path(directory) / 'agent_result.json').exists():
            result = json.loads((Path(directory) / 'agent_result.json').read_text())
            expected = result.get('submission', '') if result.get('exit_status') == 'Submitted' else ''
            assert row['model_patch'] == expected
        else:
            assert row['model_patch'] == ''
    checks[mode] = {'rows': len(rows), 'unique_ids': len({row['instance_id'] for row in rows}),
                    'sha256': hashlib.sha256(path.read_bytes()).hexdigest(), 'unchanged_submission_exports': True}
assert audit['all_recorded_workflow_files_unchanged'] and audit['all_saved_reports_unchanged']
assert not audit['counts'].get('mismatch') and not audit['counts'].get('pending')
with (post / 'export-validation.json').open('x') as stream:
    json.dump(checks, stream, indent=2)

history = []
for entry in plan['assignment']['instances']:
    instance = entry['instance_id']
    original = batch / 'instances' / instance
    if (original / 'setup-failure.json').exists():
        history.append({'instance_id': instance, 'phase': 'primary',
                        'failure': json.loads((original / 'setup-failure.json').read_text()),
                        'timing': json.loads((original / 'setup-timing.json').read_text()) if (original / 'setup-timing.json').exists() else None,
                        'final_outcome': outcomes[instance]['status'], 'directory': str(original)})
    retry = post / 'instances' / instance
    if (retry / 'retry-setup-timing.json').exists():
        history.append({'instance_id': instance, 'phase': 'unchanged_recipe_retry',
                        'timing': json.loads((retry / 'retry-setup-timing.json').read_text()),
                        'final_outcome': outcomes[instance]['status'], 'directory': str(retry)})
for earlier in ('completion-pass', 'completion-pass-v2'):
    path = batch / earlier / 'superseded.json'
    if path.exists():
        history.append({'phase': 'coordinator_history', 'record': json.loads(path.read_text()), 'directory': str(path.parent)})
with (post / 'setup-attempt-history.json').open('x') as stream:
    json.dump(history, stream, indent=2)

totals = summary['totals']
limited = [instance for instance, pair in audit['pairs'].items() if pair['status'] == 'matched_with_evidence_limitations']
rows = [
    ('Assigned instances', 'assigned'), ('Submitted', 'submitted'),
    ('Non-submission or operational generation error', 'non_submission_or_generation_error'),
    ('Remaining setup errors', 'setup_errors'), ('Empty predictions', 'empty_predictions'),
    ('Preprocessing fallbacks', 'fallbacks'), ('Accepted specifications', 'validated_specifications'),
]
text = '# TRACE assigned generation: completed attempt ledger\n\n'
text += '| Outcome | Baseline | Improved |\n| --- | ---: | ---: |\n'
for label, key in rows:
    baseline_value = 'N/A' if key in ('fallbacks', 'validated_specifications') else totals['baseline'][key]
    text += f"| {label} | {baseline_value} | {totals['improved'][key]} |\n"
text += '\nBoth combined prediction files contain all 26 assigned IDs exactly once, in the fixed assignment order. '
text += 'Submissions are exported unchanged. Empty predictions retain unsuccessful or unstarted generation cases in the denominator. '
text += 'Submitted status is generation evidence; this full set has not been officially evaluated.\n\n'
text += '## Pair controls\n\n'
text += 'Final identity audit counts: ' + ', '.join(f'{key}={value}' for key, value in audit['counts'].items()) + '.\n\n'
text += 'Saved reports, preserved baseline configuration, shared unit-test profile, and controller/exporter hashes remain unchanged. '
text += 'Each available pair has matching saved report and effective configuration artifacts. '
text += 'Image references and their currently resolved IDs are recorded in the final audit.\n\n'
if limited:
    text += 'Historical image limitation: ' + ', '.join(limited) + ' recorded mutable tags at launch. '
    text += 'Those tags currently resolve to matching image IDs within each pair, but historical launch identity cannot be proved retrospectively.\n\n'
text += '## Preservation and infrastructure\n\n'
text += 'The primary ledger, intermediate empty predictions, failures, fallbacks, setup logs, and all retry records remain intact. '
text += 'The first preparation pass used a 600-second setup limit. Setup retries used the identical recorded recipe, new directories, and a 1,800-second limit. An additional Matplotlib attempt reused the dependency environment successfully cached by its preceding attempt. '
text += 'Prescribed harness installation edits were verified by replaying the exact recorded commands on temporary HEAD-file copies; original images were not modified. '
text += 'No generated submission was repaired or retried based on evaluator feedback.\n\n'
text += 'A coordinator handoff briefly overlapped image preparation. The redundant coordinator was stopped before it generated tests; its interrupted preparation and logs were preserved. '
text += 'Generation remained one pair at a time, baseline then improved. Raw timings include host/setup concurrency and are not a controlled method-speed comparison.\n\n'
text += 'Known agent-only cost: baseline $' + format(totals['baseline']['known_agent_cost'], '.9f')
text += ', improved $' + format(totals['improved']['known_agent_cost'], '.9f') + '. '
text += 'Preprocessing cost is additional; no complete dollar-cost claim is made.\n\n'
text += '## Artifacts\n\n'
text += '- [Baseline predictions](baseline-predictions.jsonl)\n- [Improved predictions](improved-predictions.jsonl)\n'
text += '- [Generation summary](generation-summary.json)\n- [Final pair identity audit](../verification/' + audit_path.name + ')\n'
text += '- [Export validation](export-validation.json)\n- [Setup-attempt history](setup-attempt-history.json)\n'
text += '- [Historical generation attempts](historical-generation-attempts.json)\n'
if (post / 'generation-command-review-flags.json').exists():
    flags = json.loads((post / 'generation-command-review-flags.json').read_text())
    text += '- [Generation-command review flags](generation-command-review-flags.json)\n\n'
    text += f"Command review flagged {flags['flagged_run_count']} runs for human inspection. These heuristic flags do not certify compliance or test quality, and do not alter predictions. "
    text += 'Previously recorded protocol deviations remain applicable even when pair identity checks pass.\n'
text += '\nEvaluation-only dataset rows, reference patches, and evaluator outputs remain separate from this generation archive and were not supplied by the orchestration as generation inputs. Nothing was pushed to GitHub.\n'
with (post / 'README.md').open('x') as stream:
    stream.write(text)
with (post / 'artifact-checksums.json').open('x') as stream:
    json.dump({str(path.relative_to(post)): hashlib.sha256(path.read_bytes()).hexdigest()
               for path in post.rglob('*') if path.is_file() and path.name != 'artifact-checksums.json'
               and '__pycache__' not in path.parts and 'locks' not in path.parts}, stream, indent=2)
print(json.dumps({'report': str(post / 'README.md'), 'prediction_files_validated': checks,
                  'identity_counts': audit['counts']}))
