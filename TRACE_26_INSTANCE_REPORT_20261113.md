# TRACE: report for all 26 assigned instances

Prepared 13 November 2026 from the final selected generation ledger and saved trajectories. Each assigned instance has two experimental runs, baseline and improved; some patches add several individual test cases. This report therefore covers 26 instances and 52 selected runs.

Both methods submitted 26 nonempty patches, with no remaining setup failures. Improved preprocessing accepted 22 specifications and fell back to the raw report for four instances. Submission is not proof that a regression test is valid or succeeds under official evaluation. The complete 26-instance set has not been officially evaluated. Earlier pilot evaluation artifacts are outside this report’s scope; no official success rate or coverage delta is claimed here.

The identity audit found 23 matched pairs and three pairs with historical image-identity limitations. Saved reports and recorded workflow files are unchanged. Six selected runs have heuristic command-review flags; those flags identify commands to inspect, not a final contamination verdict. This report reads generation records for analysis only and does not launch, regenerate, repair, or modify predictions. No reference fixes or evaluation outputs were used to generate this report’s test inputs.

Known selected-run agent cost totals $0.379071900 baseline and $0.383181006 improved, excluding preprocessing and historical attempts. Times below are controller elapsed generation/preprocessing time, excluding image setup. Host concurrency and environment differences mean they are descriptive timings, not a controlled speed comparison.

| # | Instance | Baseline | Improved | Improved preprocessing | Seconds B / I |
| --- | --- | --- | --- | --- | --- |
| 1 | pydata__xarray-3677 | Submitted | Submitted | Accepted (1 attempt) | 45.0 / 60.9 |
| 2 | django__django-14089 | Submitted | Submitted | Accepted (1 attempt) | 28.4 / 34.7 |
| 3 | django__django-11163 | Submitted | Submitted | Accepted (1 attempt) | 28.6 / 41.3 |
| 4 | sympy__sympy-24539 | Submitted | Submitted | Accepted (1 attempt) | 35.4 / 56.7 |
| 5 | scikit-learn__scikit-learn-14894 | Submitted | Submitted | Accepted (1 attempt) | 44.0 / 68.9 |
| 6 | sphinx-doc__sphinx-9711 | Submitted | Submitted | Accepted (1 attempt) | 53.3 / 64.4 |
| 7 | astropy__astropy-14508 | Submitted | Submitted | Accepted (2 attempts) | 58.9 / 101.9 |
| 8 | pytest-dev__pytest-7432 | Submitted | Submitted | Accepted (1 attempt) | 62.9 / 84.8 |
| 9 | pallets__flask-5014 | Submitted | Submitted | Accepted (1 attempt) | 32.1 / 48.0 |
| 10 | matplotlib__matplotlib-13989 | Submitted | Submitted | Accepted (1 attempt) | 71.6 / 64.5 |
| 11 | psf__requests-2931 | Submitted | Submitted | Accepted (1 attempt) | 39.4 / 55.9 |
| 12 | pylint-dev__pylint-6903 | Submitted | Submitted | Accepted (1 attempt) | 77.8 / 72.7 |
| 13 | mwaskom__seaborn-3187 | Submitted | Submitted | Accepted (3 attempts) | 206.6 / 324.8 |
| 14 | django__django-13513 | Submitted | Submitted | Accepted (1 attempt) | 58.1 / 71.0 |
| 15 | sphinx-doc__sphinx-8548 | Submitted | Submitted | Accepted (1 attempt) | 156.4 / 184.0 |
| 16 | django__django-13344 | Submitted | Submitted | Accepted (2 attempts) | 153.7 / 271.2 |
| 17 | django__django-15098 | Submitted | Submitted | Raw-report fallback (3 attempts) | 133.0 / 237.5 |
| 18 | django__django-12155 | Submitted | Submitted | Accepted (1 attempt) | 64.3 / 104.2 |
| 19 | sphinx-doc__sphinx-8638 | Submitted | Submitted | Accepted (1 attempt) | 184.2 / 296.0 |
| 20 | django__django-15252 | Submitted | Submitted | Accepted (1 attempt) | 221.3 / 161.4 |
| 21 | django__django-16631 | Submitted | Submitted | Raw-report fallback (3 attempts) | 77.6 / 185.1 |
| 22 | sphinx-doc__sphinx-8551 | Submitted | Submitted | Raw-report fallback (3 attempts) | 177.7 / 206.3 |
| 23 | django__django-13810 | Submitted | Submitted | Raw-report fallback (3 attempts) | 76.6 / 101.4 |
| 24 | sphinx-doc__sphinx-8721 | Submitted | Submitted | Accepted (1 attempt) | 105.2 / 155.1 |
| 25 | sphinx-doc__sphinx-8621 | Submitted | Submitted | Accepted (1 attempt) | 109.9 / 148.5 |
| 26 | matplotlib__matplotlib-25311 | Submitted | Submitted | Accepted (1 attempt) | 127.8 / 103.0 |

## What happened in each instance

Failure counts below refer to recorded generation-time commands. Tests often change during exploration, and a whole-file run may contain unrelated failures. Passing diagnostics after temporary modifications are not evidence of official before/after success. The linked trajectories retain the exact commands and outputs.

### 1. pydata__xarray-3677

**Issue:** Merging dataArray into dataset using dataset method fails

Both methods compare Dataset.merge(DataArray) with the top-level merge result. Both fail with AttributeError because DataArray has no items attribute. Baseline places the test in test_dataset.py; improved uses test_merge.py, where the broader run has one failure and eight passes.

**Setup and provenance:** Generation followed infrastructure recovery and verification of the exact prescribed benchmark setup edits. Earlier setup failures and empty predictions remain preserved.

Initial setup record: `RuntimeError`. [Preserved failure record](runs/assigned-pairs-20261113-002517/instances/pydata__xarray-3677/setup-failure.json).

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 45.0s | $0.005671 | `xarray/tests/test_dataset.py` |
| Improved | Submitted | 60.9s | $0.007206 | `xarray/tests/test_merge.py` |

