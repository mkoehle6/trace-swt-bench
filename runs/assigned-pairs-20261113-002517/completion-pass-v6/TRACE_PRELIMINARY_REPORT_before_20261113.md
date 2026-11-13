# TRACE: Preliminary Research Report

Date: November 11, 2026

## Research question and preliminary answer

**Does adding evidence-grounded bug-specification extraction and validation improve
DeepSeek-Flash's issue reproduction success rate compared with the baseline?**

The current pilot does **not demonstrate an improvement**. On one Django instance,
both methods generated identical unit-test patches and exhibited the same
issue-relevant failure on buggy code. The improved workflow added runtime and
preprocessing calls. Official reproduction success remains unknown because
before/after evaluation has not yet been completed. This is an inconclusive
development pilot, not evidence that the workflow cannot help on harder issues.

## Method

We compared two methods on `django__django-11163`:

- **Baseline:** original issue report passed directly to mini-SWE-agent with DeepSeek-Flash.
- **Improved:** DeepSeek extracted five behavioral fields with supporting quotations;
  Python checked structure and verbatim evidence; a second DeepSeek call reviewed
  semantic support before the accepted specification accompanied the original report.

The proposed benefit is to make triggering conditions and expected behavior explicit
while filtering unsupported assumptions before test generation.

Both runs used mini-SWE-agent 2.4.6, the same report, Docker image tag, model
configuration, 100-step/$0.50 agent limits, and shared unit-test profile hash. The
profile adapts the preserved standalone-script baseline instructions to native
unit-test output and enables Bash pipefail for both methods. It is therefore an
adapted unit-test baseline, not an exact replay of the original script protocol.
Both agent and preprocessing responses identified the model as `deepseek-flash`;
an immutable provider implementation version was not established.

The dataset snapshot is SWE-bench Verified revision
`c104f840cc67f8b6eec6f759ebc8b2693d585d4a`, with 13 Easy and 13 Hard instances.
Only one distinct instance has been reviewed in this report. The case was selected
as the first end-to-end development smoke test, not as a representative sample.

## Django case: issue, test, and behavior

The issue states that `model_to_dict(instance, fields=[])` should return `{}`, but
instead returns model fields. Both submissions added the same method to the
existing `ModelToDictTests` class in `tests/model_forms/tests.py`:

```python
def test_empty_fields(self):
    item = ColourfulItem.objects.create()
    self.assertEqual(model_to_dict(item, fields=[]), {})
```

Both generation trajectories show Django running 165 tests. Exactly one failed:
the new test reached its assertion and received
`{'id': 1, 'name': '', 'colours': []}` instead of `{}`. The recorded command returned
exit status 1. This supports an issue-relevant failure rather than a syntax,
import, fixture, or database-setup failure in the observed executions. Existing
tests in that executed suite passed.

The assertion meaningfully represents the issue because it checks the requested
empty-field behavior using an existing model and native test framework. Neither
submitted patch changes production code. Behavior after the reference fix has not
been measured, so neither candidate is yet an officially successful reproduction.

## Observed results

| Measure | Baseline | Improved |
| --- | ---: | ---: |
| Distinct pilot instances | 1 | 1 |
| Submitted native unit-test patch | Yes | Yes |
| Buggy execution | 1 intended failure / 165 tests | 1 intended failure / 165 tests |
| Specification acceptance | Not applicable | First attempt; no fallback |
| Agent API calls | 10 | 9 |
| Additional preprocessing calls | 0 | 2 |
| Controller runtime | 28.57 s | 41.27 s |
| Agent-only cost, trajectory estimate | $0.003609696 | $0.003834948 |
| Preprocessing usage | None | 2,717 tokens |
| Total generation dollar cost | $0.003609696, recorded estimate | N/A: preprocessing cost not calculated |
| Official reproduction success rate | N/A: not evaluated | N/A: not evaluated |
| Official patch applicability | N/A: not evaluated | N/A: not evaluated |
| Coverage delta | N/A: no harness results | N/A: no harness results |
| Evaluation time | N/A: evaluation not run | N/A: evaluation not run |

The improved run took 12.70 seconds longer, approximately 44% in this single pair.
Its nine generation calls plus two preprocessing calls total eleven model calls,
compared with ten for baseline. The agent-only cost excludes preprocessing and
must not be reported as the improved method's total. No repeated-run average or
statistical conclusion is justified by these observations.

Identical submitted patches indicate no observed test-content benefit on this
instance. The original issue already describes the trigger, expected result, and
suggested correction clearly, which may leave little benefit for extraction.

## Limitations and threats to validity

- **One easy instance:** the pilot cannot establish a success-rate effect across
  the assigned set, particularly the Hard instances.
- **Correlated review errors:** DeepSeek performs both extraction and semantic
  review. A real supporting quotation does not guarantee logical correctness.
- **Uncontrolled variability:** there is one run per method; sampling, provider
  caching, and timing variation may influence cost and runtime.
- **Evaluation incomplete:** generation-time failure is a candidate reproduction,
  not proof of passing after the reference fix or satisfying the harness criterion.
- **Protocol identity:** matching image tags and model names are recorded, but
  immutable image/provider identities should also be captured for reproducibility.

Six distinct cases cannot yet be analyzed: only one evaluation candidate has been
reviewed and no official evaluated successes, failures, or disagreements are
available. This report does not satisfy the final six-case analysis requirement.

## Next steps and future improvement

Export the matched predictions and evaluate both using official SWT-Bench
unit-test mode. Keep reference fixes, reference tests, and evaluator-only results
isolated from generation. Then evaluate both methods on the full assigned set,
keeping missing predictions and generation failures in the denominator. Record
infrastructure failures separately and retry unchanged predictions after recovery.

Report official success counts over all assigned instances, patch applicability,
the exact coverage-delta field/units/aggregation and availability count, total
generation cost, average generation time, and evaluation time. Treat unavailable
coverage as N/A, not zero.

For the final case study, sort IDs and select two successes, two unsuccessful
cases, and two method disagreements; deduplicate and fill to six distinct cases
using remaining failures then other available cases in ID order. Report category
shortfalls and any diagnostic exceptions explicitly.

A future improvement is a diagnostic quality checker applied consistently to both
methods: inspect assertions and classify execution failures using the issue and
traceback. Begin without automatic repair so this remains a measurement step.
Human review on a development sample would help assess semantic correctness
independently of DeepSeek's own reviewer.

## Evidence

Matched run directories, relative to the project root:

- `runs/django-unit-baseline-20261111-212132/`
- `runs/django-unit-improved-20261111-211606/`

Evidence comes from their `manifest.json`, `submission.patch`, `agent.traj.json`,
and the improved run's preprocessing metrics. Baseline test output is at zero-based
trajectory message 15; improved test output is at message 13. The submitted patches
were previously verified as byte-for-byte identical. Earlier standalone-script
runs and the missing-key fallback run remain development records and are not
substituted for this matched pair.
