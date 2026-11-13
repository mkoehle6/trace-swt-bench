#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD 82ef497a8c88f0f6e50d84520e7276bfbf65025d >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff 82ef497a8c88f0f6e50d84520e7276bfbf65025d
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .[test]
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_ext_viewcode.py b/tests/test_ext_viewcode.py
index 79864095b..33e8e1992 100644
--- a/tests/test_ext_viewcode.py
+++ b/tests/test_ext_viewcode.py
@@ -102,3 +102,19 @@ def test_local_source_files(app, status, warning):
 
     assert result.count('href="_modules/not_a_package/submodule.html#not_a_package.submodule.Class3.class_attr"') == 1
     assert result.count('This is the class attribute class_attr') == 1
+
+
+@pytest.mark.sphinx('epub', testroot='ext-viewcode')
+def test_viewcode_epub(make_app, app_params):
+    args, kwargs = app_params
+
+    # Build HTML first so that the shared build environment contains
+    # the modules collected by the viewcode extension.
+    html_app = make_app('html', **kwargs)
+    html_app.build()
+    assert (html_app.outdir / '_modules/spam/mod1.html').exists()
+
+    # The EPUB builder must not generate viewcode pages by default.
+    epub_app = make_app(*args, **kwargs)
+    epub_app.build()
+    assert not (epub_app.outdir / '_modules').exists()

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(sphinx/ext/viewcode\.py)' -m tox -epy39 -v -- tests/test_ext_viewcode.py
cat coverage.cover
git checkout 82ef497a8c88f0f6e50d84520e7276bfbf65025d
git apply /root/pre_state.patch
