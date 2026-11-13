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
diff --git a/sphinx/domains/python.py b/sphinx/domains/python.py
--- a/sphinx/domains/python.py
+++ b/sphinx/domains/python.py
@@ -354,7 +354,7 @@ class PyObject(ObjectDescription):
                             'keyword', 'kwarg', 'kwparam'),
                      typerolename='class', typenames=('paramtype', 'type'),
                      can_collapse=True),
-        PyTypedField('variable', label=_('Variables'), rolename='obj',
+        PyTypedField('variable', label=_('Variables'),
                      names=('var', 'ivar', 'cvar'),
                      typerolename='class', typenames=('vartype',),
                      can_collapse=True),

EOF_114329324912
git apply -v - <<'EOF_114329324912'
diff --git a/tests/roots/test-domain-py/index.rst b/tests/roots/test-domain-py/index.rst
index 35a0c1927..ed0f1b795 100644
--- a/tests/roots/test-domain-py/index.rst
+++ b/tests/roots/test-domain-py/index.rst
@@ -5,3 +5,5 @@ test-domain-py
 
     roles
     module
+
+    instance_variable
diff --git a/tests/roots/test-domain-py/instance_variable.rst b/tests/roots/test-domain-py/instance_variable.rst
new file mode 100644
index 000000000..8cc7dfe45
--- /dev/null
+++ b/tests/roots/test-domain-py/instance_variable.rst
@@ -0,0 +1,19 @@
+instance_variable
+=================
+
+.. py:module:: module_a.submodule
+
+.. py:data:: limit
+
+   A global variable named limit.
+
+.. py:class:: OtherClass
+
+   .. py:attribute:: other
+
+      An attribute of another class.
+
+.. py:class:: Foo
+
+   :ivar limit: An instance variable named limit.
+   :ivar other: An instance variable named other.
diff --git a/tests/test_domain_py.py b/tests/test_domain_py.py
index e0c690518..64c82edb5 100644
--- a/tests/test_domain_py.py
+++ b/tests/test_domain_py.py
@@ -164,6 +164,16 @@ def test_domain_py_objects(app, status, warning):
     assert objects['NestedParentB.child_1'][2] == 'method'
 
 
+@pytest.mark.sphinx('html', testroot='domain-py')
+def test_domain_py_instance_variable_xrefs(app, status, warning):
+    """Instance variables must not link to unrelated objects with the same name."""
+    app.builder.build_all()
+
+    content = (app.outdir / 'instance_variable.html').read_text()
+    assert '<p><strong>limit</strong> – An instance variable named limit.</p>' in content
+    assert '<p><strong>other</strong> – An instance variable named other.</p>' in content
+
+
 @pytest.mark.sphinx('html', testroot='domain-py')
 def test_resolve_xref_for_properties(app, status, warning):
     app.builder.build_all()

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(sphinx/domains/python\.py)' -m tox -epy39 -v -- tests/roots/test-domain-py/index.rst tests/roots/test-domain-py/instance_variable.rst tests/test_domain_py.py
cat coverage.cover
git checkout 4b452338f914d4f6b54704222d70ae8a746e3db5
git apply /root/pre_state.patch
