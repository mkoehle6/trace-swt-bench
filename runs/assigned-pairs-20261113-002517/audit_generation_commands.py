"""Preserve potential protocol deviations for review; never repair predictions."""
import datetime
import json
import re
import sys
from pathlib import Path

outcomes_file = Path(sys.argv[1]).resolve()
outcomes = json.loads(outcomes_file.read_text())
report = {'audited_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
          'scope': 'Heuristic flags from saved generation commands, not an automated test-quality classifier.',
          'predictions_changed': False, 'runs': []}
for instance, outcome in outcomes.items():
    for mode, directory in outcome.get('runs', {}).items():
        path = Path(directory) / 'agent.traj.json'
        if not path.exists():
            continue
        trajectory = json.loads(path.read_text())
        flags = []
        for index, message in enumerate(trajectory.get('messages', [])):
            if message.get('role') != 'assistant':
                continue
            for call in message.get('tool_calls', []):
                raw = call.get('function', {}).get('arguments', '')
                try:
                    args = json.loads(raw) if isinstance(raw, str) else raw
                except ValueError:
                    continue
                if not isinstance(args, dict) or not isinstance(args.get('command'), str):
                    continue
                command = args['command']
                categories = []
                if re.search(r'git(?:\s+-C\s+\S+)?\s+log\b', command):
                    # A one-commit status check is not automatically a history violation.
                    if not re.search(r'\blog\s+(?:-1|--max-count[= ]1)\b', command):
                        categories.append('history_inspection_review')
                if re.search(r'git(?:\s+-C\s+\S+)?\s+show\b', command) and re.search(r'\b[0-9a-f]{7,40}\b', command):
                    categories.append('historical_commit_inspection_review')
                if re.search(r'https?://\S*(?:/pull/|/commit/\S+\.(?:patch|diff))', command):
                    categories.append('external_fix_or_pr_reference_review')
                if categories:
                    flags.append({'message_index': index, 'categories': categories, 'command': command})
        report['runs'].append({'instance_id': instance, 'mode': mode, 'run': directory,
                               'flagged_commands': flags})
report['flagged_run_count'] = sum(bool(run['flagged_commands']) for run in report['runs'])
report['flagged_command_count'] = sum(len(run['flagged_commands']) for run in report['runs'])
target = outcomes_file.parent / 'generation-command-review-flags.json'
with target.open('x') as stream:
    json.dump(report, stream, indent=2)
    stream.write('\n')
print(json.dumps({'report': str(target), 'runs_audited': len(report['runs']),
                  'flagged_runs': report['flagged_run_count'], 'flagged_commands': report['flagged_command_count']}))
