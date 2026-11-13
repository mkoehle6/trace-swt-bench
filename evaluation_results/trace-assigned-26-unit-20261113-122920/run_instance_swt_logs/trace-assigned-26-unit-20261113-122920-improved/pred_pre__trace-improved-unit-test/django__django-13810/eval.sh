#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD 429d089d0a8fbd400e0c010708df4f0d16218970 >> /root/pre_state.patch
sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
export LC_ALL=en_US.UTF-8
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff 429d089d0a8fbd400e0c010708df4f0d16218970
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git apply -v - <<'EOF_114329324912'
diff --git a/tests/middleware_exceptions/tests.py b/tests/middleware_exceptions/tests.py
index 8b019ba524..c152b63c5e 100644
--- a/tests/middleware_exceptions/tests.py
+++ b/tests/middleware_exceptions/tests.py
@@ -252,6 +252,14 @@ class MiddlewareSyncAsyncTests(SimpleTestCase):
             'Payment Required: /middleware_exceptions/view/',
         )
 
+    @override_settings(MIDDLEWARE=[
+        'middleware_exceptions.middleware.async_payment_middleware',
+        'middleware_exceptions.tests.MyMiddleware',
+    ])
+    async def test_middleware_not_used_does_not_break_async_chain(self):
+        response = await self.async_client.get('/middleware_exceptions/view/')
+        self.assertEqual(response.status_code, 402)
+
     @override_settings(
         DEBUG=False,
         MIDDLEWARE=[

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(django/core/handlers/base\.py)' ./tests/runtests.py --verbosity 2 --settings=test_sqlite --parallel 1 middleware_exceptions.tests
cat coverage.cover
git checkout 429d089d0a8fbd400e0c010708df4f0d16218970
git apply /root/pre_state.patch
