#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD 81a4fd973d4cfcb25d01a7b0be62cdb28f82406d >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff 81a4fd973d4cfcb25d01a7b0be62cdb28f82406d
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .[test]
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_config.py b/tests/test_config.py
index 717e8658d..2248964ef 100644
--- a/tests/test_config.py
+++ b/tests/test_config.py
@@ -16,6 +16,7 @@ import pytest
 import sphinx
 from sphinx.config import ENUM, Config, check_confval_types
 from sphinx.errors import ConfigError, ExtensionError, VersionRequirementError
+from sphinx.extension import verify_needs_extensions
 from sphinx.testing.path import path
 
 
@@ -194,6 +195,23 @@ def test_needs_sphinx(make_app_with_empty_project):
         make_app(confoverrides={'needs_sphinx': '2'})  # NG: greater
 
 
+def test_needs_extensions_version_compare():
+    app = mock.Mock()
+    extension = mock.Mock()
+    extension.version = '0.10.0'
+    app.extensions = {'test_extension': extension}
+    config = mock.Mock()
+    config.needs_extensions = {'test_extension': '0.6.0'}
+
+    # Version strings must be compared as versions, not lexicographically.
+    verify_needs_extensions(app, config)
+
+    # A genuinely newer requirement must still be rejected.
+    config.needs_extensions = {'test_extension': '0.11.0'}
+    with pytest.raises(VersionRequirementError):
+        verify_needs_extensions(app, config)
+
+
 @mock.patch("sphinx.config.logger")
 def test_config_eol(logger, tempdir):
     # test config file's eol patterns: LF, CRLF

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(sphinx/extension\.py)' -m tox -epy39 -v -- tests/test_config.py
cat coverage.cover
git checkout 81a4fd973d4cfcb25d01a7b0be62cdb28f82406d
git apply /root/pre_state.patch
