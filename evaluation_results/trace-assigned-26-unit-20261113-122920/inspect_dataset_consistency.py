import os,json
from pathlib import Path
os.environ['HF_HUB_OFFLINE']='1';os.environ['HF_DATASETS_OFFLINE']='1'
from datasets import Dataset, config
root=Path(__file__).resolve().parent;p=json.loads((root/'provenance.json').read_text());project=root.parent.parent
cache=Path(config.HF_DATASETS_CACHE)/'princeton-nlp___swe-bench_verified'/'default'/'0.0.0'/p['revision']
ds=Dataset.from_file(str(next(cache.glob('*test.arrow'))));lookup={r['instance_id']:r for r in ds}
for e in json.loads((project/'data/manifest.json').read_text())['instances']:
 a=lookup[e['instance_id']]['problem_statement'];b=(project/'data'/e['report']).read_text()
 if a!=b:print(e['instance_id'],{'cached_length':len(a),'saved_length':len(b),'newline_normalized_equal':a.replace('\r\n','\n')==b.replace('\r\n','\n'),'strip_equal':a.strip()==b.strip()})