**Preprocessing:** Accepted specification after 1 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/pydata__xarray-3677/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/pydata__xarray-3677/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/pydata__xarray-3677/generation-baseline/manifest.json).

Recorded runner summaries: `message 15: 1 failed, 9 warnings in 7.44s`.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/pydata__xarray-3677/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/pydata__xarray-3677/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/pydata__xarray-3677/generation-improved/manifest.json).

Recorded runner summaries: `message 12: 1 failed, 9 warnings in 7.00s`; `message 14: 1 failed, 8 passed, 26 warnings in 4.73s`.

**Pair identity:** matched.

### 2. django__django-14089

**Issue:** Allow calling reversed() on an OrderedSet

Both add an OrderedSet reversal test and encounter TypeError: the object is not reversible. Baseline also includes an empty-set assertion, although execution stops at the first error. Baseline runs seven tests; improved runs 44, each with one error.

**Setup and provenance:** A previously completed pair was retained; no new generation was launched for this pair in the batch.

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 28.4s | $0.002185 | `tests/utils_tests/test_datastructures.py` |
| Improved | Submitted | 34.7s | $0.001644 | `tests/utils_tests/test_datastructures.py` |

**Preprocessing:** Accepted specification after 1 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/django-14089-unit-baseline-20261112-214542/agent.traj.json), [submitted patch](runs/django-14089-unit-baseline-20261112-214542/submission.patch), [manifest](runs/django-14089-unit-baseline-20261112-214542/manifest.json).

Recorded runner summaries: `message 14: Ran 6 tests in 0.001s; OK`; `message 18: Ran 7 tests in 0.001s; FAILED (errors=1)`.

**Improved evidence:** [trajectory](runs/django-14089-unit-improved-20261112-214542/agent.traj.json), [submitted patch](runs/django-14089-unit-improved-20261112-214542/submission.patch), [manifest](runs/django-14089-unit-improved-20261112-214542/manifest.json).

Recorded runner summaries: `message 11: Ran 44 tests in 0.072s; FAILED (errors=1)`.

**Pair identity:** matched.

### 3. django__django-11163

**Issue:** model_to_dict() should return an empty dict for an empty list of fields.

Both submit identical model_to_dict(fields=[]) tests. Each runs 165 tests with one failure: the result contains model fields instead of an empty dictionary.

**Setup and provenance:** A previously completed pair was retained; no new generation was launched for this pair in the batch.

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 28.6s | $0.003610 | `tests/model_forms/tests.py` |
| Improved | Submitted | 41.3s | $0.003835 | `tests/model_forms/tests.py` |

**Preprocessing:** Accepted specification after 1 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/django-unit-baseline-20261111-212132/agent.traj.json), [submitted patch](runs/django-unit-baseline-20261111-212132/submission.patch), [manifest](runs/django-unit-baseline-20261111-212132/manifest.json).

Recorded runner summaries: `message 15: Ran 165 tests in 0.266s; FAILED (failures=1)`.

**Improved evidence:** [trajectory](runs/django-unit-improved-20261111-211606/agent.traj.json), [submitted patch](runs/django-unit-improved-20261111-211606/submission.patch), [manifest](runs/django-unit-improved-20261111-211606/manifest.json).

Recorded runner summaries: `message 13: Ran 165 tests in 0.263s; FAILED (failures=1)`.

**Pair identity:** matched with evidence limitations. Recorded limitations: ["baseline: launch recorded a mutable tag; current resolution cannot prove historical image identity", "improved: launch recorded a mutable tag; current resolution cannot prove historical image identity"].

### 4. sympy__sympy-24539

**Issue:** `PolyElement.as_expr()` not accepting symbols

Both exercise PolyElement.as_expr() with replacement symbols u, v, w and observe an assertion failure. Baseline adds assertions while preserving the existing symbol case; improved changes the existing case to use different symbols. This distinction matters when reviewing the instruction to preserve existing assertions.

**Setup and provenance:** The primary batch prepared the environment and ran both methods.

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 35.4s | $0.002687 | `sympy/polys/tests/test_rings.py` |
| Improved | Submitted | 56.7s | $0.002339 | `sympy/polys/tests/test_rings.py` |

**Preprocessing:** Accepted specification after 1 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/instances/sympy__sympy-24539/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/instances/sympy__sympy-24539/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/instances/sympy__sympy-24539/generation-baseline/manifest.json).

Recorded runner summaries: `message 17: ============= tests finished: 0 passed, 1 failed, in 0.26 seconds ==============`.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/instances/sympy__sympy-24539/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/instances/sympy__sympy-24539/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/instances/sympy__sympy-24539/generation-improved/manifest.json).

Recorded runner summaries: `message 13: ============= tests finished: 0 passed, 1 failed, in 0.28 seconds ==============`.

**Pair identity:** matched.

### 5. scikit-learn__scikit-learn-14894

**Issue:** ZeroDivisionError in _sparse_fit for SVM with empty support_vectors_

Both add sparse SVR coverage for empty support vectors and encounter ZeroDivisionError in the sparse fitting path. Each focused run has one failure.

**Setup and provenance:** Generation followed infrastructure recovery and verification of the exact prescribed benchmark setup edits. Earlier setup failures and empty predictions remain preserved.

Initial setup record: `RuntimeError`. [Preserved failure record](runs/assigned-pairs-20261113-002517/instances/scikit-learn__scikit-learn-14894/setup-failure.json).

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 44.0s | $0.009461 | `sklearn/svm/tests/test_sparse.py` |
| Improved | Submitted | 68.9s | $0.008863 | `sklearn/svm/tests/test_sparse.py` |

**Preprocessing:** Accepted specification after 1 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/scikit-learn__scikit-learn-14894/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/scikit-learn__scikit-learn-14894/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/scikit-learn__scikit-learn-14894/generation-baseline/manifest.json).

