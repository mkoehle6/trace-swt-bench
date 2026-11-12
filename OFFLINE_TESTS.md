# Collaborator setup and offline checks

Run these commands from the cloned repository root: the folder containing
`controller.py`, `requirements.txt`, and this guide. Any clone location works.

Initial installation needs internet access. After installation, the verification
commands below work offline, need no API key, and make no paid DeepSeek calls.

## 1. Open an Ubuntu / WSL terminal

On Windows, open the clone in VS Code and use **WSL: Reopen Folder in WSL** from
the Command Palette, then **Terminal > New Terminal**. Use Ubuntu rather than
PowerShell for the commands in this guide. Linux users can use their usual shell.

```bash
pwd
ls controller.py requirements.txt test_controller.py baseline/swt_test.yaml
python3 --version
```

The project requires Python 3.10 or newer. If needed, install Ubuntu prerequisites:

```bash
sudo apt update
sudo apt install -y python3 python3-venv python3-pip
```

## 2. Set up a dedicated environment

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

Create the environment once. Each time you reopen a terminal, activate it with
`source .venv/bin/activate` from the repository root. You can activate an existing
dedicated environment instead. Do not copy an environment between operating
systems or computers. `.venv/` is excluded from Git.

| Dependency | Required version | Purpose |
| --- | --- | --- |
| mini-swe-agent | Exactly 2.4.6 | Agent and container integration |
| PyYAML | >=6.0.2,<7 | Read baseline YAML |
| datasets | >=3,<5 | Retrieve pinned dataset reports |

The agent's Python import is `minisweagent`; its command-line tool is `mini`.

## 3. Verify real installed dependencies

```bash
python --version
python -c "import sys; print(sys.executable)"
python -m pip --version
python -m pip check
```

Python and pip should point inside the selected environment. `pip check` should
print `No broken requirements found.` Then check package versions and imports:

```bash
python - <<'PY'
import sys
from importlib.metadata import version
import yaml
import datasets
import minisweagent
from minisweagent.agents import get_agent
from minisweagent.environments import get_environment
from minisweagent.models import get_model

assert sys.version_info >= (3, 10), 'Python 3.10+ required'
assert version('mini-swe-agent') == '2.4.6', 'Install pinned agent version'
for package in ('mini-swe-agent', 'PyYAML', 'datasets'):
    print(f'{package}: {version(package)}')
print('Dependency imports and agent version: OK')
PY
```

This checks the actual agent installation. It does not construct a model, start a
container, or invoke the CLI setup wizard. It is necessary because the unit tests
mock the agent and its version; a passing unit suite alone does not prove that
mini-SWE-agent is installed.

## 4. Run the 11 offline tests

```bash
python -m unittest -v
```

Expected ending (runtime varies):

```text
Ran 11 tests in ...s

OK
```

| Check | Verifies |
| --- | --- |
| Grounding and shape | Specification fields and verbatim evidence quotes |
| Semantic review | Review types and rejection of contradictory results |
| Revision then acceptance | An invalid candidate can be corrected |
| Bounded failure | Invalid candidates stop after the allowed attempts |
| Baseline preparation | Original report is retained; existing output is protected |
| Launcher wiring | Configuration preservation, submission output, and cleanup |
| Missing key during extraction | Stops immediately without calls or revisions |
| Missing key in improved mode | Records configuration failure without launching the agent |
| Unit-test format profile | Changes only shared instructions and Bash pipeline handling |
| Unit-test export | Preserves patches and prevents output replacement |
| Failed/script prediction export | Keeps failures as empty predictions; rejects script runs |

Model calls and agent execution are mocked. Tests use temporary directories and
do not edit the baseline or reports. A temporary path printed in the output is
normal. Docker and an API key are not required for these tests.

## 5. Verify the local dataset snapshot and baseline

```bash
python - <<'PY'
import hashlib
import json
from pathlib import Path
from controller import BASELINE_SHA

root = Path('.')
manifest = json.loads((root / 'data/manifest.json').read_text(encoding='utf-8'))
entries = manifest['instances']
assert len(entries) == 26
assert len({entry['instance_id'] for entry in entries}) == 26
for group in ('easy', 'hard'):
    listed = (root / 'data' / f'{group}.txt').read_text(encoding='utf-8').splitlines()
    expected = [entry['instance_id'] for entry in entries if entry['group'] == group]
    assert listed == expected and len(listed) == 13, group
for entry in entries:
    report = root / 'data' / entry['report']
    actual = hashlib.sha256(report.read_bytes()).hexdigest()
    assert actual == entry['report_sha256'], f'Changed report: {report}'
baseline = root / 'baseline/swt_test.yaml'
assert hashlib.sha256(baseline.read_bytes()).hexdigest() == BASELINE_SHA
print('All 26 reports, Easy/Hard lists, and baseline: OK')
print('Dataset revision:', manifest['revision'])
PY
```

This reads the saved reports without downloading anything. Original whitespace
and line endings must be preserved so that their hashes remain valid.

## 6. Optional Docker readiness check

Docker is needed for live agent runs, but not for the offline tests. On Windows,
start Docker Desktop and enable integration with your Ubuntu distro. In Ubuntu:

```bash
docker version
```

Expect both Client and Server information. Client-only output followed by an
error means the engine is unreachable. This check does not pull images or start
a container. A matching benchmark image is still required for a live run.

## Troubleshooting

- **ModuleNotFoundError:** activate the intended environment and run
  `python -m pip install -r requirements.txt`, then repeat section 3.
- **venv or ensurepip unavailable:** install Ubuntu's `python3-venv` package.
- **Wrong agent version:** reinstall the requirements inside the active
  environment; the launcher requires exactly 2.4.6.
- **Ran 0 tests or missing files:** check `pwd`; run from the repository root.
- **Hash mismatch:** inspect `git diff` for edits or line-ending changes. Preserve
  intentional work before restoring a file from the committed snapshot. Do not
  change the expected hashes just to make the check pass.
- **Package installation failure:** record the Python version, failing package,
  and error. A newly released Python version may lack dependency support; use a
  supported version agreed by the team and record it.
- **Docker connection failure:** start Docker Desktop and check WSL integration.
  This is separate from a specification-validation failure.

## Report your results

Share Python/package versions, the `pip check` result, the 11-test summary, the
snapshot-check result, and optional Docker readiness with the team. Never share
API keys or environment-file contents.

Passing verifies imports, the pinned agent version, local validation behavior,
mocked launcher wiring, and snapshot integrity. It does not verify API credentials,
model availability, image compatibility, live generation, or SWT-Bench success.
For a live experiment, continue with [PILOT.md](PILOT.md). See [README.md](README.md)
for the overall workflow.
