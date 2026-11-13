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
diff --git a/testing/test_skipping.py b/testing/test_skipping.py
index 0b1c0b49b..cad8e90cd 100644
--- a/testing/test_skipping.py
+++ b/testing/test_skipping.py
@@ -648,6 +648,21 @@ class TestSkip:
         result = testdir.runpytest("-rs")
         result.stdout.fnmatch_lines(["*unconditional skip*", "*1 skipped*"])
 
+    def test_skip_location_with_runxfail(self, testdir):
+        testdir.makepyfile(
+            test_skip_location="""
+            import pytest
+            @pytest.mark.skip
+            def test_that():
+                assert 0
+        """
+        )
+        result = testdir.runpytest("--runxfail", "-rs")
+        result.stdout.fnmatch_lines(
+            ["SKIPPED [[]1[]] test_skip_location.py:3: unconditional skip"]
+        )
+        assert result.ret == 0
+
 
 class TestSkipif:
     def test_skipif_conditional(self, testdir):
@@ -690,6 +705,21 @@ class TestSkipif:
         )
         pytest.raises(pytest.skip.Exception, lambda: pytest_runtest_setup(item))
 
+    def test_skipif_location_with_runxfail(self, testdir):
+        testdir.makepyfile(
+            test_skipif_location="""
+            import pytest
+            @pytest.mark.skipif(True, reason="skipif reason")
+            def test_that():
+                assert 0
+        """
+        )
+        result = testdir.runpytest("--runxfail", "-rs")
+        result.stdout.fnmatch_lines(
+            ["SKIPPED [[]1[]] test_skipif_location.py:3: skipif reason"]
+        )
+        assert result.ret == 0
+
     @pytest.mark.parametrize(
         "marker, msg1, msg2",
         [("skipif", "SKIP", "skipped"), ("xfail", "XPASS", "xpassed")],

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(src/_pytest/skipping\.py)' -m pytest -rA testing/test_skipping.py
cat coverage.cover
git checkout e6e300e729dd33956e5448d8be9a0b1540b4e53a
git apply /root/pre_state.patch
