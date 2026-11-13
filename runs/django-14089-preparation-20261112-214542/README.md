# Django 14089: paired generation

Both unchanged workflows submitted native test patches for OrderedSet reversibility.
Both tests were discovered and failed on the buggy checkout with the expected
TypeError: 'OrderedSet' object is not reversible. Baseline ran 7 tests; improved
ran 44 tests. Both commands preserved exit status 1. This is generation-time
reproduction evidence, not an official before/after evaluation result.

| Item | Baseline | Improved |
| --- | ---: | ---: |
| Controller time | 28.38 s | 34.73 s |
| Agent-only cost | $0.002184576 | $0.001643556 |
| Submission | Submitted | Submitted |
| Accepted extraction attempts | N/A | 1 |
| Fallback | N/A | No |

Improved preprocessing cost is additional. Setup time is excluded from controller
time. The same verified immutable image, saved report, preserved baseline config,
and shared unit-test profile were used in both runs. Workflow and saved input hashes
were verified unchanged after generation. Predictions were exported unchanged.

Generation directories:
- runs/django-14089-unit-baseline-20261112-214542
- runs/django-14089-unit-improved-20261112-214542

The first unrun manifest entry, xarray 3677, was deferred during environment setup:
its Conda solve remained active without a dependency plan for several minutes.
Its build logs and stop reason are preserved separately under
runs/xarray-3677-preparation-20261112-213317. No model run was launched for that attempt.
The next unrun manifest entry, Django 14089, was used for this completed pair.

No evaluator outputs or reference patches were supplied to generation. No reference
fix was applied for these runs, and no GitHub push was performed.
