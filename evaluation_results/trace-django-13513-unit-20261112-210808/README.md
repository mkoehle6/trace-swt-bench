# Django 13513: official evaluation and investigation

These are evaluation-only artifacts. Do not use this directory, the dataset row,
reference fields, or evaluator outcomes as generation or repair inputs.

| Metric | Baseline | Improved |
| --- | ---: | ---: |
| Patch applicability | 1/1 | 1/1 |
| Reproduction success | 0/1 | 0/1 |
| added_f2p | 0 | 0 |
| coverage_pred | 1.0 | 1.0 |
| coverage_delta_pred | 0.6470588235294118 | 0.6470588235294118 |
| Instances with available coverage | 1 | 1 |
| Evaluation command time | 265.37 s | 116.86 s |
| Harness error instances | 0 | 0 |

Both submitted tests pass before and after the reference fix. The harness runs
89 tests per prediction configuration; an existing PlainTextReportTests.test_template_exception
fails in both states. This existing failure is distinct from the generated tests,
and neither submission adds a fail-to-pass test. Coverage is not reproduction
success. coverage_delta_pred is the harness's fraction over executable changed
reference-fix lines where execution counts increase relative to base; it is not
whole-repository coverage. Successful-reproduction coverage delta is N/A.
The improved evaluation reused cached comparison work; the time difference is not
an experimental method speedup. Both harness commands exited 0; that indicates
completed evaluation, not successful bug reproduction.

The generation image is clean at the recorded base commit
6599608c4d0befdcb820ddccce55f183f247ae4f. Its get_traceback_frames() helper already
checks __suppress_context__, and its existing test_suppressed_context test covers
suppressed chaining. Both generated additions assert behavior already present in
that supplied checkout. The pinned dataset issue text matches the saved report.
This observation does not establish that the report's broader issue is absent in
every scenario; it explains the passing assertions generated here.

The baseline trajectory also records a protocol deviation: the agent inspected
historical commit logs and requested the statistics of a historical commit despite
the shared profile's prohibition on inspecting historical fixes. See investigation.json.
Do not present the baseline run as fully compliant with that restriction. Retain
its unsuccessful official outcome and the deviation together, rather than silently
excluding or repairing the run. No evaluator outputs were supplied to either generator.

The first improved generation attempt failed before extraction because the key
was not exported; it remains preserved. The completed improved generation used the
existing credential configuration, accepted its first specification, and did not
fall back. Generation artifacts remain under runs/; exported predictions were
copied byte for byte and were not repaired.

Evaluation used the existing unmodified SWT-Bench checkout at commit
eee38624e36a1b39976fffa2bddbc4c3c754d293, explicit unit_test mode, coverage enabled,
one worker, a 1,800-second per-execution timeout, vanilla patches, and the pinned
SWE-bench Verified revision recorded in provenance.json. Instance images were
preserved. The initial baseline evaluation launch failed because a launcher filename
shadowed a harness module; baseline/ contains that failed launch, and baseline-retry1/
and improved-retry1/ contain the completed commands, console logs, and timing. The
corrected launcher uses Python -P for import isolation. No harness code was changed.

summary.json contains the official fields and selected prediction test results.
run_instance_swt_logs/ and evaluation_results/ preserve raw official evidence.
evaluation-dataset.json contains reference fields and must remain evaluation-only.
prediction-checksums.json identifies unchanged exported inputs; artifact-checksums.json
records raw artifacts captured before this README was added. All recorded generation
workflow/input hashes were verified unchanged after evaluation. Nothing was pushed
to GitHub, and no existing result was replaced.
