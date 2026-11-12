# Unit-test submission protocol

The completed Django runs generated standalone reproduce.py scripts. Keep them as
development smoke tests; they are not unit-test-mode results. Do not hand-convert
only the improved prediction or combine their scores with the new protocol.

## Shared format adaptation

Use `--test-format unit_test` for BOTH baseline and improved runs. The new profile
in `profiles/unit_test.yaml` replaces the agent's task template and enables Bash pipefail in memory.
The preserved baseline YAML is unchanged. Model, other Docker settings, 100-step limit,
and $0.50 agent limit remain the same. Baseline still receives the original report;
improved receives the report plus an accepted specification (or a flagged fallback).

This is a documented shared adaptation to meet the course's unit-test requirement,
not a byte-identical reproduction of the instructor's standalone-script protocol.
Use this adapted baseline consistently in the primary comparison. Reconcile this
protocol with instructor requirements before collecting final evaluation results.

The agent must add discoverable tests to the native suite, follow existing fixtures,
and submit only test changes. For Django it should use the existing model_forms
test module rather than global settings.configure calls or a top-level script.
The profile applies to every repository and tells the agent to inspect its runner.

The inspected local SWT-Bench implementation derives test targets from paths in
the submitted diff. For Django, tests/model_forms/tests.py becomes model_forms.tests.
This motivates native-suite patches; merely renaming reproduce.py is insufficient.
Whether any generated patch applies, is collected, and succeeds is decided by the
official evaluator. This profile is not an implemented automated quality gate.

## Generate a fresh matched pair

Run from this repository root in the activated environment. Set DEEPSEEK_API_KEY
for extraction and ensure agent provider authentication is configured. These
commands make paid calls. Select the same verified buggy image for both methods:

```bash
export BENCH_IMAGE='exec.eval.x86_64.ee2ad6945f237e9160354f.9abfb63cef178bd684a2ce:latest'
docker image inspect "$BENCH_IMAGE" --format '{{.Id}} {{json .RepoDigests}}'
export PAIR_ID="$(date +%Y%m%d-%H%M%S)"
python controller.py --report data/django__django-11163/report.txt --mode baseline --test-format unit_test --out "runs/django-unit-baseline-$PAIR_ID" --image "$BENCH_IMAGE" --launch
python controller.py --report data/django__django-11163/report.txt --mode improved --test-format unit_test --out "runs/django-unit-improved-$PAIR_ID" --image "$BENCH_IMAGE" --launch
```

The image tag above is the Django image built during this project's pilot. It must
exist on the current Docker engine; it is not a public registry image guaranteed
to exist for every collaborator. Verify /testbed is the buggy Django checkout at
e6588aa4e793b7f56f4cadbfa155b581e0efc59a. Preserve the image ID/digest with results.

Compare manifests, effective configs, native-runner output in trajectories, and
submitted patches. New manifests include test_format and unit_test_profile_sha256.
Both methods should have the same profile hash. Without --test-format unit_test,
the existing reproduction_script format remains the default.

## Export predictions

Keep the PAIR_ID from the generation terminal, or substitute saved run directories.

```bash
python export_prediction.py --run "runs/django-unit-baseline-$PAIR_ID" --out "runs/predictions-unit-baseline-$PAIR_ID.jsonl"
python export_prediction.py --run "runs/django-unit-improved-$PAIR_ID" --out "runs/predictions-unit-improved-$PAIR_ID.jsonl"
```

Each JSONL row contains instance_id, model_name_or_path, and the unmodified submitted
model_patch, as expected by the inspected harness. The exporter refuses old script
runs and existing output files. A non-submission or missing agent result is exported
as an empty patch so the assigned instance is not silently removed. Preserve the
manifest to distinguish operational failure from agent failure. For later batches,
build the full assigned-instance manifest before generation; a run that never creates
a manifest also needs an empty prediction and explicit failure record.

Export performs no patch conversion, no repair, and no reference lookup. It does
not prove unit-test validity. Use the official harness with explicit
`--exec_mode unit_test`, the same pinned evaluation dataset/settings for both methods,
and no `--predictions_path gold` for model scoring. Preserve evaluator outputs and
coverage fields. We have not run an official evaluation for this protocol yet.

## Offline verification

```bash
python -m unittest -v
```

The tests verify the profile changes only the shared task template and Bash pipeline handling and that export
preserves submitted patches, protects existing files, keeps unsuccessful cases,
and rejects script-mode runs. Live Django collection/execution still needs testing.

## Preserving test exit codes

Unit-test mode runs every shell command with Bash pipefail enabled. A failed
test command piped into tail or tee therefore returns nonzero. Appending echo
or another command can still replace that status, so the profile instructs the
agent to capture it immediately and exit with the captured value. Run follow-up
patch commands separately. Previous trajectories are not rewritten. Because this
updates the shared profile hash, use the updated profile for both methods when
collecting a matched comparison; retain earlier runs as development evidence.
