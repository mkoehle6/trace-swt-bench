#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD 193e3825645d93c73e31cdceb6d742cc6919624d >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff 193e3825645d93c73e31cdceb6d742cc6919624d
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git apply -v - <<'EOF_114329324912'
diff --git a/sympy/polys/tests/test_rings.py b/sympy/polys/tests/test_rings.py
index b3962136a3..3f875e68a5 100644
--- a/sympy/polys/tests/test_rings.py
+++ b/sympy/polys/tests/test_rings.py
@@ -259,13 +259,13 @@ def test_PolyElement_as_expr():
     assert f != g
     assert f.as_expr() == g
 
-    X, Y, Z = symbols("x,y,z")
-    g = 3*X**2*Y - X*Y*Z + 7*Z**3 + 1
+    U, V, W = symbols("u,v,w")
+    g = 3*U**2*V - U*V*W + 7*W**3 + 1
 
     assert f != g
-    assert f.as_expr(X, Y, Z) == g
+    assert f.as_expr(U, V, W) == g
 
-    raises(ValueError, lambda: f.as_expr(X))
+    raises(ValueError, lambda: f.as_expr(U))
 
     R, = ring("", ZZ)
     assert R(3).as_expr() == 3

EOF_114329324912
PYTHONWARNINGS='ignore::UserWarning,ignore::SyntaxWarning' python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(sympy/polys/rings\.py)' bin/test -C --verbose sympy/polys/tests/test_rings.p
cat coverage.cover
git checkout 193e3825645d93c73e31cdceb6d742cc6919624d
git apply /root/pre_state.patch
