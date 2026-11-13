#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD fdbaa58acbead5a254f2e6d597dc1ab3b947f4c6 >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff fdbaa58acbead5a254f2e6d597dc1ab3b947f4c6
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -v --no-use-pep517 --no-build-isolation -e .
git apply -v - <<'EOF_114329324912'
diff --git a/sklearn/svm/base.py b/sklearn/svm/base.py
--- a/sklearn/svm/base.py
+++ b/sklearn/svm/base.py
@@ -287,11 +287,14 @@ def _sparse_fit(self, X, y, sample_weight, solver_type, kernel,
         n_SV = self.support_vectors_.shape[0]
 
         dual_coef_indices = np.tile(np.arange(n_SV), n_class)
-        dual_coef_indptr = np.arange(0, dual_coef_indices.size + 1,
-                                     dual_coef_indices.size / n_class)
-        self.dual_coef_ = sp.csr_matrix(
-            (dual_coef_data, dual_coef_indices, dual_coef_indptr),
-            (n_class, n_SV))
+        if not n_SV:
+            self.dual_coef_ = sp.csr_matrix([])
+        else:
+            dual_coef_indptr = np.arange(0, dual_coef_indices.size + 1,
+                                         dual_coef_indices.size / n_class)
+            self.dual_coef_ = sp.csr_matrix(
+                (dual_coef_data, dual_coef_indices, dual_coef_indptr),
+                (n_class, n_SV))
 
     def predict(self, X):
         """Perform regression on samples in X.

EOF_114329324912
git apply -v - <<'EOF_114329324912'
diff --git a/sklearn/svm/tests/test_sparse.py b/sklearn/svm/tests/test_sparse.py
index 7cf6e8af2a..ad975d4ca8 100644
--- a/sklearn/svm/tests/test_sparse.py
+++ b/sklearn/svm/tests/test_sparse.py
@@ -327,6 +327,31 @@ def test_sparse_realdata():
     assert_array_equal(clf.dual_coef_, sp_clf.dual_coef_.toarray())
 
 
+def test_sparse_svr_with_empty_support_vectors():
+    # Non-regression test for SVR fitted on sparse data when the solver
+    # returns no support vectors. The sparse dual coefficients should be
+    # empty, just as they are for the equivalent dense fit.
+    X = np.array([[0, 1, 0, 0],
+                  [0, 0, 0, 1],
+                  [0, 0, 1, 0],
+                  [0, 0, 0, 1]])
+    y = np.array([0.04, 0.04, 0.10, 0.16])
+
+    dense_svr = svm.SVR(C=316.227766017, kernel='linear', gamma=1.0,
+                        epsilon=0.1, max_iter=15000).fit(X, y)
+    sparse_svr = svm.SVR(C=316.227766017, kernel='linear', gamma=1.0,
+                         epsilon=0.1, max_iter=15000).fit(
+                             sparse.csr_matrix(X), y)
+
+    assert sparse.issparse(sparse_svr.support_vectors_)
+    assert (sparse_svr.support_vectors_.shape ==
+            dense_svr.support_vectors_.shape)
+    assert sparse.issparse(sparse_svr.dual_coef_)
+    assert sparse_svr.dual_coef_.shape == dense_svr.dual_coef_.shape
+    assert_array_equal(sparse_svr.dual_coef_.toarray(),
+                       dense_svr.dual_coef_)
+
+
 def test_sparse_svc_clone_with_callable_kernel():
     # Test that the "dense_fit" is called even though we use sparse input
     # meaning that everything works fine.

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(sklearn/svm/base\.py)' -m pytest --no-header -rA  -p no:cacheprovider sklearn/svm/tests/test_sparse.py
cat coverage.cover
git checkout fdbaa58acbead5a254f2e6d597dc1ab3b947f4c6
git apply /root/pre_state.patch