Recorded runner summaries: `message 21: 1 failed, 1 warning in 0.36s`.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/scikit-learn__scikit-learn-14894/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/scikit-learn__scikit-learn-14894/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/scikit-learn__scikit-learn-14894/generation-improved/manifest.json).

Recorded runner summaries: `message 23: 1 failed, 1 warning in 0.90s`.

**Pair identity:** matched.

### 6. sphinx-doc__sphinx-9711

**Issue:** needs_extensions checks versions using strings

Both test extension version comparison with a multi-digit minor version. Baseline has one failing case. Improved adds an older-version rejection control, producing one failure and one pass.

**Setup and provenance:** Generation followed infrastructure recovery and verification of the exact prescribed benchmark setup edits. Earlier setup failures and empty predictions remain preserved.

Initial setup record: `AssertionError`. [Preserved failure record](runs/assigned-pairs-20261113-002517/instances/sphinx-doc__sphinx-9711/setup-failure.json).

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 53.3s | $0.009630 | `tests/test_config.py` |
| Improved | Submitted | 64.4s | $0.007823 | `tests/test_extension.py` |

**Preprocessing:** Accepted specification after 1 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-9711/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-9711/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-9711/generation-baseline/manifest.json).

Recorded runner summaries: `message 23: 1 failed, 6 warnings in 0.16s`.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-9711/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-9711/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-9711/generation-improved/manifest.json).

Recorded runner summaries: `message 17: 1 failed, 1 passed, 6 warnings in 0.11s`.

**Pair identity:** matched.

### 7. astropy__astropy-14508

**Issue:** `io.fits.Card` may use a string representation of floats that is larger than necessary

Both construct the reported HIERARCH FITS card with 0.009125 and expect a short float representation that leaves the comment intact. Each focused run fails with VerifyWarning that the card is too long and its comment will be truncated. Baseline also asserts the value and comment. The saved image has prescribed build-time configuration edits; those are separate from the exported test patch.

**Setup and provenance:** Generation followed infrastructure recovery and verification of the exact prescribed benchmark setup edits. Earlier setup failures and empty predictions remain preserved.

Initial setup record: `AssertionError`. [Preserved failure record](runs/assigned-pairs-20261113-002517/instances/astropy__astropy-14508/setup-failure.json).

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 58.9s | $0.008908 | `astropy/io/fits/tests/test_header.py` |
| Improved | Submitted | 101.9s | $0.007267 | `astropy/io/fits/tests/test_header.py` |

**Preprocessing:** Accepted specification after 2 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/astropy__astropy-14508/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/astropy__astropy-14508/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/astropy__astropy-14508/generation-baseline/manifest.json).

Recorded runner summaries: `message 21: 1 failed in 1.55s`.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/astropy__astropy-14508/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/astropy__astropy-14508/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/astropy__astropy-14508/generation-improved/manifest.json).

Recorded runner summaries: `message 22: 1 failed in 1.05s`.

**Pair identity:** matched.

### 8. pytest-dev__pytest-7432

**Issue:** skipping: --runxfail breaks pytest.mark.skip location reporting

Both add skip-location checks with --runxfail. Baseline adds separate skip and skipif cases; the broader run has two failures and 77 passes. Improved combines checks into a new test and records one failure. Earlier passing exploratory runs are not the final regression outcome.

**Setup and provenance:** The primary batch prepared the environment and ran both methods.

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 62.9s | $0.010676 | `testing/test_skipping.py` |
| Improved | Submitted | 84.8s | $0.011184 | `testing/test_skipping.py` |

**Preprocessing:** Accepted specification after 1 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/instances/pytest-dev__pytest-7432/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/instances/pytest-dev__pytest-7432/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/instances/pytest-dev__pytest-7432/generation-baseline/manifest.json).

Recorded runner summaries: `message 13: 1 passed in 0.13s`; `message 17: 2 failed in 0.26s`; `message 21: 2 failed, 77 passed in 3.50s`.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/instances/pytest-dev__pytest-7432/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/instances/pytest-dev__pytest-7432/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/instances/pytest-dev__pytest-7432/generation-improved/manifest.json).

Recorded runner summaries: `message 21: 1 failed in 0.20s`; `message 27: 1 failed in 0.22s`.

**Pair identity:** matched.

### 9. pallets__flask-5014

**Issue:** Require a non-empty name for Blueprints

Both add an empty Blueprint-name rejection test. The expected ValueError is not raised. Baseline records one failure; improved records one failure and 59 passes in the broader file.

**Setup and provenance:** The primary batch prepared the environment and ran both methods.

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 32.1s | $0.005935 | `tests/test_blueprints.py` |
| Improved | Submitted | 48.0s | $0.004882 | `tests/test_blueprints.py` |

**Preprocessing:** Accepted specification after 1 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/instances/pallets__flask-5014/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/instances/pallets__flask-5014/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/instances/pallets__flask-5014/generation-baseline/manifest.json).

Recorded runner summaries: `message 17: 1 failed in 0.16s`.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/instances/pallets__flask-5014/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/instances/pallets__flask-5014/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/instances/pallets__flask-5014/generation-improved/manifest.json).

Recorded runner summaries: `message 15: 1 failed, 59 passed in 0.49s`.

**Pair identity:** matched.

### 10. matplotlib__matplotlib-13989

**Issue:** hist() no longer respects range=... when density=True

Both test density histogram normalization with an explicit range. Baseline records one assertion failure. Improved parameterizes coverage and records two failing cases. These are generation-time observations, not fixed-version validation.

**Setup and provenance:** Generation followed infrastructure recovery and verification of the exact prescribed benchmark setup edits. Earlier setup failures and empty predictions remain preserved.

Initial setup record: `RuntimeError`. [Preserved failure record](runs/assigned-pairs-20261113-002517/instances/matplotlib__matplotlib-13989/setup-failure.json).

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 71.6s | $0.011930 | `lib/matplotlib/tests/test_axes.py` |
| Improved | Submitted | 64.5s | $0.007474 | `lib/matplotlib/tests/test_axes.py` |

