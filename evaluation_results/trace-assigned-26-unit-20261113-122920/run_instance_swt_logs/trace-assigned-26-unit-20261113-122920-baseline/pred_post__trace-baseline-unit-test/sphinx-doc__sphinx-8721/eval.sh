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
diff --git a/sphinx/ext/viewcode.py b/sphinx/ext/viewcode.py
--- a/sphinx/ext/viewcode.py
+++ b/sphinx/ext/viewcode.py
@@ -182,6 +182,10 @@ def collect_pages(app: Sphinx) -> Generator[Tuple[str, Dict[str, Any], str], Non
     env = app.builder.env
     if not hasattr(env, '_viewcode_modules'):
         return
+    if app.builder.name == "singlehtml":
+        return
+    if app.builder.name.startswith("epub") and not env.config.viewcode_enable_epub:
+        return
     highlighter = app.builder.highlighter  # type: ignore
     urito = app.builder.get_relative_uri
 

EOF_114329324912
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_ext_viewcode.py b/tests/test_ext_viewcode.py
index 79864095b..f87884884 100644
--- a/tests/test_ext_viewcode.py
+++ b/tests/test_ext_viewcode.py
@@ -102,3 +102,18 @@ def test_local_source_files(app, status, warning):
 
     assert result.count('href="_modules/not_a_package/submodule.html#not_a_package.submodule.Class3.class_attr"') == 1
     assert result.count('This is the class attribute class_attr') == 1
+
+
+@pytest.mark.sphinx(testroot='ext-viewcode')
+def test_viewcode_epub(make_app, app_params):
+    args, kwargs = app_params
+
+    # build HTML first to create module pages and cache viewcode modules in env
+    app = make_app(*args, **kwargs)
+    app.build()
+    assert (app.outdir / '_modules' / 'spam' / 'mod1.html').exists()
+
+    # reuse the doctree environment for an EPUB build
+    app = make_app('epub', *args, **kwargs)
+    app.build()
+    assert not (app.outdir / '_modules').exists()

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(sphinx/ext/viewcode\.py)' -m tox -epy39 -v -- tests/test_ext_viewcode.py
cat coverage.cover
git checkout 82ef497a8c88f0f6e50d84520e7276bfbf65025d
git apply /root/pre_state.patch
