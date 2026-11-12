# SE 433 SWT-Bench: evidence-grounded bug specifications

Research question: does a structured, evidence-grounded extraction and validation
stage improve regression-test generation over the unchanged mini-SWE-agent baseline?

All commands below run from the repository root (the folder containing this README).
In VS Code, open your cloned repository and use an Ubuntu/WSL terminal.
The clone can live anywhere; no particular Windows username or folder is required.

## Preserved baseline

`baseline/swt_test.yaml` is the existing configuration, not a generated example.
SHA-256: `32278591d35efc77ae351d61461fe7b67658c8b464e40c3ac1e334c07ddf79e0`.
The controller refuses a different hash. Existing `sympy/` and
`deepseek_baseline.traj.json` are unrelated artifacts and must remain untouched.

The YAML specifies Docker, `/testbed`, 100 steps, $0.50 agent cost limit,
and `deepseek/deepseek-v4-flash`. It does not specify a Docker image.
Supply the exact benchmark image explicitly for both experimental arms.
The only configuration addition is the required runtime `environment.image`;
templates, model, limits and environment settings are retained. The runner uses
mini-SWE-agent 2.4.6's DefaultAgent factories directly, without interactive CLI
defaults or model overrides. It records the effective config and trajectory.

## Workflow

1. Read only the original `problem_statement` from a pinned dataset revision.
2. Ask DeepSeek for five `{value, evidence}` fields, with nulls for unknowns.
3. Check strict field shape and verbatim, nonempty evidence quotes locally.
4. Make a separate semantic review call for support, contradictions and omissions.
5. Allow at most two revisions; on validation exhaustion use the original report.
6. Prepare the task, or launch mini-SWE-agent with `--launch`.

`baseline` mode sends the original report verbatim and makes no extraction calls.
`improved` mode adds only an accepted specification. Operational/API failures stop
the run; invalid or truncated JSON participates in the bounded revision loop.
No fix patch, hidden test, or benchmark answer is included in extraction prompts.
The dataset loader reads rows locally but only selects report and public identifiers
for output. Do not substitute a trajectory or a solution for the original report.

## Setup in Ubuntu / WSL

Use a separate environment to preserve your existing agent installation:

```bash
# Run from the repository root.
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
python -m pip freeze > requirements.lock.local.txt
python -m unittest -v
read -rsp 'DeepSeek API key: ' DEEPSEEK_API_KEY; echo
export DEEPSEEK_API_KEY
docker version
```

For later terminal sessions, run `source .venv/bin/activate` from the repository root.
The `.venv/` directory is excluded from Git. If you already have a working environment,
you can activate that instead of creating a new one.

If `venv` is unavailable, install the Ubuntu `python3-venv` package first.
Docker Desktop must be running with Ubuntu integration enabled. API keys are
read from the environment and are never saved into run artifacts.
Improved mode requires a nonempty `DEEPSEEK_API_KEY`. If it is missing or blank,
the controller records a configuration failure and stops before extraction or
agent launch; it does not spend revision attempts or fall back to the baseline.

See [PILOT.md](PILOT.md) for the Django pilot. `--help` documents controller options.
All output run directories must be new, preventing accidental replacement.

## Artifacts and research evaluation

Each run stores the original report, report/config hashes, model requests/responses,
validation errors per attempt, accepted `bug_spec.json` (if any), final `task.txt`,
and a manifest with elapsed time and fallback status. A launch also stores
effective config, agent result, trajectory and submitted patch if available.
`agent_finished` means the loop ended; inspect `agent_result.json` for Submitted,
LimitsExceeded, or another exit condition. It does not mean benchmark success.

Extraction metrics store usage and runtime; dollar cost is deliberately null.
Calculate extraction cost using the provider's rates applicable on the run date,
including cache-hit tokens, and add it to agent cost from the trajectory. The
baseline's $0.50 limit applies only to mini-SWE-agent, may be exceeded by the last
call, and does not cap preprocessing. There are at most six preprocessing calls.

For a pilot, manually label each field as supported, contradicted, unsupported,
or missing; record quotation validity, null rate, revision count, fallback rate,
total tokens/cost/time and downstream fail-to-pass success. Repeat both arms with
the same instances, image digests, dataset revision and agent settings. Record
sampling variability. Same-model semantic review is correlated and exact quotes
do not prove logical entailment; human review supplies an independent check.

The controller generates tests, not an SWT-Bench evaluation harness. Evaluate
the submitted reproduce.py patch on the buggy and correctly fixed benchmark
environments using your course's SWT-Bench harness; distinguish assertion failures
from import/setup errors. Do not count an unexecuted submission as a success.

## Implementation references

- [mini-SWE-agent v2.4.6 factories and runner](https://github.com/SWE-agent/mini-swe-agent/tree/v2.4.6/src/minisweagent)
- [DeepSeek JSON chat completions](https://api-docs.deepseek.com/api/create-chat-completion/)

The extraction model defaults to the direct-API name `deepseek-flash`, separately
configurable through `--extract-model`. This does not rename the model in the
baseline YAML. Provider aliases and LiteLLM support must be checked before a paid
run; record returned model identifiers. No paid run is performed during setup.

## Unit-test-mode pilot

The original baseline produces standalone reproduction scripts. For the course's
unit-test requirement, use --test-format unit_test for BOTH methods. This applies
a shared task-template adaptation and Bash pipefail while preserving the original baseline file,
model, and limits. Follow [UNIT_TEST_PILOT.md](UNIT_TEST_PILOT.md) for generation
and prediction export. Earlier script runs remain development smoke tests.
