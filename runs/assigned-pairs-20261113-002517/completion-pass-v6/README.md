# TRACE assigned generation: completed attempt ledger

| Outcome | Baseline | Improved |
| --- | ---: | ---: |
| Assigned instances | 26 | 26 |
| Submitted | 26 | 26 |
| Non-submission or operational generation error | 0 | 0 |
| Remaining setup errors | 0 | 0 |
| Empty predictions | 0 | 0 |
| Preprocessing fallbacks | N/A | 4 |
| Accepted specifications | N/A | 22 |

Both combined prediction files contain all 26 assigned IDs exactly once, in the fixed assignment order. Submissions are exported unchanged. Empty predictions retain unsuccessful or unstarted generation cases in the denominator. Submitted status is generation evidence; this full set has not been officially evaluated.

## Pair controls

Final identity audit counts: matched=23, matched_with_evidence_limitations=3.

Saved reports, preserved baseline configuration, shared unit-test profile, and controller/exporter hashes remain unchanged. Each available pair has matching saved report and effective configuration artifacts. Image references and their currently resolved IDs are recorded in the final audit.

Historical image limitation: django__django-11163, django__django-13344, django__django-12155 recorded mutable tags at launch. Those tags currently resolve to matching image IDs within each pair, but historical launch identity cannot be proved retrospectively.

## Preservation and infrastructure

The primary ledger, intermediate empty predictions, failures, fallbacks, setup logs, and all retry records remain intact. The first preparation pass used a 600-second setup limit. Setup retries used the identical recorded recipe, new directories, and a 1,800-second limit. An additional Matplotlib attempt reused the dependency environment successfully cached by its preceding attempt. Prescribed harness installation edits were verified by replaying the exact recorded commands on temporary HEAD-file copies; original images were not modified. No generated submission was repaired or retried based on evaluator feedback.

A coordinator handoff briefly overlapped image preparation. The redundant coordinator was stopped before it generated tests; its interrupted preparation and logs were preserved. Generation remained one pair at a time, baseline then improved. Raw timings include host/setup concurrency and are not a controlled method-speed comparison.

Known agent-only cost: baseline $0.379071900, improved $0.383181006. Preprocessing cost is additional; no complete dollar-cost claim is made.

## Artifacts

- [Baseline predictions](baseline-predictions.jsonl)
- [Improved predictions](improved-predictions.jsonl)
- [Generation summary](generation-summary.json)
- [Final pair identity audit](../verification/pair-verification-final-v6.json)
- [Export validation](export-validation.json)
- [Setup-attempt history](setup-attempt-history.json)
- [Historical generation attempts](historical-generation-attempts.json)
- [Generation-command review flags](generation-command-review-flags.json)

Command review flagged 6 runs for human inspection. These heuristic flags do not certify compliance or test quality, and do not alter predictions. Previously recorded protocol deviations remain applicable even when pair identity checks pass.

Evaluation-only dataset rows, reference patches, and evaluator outputs remain separate from this generation archive and were not supplied by the orchestration as generation inputs. Nothing was pushed to GitHub.
