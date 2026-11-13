# TRACE: Preliminary Research Report

Updated: November 13, 2026. Supersedes the November 11 single-instance pilot summary; the prior report is preserved in the generation archive.

## Research question and preliminary answer

**Does adding evidence-grounded bug-specification extraction and validation improve DeepSeek-Flash’s issue reproduction success rate compared with the baseline?**

The completed generation phase does **not yet establish a success-rate improvement**. Both methods submitted nonempty patches for all 26 assigned instances. Improved preprocessing accepted 22 specifications and fell back to the original report in four cases. Official evaluation of the complete selected set remains pending, so submission counts and generation-time failures must not be reported as reproduction success rates.

Generation evidence is mixed: many runs reach issue-relevant failures, but Django 13513’s generated tests pass on the supplied checkout, some broader runs include unrelated failures, and exploratory modifications complicate several Sphinx results. The two methods produce byte-identical patches on two instances. Neither patch similarity nor patch difference establishes a quality advantage.

## Method and assignment

- **Baseline:** the original issue report is passed directly to mini-SWE-agent with DeepSeek-Flash.
- **Improved:** DeepSeek extracts five behavioral fields with supporting quotations; Python validates structure and verbatim evidence; a separate DeepSeek call reviews semantic support. Accepted analysis accompanies the original report. Validation exhaustion falls back to that report and remains an improved-method outcome.

The fixed assignment contains 13 Easy and 13 Hard instances from SWE-bench Verified revision `c104f840cc67f8b6eec6f759ebc8b2693d585d4a`. These groups are assignment labels derived from historical benchmark outcomes, not measured TRACE outcomes. All 26 IDs appear exactly once in each final prediction file.

The workflows retain mini-SWE-agent 2.4.6, DeepSeek-Flash settings, 100-step/$0.50 agent limits, the original baseline configuration, shared native-unit-test instructions, and Bash pipefail. The native-test profile is a shared adaptation of the original standalone-script protocol. Recorded report and workflow hashes passed the final identity audit. No experimental workflow was changed during recovery or report preparation.

Completed historical pairs were retained. New pairs ran baseline then improved; setup recovery occurred before generation for affected instances. The selected ledger represents 52 runs, not a repeated-trials experiment. An immutable provider implementation version was not established.

## Generation results across all 26 instances

| Measure | Baseline | Improved |
| --- | ---: | ---: |
| Assigned instances | 26 | 26 |
| Submitted nonempty patches | 26 | 26 |
| Remaining setup failures | 0 | 0 |
| Selected non-submissions or operational generation errors | 0 | 0 |
| Accepted specifications | N/A | 22 |
| Raw-report fallbacks | N/A | 4 |
| Mean selected controller runtime | 93.45 s | 127.09 s |
| Total selected controller runtime | 2,429.70 s | 3,304.33 s |
| Known selected-run agent-only cost | $0.379071900 | $0.383181006 |
| Total generation cost including preprocessing and historical attempts | Not fully aggregated | Not fully aggregated |
| Official full-set reproduction success rate | N/A: pending | N/A: pending |
| Official full-set patch applicability | N/A: pending | N/A: pending |
| Official full-set coverage delta | N/A: pending | N/A: pending |
| Official full-set evaluation time | N/A: pending | N/A: pending |

Improved selected-run mean runtime is 33.64 seconds higher, approximately 36%. These descriptive controller times include preprocessing where applicable and exclude image setup. Host concurrency, cached environments, historical runs, and lack of repeated randomized trials prevent a controlled method-speed conclusion. Agent-only cost excludes preprocessing; historical unsuccessful attempts and infrastructure costs are also outside these selected-run sums.

Improved fallbacks occurred on `django__django-15098`, `django__django-16631`, `sphinx-doc__sphinx-8551`, and `django__django-13810`, each after three extraction attempts. They remain in the improved denominator and must not be excluded as failed preprocessing.

## Per-instance observations

Every row below has a submitted patch from each method. Counts and error descriptions are generation-time observations, not official fixed-version outcomes. Some instances generate several individual test cases. See the [26-instance report](TRACE_26_INSTANCE_REPORT_20261113.md) for method-specific counts, changed files, timings, costs, trajectory links, and review flags.

