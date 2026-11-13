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
diff --git a/xarray/tests/test_dataset.py b/xarray/tests/test_dataset.py
index 2220abbe..34eafdc3 100644
--- a/xarray/tests/test_dataset.py
+++ b/xarray/tests/test_dataset.py
@@ -3317,6 +3317,13 @@ class TestDataset:
         with pytest.raises(ValueError):
             data.merge(other)
 
+    def test_merge_dataarray(self):
+        ds = Dataset({"a": 0})
+        da = DataArray(1, name="b")
+        expected = xr.merge([ds, da])
+        actual = ds.merge(da)
+        assert_identical(actual, expected)
+
     def test_setitem_original_non_unique_index(self):
         # regression test for GH943
         original = Dataset({"data": ("x", np.arange(5))}, coords={"x": [0, 1, 2, 0, 1]})

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(xarray/core/dataset\.py)' -m pytest --no-header -rA  -p no:cacheprovider xarray/tests/test_dataset.py
cat coverage.cover
git checkout ef6e6a7b86f8479b9a1fecf15ad5b88a2326b31e
git apply /root/pre_state.patch
