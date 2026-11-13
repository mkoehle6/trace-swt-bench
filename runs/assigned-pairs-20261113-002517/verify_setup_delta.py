"""Verify standard harness setup edits by replaying sed on temporary HEAD copies.

The original image and checkout are never changed. No reference patches are read.
"""
import json
import shlex
import subprocess
import sys
from pathlib import Path

case = Path(sys.argv[1]).resolve()
output = Path(sys.argv[2]).resolve()
output.mkdir(exist_ok=False, parents=True)
metadata = json.loads((case / 'metadata.json').read_text())
identity = json.loads((case / 'image-identity.json').read_text())
plan = json.loads((case / 'image-plan.json').read_text())
commands = []
paths = []
for line in plan['repo_script'].splitlines():
    if not line.startswith('sed -i '):
        continue
    tokens = shlex.split(line)
    target = tokens[-1]
    assert not Path(target).is_absolute() and '..' not in Path(target).parts
    assert not any(character in target for character in '*?$`')
    commands.append(line)
    paths.append(target)
payload = {'commands': commands, 'paths': sorted(set(paths)), 'expected_head': metadata['base_commit']}
code = '''import hashlib,json,os,subprocess,sys,tempfile
from pathlib import Path
payload=json.loads(sys.argv[1])
git=lambda *args:subprocess.check_output(['git',*args])
head=git('rev-parse','HEAD').decode().strip()
modified=[x for x in git('diff','--name-only','HEAD','-z').decode().split('\\0') if x]
untracked=[x for x in git('ls-files','--others','--exclude-standard','-z').decode().split('\\0') if x]
unexpected=sorted(set(modified)-set(payload['paths']))
hashes={}
with tempfile.TemporaryDirectory() as directory:
    for name in payload['paths']:
        target=Path(directory)/name
        target.parent.mkdir(parents=True,exist_ok=True)
        target.write_bytes(git('show','HEAD:'+name))
    for command in payload['commands']:
        subprocess.run(command,shell=True,executable='/bin/bash',cwd=directory,check=True)
    for name in payload['paths']:
        expected=(Path(directory)/name).read_bytes()
        actual=Path(name).read_bytes()
        hashes[name]={'expected_sha256':hashlib.sha256(expected).hexdigest(),
                      'actual_sha256':hashlib.sha256(actual).hexdigest(),'matches':expected==actual}
accepted=head==payload['expected_head'] and not unexpected and not untracked and all(v['matches'] for v in hashes.values())
print(json.dumps({'head':head,'clean':not git('status','--porcelain').strip(),
                 'accepted':accepted,'source_matches_base_except_prescribed_setup':accepted,
                 'modified_paths':modified,'unexpected_paths':unexpected,'untracked_paths':untracked,
                 'file_hashes':hashes,'expected_setup_commands':payload['commands'],
                 'diff_sha256':hashlib.sha256(git('diff','HEAD','--binary')).hexdigest(),
                 'python':sys.version}))
'''
command = ['docker', 'run', '--rm', '-w', '/testbed', '-e', 'BASH_ENV=/root/.bashrc',
           identity['image_id'], 'bash', '-c', 'python -c ' + shlex.quote(code) + ' ' + shlex.quote(json.dumps(payload))]
result = subprocess.run(command, capture_output=True, text=True, timeout=90)
with (output / 'command-result.json').open('x') as stream:
    json.dump({'exit_code': result.returncode, 'stdout': result.stdout, 'stderr': result.stderr}, stream, indent=2)
result.check_returncode()
verification = json.loads(result.stdout)
with (output / 'image-verification.json').open('x') as stream:
    json.dump(verification, stream, indent=2)
with (output / 'image-identity.json').open('x') as stream:
    json.dump(identity, stream, indent=2)
print(json.dumps({'instance_id': metadata['instance_id'], 'verification': verification}), flush=True)
sys.exit(0 if verification['accepted'] else 1)
