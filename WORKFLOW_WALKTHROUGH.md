# TRACE: from a bug report to an evaluated regression test

This guide explains the current implementation, including every Python file in
the project root. It describes the unit-test workflow used for the course and
distinguishes implemented behavior from checks that still need development.
Run command examples from the repository root in your activated Python environment.

## 1. Who does what?

| Component | Responsibility |
| --- | --- |
| Our Python controller | Reads the report, validates analysis, starts the agent, and saves records |
| DeepSeek-Flash | Interprets supplied text and repository observations; proposes tests and shell commands |
| mini-SWE-agent 2.4.6 | Maintains the conversation, sends model requests, executes commands, and feeds results back |
| Docker benchmark image | Provides the buggy source checkout, dependencies, and native test runner |
| SWT-Bench evaluator | Applies predictions and checks behavior before and after the reference fix |
| Researcher | Reviews evidence, preserves failures, and compares both methods across assigned instances |

DeepSeek does not open a local file directly. Python reads the issue text and sends
it to the model. Later, mini-SWE-agent executes shell commands chosen by DeepSeek
to read source files and existing tests inside the container.

## 2. The files and their connections

```text
Hugging Face dataset at a fixed revision
    |
    | fetch_report.py (input preparation, not repeated for saved reports)
    v
data/<instance>/report.txt + source.json
    |
    | controller.py --mode baseline OR --mode improved
    |
    +-- baseline: original report ----------------------------+
    |                                                        |
    +-- improved: ask DeepSeek to extract                     |
                  -> Python structure/evidence checks        |
                  -> DeepSeek semantic review                |
                  -> accepted specification, revisions,      |
                     or flagged raw-report fallback          |
                  -> original report + accepted analysis ----+
                                                             |
baseline/swt_test.yaml + profiles/unit_test.yaml               |
    |                                                        |
    +-----------------> mini-SWE-agent + DeepSeek <-------------+
                             |
                             | read -> write native tests -> run -> observe
                             v
                    submitted Git patch + run records
                             |
                    export_prediction.py
                             v
                    prediction JSONL
                             |
                    official SWT-Bench unit-test evaluator
                             v
                    evaluation outputs -> research comparison

test_controller.py verifies local logic using mocked model/agent execution.
```

The four project-root Python files are `fetch_report.py`, `controller.py`,
`export_prediction.py`, and `test_controller.py`. Upstream Django/SymPy code and
the separate SWT-Bench checkout contain their own Python files; they are not
additional TRACE controller modules.

## 3. Input preparation: fetch_report.py

This is a standalone command-line program with a `main()` entry point. It is not
automatically invoked by the controller.

1. Parse the dataset name, immutable revision, split, instance ID, and output path.
2. Use the `datasets` package to load that revision from Hugging Face.
3. Find exactly one matching instance; stop if none or multiple are found.
4. Create a new directory without replacing existing files.
5. Save the original `problem_statement` as `report.txt`.
6. Save `instance_id`, `repo`, `base_commit`, dataset name, revision, and split as
   `source.json`.

The loader reads dataset rows locally, which contain benchmark fields, but this
script exports only issue text and public source identifiers. It does not send
reference fixes or reference test patches to DeepSeek.

Our 26 reports are already captured in `data/`. `data/easy.txt`, `data/hard.txt`,
and `data/manifest.json` identify the selection and checksums. Use those saved
reports for both methods rather than fetching changing inputs during each run.

Fetching reports does not download a runnable buggy repository or build Docker
images. Those environments are prepared separately using benchmark tooling.

## 4. Starting a run: controller.py main()

`controller.py` is the coordinator. Its `main()` function parses your command and
controls the sequence; the other functions implement individual steps.

Important arguments:

