"""Run an unchanged method after exact prescribed setup changes are verified."""
import hashlib
import json
import os
import sys
from pathlib import Path
from dotenv import load_dotenv

batch = Path(__file__).resolve().parent
project = batch.parent.parent
case = Path(sys.argv[1]).resolve()
mode = sys.argv[2]
assert mode in ('baseline', 'improved')
plan = json.loads((batch / 'plan.json').read_text())
metadata = json.loads((case / 'metadata.json').read_text())
verification = json.loads((case / 'image-verification.json').read_text())
identity = json.loads((case / 'image-identity.json').read_text())
assert verification['accepted'] and verification['head'] == metadata['base_commit']
for filename, expected in plan['workflow_hashes'].items():
    assert hashlib.sha256((project / filename).read_bytes()).hexdigest() == expected
sys.path.insert(0, str(project))
import controller
load_dotenv(Path('/home/mlkoe/.config/mini-swe-agent/.env'), override=False)
os.chdir(project)
controller.main(['--report', str(project / 'data' / metadata['instance_id'] / 'report.txt'),
                 '--instance', metadata['instance_id'], '--mode', mode, '--test-format', 'unit_test',
                 '--out', str(case / ('generation-' + mode)), '--image', identity['image_id'], '--launch'])
