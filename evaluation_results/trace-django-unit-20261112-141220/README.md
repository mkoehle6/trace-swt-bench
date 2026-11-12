# Official Django unit-test evaluation

Evaluation date: November 12, 2026. Instance: django__django-11163.

| Metric | Baseline | Improved |
| --- | ---: | ---: |
| Reproduction success | 1/1 (100%) | 1/1 (100%) |
| Patch applicability | 1/1 (100%) | 1/1 (100%) |
| coverage_delta_pred | 1.0 | 1.0 |
| Coverage availability | 1 instance | 1 instance |
| Evaluation command wall time | 205 s | 84 s |
| Generation controller runtime | 28.57 s | 41.27 s |
| Agent-only generation cost | $0.003609696 | $0.003834948 |
| Evaluation errors | 0 | 0 |

The improved method has additional extraction/review cost not yet calculated.
Both methods submitted identical patches. The official instance reports mark both
resolved and patch_successfully_applied, and list test_empty_fields under
tests_pred.FAIL_TO_PASS. This is a successful reproduction for each method on one
instance; it does not establish a benefit across the 26-instance selection.

## Reading the evidence

Each method folder contains the unmodified official aggregate summary, instance
report, predicted-test before/after output, console log, and command timing.
The provenance identifies the pinned dataset and shared generation profile.
The harness commit and installed package list record the evaluation implementation.
artifact_checksums.json verifies the copied source artifacts.

Reference patches, full evaluation dataset rows, gold test logs, images, and
container filesystem contents are not included. These are evaluation outputs:
do not feed them back into generation, analysis prompts, or test repair. Instance
reports include evaluator classifications and must stay in this evaluation area.

## Coverage interpretation

The official instance field is coverage_delta_pred; the aggregate field is
"Mean coverage delta". The inspected harness calculates a fraction over executable
added/removed reference-fix lines, counting increased execution counts relative to
its base coverage. It is not whole-repository line coverage. Value 1.0 is a unitless
fraction (100% on this metric's scale), not one percentage point.

Aggregation is the arithmetic mean of per-instance coverage_delta_pred where
coverage_pred is available. Here one of one instances has coverage. Since both
instances per method (one each) are resolved, overall and successful-reproduction
coverage averages coincide. For future batches report both explicitly; missing
coverage is N/A, not zero. The harness summary defaults to zero when none is
available, so inspect per-instance availability before reporting it.

## Reporting caveats

"completed_instances: 0" counts previously existing instance reports reused by
the reporting function. These newly evaluated reports have resolved_instances: 1
and no errors; zero does not mean the evaluation failed to complete.

The improved evaluation reused cached reference/base work created during baseline
evaluation. Its shorter evaluation time is not evidence of a workflow speedup.
Times above include invocation/reporting overhead and come from timing.txt, not
just the progress-bar duration.

The harness also lists the existing test_many_to_many under FAIL_TO_PASS. Do not
equate added_f2p: 2 with two newly generated tests: the submitted patch adds one
test. Preserve the official classification rather than rewriting it.

Matched generation runs: runs/django-unit-baseline-20261111-212132 and
runs/django-unit-improved-20261111-211606. The earlier preliminary report predates
this evaluation; this document is the evaluation follow-up.