**Preprocessing:** Accepted specification after 1 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/matplotlib__matplotlib-13989/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/matplotlib__matplotlib-13989/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/matplotlib__matplotlib-13989/generation-baseline/manifest.json).

Recorded runner summaries: `message 21: 1 failed, 13 warnings in 1.64s`; `message 29: 1 failed, 13 warnings in 1.06s`.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/matplotlib__matplotlib-13989/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/matplotlib__matplotlib-13989/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/matplotlib__matplotlib-13989/generation-improved/manifest.json).

Recorded runner summaries: `message 19: 2 failed, 651 deselected, 13 warnings in 1.88s`.

**Pair identity:** matched.

### 11. psf__requests-2931

**Issue:** Request with binary payload fails due to calling to_native_string

Both add a request with a non-ASCII binary payload. Execution fails with UnicodeDecodeError because an ASCII conversion is attempted. Each focused run records one failure.

**Setup and provenance:** The primary batch prepared the environment and ran both methods.

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 39.4s | $0.006537 | `test_requests.py` |
| Improved | Submitted | 55.9s | $0.007312 | `test_requests.py` |

**Preprocessing:** Accepted specification after 1 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/instances/psf__requests-2931/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/instances/psf__requests-2931/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/instances/psf__requests-2931/generation-baseline/manifest.json).

Recorded runner summaries: `message 21: 1 failed, 167 deselected, 2 warnings in 0.43s`.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/instances/psf__requests-2931/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/instances/psf__requests-2931/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/instances/psf__requests-2931/generation-improved/manifest.json).

Recorded runner summaries: `message 22: 1 failed, 2 warnings in 0.28s`.

**Pair identity:** matched.

### 12. pylint-dev__pylint-6903

**Issue:** Running pylint in Kubernetes Pod with --jobs=0 fails

Both simulate restricted CPU availability and require a positive worker/CPU count. Baseline records one failing case; improved records two. The tests model the Kubernetes symptom rather than launching Kubernetes.

**Setup and provenance:** The primary batch prepared the environment and ran both methods.

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 77.8s | $0.015055 | `tests/lint/test_run.py` |
| Improved | Submitted | 72.7s | $0.010184 | `tests/lint/test_run.py` |

**Preprocessing:** Accepted specification after 1 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/instances/pylint-dev__pylint-6903/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/instances/pylint-dev__pylint-6903/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/instances/pylint-dev__pylint-6903/generation-baseline/manifest.json).

Recorded runner summaries: `message 23: 1 failed, 1 warning in 0.08s`; `message 25: 1 failed, 1 warning in 0.06s`.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/instances/pylint-dev__pylint-6903/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/instances/pylint-dev__pylint-6903/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/instances/pylint-dev__pylint-6903/generation-improved/manifest.json).

Recorded runner summaries: `message 15: 2 failed, 1 warning in 0.07s`.

**Pair identity:** matched.

### 13. mwaskom__seaborn-3187

**Issue:** Wrong legend values of large ranges

Baseline checks large-range legend labels in both plotting and utility coverage and records two failures: labels such as 2 or 1.6 do not represent the million-scale values. Improved submits a continuous-legend test with one failure. Improved preprocessing needed three extraction attempts before acceptance. Its trajectory also contains a history-inspection flag.

**Setup and provenance:** The primary batch prepared the environment and ran both methods.

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 206.6s | $0.043894 | `tests/_core/test_scales.py`, `tests/test_utils.py` |
| Improved | Submitted | 324.8s | $0.040890 | `tests/_core/test_plot.py` |

**Preprocessing:** Accepted specification after 3 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/instances/mwaskom__seaborn-3187/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/instances/mwaskom__seaborn-3187/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/instances/mwaskom__seaborn-3187/generation-baseline/manifest.json).

Recorded runner summaries: `message 61: 2 failed in 1.39s`.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/instances/mwaskom__seaborn-3187/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/instances/mwaskom__seaborn-3187/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/instances/mwaskom__seaborn-3187/generation-improved/manifest.json).

Recorded runner summaries: `message 59: 1 failed in 1.44s`; `message 61: 1 failed in 1.86s`; `message 67: 1 failed in 1.58s`.

Review flags: history_inspection_review. See the linked command-review record for exact commands.

**Pair identity:** matched.

### 14. django__django-13513

**Issue:** debug error view doesn't respect exc.__suppress_context__ (PEP 415)

Both add exception-context suppression checks in the debug reporter tests, but both saved generation runs finish with 24 tests passing. These runs do not demonstrate a failing regression on the supplied checkout. Baseline inspected Git history and a historical commit summary; this requires protocol review. The selected improved run is a historical retry; earlier attempts remain preserved.

**Setup and provenance:** A previously completed pair was retained; no new generation was launched for this pair in the batch.

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 58.1s | $0.006055 | `tests/view_tests/tests/test_debug.py` |
| Improved | Submitted | 71.0s | $0.004988 | `tests/view_tests/tests/test_debug.py` |

**Preprocessing:** Accepted specification after 1 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/django-13513-unit-baseline-20261112-205739/agent.traj.json), [submitted patch](runs/django-13513-unit-baseline-20261112-205739/submission.patch), [manifest](runs/django-13513-unit-baseline-20261112-205739/manifest.json).

Recorded runner summaries: `message 17: OK`; `message 23: OK`; `message 25: Ran 24 tests in 1.417s; OK`.

Review flags: historical_commit_inspection_review, history_inspection_review. See the linked command-review record for exact commands.

**Improved evidence:** [trajectory](runs/django-13513-unit-improved-20261112-205739-retry1/agent.traj.json), [submitted patch](runs/django-13513-unit-improved-20261112-205739-retry1/submission.patch), [manifest](runs/django-13513-unit-improved-20261112-205739-retry1/manifest.json).

Recorded runner summaries: `message 12: OK`; `message 20: OK`; `message 22: Ran 24 tests in 1.182s; OK`.

**Pair identity:** matched.

