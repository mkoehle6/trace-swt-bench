#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD 21698c14461d27933864d73e6fba568a154e83b3 >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff 21698c14461d27933864d73e6fba568a154e83b3
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .[test]
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_markup.py b/tests/test_markup.py
index a2bcb2dc1..25a6a2636 100644
--- a/tests/test_markup.py
+++ b/tests/test_markup.py
@@ -266,6 +266,27 @@ def get_verifier(verify, verify_re):
          '</kbd></p>'),
         '\\sphinxkeyboard{\\sphinxupquote{M\\sphinxhyphen{}x  M\\sphinxhyphen{}s}}',
     ),
+    (
+        # kbd role: separator used as a single keystroke
+        'verify',
+        ':kbd:`-`',
+        '<p><kbd class="kbd docutils literal notranslate">-</kbd></p>',
+        None,
+    ),
+    (
+        # kbd role: separator used as a single keystroke
+        'verify',
+        ':kbd:`+`',
+        '<p><kbd class="kbd docutils literal notranslate">+</kbd></p>',
+        None,
+    ),
+    (
+        # kbd role: separator used as a single keystroke
+        'verify',
+        ':kbd:`^`',
+        '<p><kbd class="kbd docutils literal notranslate">^</kbd></p>',
+        None,
+    ),
     (
         # non-interpolation of dashes in option role
         'verify_re',
@@ -348,6 +369,20 @@ def test_inline(get_verifier, type, rst, html_expected, latex_expected):
     verifier(rst, html_expected, latex_expected)
 
 
+def test_kbd_compound_key_with_separator_as_keystroke(app, parse):
+    # A separator character used as a keystroke must not produce empty
+    # nested <kbd> elements in compound keystrokes.
+    document = parse(':kbd:`Shift-+`')
+    KeyboardTransform(document).apply()
+    html_translator = ForgivingHTMLTranslator(document, app.builder)
+    document.walkabout(html_translator)
+    html_translated = ''.join(html_translator.fragment).strip()
+
+    assert '<kbd class="kbd docutils literal notranslate"></kbd>' not in html_translated
+    assert '<kbd class="kbd docutils literal notranslate">Shift</kbd>-' in html_translated
+    assert re.sub(r'<[^>]+>', '', html_translated) == 'Shift-+'
+
+
 @pytest.mark.parametrize('type,rst,html_expected,latex_expected', [
     (
         'verify',

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(sphinx/builders/html/transforms\.py)' -m tox -epy39 -v -- tests/test_markup.py
cat coverage.cover
git checkout 21698c14461d27933864d73e6fba568a154e83b3
git apply /root/pre_state.patch
