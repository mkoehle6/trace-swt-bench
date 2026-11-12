# Saved development runs

These are preserved development artifacts, including unsuccessful attempts.
No official SWT-Bench before/after evaluation results have been recorded here yet.

## Current matched unit-test pair

- Baseline: django-unit-baseline-20261111-212132
- Improved: django-unit-improved-20261111-211606

Both use the same unit-test profile hash, issue report, and image tag. Both submit
identical native test patches and their trajectories show one issue-relevant
failure among 165 tests on buggy Django. Exit status 1 was preserved. This is
candidate reproduction evidence, not official reproduction success.

## Earlier development records

- django-unit-baseline-20261111-210305: earlier unit-test profile; tail masked the
  test runner exit status as zero although output reported the intended failure.
- django-baseline-20261111-140849: original standalone-script baseline pilot.
- django-improved-20261111-141837: validated improved standalone-script pilot.
- django-improved-20261111-141243: missing extraction API key caused an incorrect
  validation-exhaustion fallback in the older controller. Treat as configuration
  failure with fallback, not semantic rejection. Missing-key handling was fixed.
- django-analysis-01 through django-analysis-04: early analysis attempts. Inspect
  available manifests and validation artifacts; some attempts are incomplete.

## Reading each run

Start with manifest.json, then agent_result.json and submission.patch when present.
agent.traj.json records model requests, commands, observations, and agent-only cost.
Candidate, validation, and review files explain improved-mode preprocessing.
Missing artifacts can indicate preparation-only runs or failures; do not infer
success from directory existence. Extraction dollar costs may be null; include
preprocessing usage when calculating total improved generation cost.

The runs/ folder remains ignored for future automatic staging. The existing JSON,
text, and patch files were explicitly reviewed and added as a fixed snapshot.
Review new artifacts for credentials before adding them. Never commit API keys,
.env files, virtual environments, or container filesystem exports.