| Argument | Meaning |
| --- | --- |
| `--report` | Saved UTF-8 original issue text |
| `--instance` | Instance identifier; defaults to django__django-11163 |
| `--mode baseline` | Skip preprocessing and pass the original report |
| `--mode improved` | Extract and validate a specification before generation |
| `--test-format unit_test` | Generate a native-suite patch for course evaluation |
| `--out` | New run directory; existing directories are refused |
| `--image` | Explicit benchmark Docker image |
| `--launch` | Actually start the agent; omitting it only prepares the task |
| `--revisions` | Zero, one, or two revisions after the initial extraction |
| `--extract-model` | Direct-API extraction/review model name |

For instances other than Django 11163, explicitly supply `--instance`; the
controller does not infer it from the report filename or read `source.json`.

Before generation, `main()` verifies the baseline YAML's SHA-256 against the
recorded original. It records the selected unit-test profile hash, rejects an
empty report, creates the run directory, and saves the original report.

`digest()` computes SHA-256 values. `save()` writes formatted JSON using exclusive
creation, so an existing artifact is not silently replaced.

The manifest records report/config hashes, image reference, mode, format, Python
version, extraction settings, validation/fallback state, and elapsed time. The
image reference is recorded as supplied; the controller does not automatically
resolve a mutable image tag to its immutable digest.

## 5. Improved-mode credentials and errors

`require_deepseek_key()` reads and trims `DEEPSEEK_API_KEY` from the environment.
Missing, empty, or whitespace-only values raise `ConfigurationError`, a dedicated
operational exception. Improved mode checks this before extraction; `ask()` also
checks it before sending a request.

A missing key records a configuration failure with zero attempts and no fallback.
It does not launch the agent. The command-line entry point displays a concise
configuration error. The key is placed in the HTTP authorization header, not in
the saved extraction request body.

The baseline does not require this extraction precheck; its model authentication
is handled by mini-SWE-agent's provider integration. Baseline preparation without
`--launch` needs no model credentials.

Other HTTP/network failures generally propagate as operational errors. Invalid
JSON, malformed response shapes, and incomplete model responses can enter the
bounded revision path. An HTTP 401 is not a semantic rejection. On an operational
failure partway through extraction, saved attempt artifacts are useful evidence;
the manifest's attempts counter is updated when `extract()` returns and may still
be zero if extraction raised before returning.

## 6. DeepSeek extraction: ask() and extract()

`ask()` is the direct DeepSeek HTTP client for preprocessing. It:

1. Builds a system instruction and a user message containing a JSON-encoded payload.
2. Saves the request body, without the authorization header.
3. Calls the DeepSeek chat-completions endpoint with JSON-object output requested,
   a 4,096-token output limit, and a 180-second HTTP timeout.
4. Saves the provider response, token usage, returned model name, and elapsed time.
5. Requires a completed response and parses its message as JSON.

`extract()` provides the extraction instructions and controls validation/revisions.
The model receives only the original report and, on later attempts, validation
feedback. It is asked for exactly five fields:

| Field | Django example |
| --- | --- |
| target_function | model_to_dict |
| triggering_input | fields=[] |
| observed_behavior | Returns model fields |
| expected_behavior | Returns an empty dictionary |
| suggested_assertion | Compare the returned dictionary with {} |

Each field is an object with `value` and `evidence`. Unknown information uses null
for both. The assertion is a supported behavioral suggestion, not a complete test.
The extractor does not inspect the repository or generate the final unit-test patch.

## 7. Local validation: validate()

Python checks facts that do not need a language model:

- The specification has exactly the five expected fields.
- Each entry has exactly `value` and `evidence`.
- A known value is a nonempty string with a nonempty supporting quote.
- The quote occurs verbatim in the original report.
- Unknown values have null evidence.
- The entire specification is not unknown.

A structurally valid specification can still be wrong. A real quotation might
not support the claim attached to it, so quotation matching alone is insufficient.

## 8. Semantic review: a second ask() call and semantic_errors()

If local validation passes, `extract()` makes a separate DeepSeek request with
the original report and candidate specification. It asks the model to identify
unsupported fields, contradictions, assumptions, and important missing information.

