#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD ef6e6a7b86f8479b9a1fecf15ad5b88a2326b31e >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff ef6e6a7b86f8479b9a1fecf15ad5b88a2326b31e
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git apply -v - <<'EOF_114329324912'
diff --git a/xarray/core/dataset.py b/xarray/core/dataset.py
--- a/xarray/core/dataset.py
+++ b/xarray/core/dataset.py
@@ -3604,6 +3604,7 @@ def merge(
             If any variables conflict (see ``compat``).
         """
         _check_inplace(inplace)
+        other = other.to_dataset() if isinstance(other, xr.DataArray) else other
         merge_result = dataset_merge_method(
             self,
             other,

EOF_114329324912
git apply -v - <<'EOF_114329324912'
diff --git a/xarray/tests/test_merge.py b/xarray/tests/test_merge.py
index c1e6c7a5..574ab22f 100644
--- a/xarray/tests/test_merge.py
+++ b/xarray/tests/test_merge.py
@@ -134,6 +134,15 @@ class TestMergeFunction:
 
 
 class TestMergeMethod:
+    def test_merge_dataarray(self):
+        ds = xr.Dataset({"a": 0})
+        da = xr.DataArray(1, name="b")
+
+        expected = xr.merge([ds, da])
+        actual = ds.merge(da)
+
+        assert expected.identical(actual)
+
     def test_merge(self):
         data = create_test_data()
         ds1 = data[["var1"]]

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(xarray/core/dataset\.py)' -m pytest --no-header -rA  -p no:cacheprovider xarray/tests/test_merge.py
cat coverage.cover
git checkout ef6e6a7b86f8479b9a1fecf15ad5b88a2326b31e
git apply /root/pre_state.patch
