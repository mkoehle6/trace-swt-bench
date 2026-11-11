# Pilot: django__django-11163

Run from the activated environment described in README.md.

1. Choose the exact dataset and immutable revision used by your course baseline.
   SWE-bench Verified is the retrieval default; this does not establish which
   SWT-Bench variant your course evaluates. Set the appropriate dataset if different.

```bash
export DATASET_REVISION='<actual dataset commit SHA>'
python fetch_report.py --revision "$DATASET_REVISION" --out data/django__django-11163
cat data/django__django-11163/source.json
cat data/django__django-11163/report.txt
```

Do not copy the illustrative model_to_dict report from the prior chat: its instance
mapping was never verified. Inspect the fetched original report and base commit.
If the instance is absent, resolve the dataset mismatch; do not invent a report.

2. Select the official prebuilt benchmark image matching that instance and base
   commit, using your existing SWT-Bench harness. Confirm architecture, `/testbed`,
   installed dependencies and the image digest. The script deliberately does not
   guess a registry tag or build an image from the existing SymPy checkout.

```bash
export BENCH_IMAGE='<verified benchmark image reference, preferably @sha256:digest>'
docker image inspect "$BENCH_IMAGE" --format '{{json .RepoDigests}}'
```

3. Prepare a baseline task without API calls, then extract and validate the improved
   task (this second command calls DeepSeek). Use fresh output names for repeats.

```bash
python controller.py --report data/django__django-11163/report.txt --mode baseline --out runs/django-baseline-prepare
python controller.py --report data/django__django-11163/report.txt --out runs/django-improved-prepare
```

Inspect every candidate, validation result, `task.txt` and `manifest.json`. Unknown
fields are allowed; an entirely unknown specification is rejected. Validation
exhaustion produces a flagged original-report fallback. No agent runs in prepare mode.

4. Launch matched baseline and improved experiments. The improved command performs
   a new extraction, so use its own saved artifacts when reporting results.

```bash
python controller.py --report data/django__django-11163/report.txt --mode baseline --out runs/django-baseline-01 --image "$BENCH_IMAGE" --launch
python controller.py --report data/django__django-11163/report.txt --out runs/django-improved-01 --image "$BENCH_IMAGE" --launch
```

Each launch creates a fresh container; it does not mount or edit the existing
SymPy directory. Containers are cleaned up, so retain the submitted patch from
the run directory. Inspect patch paths: only reproduce.py should be added, then
evaluate with the course SWT-Bench harness. Existing YAML instructs the agent to
make patch.txt despite its exactly-one-file boundary; that inconsistency has been
preserved for experimental fidelity, not silently corrected by the controller.

5. Record per-arm submission status, buggy failure reason, fixed success, API cost,
   runtime, revision/fallback counts and a human field review. Lock dataset/image
   and package versions before expanding beyond this pilot.
