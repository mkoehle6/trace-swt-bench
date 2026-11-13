#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD e39e727ded673e74016b5d3658d23cbe20234d11 >> /root/pre_state.patch
sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
export LC_ALL=en_US.UTF-8
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff e39e727ded673e74016b5d3658d23cbe20234d11
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git apply -v - <<'EOF_114329324912'
diff --git a/tests/middleware_exceptions/middleware.py b/tests/middleware_exceptions/middleware.py
index 9fb9726b50..bbc32fd664 100644
--- a/tests/middleware_exceptions/middleware.py
+++ b/tests/middleware_exceptions/middleware.py
@@ -4,6 +4,7 @@ from django.template.response import TemplateResponse
 from django.utils.decorators import (
     async_only_middleware, sync_and_async_middleware, sync_only_middleware,
 )
+from django.utils.deprecation import MiddlewareMixin
 
 log = []
 
@@ -80,6 +81,20 @@ class LogMiddleware(BaseMiddleware):
         return response
 
 
+@async_only_middleware
+class AsyncMiddleware(BaseMiddleware):
+    async def __call__(self, request):
+        return await self.get_response(request)
+
+
+class ProcessResponseMiddleware(MiddlewareMixin):
+    response = None
+
+    def process_response(self, request, response):
+        type(self).response = response
+        return response
+
+
 class NoTemplateResponseMiddleware(BaseMiddleware):
     def process_template_response(self, request, response):
         return None
diff --git a/tests/middleware_exceptions/tests.py b/tests/middleware_exceptions/tests.py
index 8b019ba524..f2eb421c70 100644
--- a/tests/middleware_exceptions/tests.py
+++ b/tests/middleware_exceptions/tests.py
@@ -285,6 +285,19 @@ class MiddlewareSyncAsyncTests(SimpleTestCase):
 
 @override_settings(ROOT_URLCONF='middleware_exceptions.urls')
 class AsyncMiddlewareTests(SimpleTestCase):
+    @override_settings(MIDDLEWARE=[
+        'middleware_exceptions.middleware.ProcessResponseMiddleware',
+        'middleware_exceptions.middleware.AsyncMiddleware',
+    ])
+    async def test_process_response_receives_response(self):
+        mw.ProcessResponseMiddleware.response = None
+        response = await self.async_client.get('/middleware_exceptions/view/')
+        self.assertEqual(response.content, b'OK')
+        self.assertIsInstance(
+            mw.ProcessResponseMiddleware.response,
+            HttpResponse,
+        )
+
     @override_settings(MIDDLEWARE=[
         'middleware_exceptions.middleware.AsyncTemplateResponseMiddleware',
     ])

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(django/middleware/cache\.py|django/middleware/security\.py|django/contrib/sessions/middleware\.py)' ./tests/runtests.py --verbosity 2 --settings=test_sqlite --parallel 1 middleware_exceptions.middleware middleware_exceptions.tests
cat coverage.cover
git checkout e39e727ded673e74016b5d3658d23cbe20234d11
git apply /root/pre_state.patch
