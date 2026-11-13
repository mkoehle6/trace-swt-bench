#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD 4b452338f914d4f6b54704222d70ae8a746e3db5 >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff 4b452338f914d4f6b54704222d70ae8a746e3db5
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .[test]
git apply -v - <<'EOF_114329324912'
diff --git a/tests/roots/test-domain-py-variable/conf.py b/tests/roots/test-domain-py-variable/conf.py
new file mode 100644
index 000000000..a45d22e28
--- /dev/null
+++ b/tests/roots/test-domain-py-variable/conf.py
@@ -0,0 +1 @@
+exclude_patterns = ['_build']
diff --git a/tests/roots/test-domain-py-variable/index.rst b/tests/roots/test-domain-py-variable/index.rst
new file mode 100644
index 000000000..64bf02caf
--- /dev/null
+++ b/tests/roots/test-domain-py-variable/index.rst
@@ -0,0 +1,14 @@
+test-domain-py-variable
+=======================
+
+.. py:module:: mod
+
+.. py:data:: limit
+
+   Global variable.
+
+.. py:class:: Foo
+
+   Class docs.
+
+   :ivar limit: Instance variable.
diff --git a/tests/test_domain_py.py b/tests/test_domain_py.py
index e0c690518..18d17ec17 100644
--- a/tests/test_domain_py.py
+++ b/tests/test_domain_py.py
@@ -8,6 +8,7 @@
     :license: BSD, see LICENSE for details.
 """
 
+import re
 import sys
 from unittest.mock import Mock
 
@@ -179,6 +180,17 @@ def test_resolve_xref_for_properties(app, status, warning):
             'prop</span> <span class="pre">method</span></code></a>' in content)
 
 
+@pytest.mark.sphinx('html', testroot='domain-py-variable')
+def test_domain_py_class_variable_xref(app, status, warning):
+    app.builder.build_all()
+
+    content = (app.outdir / 'index.html').read_text()
+    variables = re.search(r'<dt[^>]*>Variables.*?</dd>', content, re.S)
+    assert variables
+    assert 'limit' in variables.group(0)
+    assert 'href=' not in variables.group(0)
+
+
 @pytest.mark.sphinx('dummy', testroot='domain-py')
 def test_domain_py_find_obj(app, status, warning):
 

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(sphinx/domains/python\.py)' -m tox -epy39 -v -- tests/roots/test-domain-py-variable/conf.py tests/roots/test-domain-py-variable/index.rst tests/test_domain_py.py
cat coverage.cover
git checkout 4b452338f914d4f6b54704222d70ae8a746e3db5
git apply /root/pre_state.patch
