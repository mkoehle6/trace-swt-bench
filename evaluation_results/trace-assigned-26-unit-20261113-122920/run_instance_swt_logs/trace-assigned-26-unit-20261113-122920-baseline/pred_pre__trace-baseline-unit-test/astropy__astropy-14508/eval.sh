#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD a3f4ae6cd24d5ecdf49f213d77b3513dd509a06c >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff a3f4ae6cd24d5ecdf49f213d77b3513dd509a06c
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .[test] --verbose
git apply -v - <<'EOF_114329324912'
diff --git a/astropy/io/fits/tests/test_header.py b/astropy/io/fits/tests/test_header.py
index a8f4e1160f..f5f1ff48fe 100644
--- a/astropy/io/fits/tests/test_header.py
+++ b/astropy/io/fits/tests/test_header.py
@@ -632,6 +632,24 @@ class TestHeaderFunctions(FitsTestCase):
             "'ENC=OFFSET+RESOL*acos((WID-(MAX+MIN))/(MAX-MIN)'"
         )
 
+    def test_hierarch_float_value_not_needlessly_expanded(self):
+        """Regression test for a HIERARCH card whose float value should not
+        expand beyond the precision needed to reproduce it.
+
+        This is important because unnecessarily expanding the float uses up
+        space that would otherwise be available for the comment.
+        """
+        c = fits.Card(
+            "HIERARCH ESO IFM CL RADIUS",
+            0.009125,
+            "[m] radius arround actuator to avoid",
+        )
+        assert str(c) == _pad(
+            "HIERARCH ESO IFM CL RADIUS = 0.009125 / [m] radius arround actuator to avoid"
+        )
+        assert c.value == 0.009125
+        assert c.comment == "[m] radius arround actuator to avoid"
+
     def test_hierarch_with_abbrev_value_indicator(self):
         """Regression test for
         https://github.com/spacetelescope/PyFITS/issues/5

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(astropy/io/fits/card\.py)' -m pytest --no-header -rA  -p no:cacheprovider astropy/io/fits/tests/test_header.py
cat coverage.cover
git checkout a3f4ae6cd24d5ecdf49f213d77b3513dd509a06c
git apply /root/pre_state.patch
