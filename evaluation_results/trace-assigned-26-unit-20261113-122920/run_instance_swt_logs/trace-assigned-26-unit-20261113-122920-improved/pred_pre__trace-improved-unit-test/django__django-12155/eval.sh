#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD e8fcdaad5c428878d0a5d6ba820d957013f75595 >> /root/pre_state.patch
sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
export LC_ALL=en_US.UTF-8
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff e8fcdaad5c428878d0a5d6ba820d957013f75595
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git apply -v - <<'EOF_114329324912'
diff --git a/tests/admin_docs/test_utils.py b/tests/admin_docs/test_utils.py
index 17ea912015..40b9956661 100644
--- a/tests/admin_docs/test_utils.py
+++ b/tests/admin_docs/test_utils.py
@@ -44,6 +44,30 @@ class TestUtils(AdminDocsSimpleTestCase):
         )
         self.assertEqual(trim_docstring_output, trimmed_docstring)
 
+    def test_trim_docstring_first_line_not_empty(self):
+        docstring = (
+            'This is a docstring.\n'
+            '\n'
+            '    This is the body.\n'
+        )
+        self.assertEqual(
+            trim_docstring(docstring),
+            'This is a docstring.\n\nThis is the body.',
+        )
+
+    def test_parse_docstring_first_line_not_empty(self):
+        docstring = (
+            'This is a view docstring.\n'
+            '\n'
+            '    This is the body.\n'
+        )
+        title, description, metadata = parse_docstring(docstring)
+        self.assertEqual(title, 'This is a view docstring.')
+        self.assertEqual(metadata, {})
+        description_output = parse_rst(description, 'view', 'view:admindocs')
+        self.assertNotIn('System Message', description_output)
+        self.assertHTMLEqual(description_output, '<p>This is the body.</p>\n')
+
     def test_parse_docstring(self):
         title, description, metadata = parse_docstring(self.docstring)
         docstring_title = (

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(django/contrib/admindocs/views\.py|django/contrib/admindocs/utils\.py)' ./tests/runtests.py --verbosity 2 --settings=test_sqlite --parallel 1 admin_docs.test_utils
cat coverage.cover
git checkout e8fcdaad5c428878d0a5d6ba820d957013f75595
git apply /root/pre_state.patch
