import os,json,hashlib
from pathlib import Path
os.environ['HF_HUB_OFFLINE']='1'
os.environ['HF_DATASETS_OFFLINE']='1'
from datasets import load_dataset
root=Path(__file__).resolve().parent
p=json.loads((root/'provenance.json').read_text())
ds=load_dataset(p['dataset'],revision=p['revision'],split=p['split'])
lookup={r['instance_id']:r for r in ds if r['instance_id'] in p['instance_ids']}
assert len(lookup)==26
project=root.parent.parent
manifest=json.loads((project/'data/manifest.json').read_text())
for entry in manifest['instances']:
 row=lookup[entry['instance_id']]
 assert row['base_commit']==entry['base_commit']
 assert row['problem_statement']==(project/'data'/entry['report']).read_text()
rows=[lookup[i] for i in p['instance_ids']]
with (root/'evaluation-dataset.json').open('x') as f:json.dump(rows,f)
print('Saved 26 pinned evaluation-only rows; issue text and base commits match frozen generation metadata. Reference fields not printed.')
