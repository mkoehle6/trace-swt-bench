from pathlib import Path
import os,sys,json,hashlib
from dotenv import load_dotenv
prep_dir=Path(__file__).resolve().parent
project=prep_dir.parent.parent
sys.path.insert(0,str(project))
import controller
os.chdir(project)
mode=sys.argv[1]
assert mode in ('baseline','improved')
prep=json.loads((prep_dir/'preparation.json').read_text())
for filename,h in prep['sha256'].items():
 assert hashlib.sha256((project/filename).read_bytes()).hexdigest()==h,filename
identity=json.loads((prep_dir/'image-identity.json').read_text())
verification=json.loads((prep_dir/'image-verification.json').read_text())
assert verification['head']==prep['source']['base_commit'] and verification['clean']
load_dotenv(Path('/home/user/.config/mini-swe-agent/.env'),override=False)
out=project/'runs'/f"django-14089-unit-{mode}-{prep['pair_id']}"
controller.main(['--report','data/django__django-14089/report.txt','--instance','django__django-14089','--mode',mode,'--test-format','unit_test','--out',str(out),'--image',identity['image_id'],'--launch'])
