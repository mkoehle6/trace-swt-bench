# Official TRACE evaluation: 26 assigned instances

Evaluation-only evidence. Predictions were copied unchanged; generation workflows were not modified. Missing reports are infrastructure/reporting gaps, not confirmed unsuccessful reproductions. All rates retain the 26-instance assignment denominator.

| Method | Reports | Applicable | Resolved | Missing reports | Coverage delta mean (available count) | Time |
| --- | ---: | ---: | ---: | ---: | --- | ---: |
| baseline | 26/26 | 26/26 | 16/26 | 0 | 0.567364 (25) | 3425.92s |
| improved | 26/26 | 26/26 | 17/26 | 0 | 0.602731 (25) | 1549.86s |

coverage_delta_pred is the harness fraction of executable reference-fix changed lines whose execution counts increase relative to base. It is not whole-repository coverage, and unavailable values are not zero. Coverage above averages available reports, independently of reproduction success. Full fields and success-conditioned coverage are in summary.json. Improved runs after baseline and can reuse comparison caches; timing differences are not experimental speedups.

| Instance | Baseline | Improved | Coverage delta B / I |
| --- | --- | --- | --- |
| pydata__xarray-3677 | Resolved | Resolved | 1.000000 / 1.000000 |
| django__django-14089 | Resolved | Resolved | 0.500000 / 0.500000 |
| django__django-11163 | Resolved | Resolved | 0.500000 / 1.000000 |
| sympy__sympy-24539 | Resolved | Resolved | 0.285714 / 0.000000 |
| scikit-learn__scikit-learn-14894 | Resolved | Resolved | 0.416667 / 0.416667 |
| sphinx-doc__sphinx-9711 | Resolved | Resolved | 0.583333 / 0.583333 |
| astropy__astropy-14508 | Resolved | Resolved | 0.785714 / 0.785714 |
| pytest-dev__pytest-7432 | Unresolved | Resolved | 1.000000 / 1.000000 |
| pallets__flask-5014 | Resolved | Resolved | 1.000000 / 1.000000 |
| matplotlib__matplotlib-13989 | Resolved | Resolved | 0.500000 / 1.000000 |
| psf__requests-2931 | Resolved | Resolved | 0.750000 / 0.750000 |
| pylint-dev__pylint-6903 | Resolved | Resolved | 1.000000 / 1.000000 |
| mwaskom__seaborn-3187 | Resolved | Resolved | 1.000000 / 0.666667 |
| django__django-13513 | Unresolved | Unresolved | 0.647059 / 0.647059 |
| sphinx-doc__sphinx-8548 | Unresolved | Unresolved | 0.000000 / 0.000000 |
| django__django-13344 | Resolved | Unresolved | 0.096774 / 0.000000 |
| django__django-15098 | Unresolved | Resolved | 0.000000 / 0.000000 |
| django__django-12155 | Unresolved | Unresolved | 0.466667 / 0.466667 |
| sphinx-doc__sphinx-8638 | Unresolved | Unresolved | 1.000000 / 1.000000 |
| django__django-15252 | Unresolved | Unresolved | 0.000000 / 0.600000 |
| django__django-16631 | Resolved | Resolved | 0.652174 / 0.652174 |
| sphinx-doc__sphinx-8551 | Unresolved | Unresolved | 0.000000 / 0.000000 |
| django__django-13810 | Resolved | Resolved | 1.000000 / 1.000000 |
| sphinx-doc__sphinx-8721 | Unresolved | Unresolved | N/A / N/A |
| sphinx-doc__sphinx-8621 | Unresolved | Unresolved | 0.000000 / 0.000000 |
| matplotlib__matplotlib-25311 | Resolved | Resolved | 1.000000 / 1.000000 |

Method disagreements: pytest-dev__pytest-7432, django__django-13344, django__django-15098.

[Machine-readable summary](summary.json) · [Input provenance and checksums](provenance.json) · [Workflow/prediction post-checks](execution-complete.json)

Generation-stage history-inspection flags and diagnostic deviations remain applicable; evaluation scores do not certify protocol compliance. No evaluation result was fed back to a generator or used to repair a prediction.