| Instance | What happened during generation |
| --- | --- |
| pydata__xarray-3677 | Both fail merging a DataArray through Dataset.merge with a missing items attribute; improved’s broader run has eight passes alongside the failure. |
| django__django-14089 | Both reversal tests raise TypeError because OrderedSet is not reversible. |
| django__django-11163 | Identical patches; both fail the empty-fields dictionary assertion, with one failure among 165 tests. |
| sympy__sympy-24539 | Both fail replacement-symbol assertions for PolyElement.as_expr; improved alters an existing symbol case while baseline adds coverage. |
| scikit-learn__scikit-learn-14894 | Both sparse SVR tests encounter ZeroDivisionError with empty support vectors. |
| sphinx-doc__sphinx-9711 | Both reject a newer multi-digit extension version incorrectly; improved adds a passing older-version rejection control. |
| astropy__astropy-14508 | Both HIERARCH float-format tests fail with a comment-truncation VerifyWarning. |
| pytest-dev__pytest-7432 | Baseline records two skip-location failures with --runxfail; improved records one combined-test failure. |
| pallets__flask-5014 | Both fail because an empty Blueprint name does not raise the expected ValueError. |
| matplotlib__matplotlib-13989 | Density-histogram range assertions fail: one baseline case and two improved cases. |
| psf__requests-2931 | Both binary-payload tests fail with UnicodeDecodeError from ASCII conversion. |
| pylint-dev__pylint-6903 | Restricted-CPU simulations fail positive-count assertions: one baseline case and two improved cases. |
| mwaskom__seaborn-3187 | Large-range legend-label checks fail in both methods; improved needs three extraction attempts before acceptance and has a history-inspection flag. |
| django__django-13513 | Both generated checks pass in 24-test runs, so no failing regression is demonstrated; baseline has history/commit-inspection flags. |
| sphinx-doc__sphinx-8548 | Both final focused tests fail for inherited attributes; exploratory passing runs, missing dependencies, and broader unrelated failures require care. Improved has a history flag. |
| django__django-13344 | Both expose a coroutine reaching process_response instead of HttpResponse, using different native suites. |
| django__django-15098 | Locale-with-script-and-region checks fail; improved falls back and its broader run also has an import error. Baseline has history flags. |
| django__django-12155 | Both record two docstring indentation/parsing failures; improved also observes a docutils rendering error. |
| sphinx-doc__sphinx-8638 | Both final cross-reference tests fail; scratch fixtures and dependency stubs complicate evidence. Improved has a history flag; baseline clones issue examples. |
| django__django-15252 | Baseline recorder-router checks have three failures; improved migrate-command coverage has one failure because a forbidden migration table is created. |
| django__django-16631 | Both return AnonymousUser after secret-key rotation instead of the expected user. Improved falls back; baseline has a history flag. |
| sphinx-doc__sphinx-8551 | Both expose incorrect or ambiguous class links. Improved falls back; its later passing diagnostic is not official fixed-version validation. |
| django__django-13810 | Both hit AsyncToSync RuntimeError in MiddlewareNotUsed scenarios; baseline has two errors and improved one. Improved falls back. |
| sphinx-doc__sphinx-8721 | Both find unwanted EPUB viewcode pages after successive builds; missing roman dependencies appear during exploration. |
| sphinx-doc__sphinx-8621 | Keyboard markup cases fail in both methods. Baseline later obtains nine passes using an agent-authored temporary fix plugin; this is a diagnostic deviation, not official evaluation. |
| matplotlib__matplotlib-25311 | Both legend/annotation pickle tests fail with TypeError. The final setup recovery completed after Docker and coordinator interruptions; baseline’s broader run adds another failure. |

## Infrastructure, provenance, and protocol limitations

All original results, failures, intermediate empty predictions, and retry logs were retained. Initial setup failures included timeouts and a clean-checkout admission check that rejected prescribed benchmark installation edits. Recovery used the unchanged recipes and verified those edits before generation. No selected submission was repaired based on evaluator feedback.

Matplotlib 25311 was the last unfinished environment. Docker Desktop was initially unreachable. A sandboxed retry then failed on dependency-host resolution. An approved retry built the image; a server restart interrupted its coordinator while the build survived. A resumed coordinator reused the completed image and ran baseline then improved on the same immutable image. The final audit initially encountered an existing output filename and succeeded under a new filename.

The final pair audit reports 23 matched pairs and three matched pairs with evidence limitations: Django 11163, 13344, and 12155 used mutable image tags at historical launch. Current tag resolution is consistent within those pairs, but historical immutable image identity cannot be established retrospectively.