### 15. sphinx-doc__sphinx-8548

**Issue:** autodoc inherited-members won't work for inherited attributes (data members).

Both add inherited-attribute fixtures and autodoc checks. Final focused runs show the inherited attribute missing. Baseline records one failure with five passes in a focused group; improved records a focused failure and broader unrelated failures. Other exploratory runs pass, so the chronological evidence must be interpreted with the command used. Improved also encountered missing roman dependencies and has a history-inspection flag.

**Setup and provenance:** Generation followed infrastructure recovery and verification of the exact prescribed benchmark setup edits. Earlier setup failures and empty predictions remain preserved.

Initial setup record: `AssertionError`. [Preserved failure record](runs/assigned-pairs-20261113-002517/instances/sphinx-doc__sphinx-8548/setup-failure.json).

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 156.4s | $0.028940 | `tests/roots/test-ext-autodoc/target/inheritance.py`, `tests/test_ext_autodoc.py` |
| Improved | Submitted | 184.0s | $0.035901 | `tests/roots/test-ext-autodoc/target/inheritance.py`, `tests/test_ext_autodoc.py` |

**Preprocessing:** Accepted specification after 1 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8548/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8548/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8548/generation-baseline/manifest.json).

Recorded runner summaries: `message 55: 4 failed, 64 passed, 41 warnings in 8.06s`; `message 57: 2 failed, 6 warnings in 0.67s`; `message 61: 1 failed, 5 passed, 6 warnings in 0.89s`; `message 63: 6 passed, 6 warnings in 0.57s`.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8548/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8548/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8548/generation-improved/manifest.json).

Recorded runner summaries: `message 64: 1 failed, 6 warnings in 0.56s`; `message 66: 1 passed, 6 warnings in 0.38s`; `message 68: 2 failed, 66 passed, 41 warnings in 6.15s`; `message 70: 1 failed, 41 warnings in 0.57s`.

Review flags: history_inspection_review. See the linked command-review record for exact commands.

**Pair identity:** matched.

### 16. django__django-13344

**Issue:** Coroutine passed to the first middleware's process_response() instead of HttpResponse.

Both exercise async middleware process_response receiving a coroutine instead of HttpResponse. Baseline submits ASGI-suite coverage and records one failure among ten tests. Improved submits middleware-suite coverage and records one failure among 33 tests after exploratory fixtures and an incorrect test-target import attempt.

**Setup and provenance:** A previously completed pair was retained; no new generation was launched for this pair in the batch.

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 153.7s | $0.017650 | `tests/asgi/tests.py` |
| Improved | Submitted | 271.2s | $0.022968 | `tests/middleware_exceptions/middleware.py`, `tests/middleware_exceptions/tests.py` |

**Preprocessing:** Accepted specification after 2 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/django-13344-unit-baseline-20261112-151544/agent.traj.json), [submitted patch](runs/django-13344-unit-baseline-20261112-151544/submission.patch), [manifest](runs/django-13344-unit-baseline-20261112-151544/manifest.json).

Recorded runner summaries: `message 43: FAILED (failures=1)`; `message 45: FAILED (errors=1)`; `message 51: Ran 10 tests in 0.865s; FAILED (failures=1)`; `message 55: Ran 10 tests in 2.051s; FAILED (failures=1)`.

**Improved evidence:** [trajectory](runs/django-13344-unit-improved-20261112-151925/agent.traj.json), [submitted patch](runs/django-13344-unit-improved-20261112-151925/submission.patch), [manifest](runs/django-13344-unit-improved-20261112-151925/manifest.json).

Recorded runner summaries: `message 72: FAILED (failures=1)`; `message 76: Ran 33 tests in 0.412s; FAILED (failures=1)`; `message 82: FAILED (errors=1)`; `message 84: Ran 33 tests in 0.279s; FAILED (failures=1)`.

**Pair identity:** matched with evidence limitations. Recorded limitations: ["baseline: launch recorded a mutable tag; current resolution cannot prove historical image identity", "improved: launch recorded a mutable tag; current resolution cannot prove historical image identity"].

### 17. django__django-15098

**Issue:** Internationalisation didn't support language locale containing both script and region.

Both test locales containing script and region, such as en-latn-us. Baseline observes a 404 instead of 200 and a language-path lookup returning None during exploration. Improved submits both checks and observes two failures; its broader run also has an unrelated tests-module import error and 74 skips. Improved exhausted three preprocessing attempts and fell back to the raw report. Baseline has history-inspection flags.

**Setup and provenance:** The primary batch prepared the environment and ran both methods.

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 133.0s | $0.015513 | `tests/i18n/patterns/tests.py`, `tests/i18n/tests.py` |
| Improved | Submitted | 237.5s | $0.020098 | `tests/i18n/patterns/tests.py`, `tests/i18n/tests.py` |

**Preprocessing:** Validation exhausted after three extraction attempts; generation used the original report.

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/instances/django__django-15098/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/instances/django__django-15098/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/instances/django__django-15098/generation-baseline/manifest.json).

Recorded runner summaries: `message 45: Ran 2 tests in 0.033s; FAILED (failures=2)`; `message 49: Ran 38 tests in 0.086s; FAILED (failures=1)`; `message 50: Ran 13 tests in 0.012s; FAILED (failures=1)`; `message 52: OK`.

Review flags: history_inspection_review. See the linked command-review record for exact commands.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/instances/django__django-15098/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/instances/django__django-15098/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/instances/django__django-15098/generation-improved/manifest.json).

Recorded runner summaries: `message 30: Ran 37 tests in 0.091s; OK`; `message 55: Ran 2 tests in 0.030s; FAILED (failures=2)`; `message 57: Ran 216 tests in 0.626s; FAILED (failures=2, errors=1, skipped=74)`.

**Pair identity:** matched.

### 18. django__django-12155

**Issue:** docutils reports an error rendering view docstring when the first line is not empty

