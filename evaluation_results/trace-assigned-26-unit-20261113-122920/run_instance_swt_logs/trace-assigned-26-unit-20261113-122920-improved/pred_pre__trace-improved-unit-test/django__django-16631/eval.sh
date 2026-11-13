#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD 9b224579875e30203d079cc2fee83b116d98eb78 >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff 9b224579875e30203d079cc2fee83b116d98eb78
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git apply -v - <<'EOF_114329324912'
diff --git a/tests/auth_tests/test_basic.py b/tests/auth_tests/test_basic.py
index 4b491e521e..87a173e29d 100644
--- a/tests/auth_tests/test_basic.py
+++ b/tests/auth_tests/test_basic.py
@@ -1,4 +1,4 @@
-from django.contrib.auth import get_user, get_user_model
+from django.contrib.auth import SESSION_KEY, get_user, get_user_model
 from django.contrib.auth.models import AnonymousUser, User
 from django.core.exceptions import ImproperlyConfigured
 from django.db import IntegrityError
@@ -138,3 +138,20 @@ class TestGetUser(TestCase):
         user = get_user(request)
         self.assertIsInstance(user, User)
         self.assertEqual(user.username, created_user.username)
+
+    @override_settings(SECRET_KEY="old-secret")
+    def test_get_user_with_secret_key_fallbacks(self):
+        created_user = User.objects.create_user(
+            "testuser", "test@example.com", "testpw"
+        )
+        self.client.login(username="testuser", password="testpw")
+        with self.settings(
+            SECRET_KEY="new-secret",
+            SECRET_KEY_FALLBACKS=["old-secret"],
+        ):
+            request = HttpRequest()
+            request.session = self.client.session
+            self.assertIn(SESSION_KEY, request.session)
+            user = get_user(request)
+        self.assertIsInstance(user, User)
+        self.assertEqual(user.username, created_user.username)

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(django/contrib/auth/base_user\.py|django/contrib/auth/__init__\.py)' ./tests/runtests.py --verbosity 2 --settings=test_sqlite --parallel 1 auth_tests.test_basic
cat coverage.cover
git checkout 9b224579875e30203d079cc2fee83b116d98eb78
git apply /root/pre_state.patch
