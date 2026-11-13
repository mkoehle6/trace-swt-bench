# Setup audit: django__django-13513

The local image and evaluator setup match the pinned benchmark metadata. The
remaining discrepancy is between the issue text and the reference regression in
that pinned case. This is an evaluation-only finding, not a replacement generation
specification. It must not be supplied to a generator or used to repair submissions.

## Evidence

- The saved source.json and evaluation row agree on base commit
  6599608c4d0befdcb820ddccce55f183f247ae4f. The evaluation row exactly matches
  the instance in the Arrow cache for the recorded immutable dataset revision.
  Its problem_statement also matches the saved report.
- The original image setup script resets Django to that same base commit before
  installation. The immutable generation image has that HEAD, a clean checkout,
  and no Git replacement refs. Its working django/views/debug.py hashes to Git
  blob 7a89f7bd1563e8ce17b066e7c5df28a8e5c2dde1, matching HEAD's blob.
  There is no evidence of an accidentally applied reference patch in that file.
- The reported missing __suppress_context__ handling is already in the base helper.
  An existing suppression test is also present. Both generated tests assert this
  already implemented behavior.
- Evaluation-only reference evidence targets an innermost exception without a
  traceback. The reference change retains suppression handling and changes
  traceback traversal. The reference regression test fails before and passes
  after the fix in the saved official logs.
- Both methods' execution specifications use the correct base commit and unit-test
  target. Pre-fix applies only the unchanged prediction; post-fix applies the
  reference code patch, then the unchanged prediction. All four patch sequences
  match their expected inputs exactly. The states are not reversed.
- An existing template-reporting test fails in the unmodified base in both states,
  as well as in reference and prediction runs. It is separate from this discrepancy.

## Research disposition

Keep the official unsuccessful results for both methods: applicable patches,
zero added fail-to-pass tests, and no reproduction success. Flag this instance as
having an issue/reference-regression mismatch in the pinned snapshot. Do not
silently remove it from the assigned-set denominator or recategorize it as a
Docker failure. Any later sensitivity analysis excluding problematic cases needs
an explicit, consistently applied rule and should accompany the full-set result.

Preserve the baseline history-inspection protocol deviation separately. It is
not explained away by the metadata discrepancy. Do not claim the baseline run
complied fully with the no-history restriction.

No image rebuild, metadata correction, workflow modification, or prediction repair
is indicated by this audit. Continue remaining assigned instances from their saved
reports using the existing workflows, keeping this audit and all reference/evaluation
artifacts out of generation context. No next-instance generation was launched by
this audit.

## Preservation

setup-audit.json records the machine-readable checks. Existing raw evaluation
artifact hashes, workflow/input hashes, and original prediction hashes were verified
unchanged. All prior results and failed attempts remain preserved. No GitHub push
was performed.
