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
diff --git a/django/utils/translation/trans_real.py b/django/utils/translation/trans_real.py
--- a/django/utils/translation/trans_real.py
+++ b/django/utils/translation/trans_real.py
@@ -43,7 +43,7 @@
     re.IGNORECASE
 )
 
-language_code_prefix_re = _lazy_re_compile(r'^/(\w+([@-]\w+)?)(/|$)')
+language_code_prefix_re = _lazy_re_compile(r'^/(\w+([@-]\w+){0,2})(/|$)')
 
 
 @receiver(setting_changed)

EOF_114329324912
git apply -v - <<'EOF_114329324912'
diff --git a/tests/i18n/patterns/tests.py b/tests/i18n/patterns/tests.py
index ebd2430428..3efce20be1 100644
--- a/tests/i18n/patterns/tests.py
+++ b/tests/i18n/patterns/tests.py
@@ -317,6 +317,19 @@ class URLResponseTests(URLTestCaseBase):
         self.assertEqual(response.headers['content-language'], 'en')
         self.assertEqual(response.context['LANGUAGE_CODE'], 'en')
 
+    @override_settings(
+        LANGUAGES=[
+            ('en-us', 'English'),
+            ('en-latn-us', 'Latin English'),
+            ('en-Latn-US', 'BCP 47 case format'),
+        ],
+    )
+    def test_en_latn_us_url(self):
+        response = self.client.get('/en-latn-us/account/register/')
+        self.assertEqual(response.status_code, 200)
+        self.assertEqual(response.headers['content-language'], 'en-latn-us')
+        self.assertEqual(response.context['LANGUAGE_CODE'], 'en-latn-us')
+
     def test_nl_url(self):
         response = self.client.get('/nl/profiel/registreren/')
         self.assertEqual(response.status_code, 200)
diff --git a/tests/i18n/tests.py b/tests/i18n/tests.py
index bb6ea15f85..49d131349f 100644
--- a/tests/i18n/tests.py
+++ b/tests/i18n/tests.py
@@ -1610,6 +1610,20 @@ class MiscTests(SimpleTestCase):
         self.assertEqual(g('/de-ch/'), 'de')
         self.assertIsNone(g('/de-simple-page/'))
 
+    @override_settings(
+        LANGUAGES=[
+            ('en-us', 'English'),
+            ('en-latn-us', 'Latin English'),
+            ('en-Latn-US', 'BCP 47 case format'),
+        ],
+    )
+    def test_get_language_from_path_with_script_and_region(self):
+        g = trans_real.get_language_from_path
+        self.assertEqual(g('/en-latn-us/'), 'en-latn-us')
+        self.assertEqual(g('/en-Latn-US/'), 'en-Latn-US')
+        self.assertEqual(g('/en-latn-us/account/register/'), 'en-latn-us')
+        self.assertEqual(g('/en-Latn-US/account/register/'), 'en-Latn-US')
+
     def test_get_language_from_path_null(self):
         g = trans_null.get_language_from_path
         self.assertIsNone(g('/pl/'))

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(django/utils/translation/trans_real\.py)' ./tests/runtests.py --verbosity 2 --settings=test_sqlite --parallel 1 i18n.patterns.tests i18n.tests
cat coverage.cover
git checkout 2c7846d992ca512d36a73f518205015c88ed088c
git apply /root/pre_state.patch
