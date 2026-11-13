#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD 57ed10c68057c96491acbd3e62254ccfaf9e3861 >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff 57ed10c68057c96491acbd3e62254ccfaf9e3861
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .[test]
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_domain_py.py b/tests/test_domain_py.py
index 2dc97bed9..b968dbc48 100644
--- a/tests/test_domain_py.py
+++ b/tests/test_domain_py.py
@@ -206,6 +206,33 @@ def test_domain_py_find_obj(app, status, warning):
               ('roles', 'NestedParentA.NestedChildA.subchild_1', 'method'))])
 
 
+@pytest.mark.sphinx('html', freshenv=True)
+def test_domain_py_field_type_xrefs(app, status, warning):
+    text = (".. py:class:: mod.A\n"
+            ".. py:class:: mod.submod.A\n"
+            "\n"
+            ".. py:currentmodule:: mod.submod\n"
+            "\n"
+            ".. py:function:: f()\n"
+            "\n"
+            "   :param A a:\n"
+            "   :param b:\n"
+            "   :type b: A\n"
+            "   :rtype: A\n")
+    doctree = restructuredtext.parse(app, text)
+    domain = app.env.get_domain('py')
+    xrefs = list(doctree.traverse(addnodes.pending_xref))
+    assert [xref.astext() for xref in xrefs] == ['A', 'A', 'A']
+
+    for xref in xrefs:
+        refnode = domain.resolve_xref(app.env, 'index', app.builder,
+                                      xref['reftype'], xref['reftarget'],
+                                      xref, xref[0])
+        assert_node(refnode, nodes.reference, refid='mod.submod.A')
+
+    assert 'more than one target found for cross-reference' not in warning.getvalue()
+
+
 def test_get_full_qualified_name():
     env = Mock(domaindata={})
     domain = PythonDomain(env)

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(sphinx/util/docfields\.py|sphinx/domains/python\.py)' -m tox -epy39 -v -- tests/test_domain_py.py
cat coverage.cover
git checkout 57ed10c68057c96491acbd3e62254ccfaf9e3861
git apply /root/pre_state.patch
