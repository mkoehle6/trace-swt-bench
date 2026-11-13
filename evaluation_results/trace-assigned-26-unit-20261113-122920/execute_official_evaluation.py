import os,sys,json,time,subprocess,hashlib,datetime
from pathlib import Path
root=Path(__file__).resolve().parent
p=json.loads((root/'provenance.json').read_text());h=Path(p['harness_root']);project=root.parent.parent
def save(path,value):
 with path.open('x') as f:json.dump(value,f,indent=2)
def event(stage,**kw):
 line=json.dumps(dict(utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),stage=stage,**kw))
 with (root/'events.jsonl').open('a') as f:f.write(line+'\n')
 print(line,flush=True)
env=os.environ.copy();env['PYTHONPATH']=str(h)+os.pathsep+str(h/'src');env['HF_HUB_OFFLINE']='1';env['HF_DATASETS_OFFLINE']='1'
for name,sha in p['workflow_hashes'].items():assert hashlib.sha256((project/name).read_bytes()).hexdigest()==sha
for mode in ('baseline','improved'):
 out=root/mode;pred=out/'prediction.jsonl'
 assert hashlib.sha256(pred.read_bytes()).hexdigest()==p['prediction_sha256'][mode]
 args=[sys.executable,'-P','-m','src.main','--dataset_name',str(root/'evaluation-dataset.json'),'--split','test','--instance_ids',*p['instance_ids'],'--predictions_path',str(pred),'--max_workers','2','--run_id',root.name+'-'+mode,'--exec_mode','unit_test','--compute_coverage','true','--timeout','1800','--patch_types','vanilla','--cache_level','instance','--clean','false','--force_rebuild','false','--build_mode','api']
 save(out/'command.json',args);event('evaluation_started',mode=mode,instances=26)
 start=time.monotonic()
 with (out/'console.log').open('x') as f:result=subprocess.run(args,cwd=root,env=env,stdout=f,stderr=subprocess.STDOUT)
 save(out/'timing.json',dict(seconds=time.monotonic()-start,exit_code=result.returncode));event('evaluation_finished',mode=mode,exit_code=result.returncode,seconds=time.monotonic()-start)
for name,sha in p['workflow_hashes'].items():assert hashlib.sha256((project/name).read_bytes()).hexdigest()==sha
for mode in ('baseline','improved'):assert hashlib.sha256((root/mode/'prediction.jsonl').read_bytes()).hexdigest()==p['prediction_sha256'][mode]
save(root/'execution-complete.json',dict(workflow_hashes_unchanged=True,predictions_unchanged=True,completed_utc=datetime.datetime.now(datetime.timezone.utc).isoformat()))
event('both_evaluation_commands_finished')
