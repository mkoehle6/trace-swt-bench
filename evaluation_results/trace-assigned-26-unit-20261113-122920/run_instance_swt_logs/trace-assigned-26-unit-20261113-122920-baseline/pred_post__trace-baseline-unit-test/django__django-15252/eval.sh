#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD 361bb8f786f112ee275be136795c0b1ecefff928 >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff 361bb8f786f112ee275be136795c0b1ecefff928
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git apply -v - <<'EOF_114329324912'
diff --git a/django/db/migrations/executor.py b/django/db/migrations/executor.py
--- a/django/db/migrations/executor.py
+++ b/django/db/migrations/executor.py
@@ -96,8 +96,12 @@ def migrate(self, targets, plan=None, state=None, fake=False, fake_initial=False
         (un)applied and in a second step run all the database operations.
         """
         # The django_migrations table must be present to record applied
-        # migrations.
-        self.recorder.ensure_schema()
+        # migrations, but don't create it if there are no migrations to apply.
+        if plan == []:
+            if not self.recorder.has_table():
+                return self._create_project_state(with_applied_migrations=False)
+        else:
+            self.recorder.ensure_schema()
 
         if plan is None:
             plan = self.migration_plan(targets)

EOF_114329324912
git apply -v - <<'EOF_114329324912'
diff --git a/tests/migrations/test_loader.py b/tests/migrations/test_loader.py
index 03a98506e3..f9de7e07c3 100644
--- a/tests/migrations/test_loader.py
+++ b/tests/migrations/test_loader.py
@@ -8,7 +8,7 @@ from django.db.migrations.exceptions import (
 )
 from django.db.migrations.loader import MigrationLoader
 from django.db.migrations.recorder import MigrationRecorder
-from django.test import TestCase, modify_settings, override_settings
+from django.test import TestCase, TransactionTestCase, modify_settings, override_settings
 
 from .test_base import MigrationTestBase
 
@@ -46,6 +46,69 @@ class RecorderTests(TestCase):
         )
 
 
+class RecorderRouterTests(TransactionTestCase):
+    """
+    Tests that recording and unrecording migrations respects database
+    routers.
+    """
+    databases = {'default', 'other'}
+    available_apps = ['migrations']
+
+    def _delete_migrations_table(self, recorder):
+        if recorder.has_table():
+            with recorder.connection.schema_editor() as editor:
+                editor.delete_model(recorder.Migration)
+
+    def _restore_migrations_table(self, recorder):
+        if recorder.has_table():
+            recorder.migration_qs.filter(app='myapp').delete()
+        else:
+            with recorder.connection.schema_editor() as editor:
+                editor.create_model(recorder.Migration)
+
+    @override_settings(DATABASE_ROUTERS=['migrations.routers.TestRouter'])
+    def test_record_applied_respects_router(self):
+        """
+        The recorder doesn't create the migrations table or record an applied
+        migration on a database where migrations aren't allowed.
+        """
+        recorder = MigrationRecorder(connections['other'])
+        self._delete_migrations_table(recorder)
+        try:
+            recorder.record_applied('myapp', '0432_ponies')
+            self.assertFalse(recorder.has_table())
+        finally:
+            self._restore_migrations_table(recorder)
+
+    def test_record_unapplied_respects_router(self):
+        """
+        The recorder doesn't create the migrations table when unrecording a
+        migration on a database where migrations aren't allowed.
+        """
+        recorder = MigrationRecorder(connections['other'])
+        self._delete_migrations_table(recorder)
+        try:
+            with self.settings(DATABASE_ROUTERS=['migrations.routers.TestRouter']):
+                recorder.record_unapplied('myapp', '0432_ponies')
+            self.assertFalse(recorder.has_table())
+        finally:
+            self._restore_migrations_table(recorder)
+
+    @override_settings(DATABASE_ROUTERS=['migrations.routers.TestRouter'])
+    def test_ensure_schema_respects_router(self):
+        """
+        The recorder doesn't create the migrations table on a database where
+        migrations aren't allowed.
+        """
+        recorder = MigrationRecorder(connections['other'])
+        self._delete_migrations_table(recorder)
+        try:
+            recorder.ensure_schema()
+            self.assertFalse(recorder.has_table())
+        finally:
+            self._restore_migrations_table(recorder)
+
+
 class LoaderTests(TestCase):
     """
     Tests the disk and database loader, and running through migrations

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(django/db/migrations/executor\.py)' ./tests/runtests.py --verbosity 2 --settings=test_sqlite --parallel 1 migrations.test_loader
cat coverage.cover
git checkout 361bb8f786f112ee275be136795c0b1ecefff928
git apply /root/pre_state.patch
