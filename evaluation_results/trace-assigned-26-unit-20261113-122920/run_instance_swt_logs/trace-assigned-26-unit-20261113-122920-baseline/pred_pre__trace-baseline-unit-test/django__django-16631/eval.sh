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
index 4b491e521e..7e2809b8e8 100644
--- a/tests/auth_tests/test_basic.py
+++ b/tests/auth_tests/test_basic.py
@@ -138,3 +138,31 @@ class TestGetUser(TestCase):
         user = get_user(request)
         self.assertIsInstance(user, User)
         self.assertEqual(user.username, created_user.username)
+
+    @override_settings(SECRET_KEY="old-secret", SECRET_KEY_FALLBACKS=[])
+    def test_get_user_with_secret_key_fallback(self):
+        created_user = User.objects.create_user(
+            "testuser", "test@example.com", "testpw"
+        )
+        self.client.login(username="testuser", password="testpw")
+        session = self.client.session
+        with override_settings(
+            SECRET_KEY="new-secret",
+            SECRET_KEY_FALLBACKS=["old-secret"],
+        ):
+            request = HttpRequest()
+            request.session = session
+            self.assertEqual(get_user(request), created_user)
+
+    @override_settings(SECRET_KEY="old-secret", SECRET_KEY_FALLBACKS=[])
+    def test_get_user_without_secret_key_fallback(self):
+        User.objects.create_user("testuser", "test@example.com", "testpw")
+        self.client.login(username="testuser", password="testpw")
+        session = self.client.session
+        with override_settings(
+            SECRET_KEY="new-secret",
+            SECRET_KEY_FALLBACKS=[],
+        ):
+            request = HttpRequest()
+            request.session = session
+            self.assertIsInstance(get_user(request), AnonymousUser)

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(django/contrib/auth/base_user\.py|django/contrib/auth/__init__\.py)' ./tests/runtests.py --verbosity 2 --settings=test_sqlite --parallel 1 auth_tests.test_basic
cat coverage.cover
git checkout 9b224579875e30203d079cc2fee83b116d98eb78
git apply /root/pre_state.patch