`semantic_errors()` checks the review's shape and types. Acceptance requires
`valid: true` and empty `unsupported_fields`, `contradictions`, and
`missing_information` arrays. Python validates the review format; DeepSeek supplies
the semantic judgment. Same-model review can repeat the extraction model's mistakes.

On rejection, feedback is supplied to a fresh extraction request. By default there
are at most three extraction attempts: one initial attempt and two revisions. A
review call happens only when local validation passes, so there can be at most
six preprocessing calls. This is a call-count bound, not a preprocessing dollar cap.

On acceptance, save `bug_spec.json`. On validation exhaustion, return no accepted
specification and mark fallback. The controller then uses the original report.
This failure remains part of the improved method's recorded outcome.

## 9. Constructing the task

In baseline mode, `task.txt` contains the original report. In improved mode, it
contains that same report plus the accepted JSON specification. If improved mode
falls back, it contains only the original report, with fallback recorded separately.

Without `--launch`, processing stops after preparation. Improved preparation still
makes paid preprocessing calls; it is not an offline dry run.

## 10. Configuration and container launch

`unit_test_profile()` finds `profiles/unit_test.yaml` relative to the script.
`load_agent_config()` reads the preserved `baseline/swt_test.yaml` and builds an
in-memory effective configuration.

- The explicit image becomes `environment.image`.
- Unit-test mode replaces the task template with the shared unit-test instructions.
- Unit-test mode also sets the Bash interpreter to `bash -o pipefail -c`.
- The original baseline file is not rewritten.

The YAML retains DeepSeek model settings, a 100-step limit, and a $0.50 agent cost
limit. That agent limit excludes preprocessing and can be exceeded by the last
model call. The profile adaptation is used identically in both experimental arms.
It is a documented format adaptation, not an unchanged replay of the instructor's
standalone-script protocol.

`launch()` requires installed mini-SWE-agent version 2.4.6, saves the effective
configuration, and uses its `get_model`, `get_environment`, and `get_agent`
factories. It selects DefaultAgent without interactive CLI overrides, then calls
`agent.run(task)`. Docker starts a fresh container with the buggy checkout under
`/testbed`; this is separate from your local TRACE files.

## 11. The agent/model loop

Inside mini-SWE-agent, DeepSeek proposes shell actions. The environment executes
them and returns output and status. The next model request includes those
observations. Typical actions include locating a function, reading source, finding
existing tests and fixtures, writing a test, and running the native test runner.

Repository contents are read through these commands, not uploaded wholesale by
`controller.py`. The baseline observation template truncates long outputs, keeping
the beginning and end. Directory changes and environment exports do not persist
between commands because each action uses a new subshell.

The model can make mistakes, ignore instructions, or hit limits. Prompt instructions
are not a mechanical guarantee that every submitted change is valid or test-only.

## 12. Writing a native unit test

The unit-test profile tells the agent to follow the repository's existing test
framework and fixtures, avoid production changes, preserve assertions, and create
discoverable tests rather than a standalone reproduction script.

Our actual Django baseline and improved submissions both added:

```python
class ModelToDictTests(TestCase):
    def test_empty_fields(self):
        item = ColourfulItem.objects.create()
        self.assertEqual(model_to_dict(item, fields=[]), {})
```

This extends an existing test class in `tests/model_forms/tests.py`, reusing its
model and Django-managed database setup. It is more appropriate for native test
collection than a top-level script calling `settings.configure()`.

The profile supplies general repository-aware instructions. It does not hard-code
this Django patch or repair the agent's output after submission.

## 13. Running the generated tests and interpreting failure

The agent is instructed to run the relevant target on the buggy checkout. In our
matched unit-test pilot, both runs executed the model_forms suite and reported:

```text
FAIL: test_empty_fields (model_forms.tests.ModelToDictTests)
AssertionError: {'id': 1, 'name': '', 'colours': []} != {}
Ran 165 tests
FAILED (failures=1)
```

