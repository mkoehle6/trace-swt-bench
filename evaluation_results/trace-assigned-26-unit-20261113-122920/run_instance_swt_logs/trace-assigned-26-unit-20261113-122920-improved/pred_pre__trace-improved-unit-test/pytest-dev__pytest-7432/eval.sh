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
diff --git a/testing/test_skipping.py b/testing/test_skipping.py
index 0b1c0b49b..c0a48a800 100644
--- a/testing/test_skipping.py
+++ b/testing/test_skipping.py
@@ -649,6 +649,29 @@ class TestSkip:
         result.stdout.fnmatch_lines(["*unconditional skip*", "*1 skipped*"])
 
 
+def test_skip_report_location_with_runxfail(testdir):
+    testdir.makepyfile(
+        test_foo="""
+        import pytest
+        @pytest.mark.skip
+        def test_skip():
+            assert 0
+        @pytest.mark.skipif(True, reason="condition is true")
+        def test_skipif():
+            assert 0
+        """
+    )
+    result = testdir.runpytest("-rs", "--runxfail")
+    result.stdout.fnmatch_lines(
+        [
+            "SKIPPED [[]1[]] test_foo.py:2: unconditional skip",
+            "SKIPPED [[]1[]] test_foo.py:5: condition is true",
+            "*2 skipped*",
+        ]
+    )
+    assert result.ret == 0
+
+
 class TestSkipif:
     def test_skipif_conditional(self, testdir):
         item = testdir.getitem(

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(src/_pytest/skipping\.py)' -m pytest -rA testing/test_skipping.py
cat coverage.cover
git checkout e6e300e729dd33956e5448d8be9a0b1540b4e53a
git apply /root/pre_state.patch