Both add docstring trimming/parsing tests for a first line containing text. Each records two failures caused by retained indentation. Improved additionally checks rendered output and observes a docutils System Message. Baseline focuses on nine utility tests; improved also runs the broader suite.

**Setup and provenance:** A previously completed pair was retained; no new generation was launched for this pair in the batch.

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 64.3s | $0.006123 | `tests/admin_docs/test_utils.py` |
| Improved | Submitted | 104.2s | $0.007281 | `tests/admin_docs/test_utils.py` |

**Preprocessing:** Accepted specification after 1 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/django-12155-unit-baseline-20261112-143526/agent.traj.json), [submitted patch](runs/django-12155-unit-baseline-20261112-143526/submission.patch), [manifest](runs/django-12155-unit-baseline-20261112-143526/manifest.json).

Recorded runner summaries: `message 15: Ran 57 tests in 1.351s; OK`; `message 31: Ran 9 tests in 0.079s; FAILED (failures=2)`.

**Improved evidence:** [trajectory](runs/django-12155-unit-improved-20261112-144127/agent.traj.json), [submitted patch](runs/django-12155-unit-improved-20261112-144127/submission.patch), [manifest](runs/django-12155-unit-improved-20261112-144127/manifest.json).

Recorded runner summaries: `message 13: Ran 57 tests in 1.554s; OK`; `message 27: Ran 59 tests in 1.346s; FAILED (failures=2)`; `message 31: Ran 9 tests in 0.080s; FAILED (failures=2)`.

**Pair identity:** matched with evidence limitations. Recorded limitations: ["baseline: launch recorded a mutable tag; current resolution cannot prove historical image identity", "improved: launch recorded a mutable tag; current resolution cannot prove historical image identity"].

### 19. sphinx-doc__sphinx-8638

**Issue:** Instance variables link to other variables of the same name in the project

Both add cross-reference tests for an instance variable whose name collides with another documented object. Final focused runs fail, with broader runs showing one failure and 34 passes. Exploration includes scratch fixtures, passing alternatives and temporary dependency stubs; improved has a history-inspection flag. Baseline also clones the issue-example repository during exploration. These details limit a clean source-only protocol claim.

**Setup and provenance:** Generation followed infrastructure recovery and verification of the exact prescribed benchmark setup edits. Earlier setup failures and empty predictions remain preserved.

Initial setup record: `AssertionError`. [Preserved failure record](runs/assigned-pairs-20261113-002517/instances/sphinx-doc__sphinx-8638/setup-failure.json).

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 184.2s | $0.040475 | `tests/roots/test-domain-py/index.rst`, `tests/roots/test-domain-py/instance_variable.rst`, `tests/test_domain_py.py` |
| Improved | Submitted | 296.0s | $0.060399 | `tests/roots/test-domain-py-variable/conf.py`, `tests/roots/test-domain-py-variable/index.rst`, `tests/test_domain_py.py` |

**Preprocessing:** Accepted specification after 1 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8638/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8638/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8638/generation-baseline/manifest.json).

Recorded runner summaries: `message 33: 1 passed, 154 warnings in 0.68s`; `message 57: 1 failed, 449 warnings in 0.82s`; `message 59: 1 failed, 449 warnings in 0.80s`; `message 63: 1 failed, 34 passed, 1722 warnings in 1.99s`.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8638/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8638/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8638/generation-improved/manifest.json).

Recorded runner summaries: `message 81: 1 failed, 155 warnings in 0.83s`; `message 83: 1 failed, 34 passed, 1405 warnings in 2.07s`; `message 85: 1 passed, 6 warnings in 0.08s`; `message 89: 1 failed, 155 warnings in 0.75s`.

Review flags: history_inspection_review. See the linked command-review record for exact commands.

**Pair identity:** matched.

### 20. django__django-15252

**Issue:** MigrationRecorder does not obey db_router allow_migrate rules

Baseline tests MigrationRecorder schema creation and applied/unapplied recording under a denying router; its final group has three failures among four tests. Improved tests the migrate command and observes that the migration table is created despite router denial, with one failure among 42 tests. Exploratory target/import and database errors are preserved.

**Setup and provenance:** The primary batch prepared the environment and ran both methods.

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 221.3s | $0.026755 | `tests/migrations/test_loader.py` |
| Improved | Submitted | 161.4s | $0.015702 | `tests/migrations/test_commands.py` |

**Preprocessing:** Accepted specification after 1 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/instances/django__django-15252/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/instances/django__django-15252/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/instances/django__django-15252/generation-baseline/manifest.json).

Recorded runner summaries: `message 59: Ran 4 tests in 0.010s; FAILED (failures=3)`; `message 61: Ran 4 tests in 0.008s; FAILED (errors=3)`; `message 63: FAILED (errors=3)`; `message 67: Ran 4 tests in 0.046s; FAILED (failures=3)`.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/instances/django__django-15252/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/instances/django__django-15252/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/instances/django__django-15252/generation-improved/manifest.json).

Recorded runner summaries: `message 33: OK`; `message 39: FAILED (failures=1)`; `message 43: Ran 42 tests in 1.228s; FAILED (failures=1)`; `message 53: Ran 42 tests in 0.996s; FAILED (failures=1)`.

**Pair identity:** matched.

### 21. django__django-16631

**Issue:** SECRET_KEY_FALLBACKS is not used for sessions

Both test authenticated-session recovery after secret-key rotation with SECRET_KEY_FALLBACKS. Each finds AnonymousUser instead of the expected user and records one failure. Improved falls back to the original report after three rejected preprocessing attempts. Baseline has a history-inspection flag.

**Setup and provenance:** The primary batch prepared the environment and ran both methods.

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 77.6s | $0.008372 | `tests/auth_tests/test_basic.py` |
| Improved | Submitted | 185.1s | $0.009763 | `tests/auth_tests/test_basic.py` |

**Preprocessing:** Validation exhausted after three extraction attempts; generation used the original report.

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/instances/django__django-16631/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/instances/django__django-16631/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/instances/django__django-16631/generation-baseline/manifest.json).

