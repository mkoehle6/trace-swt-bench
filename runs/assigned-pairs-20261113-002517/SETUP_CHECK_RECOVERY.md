# Recovery of the clean-checkout admission error

The standard SWT-Bench Sphinx setup intentionally modifies setup.py and tox.ini
to pin dependencies and adjust native test reporting. The batch's extra clean
checkout assertion rejected this expected harness state before generation. This
is an overly strict infrastructure check, not evidence of a wrong base commit.

The original rejected attempts, empty predictions, setup errors, and images remain
preserved. verify_setup_delta.py replays only the exact recorded sed commands on
temporary copies of HEAD files in a disposable container, then compares those
bytes with the original image. It accepts only matching HEAD, exact prescribed
changes, no changes to other tracked files, and no untracked files. It never
changes the original checkout, dependencies, or image and reads no reference fixes.

The Sphinx 9711 check passed this stricter comparison: only the two prescribed
files differ and both match the replay byte for byte. A recovery generation pass
will use the same unchanged benchmark image and original saved report for both
methods. The experimental controller, baseline config, profile, prompts, model,
revision policy, and agent limits are unchanged. No generated submission is repaired
or retried because of its output; recovery applies only to rejected setup checks
where generation had not started.

The primary batch continues independently. Recovery results and combined predictions
will be written to new files; primary outcomes and empty predictions will not be
replaced. Genuine build errors and timeouts remain visible separately.
