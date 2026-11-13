#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD 6599608c4d0befdcb820ddccce55f183f247ae4f >> /root/pre_state.patch
sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
export LC_ALL=en_US.UTF-8
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff 6599608c4d0befdcb820ddccce55f183f247ae4f
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git apply -v - <<'EOF_114329324912'
diff --git a/tests/view_tests/tests/test_debug.py b/tests/view_tests/tests/test_debug.py
index 3cbeb2e03a..68aa0d71e1 100644
--- a/tests/view_tests/tests/test_debug.py
+++ b/tests/view_tests/tests/test_debug.py
@@ -467,6 +467,24 @@ class ExceptionReporterTests(SimpleTestCase):
         self.assertIn('<p>Request data not supplied</p>', html)
         self.assertNotIn('During handling of the above exception', html)
 
+    def test_suppressed_context_not_in_traceback_frames(self):
+        try:
+            try:
+                raise RuntimeError('Suppressed context')
+            except RuntimeError:
+                raise ValueError('Raised with suppressed context') from None
+        except ValueError:
+            exc_type, exc_value, tb = sys.exc_info()
+
+        reporter = ExceptionReporter(None, exc_type, exc_value, tb)
+        frames = reporter.get_traceback_frames()
+        self.assertEqual(len(frames), 1)
+        self.assertIsNone(frames[0]['exc_cause'])
+        self.assertIn(
+            "raise ValueError('Raised with suppressed context') from None",
+            frames[0]['context_line'],
+        )
+
     def test_reporting_of_nested_exceptions(self):
         request = self.rf.get('/test_view/')
         try:

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(django/views/debug\.py)' ./tests/runtests.py --verbosity 2 --settings=test_sqlite --parallel 1 view_tests.tests.test_debug
cat coverage.cover
git checkout 6599608c4d0befdcb820ddccce55f183f247ae4f
git apply /root/pre_state.patch