That is evidence of an issue-relevant failure: setup completed, the new test was
discovered, and it failed at the expected dictionary comparison. The test did not
merely fail because of a syntax error, missing import, or misspelled name.

Bash pipefail prevents a successful `tail` or `tee` from masking a failed runner.
If the agent prints a status afterward, it must capture the status immediately
and exit with it; a later successful command could otherwise overwrite the result.
The updated profile explains that rule, and both matched pilot executions returned 1.

The separate automated test-quality classifier is still not implemented. Current
classification is based on human inspection of saved commands, tracebacks, and
assertions. An AssertionError by itself is not proof of bug relevance.

## 14. Patch submission and saved run records

The profile instructs the agent to inspect its diff, include only native test
changes, and create a temporary patch. For new test files, intent-to-add makes
them visible in Git diff. The final submission command prints the completion
marker followed by the patch. mini-SWE-agent recognizes the marker and ends its loop.

`launch()` saves `agent_result.json`, writes a nonempty submitted patch to
`submission.patch`, saves the serialized trajectory in a finally block, and calls
container cleanup. Files created inside the temporary container should not be
treated as permanent local files; the saved patch preserves the prediction.

| Artifact | Meaning |
| --- | --- |
| report.txt | Original issue used for this run |
| extract-N.request/response/metrics.json | Extraction input, output, usage, timing |
| candidate-N.json | Parsed candidate specification |
| review-N.request/response/metrics.json | Semantic review evidence |
| validation-N.json | Errors for an extraction attempt |
| bug_spec.json | Accepted specification, if one exists |
| task.txt | Exact task text supplied to the agent |
| effective_config.json | In-memory generation configuration |
| agent.traj.json | Agent messages, actions, observations, and model statistics |
| agent_result.json | Exit status and submission returned by the agent |
| submission.patch | Saved generated patch, when nonempty |
| manifest.json | Run identity, hashes, mode, format, runtime, and outcome metadata |

Not every file exists on every failure path. The controller records a failure
manifest for errors inside its guarded execution section. Earlier input/config
checks or failure to create the output directory can stop before a manifest exists.
`agent_finished` means the loop returned, not that the evaluator accepted the test.
Check `agent_result.json` for Submitted, limits, or other exit conditions.

These records are written by Python and the agent library; DeepSeek does not
author an official results report. Extraction metrics leave dollar cost null.
Compute that overhead from provider usage/rates and add agent cost separately.

## 15. Export: export_prediction.py

This script runs after generation, not inside `controller.py`. Its
`export_prediction(run, out, label=None)` function:

1. Reads the manifest and requires `test_format: unit_test`.
2. Reads the agent result if present.
3. Copies the submitted patch only when exit status is Submitted.
4. Uses an empty patch for non-submission or a missing agent result.
5. Writes one JSONL row using exclusive creation.

```json
{
  "instance_id": "django__django-11163",
  "model_patch": "<unchanged submitted unified diff>",
  "model_name_or_path": "trace-baseline-unit-test"
}
```

The method label distinguishes baseline and improved predictions. It is not a
provider model identifier. `--label` can override it. The exporter does not apply,
parse, repair, validate, or score the patch, and cannot certify native-test validity.

It rejects old script-format runs and existing export files. Exporting a missing
result as an empty patch keeps that instance represented, but a full assigned-set
runner must also account for runs that never produced a manifest. Do not silently
omit missing predictions from the experiment denominator.

For our current matched pair:

```bash
python export_prediction.py --run runs/django-unit-baseline-20261111-212132 --out runs/django-unit-baseline-prediction.jsonl
python export_prediction.py --run runs/django-unit-improved-20261111-211606 --out runs/django-unit-improved-prediction.jsonl
```

## 16. Evaluation is a separate program

