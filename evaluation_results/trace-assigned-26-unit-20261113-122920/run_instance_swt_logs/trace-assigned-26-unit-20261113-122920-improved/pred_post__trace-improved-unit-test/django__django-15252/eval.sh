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
diff --git a/tests/migrations/test_commands.py b/tests/migrations/test_commands.py
index bf78b60a85..e3275452f9 100644
--- a/tests/migrations/test_commands.py
+++ b/tests/migrations/test_commands.py
@@ -25,12 +25,40 @@ from .routers import TestRouter
 from .test_base import MigrationTestBase
 
 
+class MigrateOnlyDefaultRouter:
+    def allow_migrate(self, db, app_label, model_name=None, **hints):
+        return db == "default"
+
+
 class MigrateTests(MigrationTestBase):
     """
     Tests running the migrate command.
     """
     databases = {'default', 'other'}
 
+    @override_settings(
+        MIGRATION_MODULES={"migrations": "migrations.test_migrations"},
+        DATABASE_ROUTERS=[MigrateOnlyDefaultRouter()],
+    )
+    def test_migrate_does_not_create_migration_table_when_router_disallows(self):
+        """
+        The migration recorder table isn't created on a database where the
+        router disallows migrations.
+        """
+        recorder = MigrationRecorder(connections["other"])
+        if recorder.has_table():
+            with connections["other"].schema_editor() as editor:
+                editor.delete_model(MigrationRecorder.Migration)
+        try:
+            self.assertFalse(recorder.has_table())
+            call_command("migrate", "migrations", database="other", verbosity=0)
+            self.assertFalse(recorder.has_table())
+        finally:
+            # Restore the table for the test suite's teardown and other tests.
+            if not recorder.has_table():
+                with connections["other"].schema_editor() as editor:
+                    editor.create_model(MigrationRecorder.Migration)
+
     @override_settings(MIGRATION_MODULES={"migrations": "migrations.test_migrations"})
     def test_migrate(self):
         """

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(django/db/migrations/executor\.py)' ./tests/runtests.py --verbosity 2 --settings=test_sqlite --parallel 1 migrations.test_commands
cat coverage.cover
git checkout 361bb8f786f112ee275be136795c0b1ecefff928
git apply /root/pre_state.patch