Recorded runner summaries: `message 28: Ran 4 tests in 0.069s; FAILED (failures=1)`; `message 30: Ran 14 tests in 0.144s; FAILED (failures=1)`.

Review flags: history_inspection_review. See the linked command-review record for exact commands.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/instances/django__django-16631/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/instances/django__django-16631/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/instances/django__django-16631/generation-improved/manifest.json).

Recorded runner summaries: `message 33: Ran 12 tests in 0.088s; OK`; `message 35: Ran 2 tests in 0.011s; OK`; `message 43: Ran 3 tests in 0.020s; FAILED (failures=1)`; `message 45: FAILED (failures=1)`.

**Pair identity:** matched.

### 22. sphinx-doc__sphinx-8551

**Issue:** :type: and :rtype: gives false ambiguous class lookup warnings

Both test Python-domain type-field cross-references with colliding class names. Baseline observes a link to mod.A where mod.submod.A is expected; the broader run has one failure and 32 passes. Improved observes an ambiguous-reference warning and records one failure with 32 passes; a later diagnostic run reports 33 passes and must be interpreted with its preceding command rather than treated as official fixed-version validation. Improved falls back after three preprocessing attempts.

**Setup and provenance:** Generation followed infrastructure recovery and verification of the exact prescribed benchmark setup edits. Earlier setup failures and empty predictions remain preserved.

Initial setup record: `AssertionError`. [Preserved failure record](runs/assigned-pairs-20261113-002517/instances/sphinx-doc__sphinx-8551/setup-failure.json).

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 177.7s | $0.031117 | `tests/test_domain_py.py` |
| Improved | Submitted | 206.3s | $0.024386 | `tests/roots/test-domain-py-field-types/conf.py`, `tests/roots/test-domain-py-field-types/index.rst`, `tests/test_domain_py.py` |

**Preprocessing:** Validation exhausted after three extraction attempts; generation used the original report.

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8551/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8551/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8551/generation-baseline/manifest.json).

Recorded runner summaries: `message 65: 1 failed, 30 warnings in 0.43s`; `message 69: 1 failed, 30 warnings in 0.59s`; `message 71: 1 passed, 30 warnings in 0.45s`; `message 75: 1 failed, 32 passed, 1269 warnings in 2.97s`.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8551/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8551/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8551/generation-improved/manifest.json).

Recorded runner summaries: `message 52: 1 failed, 149 warnings in 1.00s`; `message 54: 1 passed, 149 warnings in 0.67s`; `message 56: 1 failed, 32 passed, 1388 warnings in 2.93s`; `message 58: 33 passed, 1388 warnings in 5.27s`.

**Pair identity:** matched.

### 23. django__django-13810

**Issue:** MiddlewareNotUsed leaves undesired side effects when loading middleware in ASGI context

Both add async middleware coverage with MiddlewareNotUsed. Baseline records two errors among 34 tests; improved records one error among 33. Both errors are RuntimeError from AsyncToSync being used in a thread with an active event loop. Improved falls back to the original report after three preprocessing attempts.

**Setup and provenance:** The primary batch prepared the environment and ran both methods.

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 76.6s | $0.008023 | `tests/middleware_exceptions/tests.py` |
| Improved | Submitted | 101.4s | $0.004280 | `tests/middleware_exceptions/tests.py` |

**Preprocessing:** Validation exhausted after three extraction attempts; generation used the original report.

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/instances/django__django-13810/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/instances/django__django-13810/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/instances/django__django-13810/generation-baseline/manifest.json).

Recorded runner summaries: `message 20: FAILED (errors=1)`; `message 22: FAILED (errors=1)`; `message 26: FAILED (errors=1)`; `message 30: Ran 34 tests in 0.512s; FAILED (errors=2)`.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/instances/django__django-13810/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/instances/django__django-13810/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/instances/django__django-13810/generation-improved/manifest.json).

Recorded runner summaries: `message 15: Ran 32 tests in 0.249s; OK`; `message 19: Ran 33 tests in 0.279s; FAILED (errors=1)`.

**Pair identity:** matched.

### 24. sphinx-doc__sphinx-8721

**Issue:** viewcode creates pages for epub even if `viewcode_enable_epub=False` on `make html epub`

Both extend EPUB viewcode coverage across successive builds with viewcode_enable_epub disabled and find unwanted generated pages. Focused runs fail on an assertion that a page should not exist. Missing roman dependencies occur during setup/exploration; improved also runs a broader group with two failures and two passes.

**Setup and provenance:** Generation followed infrastructure recovery and verification of the exact prescribed benchmark setup edits. Earlier setup failures and empty predictions remain preserved.

Initial setup record: `AssertionError`. [Preserved failure record](runs/assigned-pairs-20261113-002517/instances/sphinx-doc__sphinx-8721/setup-failure.json).

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 105.2s | $0.019212 | `tests/test_ext_viewcode.py` |
| Improved | Submitted | 155.1s | $0.020944 | `tests/test_ext_viewcode.py` |

**Preprocessing:** Accepted specification after 1 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8721/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8721/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8721/generation-baseline/manifest.json).

Recorded runner summaries: `message 35: 1 failed, 2 passed, 117 warnings in 2.58s`; `message 45: 1 failed, 50 warnings in 2.46s`.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8721/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8721/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8721/generation-improved/manifest.json).

Recorded runner summaries: `message 39: 1 failed, 459 warnings in 2.67s`; `message 41: 1 failed in 1.47s`; `message 43: 2 failed, 2 passed in 10.85s`; `message 45: 1 failed in 1.72s`.

**Pair identity:** matched.

### 25. sphinx-doc__sphinx-8621

**Issue:** kbd role produces incorrect HTML when compound-key separators (-, + or ^) are used as keystrokes

