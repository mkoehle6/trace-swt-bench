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
diff --git a/django/core/handlers/base.py b/django/core/handlers/base.py
--- a/django/core/handlers/base.py
+++ b/django/core/handlers/base.py
@@ -51,11 +51,11 @@ def load_middleware(self, is_async=False):
                 middleware_is_async = middleware_can_async
             try:
                 # Adapt handler, if needed.
-                handler = self.adapt_method_mode(
+                adapted_handler = self.adapt_method_mode(
                     middleware_is_async, handler, handler_is_async,
                     debug=settings.DEBUG, name='middleware %s' % middleware_path,
                 )
-                mw_instance = middleware(handler)
+                mw_instance = middleware(adapted_handler)
             except MiddlewareNotUsed as exc:
                 if settings.DEBUG:
                     if str(exc):
@@ -63,6 +63,8 @@ def load_middleware(self, is_async=False):
                     else:
                         logger.debug('MiddlewareNotUsed: %r', middleware_path)
                 continue
+            else:
+                handler = adapted_handler
 
             if mw_instance is None:
                 raise ImproperlyConfigured(

EOF_114329324912
git apply -v - <<'EOF_114329324912'
diff --git a/tests/middleware_exceptions/tests.py b/tests/middleware_exceptions/tests.py
--- a/tests/middleware_exceptions/tests.py
+++ b/tests/middleware_exceptions/tests.py
@@ -181,6 +181,25 @@ def test_do_not_log_when_debug_is_false(self):
             with self.assertLogs('django.request', 'DEBUG'):
                 self.client.get('/middleware_exceptions/view/')
 
+    @override_settings(MIDDLEWARE=[
+        'middleware_exceptions.middleware.SyncAndAsyncMiddleware',
+        'middleware_exceptions.tests.MyMiddleware',
+    ])
+    async def test_async_and_sync_middleware_chain_async_call(self):
+        with self.assertLogs('django.request', 'DEBUG') as cm:
+            response = await self.async_client.get('/middleware_exceptions/view/')
+        self.assertEqual(response.content, b'OK')
+        self.assertEqual(response.status_code, 200)
+        self.assertEqual(
+            cm.records[0].getMessage(),
+            'Asynchronous middleware middleware_exceptions.tests.MyMiddleware '
+            'adapted.',
+        )
+        self.assertEqual(
+            cm.records[1].getMessage(),
+            "MiddlewareNotUsed: 'middleware_exceptions.tests.MyMiddleware'",
+        )
+
 
 @override_settings(
     DEBUG=True,

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(django/core/handlers/base\.py)' ./tests/runtests.py --verbosity 2 --settings=test_sqlite --parallel 1 middleware_exceptions.tests
cat coverage.cover
git checkout 429d089d0a8fbd400e0c010708df4f0d16218970
git apply /root/pre_state.patch