The official SWT-Bench harness lives in a separate checkout, not in these four
project Python files. Its `src.main` entry point consumes the prediction file.
Use explicit unit-test mode and consistent dataset/settings for both methods.

For the inspected local harness, changed paths determine test targets. Django
test paths are converted to dotted module names. A native-suite patch therefore
lets the harness collect the relevant tests; renaming reproduce.py is insufficient.

Evaluation is where reference fixes and evaluator artifacts may be used. They must
not be returned to the generator for generation or repair. The evaluator checks
patch applicability and behavior on buggy and fixed code according to its official
criterion, and produces evaluation logs and metrics.

We have verified issue-relevant failures during generation, but have not yet
established official before/after success for this matched pair. Do not infer
fixed-version success merely from a sensible assertion or a Submitted status.

## 17. Offline verification: test_controller.py

This is a unittest suite, not a generated benchmark regression test. Run it with:

```bash
python -m unittest -v
```

The current 11 tests cover:

1. Specification structure and verbatim evidence grounding.
2. Semantic review shape, types, and rejection.
3. Shared profile settings and pipeline-failure handling.
4. Prediction patch preservation and refusal to overwrite exports.
5. Failed-prediction retention and rejection of script-format exports.
6. Revision followed by acceptance.
7. Bounded validation exhaustion.
8. Baseline preparation and output no-overwrite behavior, without an extraction key.
9. Missing-key extraction stopping without network calls or revision artifacts.
10. Missing-key configuration failure without extraction or agent launch.
11. Launcher configuration, submission saving, and cleanup with mocked execution.

It imports `controller` and `export_prediction`; it mocks model calls and agent
execution. These tests do not need Docker or API credentials. They do not prove
that the actual agent package is installed, that provider authentication works,
or that Bash/Django runs successfully in a real container. Follow
[OFFLINE_TESTS.md](OFFLINE_TESTS.md) for actual dependency imports and snapshot checks.

## 18. What the current experiment tells us

The updated-profile matched pair is:

| Item | Baseline | Improved |
| --- | --- | --- |
| Run | django-unit-baseline-20261111-212132 | django-unit-improved-20261111-211606 |
| Accepted preprocessing | Not applicable | First attempt, no fallback |
| Native patch | Same patch | Same patch |
| Buggy execution | One intended failure out of 165 tests | One intended failure out of 165 tests |
| Controller runtime | 28.57 seconds | 41.27 seconds |
| Agent-only trajectory cost | $0.003609696 | $0.003834948 |
| Official fixed-version outcome | Not yet evaluated | Not yet evaluated |

The improved method's preprocessing cost is additional. Identical patches on this
clear issue do not demonstrate a success-rate improvement. Both runs used the same
recorded report, baseline hash, image tag, and updated unit-test profile hash.
Record immutable image identity and provider model details for final reproducibility.

The next steps are official evaluation of both predictions, preserving all outputs,
then expansion to the full assigned set. Report success/applicability over all
assigned instances, official coverage delta with its exact field and available
count, total generation cost, average generation time, and evaluation time. Keep
configuration failures, missing predictions, and timeouts visible. Classify
infrastructure failures separately and retry unchanged predictions after recovery.

## 19. Supporting files

- `requirements.txt`: Python dependency ranges and pinned mini-SWE-agent version.
- `baseline/swt_test.yaml`: preserved original script-generation configuration.
- `profiles/unit_test.yaml`: shared native-test instructions and Bash pipefail.
- `.gitattributes`: preserves important report/config bytes across checkouts.
- `.gitignore`: excludes environments, runs, and unrelated artifacts from normal commits.
- `README.md`: project overview and setup.
- `PILOT.md`: original script-format smoke-test instructions.
- `UNIT_TEST_PILOT.md`: current native unit-test generation/export protocol.
- `OFFLINE_TESTS.md`: collaborator installation and offline verification.

`runs/` being ignored means local artifacts are not automatically backed up to
GitHub. Preserve them explicitly using an agreed private artifact archive.