Both extend keyboard-role markup coverage for separator characters used as keys. Baseline records six failures in its first expanded selection and later three failures under a temporary plugin; a modified temporary kbd_fix_plugin then yields nine passes. That plugin is an agent-authored diagnostic change, not an official reference fix or official evaluation. Improved records four failures in the keyboard selection and six failures with 31 passes in the full file, including two PEP-link failures. Both encountered missing roman dependencies. The exported patches contain tests, while diagnostic plugin results require separate interpretation.

**Setup and provenance:** Generation followed infrastructure recovery and verification of the exact prescribed benchmark setup edits. Earlier setup failures and empty predictions remain preserved.

Initial setup record: `AssertionError`. [Preserved failure record](runs/assigned-pairs-20261113-002517/instances/sphinx-doc__sphinx-8621/setup-failure.json).

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 109.9s | $0.020455 | `tests/test_markup.py` |
| Improved | Submitted | 148.5s | $0.025897 | `tests/test_markup.py` |

**Preprocessing:** Accepted specification after 1 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8621/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8621/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8621/generation-baseline/manifest.json).

Recorded runner summaries: `message 20: 3 passed, 30 deselected, 309 warnings in 0.99s`; `message 26: 6 failed, 3 passed, 30 deselected, 909 warnings in 1.03s`; `message 32: 3 failed, 6 passed, 30 deselected, 908 warnings in 0.83s`; `message 36: 9 passed, 30 deselected, 908 warnings in 0.63s`.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8621/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8621/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v3/instances/sphinx-doc__sphinx-8621/generation-improved/manifest.json).

Recorded runner summaries: `message 21: 3 passed, 30 deselected, 309 warnings in 0.73s`; `message 29: 4 failed, 3 passed, 30 deselected, 709 warnings in 0.90s`; `message 33: 6 failed, 31 passed, 3490 warnings in 2.05s`.

**Pair identity:** matched.

### 26. matplotlib__matplotlib-25311

**Issue:** [Bug]: Unable to pickle figure with draggable legend

Both test pickling figures with draggable legends and annotations while attaching an unpicklable object to the canvas. Baseline uses a helper object; improved uses threading.Lock. Both focused runs have two TypeError failures. Baseline also runs the whole file and records three failures with 182 passes, including an additional subprocess-pickling failure. Setup was recovered only after Docker restart, dependency installation, compilation, and coordinator recovery; baseline then improved ran once on the same immutable image.

**Setup and provenance:** Generation followed infrastructure recovery and verification of the exact prescribed benchmark setup edits. Earlier setup failures and empty predictions remain preserved.

Initial setup record: `RuntimeError`. [Preserved failure record](runs/assigned-pairs-20261113-002517/instances/matplotlib__matplotlib-25311/setup-failure.json).

| Method | Result | Time | Agent-only cost | Submitted files |
| --- | --- | ---: | ---: | --- |
| Baseline | Submitted | 127.8s | $0.014205 | `lib/matplotlib/tests/test_pickle.py` |
| Improved | Submitted | 103.0s | $0.009672 | `lib/matplotlib/tests/test_pickle.py` |

**Preprocessing:** Accepted specification after 1 extraction attempt(s).

**Baseline evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v6/instances/matplotlib__matplotlib-25311/generation-baseline/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v6/instances/matplotlib__matplotlib-25311/generation-baseline/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v6/instances/matplotlib__matplotlib-25311/generation-baseline/manifest.json).

Recorded runner summaries: `message 39: 2 failed, 183 deselected in 0.29s`; `message 49: 2 failed, 183 deselected in 0.27s`; `message 55: 3 failed, 182 passed in 2.62s`.

**Improved evidence:** [trajectory](runs/assigned-pairs-20261113-002517/completion-pass-v6/instances/matplotlib__matplotlib-25311/generation-improved/agent.traj.json), [submitted patch](runs/assigned-pairs-20261113-002517/completion-pass-v6/instances/matplotlib__matplotlib-25311/generation-improved/submission.patch), [manifest](runs/assigned-pairs-20261113-002517/completion-pass-v6/instances/matplotlib__matplotlib-25311/generation-improved/manifest.json).

Recorded runner summaries: `message 34: 2 failed, 183 deselected in 0.30s`.

**Pair identity:** matched.

## Infrastructure and interpretation

Initial image preparation included timeouts and an overly strict clean-checkout admission check. Recovery replayed prescribed setup edits and reused the unchanged recipes; it did not repair generated submissions. Matplotlib 25311 was the last recovery: Docker was initially unavailable, a sandboxed retry could not resolve a dependency host, and a server restart interrupted the coordinator while its build survived. The resumed coordinator reused the completed image. A final audit filename collision was resolved by writing a new audit, preserving the older file.

Temporary dependency shims, exploratory fixtures, agent-authored diagnostic changes, and history inspection must be considered when interpreting generation evidence. The command-flag heuristic does not catch every such action. The narratives highlight observed issues; this is not a complete automated compliance or test-quality certification. Official evaluation must consume the unchanged predictions and remain separate from generation.

## Source records

- [Final generation summary](runs/assigned-pairs-20261113-002517/completion-pass-v6/generation-summary.json)
- [Final pair identity audit](runs/assigned-pairs-20261113-002517/verification/pair-verification-final-v6.json)
- [Command-review flags](runs/assigned-pairs-20261113-002517/completion-pass-v6/generation-command-review-flags.json)
- [Export validation](runs/assigned-pairs-20261113-002517/completion-pass-v6/export-validation.json)
- [Historical generation attempts](runs/assigned-pairs-20261113-002517/completion-pass-v6/historical-generation-attempts.json)
- [Latest recovery notes](runs/assigned-pairs-20261113-002517/completion-pass-v6/RECOVERY_NOTES.md)
- [Baseline predictions](runs/assigned-pairs-20261113-002517/completion-pass-v6/baseline-predictions.jsonl)
- [Improved predictions](runs/assigned-pairs-20261113-002517/completion-pass-v6/improved-predictions.jsonl)
- [Per-instance structured evidence](runs/assigned-pairs-20261113-002517/completion-pass-v6/instance-report-evidence-20261113.json)
