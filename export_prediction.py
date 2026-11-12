"""Export one saved unit-test prediction for the installed SWT-Bench harness."""
import argparse
import json
from pathlib import Path


def export_prediction(run, out, label=None):
    manifest = json.loads((run / 'manifest.json').read_text(encoding='utf-8'))
    if manifest.get('test_format') != 'unit_test':
        raise ValueError('Expected a unit_test run; preserve older script runs as smoke tests')
    result_path = run / 'agent_result.json'
    result = json.loads(result_path.read_text(encoding='utf-8')) if result_path.exists() else {}
    # Preserve unsuccessful assigned predictions as empty patches, not dropped rows.
    submission = result.get('submission', '') if result.get('exit_status') == 'Submitted' else ''
    record = {'instance_id': manifest['instance_id'], 'model_patch': submission,
              'model_name_or_path': label or f"trace-{manifest['mode']}-unit-test"}
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open('x', encoding='utf-8') as stream:
        stream.write(json.dumps(record, ensure_ascii=False) + '\n')
    return record


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--label')
    args = parser.parse_args()
    export_prediction(args.run, args.out, args.label)
