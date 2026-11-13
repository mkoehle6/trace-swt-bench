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
diff --git a/tests/test_extension.py b/tests/test_extension.py
new file mode 100644
index 000000000..4d5b6051c
--- /dev/null
+++ b/tests/test_extension.py
@@ -0,0 +1,43 @@
+"""
+    test_extension
+    ~~~~~~~~~~~~~~
+
+    Test utilities for Sphinx extensions.
+
+    :copyright: Copyright 2007-2021 by the Sphinx team, see AUTHORS.
+    :license: BSD, see LICENSE for details.
+"""
+
+from unittest.mock import Mock
+
+import pytest
+
+from sphinx.errors import VersionRequirementError
+from sphinx.extension import Extension, verify_needs_extensions
+
+
+def test_needs_extensions_accepts_newer_multi_digit_minor_version():
+    """Required version 0.6.0 should be lower than loaded version 0.10.0."""
+    app = Mock()
+    app.extensions = {
+        'sphinx_gallery.gen_gallery': Extension(
+            'sphinx_gallery.gen_gallery', None, version='0.10.0'),
+    }
+    config = Mock()
+    config.needs_extensions = {'sphinx_gallery.gen_gallery': '0.6.0'}
+
+    verify_needs_extensions(app, config)
+
+
+def test_needs_extensions_rejects_older_extension_version():
+    """An extension older than the required version must still be rejected."""
+    app = Mock()
+    app.extensions = {
+        'sphinx_gallery.gen_gallery': Extension(
+            'sphinx_gallery.gen_gallery', None, version='0.5.0'),
+    }
+    config = Mock()
+    config.needs_extensions = {'sphinx_gallery.gen_gallery': '0.6.0'}
+
+    with pytest.raises(VersionRequirementError):
+        verify_needs_extensions(app, config)

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(sphinx/extension\.py)' -m tox -epy39 -v -- tests/test_extension.py
cat coverage.cover
git checkout 81a4fd973d4cfcb25d01a7b0be62cdb28f82406d
git apply /root/pre_state.patch
