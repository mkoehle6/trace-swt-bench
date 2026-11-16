"""Invoke the unchanged experimental controller with only its saved report."""
import hashlib
import json
import os
import sys
from pathlib import Path
from dotenv import load_dotenv

batch = Path(__file__).resolve().parent
project = batch.parent.parent
instance, mode = sys.argv[1:]
assert mode in ('baseline', 'improved')
plan = json.loads((batch / 'plan.json').read_text())
for filename, expected in plan['workflow_hashes'].items():
    assert hashlib.sha256((project / filename).read_bytes()).hexdigest() == expected
case = batch / 'instances' / instance
image = json.loads((case / 'image-identity.json').read_text())['image_id']
verification = json.loads((case / 'image-verification.json').read_text())
assert verification['head'] == plan['metadata'][instance]['base_commit'] and verification['clean']
sys.path.insert(0, str(project))
import controller
load_dotenv(Path.home() / '.config' / 'mini-swe-agent' / '.env', override=False)
os.chdir(project)
controller.main(['--report', str(project / 'data' / instance / 'report.txt'),
                 '--instance', instance, '--mode', mode, '--test-format', 'unit_test',
                 '--out', str(case / ('generation-' + mode)), '--image', image, '--launch'])
