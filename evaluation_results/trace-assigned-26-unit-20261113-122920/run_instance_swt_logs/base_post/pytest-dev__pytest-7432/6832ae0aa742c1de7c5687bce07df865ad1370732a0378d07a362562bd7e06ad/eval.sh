#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD e6e300e729dd33956e5448d8be9a0b1540b4e53a >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff e6e300e729dd33956e5448d8be9a0b1540b4e53a
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git apply -v - <<'EOF_114329324912'
diff --git a/src/_pytest/skipping.py b/src/_pytest/skipping.py
--- a/src/_pytest/skipping.py
+++ b/src/_pytest/skipping.py
@@ -291,7 +291,8 @@ def pytest_runtest_makereport(item: Item, call: CallInfo[None]):
             else:
                 rep.outcome = "passed"
                 rep.wasxfail = xfailed.reason
-    elif (
+
+    if (
         item._store.get(skipped_by_mark_key, True)
         and rep.skipped
         and type(rep.longrepr) is tuple

EOF_114329324912
git apply -v - <<'EOF_114329324912'
None
EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(src/_pytest/skipping\.py)' -m pytest -rA testing/test_skipping.py
cat coverage.cover
git checkout e6e300e729dd33956e5448d8be9a0b1540b4e53a
git apply /root/pre_state.patch
