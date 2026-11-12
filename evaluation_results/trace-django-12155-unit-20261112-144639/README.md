# Hard-set pilot: Django 12155

Official SWT-Bench unit-test evaluation, November 12, 2026.

| Metric | Baseline | Improved |
| --- | ---: | ---: |
| Reproduction success | 0/1 (0%) | 0/1 (0%) |
| Patch applicability | 1/1 (100%) | 1/1 (100%) |
| coverage_pred | 0.5333333333 | 0.5333333333 |
| coverage_delta_pred | 0.4666666667 | 0.4666666667 |
| Instances with available coverage | 1 | 1 |
| Evaluation command wall time | 176 s | 77 s |
| Generation controller time | 64.26 s | 104.22 s |
| Agent-only generation cost | $0.006123252 | $0.007280718 |
| Harness infrastructure errors | 0 | 0 |

Preprocessing cost is additional for improved mode and has not been calculated.
The faster second evaluation benefits from cached work; it is not a method speedup.

## Case analysis

The issue reports admindoc rendering errors when a docstring starts with text on
the first line. The baseline added trimming and parsing assertions to
tests/admin_docs/test_utils.py. The improved method added a trimming check and a
rendering check through parse_rst, including absence of a docutils System Message.
Its specification was accepted on the first attempt without fallback.

Both predictions applied successfully. On buggy code, each ran nine targeted
tests with two relevant failures. The improved rendering assertion observed the
reported default-role/no-content-permitted symptom directly. This was meaningful
generation-time evidence, but did not establish fixed-version compatibility.

After the reference fix, BOTH test modules failed to import with:

```text
ImportError: cannot import name 'trim_docstring'
```

The generated additions are coupled to the internal helper in an existing test
module. The evaluator's fixed environment no longer provides that helper, so
neither prediction meets the official success criterion. This is an unsuccessful
prediction outcome, not an infrastructure exclusion. The stronger rendering check
did not translate into better official success.

Evaluator-only diagnosis must not be fed back into generation or repair of this
instance. Preserve the unchanged predictions. Future workflow ideas should be
developed without access to reference fixes or evaluator-only outcomes and tested
on an appropriate separate development set.

## Evidence and isolation

Each method directory contains the original official summary and instance report,
prediction before/after logs, console log, and command timing. Provenance records
dataset revision, shared profile, harness commit, and installed packages.
artifact_checksums.json records hashes of the copied source artifacts.

These are EVALUATION OUTPUTS. They are not allowed generation inputs. No reference
patches, gold test logs, or full evaluation dataset rows were copied. Official
reports include evaluator classifications and must stay in the evaluation area.

Coverage delta is the official coverage_delta_pred field, a unitless fraction over
executable changed reference-fix lines where execution counts increased over base
coverage. Overall aggregation is the arithmetic mean over instances with available
coverage (one here). Mean delta is 0.4666666667, or 46.67% on that metric's scale;
this is not whole-repository coverage. Successful-reproduction coverage delta is
N/A because neither method has a success on this instance. Do not replace N/A with 0.

The summary's completed_instances=0 counts previously saved reports reused during
reporting, not newly evaluated instances. resolved=false and error_instances=0 are
consistent with a completed evaluation of an unsuccessful generated prediction.

Generation sources: runs/django-12155-unit-baseline-20261112-143526 and
runs/django-12155-unit-improved-20261112-144127. Both use matching report/config/profile
hashes and the same recorded Docker image tag.

## Two-instance pilot status

Across Django 11163 (Easy) and Django 12155 (Hard), each method has one official
success out of two instances (50%) and two applicable patches (100%). There are
no success-outcome disagreements yet. These two development pilots do not estimate
performance over all 26 selected instances and do not meet the six-case requirement.
Both complete evaluation pairs and all unsuccessful attempts should remain visible.
