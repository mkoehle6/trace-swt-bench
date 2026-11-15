"""Build from allowlisted source/environment metadata; no reference patches."""
import json
import os
import sys
from pathlib import Path

batch = Path(__file__).resolve().parent
case = batch / 'instances' / sys.argv[1]
metadata = json.loads((case / 'metadata.json').read_text())
harness = Path('/workspace/swt-bench')
sys.path[:0] = [str(harness), str(harness / 'src')]
from src.exec_spec import ExecSpec
from src.docker_build import build_instance_image_from_exec_spec
import docker

os.chdir(case)
spec = ExecSpec(**metadata, patch_list=[], arch='x86_64', test_directives=None,
                coverage_files=[], env_name='testbed')
with (case / 'image-plan.json').open('x') as stream:
    json.dump({'instance_tag': spec.instance_image_key, 'env_tag': spec.env_image_key,
               'repo_script': spec.repo_script, 'env_script': spec.env_script}, stream, indent=2)
build_instance_image_from_exec_spec(spec, force_rebuild=False, build_mode='api')
image = docker.from_env().images.get(spec.instance_image_key)
with (case / 'image-identity.json').open('x') as stream:
    json.dump({'image_id': image.id, 'image_tag': spec.instance_image_key,
               'repo_digests': image.attrs.get('RepoDigests', [])}, stream, indent=2)
print(image.id, flush=True)
