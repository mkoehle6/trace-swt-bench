"""Fetch original problem_statement only; never persist fixes or hidden tests."""
import argparse
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dataset', default='princeton-nlp/SWE-bench_Verified')
    parser.add_argument('--revision', required=True, help='Pinned dataset commit for reproducibility')
    parser.add_argument('--split', default='test')
    parser.add_argument('--instance', default='django__django-11163')
    parser.add_argument('--out', type=Path, required=True, help='New directory')
    args = parser.parse_args()
    from datasets import load_dataset
    data = load_dataset(args.dataset, revision=args.revision, split=args.split)
    matches = [r for r in data if r['instance_id'] == args.instance]
    if len(matches) != 1:
        raise ValueError(f'Expected one instance, found {len(matches)}')
    row = matches[0]
    args.out.mkdir(parents=True, exist_ok=False)
    (args.out / 'report.txt').write_text(row['problem_statement'], encoding='utf-8')
    metadata = {k: row[k] for k in ('instance_id', 'repo', 'base_commit')}
    metadata.update(dataset=args.dataset, revision=args.revision, split=args.split)
    (args.out / 'source.json').write_text(json.dumps(metadata, indent=2), encoding='utf-8')


if __name__ == '__main__':
    main()
