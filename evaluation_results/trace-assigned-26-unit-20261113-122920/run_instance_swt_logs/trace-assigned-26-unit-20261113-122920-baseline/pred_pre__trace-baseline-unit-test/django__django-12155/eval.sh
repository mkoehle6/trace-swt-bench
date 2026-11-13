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
index 17ea912015..1b167fb4d8 100644
--- a/tests/admin_docs/test_utils.py
+++ b/tests/admin_docs/test_utils.py
@@ -44,6 +44,31 @@ class TestUtils(AdminDocsSimpleTestCase):
         )
         self.assertEqual(trim_docstring_output, trimmed_docstring)
 
+    def test_trim_docstring_with_first_line_content(self):
+        docstring = (
+            'This is the first line.\n'
+            '    This is the second line.\n'
+            '        This is the third line.'
+        )
+        self.assertEqual(
+            trim_docstring(docstring),
+            'This is the first line.\n'
+            'This is the second line.\n'
+            '    This is the third line.',
+        )
+
+    def test_parse_docstring_with_first_line_content(self):
+        docstring = (
+            'Title\n'
+            '\n'
+            '    Description.\n'
+            '    More description.'
+        )
+        self.assertEqual(
+            parse_docstring(docstring),
+            ('Title', 'Description.\nMore description.', {}),
+        )
+
     def test_parse_docstring(self):
         title, description, metadata = parse_docstring(self.docstring)
         docstring_title = (

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(django/contrib/admindocs/views\.py|django/contrib/admindocs/utils\.py)' ./tests/runtests.py --verbosity 2 --settings=test_sqlite --parallel 1 admin_docs.test_utils
cat coverage.cover
git checkout e8fcdaad5c428878d0a5d6ba820d957013f75595
git apply /root/pre_state.patch
