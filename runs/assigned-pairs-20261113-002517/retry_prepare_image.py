"""One unchanged-recipe retry in a new preparation directory."""
import json
import os
import sys
from pathlib import Path

batch = Path(__file__).resolve().parent
case = Path(sys.argv[1]).resolve()
old = Path(sys.argv[2]).resolve()
metadata = json.loads((case / 'metadata.json').read_text())
harness = Path('/mnt/c/Users/mlkoe/projects/swt-bench')
sys.path[:0] = [str(harness), str(harness / 'src')]
from src.exec_spec import ExecSpec
from src.docker_build import build_instance_image_from_exec_spec
import docker

spec = ExecSpec(**metadata, patch_list=[], arch='x86_64', test_directives=None,
                coverage_files=[], env_name='testbed')
current = {'instance_tag': spec.instance_image_key, 'env_tag': spec.env_image_key,
           'repo_script': spec.repo_script, 'env_script': spec.env_script}
original = json.loads((old / 'image-plan.json').read_text())
assert current == original, 'Retry recipe differs from the original attempt'
with (case / 'image-plan.json').open('x') as stream:
    json.dump(current, stream, indent=2)
os.chdir(case)
build_instance_image_from_exec_spec(spec, force_rebuild=False, build_mode='api')
image = docker.from_env().images.get(spec.instance_image_key)
with (case / 'image-identity.json').open('x') as stream:
    json.dump({'image_id': image.id, 'image_tag': spec.instance_image_key,
               'repo_digests': image.attrs.get('RepoDigests', [])}, stream, indent=2)
print(image.id, flush=True)
