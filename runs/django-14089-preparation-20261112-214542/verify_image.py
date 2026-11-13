from pathlib import Path
import json,shlex
import docker
root=Path(__file__).resolve().parent
image=json.loads((root/'image-identity.json').read_text())['image_id']
code="import subprocess,json,sys,django; print(json.dumps({'head':subprocess.check_output(['git','rev-parse','HEAD']).decode().strip(),'clean':not subprocess.check_output(['git','status','--porcelain']).decode().strip(),'python':sys.version,'django':django.get_version(),'django_path':django.__file__}))"
output=docker.from_env().containers.run(image,['bash','-c','python -c '+shlex.quote(code)],working_dir='/testbed',environment={'BASH_ENV':'/root/.bashrc'},remove=True)
verification=json.loads(output)
prep=json.loads((root/'preparation.json').read_text())
assert verification['head']==prep['source']['base_commit'] and verification['clean']
assert verification['django_path'].startswith('/testbed/')
with (root/'image-verification.json').open('x') as f:json.dump(verification,f,indent=2)
print(json.dumps(verification,indent=2))
