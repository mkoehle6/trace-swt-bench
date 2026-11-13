import os,sys,json,time,subprocess
from pathlib import Path
root=Path(__file__).resolve().parent
harness=Path('/mnt/c/Users/mlkoe/projects/swt-bench')
mode=sys.argv[1]
assert mode in ('baseline','improved')
out=root/mode
env=os.environ.copy()
env['PYTHONPATH']=str(harness)+os.pathsep+str(harness/'src')
env['HF_HUB_OFFLINE']='1'
env['HF_DATASETS_OFFLINE']='1'
args=[sys.executable,'-m','src.main','--dataset_name',str(root/'evaluation-dataset.json'),'--split','test','--instance_ids','django__django-13513','--predictions_path',str(out/'prediction.jsonl'),'--max_workers','1','--run_id',root.name+'-'+mode,'--exec_mode','unit_test','--compute_coverage','true','--timeout','1800','--cache_level','instance','--clean','false','--force_rebuild','false','--build_mode','api']
with (out/'command.json').open('x') as f: json.dump(args,f,indent=2)
start=time.monotonic()
with (out/'console.log').open('x') as f:
 result=subprocess.run(args,cwd=root,env=env,stdout=f,stderr=subprocess.STDOUT)
with (out/'timing.json').open('x') as f:json.dump({'seconds':time.monotonic()-start,'exit_code':result.returncode},f,indent=2)
print(mode,'exit code:',result.returncode,'seconds:',round(time.monotonic()-start,2))
sys.exit(result.returncode)
