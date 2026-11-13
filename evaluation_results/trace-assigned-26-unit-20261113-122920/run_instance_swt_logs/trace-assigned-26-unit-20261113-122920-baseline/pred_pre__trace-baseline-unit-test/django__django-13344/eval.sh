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
diff --git a/tests/asgi/tests.py b/tests/asgi/tests.py
index 2ec493085e..c225a85a1c 100644
--- a/tests/asgi/tests.py
+++ b/tests/asgi/tests.py
@@ -11,9 +11,11 @@ from django.contrib.staticfiles.handlers import ASGIStaticFilesHandler
 from django.core.asgi import get_asgi_application
 from django.core.signals import request_finished, request_started
 from django.db import close_old_connections
+from django.http import HttpResponse
 from django.test import (
     AsyncRequestFactory, SimpleTestCase, modify_settings, override_settings,
 )
+from django.utils.deprecation import MiddlewareMixin
 from django.utils.http import http_date
 
 from .urls import test_filename
@@ -21,6 +23,12 @@ from .urls import test_filename
 TEST_STATIC_ROOT = Path(__file__).parent / 'project' / 'static'
 
 
+class ProcessResponseMiddleware(MiddlewareMixin):
+    def process_response(self, request, response):
+        request.process_response = response
+        return response
+
+
 @skipIf(sys.platform == 'win32' and (3, 8, 0) < sys.version_info < (3, 8, 1), 'https://bugs.python.org/issue38563')
 @override_settings(ROOT_URLCONF='asgi.urls')
 class ASGITest(SimpleTestCase):
@@ -32,6 +40,20 @@ class ASGITest(SimpleTestCase):
     def tearDown(self):
         request_started.connect(close_old_connections)
 
+    @override_settings(MIDDLEWARE=[
+        'asgi.tests.ProcessResponseMiddleware',
+        'django.middleware.security.SecurityMiddleware',
+    ])
+    async def test_first_middleware_process_response(self):
+        """
+        The first middleware receives an HttpResponse in process_response().
+        """
+        response = await self.async_client.get('/')
+        self.assertIsInstance(
+            response.asgi_request.process_response,
+            HttpResponse,
+        )
+
     async def test_get_asgi_application(self):
         """
         get_asgi_application() returns a functioning ASGI callable.

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(django/middleware/security\.py|django/contrib/sessions/middleware\.py|django/middleware/cache\.py)' ./tests/runtests.py --verbosity 2 --settings=test_sqlite --parallel 1 asgi.tests
cat coverage.cover
git checkout e39e727ded673e74016b5d3658d23cbe20234d11
git apply /root/pre_state.patch
