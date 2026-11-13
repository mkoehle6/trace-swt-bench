#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD a3e2897bfaf9eaac1d6649da535c4e721c89fa69 >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff a3e2897bfaf9eaac1d6649da535c4e721c89fa69
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git apply -v - <<'EOF_114329324912'
diff --git a/lib/matplotlib/axes/_axes.py b/lib/matplotlib/axes/_axes.py
--- a/lib/matplotlib/axes/_axes.py
+++ b/lib/matplotlib/axes/_axes.py
@@ -6686,7 +6686,7 @@ def hist(self, x, bins=None, range=None, density=None, weights=None,
 
         density = bool(density) or bool(normed)
         if density and not stacked:
-            hist_kwargs = dict(density=density)
+            hist_kwargs['density'] = density
 
         # List to store all the top coordinates of the histograms
         tops = []

EOF_114329324912
git apply -v - <<'EOF_114329324912'
diff --git a/lib/matplotlib/tests/test_axes.py b/lib/matplotlib/tests/test_axes.py
--- a/lib/matplotlib/tests/test_axes.py
+++ b/lib/matplotlib/tests/test_axes.py
@@ -6369,3 +6369,10 @@ def test_hist_nan_data():
 
     assert np.allclose(bins, nanbins)
     assert np.allclose(edges, nanedges)
+
+
+def test_hist_range_and_density():
+    _, bins, _ = plt.hist(np.random.rand(10), "auto",
+                          range=(0, 1), density=True)
+    assert bins[0] == 0
+    assert bins[-1] == 1

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(lib/matplotlib/axes/_axes\.py)' -m pytest --no-header -rA  -p no:cacheprovider lib/matplotlib/tests/test_axes.py
cat coverage.cover
git checkout a3e2897bfaf9eaac1d6649da535c4e721c89fa69
git apply /root/pre_state.patch
