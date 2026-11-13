import json,os
from pathlib import Path
from datasets import load_dataset
root=Path(__file__).resolve().parent
source=json.loads((root/'provenance.json').read_text())['source']
ds=load_dataset(source['dataset'],revision=source['revision'],split=source['split'])
rows=[row for row in ds if row['instance_id']==source['instance_id']]
assert len(rows)==1
assert rows[0]['base_commit']==source['base_commit']
with (root/'evaluation-dataset.json').open('x') as f:json.dump(rows,f)
print('Saved one pinned dataset row in evaluation-only directory; reference fields not printed.')