A heuristic command audit flags six runs and eight commands: baseline Django 13513, 15098, and 16631; improved Seaborn 3187, Sphinx 8548, and Sphinx 8638. The flagged commands inspect repository history or a historical commit summary. Flags require human review and are not a complete contamination determination. The baseline Sphinx 8621 diagnostic fix plugin and other temporary stubs illustrate actions the history heuristic does not capture. Unchanged test-only exports alone do not establish that generation followed every protocol constraint.

Generation orchestration kept evaluator-only data and reference patches separate from its inputs. That orchestration boundary must not be presented as proof that every agent action was compliant. No evaluation outputs or official reference fixes were fed back to regenerate or repair these selected predictions. No GitHub push was performed.

## Interpretation and threats to validity

- **Outcome validity:** Submitted status, an assertion failure, and official reproduction success are distinct. Some runs pass, and some failures are dependency, collection, or unrelated-suite failures.
- **Preprocessing validity:** Same-model semantic review can repeat extraction mistakes. Acceptance does not independently establish correctness; four fallbacks remain improved outcomes.
- **Protocol deviations:** History inspection, temporary diagnostic changes, dependency stubs, and changes to existing test cases require explicit review before strong method claims.
- **Experimental control:** One selected run per method per instance, reused historical pairs, host concurrency, and cached environments limit timing and causal interpretation.
- **Reproducibility:** Three historical image identities have limitations; provider model names do not establish an immutable model implementation.
- **Incomplete cost and evaluation:** Preprocessing dollars, historical-attempt totals, official coverage, and complete-set evaluation time remain unaggregated or unavailable.

The full-set generation report covers 26 distinct cases. It does not yet satisfy the final requirement to analyze two official successes, two unsuccessful cases, and two method disagreements: those outcome categories require official evaluation. Generation-time case descriptions must not be substituted for that selection.

## Next steps

1. Evaluate both unchanged 26-row prediction files with the official SWT-Bench unit-test harness and consistent dataset/settings. Preserve outputs in new directories and keep them isolated from generation.
2. Record applicability, official success counts over all 26 assigned instances, exact coverage fields/units and availability counts, and evaluation time. Infrastructure failures must remain visible; retry unchanged predictions after infrastructure recovery.
3. Review the six flagged runs and other observed diagnostic deviations. Report sensitivity analyses transparently while retaining the complete assigned-set denominator; do not silently discard difficult cases.
4. Aggregate preprocessing usage/cost, selected generation cost, historical failed-attempt cost, and setup/evaluation overhead separately. Treat unavailable coverage or cost as N/A rather than zero.
5. After official outcomes exist, sort IDs and select two successes, two unsuccessful cases, and two method disagreements; deduplicate and fill to six distinct cases using remaining failures then other cases in ID order. Report category shortfalls.

A future quality checker could inspect issue relevance, assertions, and execution failures consistently across both methods, initially without automatic repair. This remains proposed measurement work, not part of the current experiment.

## Evidence

- [Detailed report for all 26 instances](TRACE_26_INSTANCE_REPORT_20261113.md)
- [Final generation summary](runs/assigned-pairs-20261113-002517/completion-pass-v6/generation-summary.json)
- [Final pair identity audit](runs/assigned-pairs-20261113-002517/verification/pair-verification-final-v6.json)
- [Per-instance structured generation evidence](runs/assigned-pairs-20261113-002517/completion-pass-v6/instance-report-evidence-20261113.json)
- [Command-review flags](runs/assigned-pairs-20261113-002517/completion-pass-v6/generation-command-review-flags.json)
- [Export validation](runs/assigned-pairs-20261113-002517/completion-pass-v6/export-validation.json)
- [Historical generation attempts](runs/assigned-pairs-20261113-002517/completion-pass-v6/historical-generation-attempts.json)
- [Baseline predictions](runs/assigned-pairs-20261113-002517/completion-pass-v6/baseline-predictions.jsonl)
- [Improved predictions](runs/assigned-pairs-20261113-002517/completion-pass-v6/improved-predictions.jsonl)
- [Preserved November 11 preliminary report](runs/assigned-pairs-20261113-002517/completion-pass-v6/TRACE_PRELIMINARY_REPORT_before_20261113.md)
