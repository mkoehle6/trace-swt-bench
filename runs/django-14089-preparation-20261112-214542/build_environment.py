from pathlib import Path
import os,sys,json
root=Path(__file__).resolve().parent
harness=Path('/workspace/swt-bench')
sys.path[:0]=[str(harness),str(harness/'src')]
from datasets import Dataset, config
from src.exec_spec import ExecSpec
from src.docker_build import build_env_image_from_exec_spec,build_instance_image_from_exec_spec
import docker
prep=json.loads((root/'preparation.json').read_text());source=prep['source']
cache=Path(config.HF_DATASETS_CACHE)/'princeton-nlp___swe-bench_verified'/'default'/'0.0.0'/source['revision']
fields=['instance_id','repo','base_commit','version','environment_setup_commit']
rows=[]
for p in cache.glob('*test*.arrow'):
 ds=Dataset.from_file(str(p)).select_columns(fields)
 rows.extend(row for row in ds if row['instance_id']==source['instance_id'])
assert len(rows)==1
metadata=rows[0]
assert metadata['base_commit']==source['base_commit'] and metadata['repo']==source['repo']
with (root/'environment-metadata.json').open('x') as f:json.dump(metadata,f,indent=2)
spec=ExecSpec(**metadata,patch_list=[],arch='x86_64',test_directives=None,coverage_files=[],env_name='testbed')
with (root/'image-plan.json').open('x') as f:json.dump({'base':spec.base_image_key,'env':spec.env_image_key,'instance':spec.instance_image_key,'repo_script':spec.repo_script,'env_script':spec.env_script},f,indent=2)
os.chdir(root)
build_env_image_from_exec_spec(spec,force_rebuild=False,build_mode='api')
build_instance_image_from_exec_spec(spec,force_rebuild=False,build_mode='api')
image=docker.from_env().images.get(spec.instance_image_key)
with (root/'image-identity.json').open('x') as f:json.dump({'image_id':image.id,'image_tag':spec.instance_image_key,'repo_digests':image.attrs.get('RepoDigests',[])},f,indent=2)
print('Prepared image:',image.id,flush=True)
