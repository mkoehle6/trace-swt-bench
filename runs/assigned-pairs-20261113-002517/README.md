# Continuing assigned TRACE generation pairs

This batch covers the fixed 26-instance assignment. It preserves completed matched
unit-test generation pairs and attempts the remaining instances, running baseline
before improved for each new pair. Official evaluation is not part of this batch.

The existing controller, baseline configuration, shared unit-test profile, model
settings, revision bounds, and agent limits are unchanged. Inputs are the saved
issue reports and the buggy checkout. Image construction reads only allowlisted
repository/environment metadata from the pinned cache; it does not read reference
patches or evaluator results. Existing credentials are loaded without printing them.

Two independent image builders run at most concurrently, with a 600-second setup
limit per instance. Generation is sequential. Every ready image must pass a base
commit and clean-checkout verification. Both methods use the same immutable image
ID for their pair. Images and previous artifacts are preserved. Setup failures
are recorded separately with empty predictions, retaining every assigned instance
in each final prediction file.

Live status is in events.jsonl and per-instance console logs. The initial two setup
start events were emitted concurrently; the per-case metadata and timing records
are authoritative if a filesystem append race omits an event. plan.json fixes the
assignment and workflow hashes. execution-order.json lists the queue. Each case
gets an immutable outcome.json after processing. outcomes.json and the two combined
prediction JSONL files appear only after the batch finishes.

Generated submissions are exported unchanged; unsuccessful predictions are not
repaired or silently omitted. No GitHub push is performed. No evaluation/reference
artifacts are allowed in generation context. Setup time is separate from generation
time, and model submission does not establish official reproduction success.
