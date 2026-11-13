#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD 7ee9ceb71e868944a46e1ff00b506772a53a4f1d >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff 7ee9ceb71e868944a46e1ff00b506772a53a4f1d
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git apply -v - <<'EOF_114329324912'
diff --git a/src/flask/blueprints.py b/src/flask/blueprints.py
--- a/src/flask/blueprints.py
+++ b/src/flask/blueprints.py
@@ -190,6 +190,9 @@ def __init__(
             root_path=root_path,
         )
 
+        if not name:
+            raise ValueError("'name' may not be empty.")
+
         if "." in name:
             raise ValueError("'name' may not contain a dot '.' character.")
 

EOF_114329324912
git apply -v - <<'EOF_114329324912'
diff --git a/tests/test_blueprints.py b/tests/test_blueprints.py
index d46b769b..76cee660 100644
--- a/tests/test_blueprints.py
+++ b/tests/test_blueprints.py
@@ -256,6 +256,11 @@ def test_dotted_name_not_allowed(app, client):
         flask.Blueprint("app.ui", __name__)
 
 
+def test_empty_name_not_allowed(app, client):
+    with pytest.raises(ValueError):
+        flask.Blueprint("", __name__)
+
+
 def test_dotted_names_from_app(app, client):
     test = flask.Blueprint("test", __name__)
 

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(src/flask/blueprints\.py)' -m pytest --no-header -rA  -p no:cacheprovider tests/test_blueprints.py
cat coverage.cover
git checkout 7ee9ceb71e868944a46e1ff00b506772a53a4f1d
git apply /root/pre_state.patch
