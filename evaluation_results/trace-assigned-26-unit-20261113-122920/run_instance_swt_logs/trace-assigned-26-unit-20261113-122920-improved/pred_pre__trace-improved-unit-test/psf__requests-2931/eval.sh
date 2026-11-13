#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD 5f7a3a74aab1625c2bb65f643197ee885e3da576 >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff 5f7a3a74aab1625c2bb65f643197ee885e3da576
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install .
git apply -v - <<'EOF_114329324912'
diff --git a/test_requests.py b/test_requests.py
index 137edc08..b2c2710a 100755
--- a/test_requests.py
+++ b/test_requests.py
@@ -521,6 +521,13 @@ class TestRequests(object):
             headers={str('Content-Type'): 'application/octet-stream'},
             data='\xff')  # compat.str is unicode.
 
+    def test_binary_payload(self):
+        data = u'ööö'.encode('utf-8')
+        request = requests.Request('PUT', 'http://httpbin.org/put', data=data)
+        prepared = request.prepare()
+
+        assert prepared.body == data
+
     def test_pyopenssl_redirect(self, httpsbin_url, httpbin_ca_bundle):
         requests.get(httpsbin_url('status', '301'), verify=httpbin_ca_bundle)
 

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(requests/models\.py)' -m pytest --no-header -rA  -p no:cacheprovider test_requests.py
cat coverage.cover
git checkout 5f7a3a74aab1625c2bb65f643197ee885e3da576
git apply /root/pre_state.patch
