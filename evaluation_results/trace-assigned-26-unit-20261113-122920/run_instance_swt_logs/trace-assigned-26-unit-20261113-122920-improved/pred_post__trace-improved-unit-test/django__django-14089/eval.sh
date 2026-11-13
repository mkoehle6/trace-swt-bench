#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD d01709aae21de9cd2565b9c52f32732ea28a2d98 >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff d01709aae21de9cd2565b9c52f32732ea28a2d98
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git apply -v - <<'EOF_114329324912'
diff --git a/django/utils/datastructures.py b/django/utils/datastructures.py
--- a/django/utils/datastructures.py
+++ b/django/utils/datastructures.py
@@ -25,6 +25,9 @@ def discard(self, item):
     def __iter__(self):
         return iter(self.dict)
 
+    def __reversed__(self):
+        return reversed(self.dict)
+
     def __contains__(self, item):
         return item in self.dict
 

EOF_114329324912
git apply -v - <<'EOF_114329324912'
diff --git a/tests/utils_tests/test_datastructures.py b/tests/utils_tests/test_datastructures.py
index 45d172f984..a22e015027 100644
--- a/tests/utils_tests/test_datastructures.py
+++ b/tests/utils_tests/test_datastructures.py
@@ -55,6 +55,10 @@ class OrderedSetTests(SimpleTestCase):
         s.add(2)
         self.assertEqual(len(s), 2)
 
+    def test_reversed(self):
+        s = OrderedSet([1, 2, 3])
+        self.assertEqual(list(reversed(s)), [3, 2, 1])
+
 
 class MultiValueDictTests(SimpleTestCase):
 

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(django/utils/datastructures\.py)' ./tests/runtests.py --verbosity 2 --settings=test_sqlite --parallel 1 utils_tests.test_datastructures
cat coverage.cover
git checkout d01709aae21de9cd2565b9c52f32732ea28a2d98
git apply /root/pre_state.patch
