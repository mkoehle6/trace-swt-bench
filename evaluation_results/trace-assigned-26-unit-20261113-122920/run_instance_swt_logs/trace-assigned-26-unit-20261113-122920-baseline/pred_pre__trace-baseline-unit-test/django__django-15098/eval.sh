#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD 2c7846d992ca512d36a73f518205015c88ed088c >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff 2c7846d992ca512d36a73f518205015c88ed088c
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git apply -v - <<'EOF_114329324912'
diff --git a/tests/i18n/patterns/tests.py b/tests/i18n/patterns/tests.py
index ebd2430428..cf2d48e1cc 100644
--- a/tests/i18n/patterns/tests.py
+++ b/tests/i18n/patterns/tests.py
@@ -323,6 +323,20 @@ class URLResponseTests(URLTestCaseBase):
         self.assertEqual(response.headers['content-language'], 'nl')
         self.assertEqual(response.context['LANGUAGE_CODE'], 'nl')
 
+    @override_settings(
+        LANGUAGES=[
+            ('nl', 'Dutch'),
+            ('en', 'English'),
+            ('en-latn-us', 'Latin English'),
+            ('pt-br', 'Brazilian Portuguese'),
+        ],
+    )
+    def test_en_latn_us_url(self):
+        response = self.client.get('/en-latn-us/account/register/')
+        self.assertEqual(response.status_code, 200)
+        self.assertEqual(response.headers['content-language'], 'en-latn-us')
+        self.assertEqual(response.context['LANGUAGE_CODE'], 'en-latn-us')
+
     def test_wrong_en_prefix(self):
         response = self.client.get('/en/profiel/registreren/')
         self.assertEqual(response.status_code, 404)
diff --git a/tests/i18n/tests.py b/tests/i18n/tests.py
index bb6ea15f85..336561d424 100644
--- a/tests/i18n/tests.py
+++ b/tests/i18n/tests.py
@@ -1593,6 +1593,7 @@ class MiscTests(SimpleTestCase):
     @override_settings(
         LANGUAGES=[
             ('en', 'English'),
+            ('en-latn-us', 'Latin English'),
             ('de', 'German'),
             ('de-at', 'Austrian German'),
             ('pl', 'Polish'),
@@ -1605,6 +1606,7 @@ class MiscTests(SimpleTestCase):
         self.assertIsNone(g('/xyz/'))
         self.assertEqual(g('/en/'), 'en')
         self.assertEqual(g('/en-gb/'), 'en')
+        self.assertEqual(g('/en-latn-us/'), 'en-latn-us')
         self.assertEqual(g('/de/'), 'de')
         self.assertEqual(g('/de-at/'), 'de-at')
         self.assertEqual(g('/de-ch/'), 'de')

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(django/utils/translation/trans_real\.py)' ./tests/runtests.py --verbosity 2 --settings=test_sqlite --parallel 1 i18n.patterns.tests i18n.tests
cat coverage.cover
git checkout 2c7846d992ca512d36a73f518205015c88ed088c
git apply /root/pre_state.patch
