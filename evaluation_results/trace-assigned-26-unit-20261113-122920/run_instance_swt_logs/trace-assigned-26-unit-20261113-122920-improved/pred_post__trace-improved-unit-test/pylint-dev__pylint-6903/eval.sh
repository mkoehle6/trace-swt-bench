#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD ca80f03a43bc39e4cc2c67dc99817b3c9f13b8a6 >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff ca80f03a43bc39e4cc2c67dc99817b3c9f13b8a6
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git apply -v - <<'EOF_114329324912'
diff --git a/pylint/lint/run.py b/pylint/lint/run.py
--- a/pylint/lint/run.py
+++ b/pylint/lint/run.py
@@ -58,6 +58,13 @@ def _query_cpu() -> int | None:
             cpu_shares = int(file.read().rstrip())
         # For AWS, gives correct value * 1024.
         avail_cpu = int(cpu_shares / 1024)
+
+    # In K8s Pods also a fraction of a single core could be available
+    # As multiprocessing is not able to run only a "fraction" of process
+    # assume we have 1 CPU available
+    if avail_cpu == 0:
+        avail_cpu = 1
+
     return avail_cpu
 
 

EOF_114329324912
git apply -v - <<'EOF_114329324912'
diff --git a/tests/lint/test_run.py b/tests/lint/test_run.py
new file mode 100644
index 000000000..12d378c12
--- /dev/null
+++ b/tests/lint/test_run.py
@@ -0,0 +1,45 @@
+# Licensed under the GPL: https://www.gnu.org/licenses/old-licenses/gpl-2.0.html
+# For details: https://github.com/PyCQA/pylint/blob/main/LICENSE
+# Copyright (c) https://github.com/PyCQA/pylint/blob/main/CONTRIBUTORS.txt
+
+from __future__ import annotations
+
+from io import StringIO
+from pathlib import Path
+from unittest import mock
+
+import pytest
+
+from pylint.lint.run import _cpu_count, _query_cpu
+
+
+@pytest.mark.parametrize(
+    "cpu_files",
+    [
+        # Docker reports -1 for an unlimited quota but can report a
+        # cpu.shares value below 1024.
+        {
+            "/sys/fs/cgroup/cpu/cpu.cfs_quota_us": "-1",
+            "/sys/fs/cgroup/cpu/cpu.shares": "2",
+        },
+        # A quota smaller than the period also rounds down to zero.
+        {
+            "/sys/fs/cgroup/cpu/cpu.cfs_quota_us": "50000",
+            "/sys/fs/cgroup/cpu/cpu.cfs_period_us": "100000",
+        },
+    ],
+)
+def test_cpu_query_never_returns_zero(cpu_files: dict[str, str]) -> None:
+    """The CPU count must be positive so --jobs=0 can start a process pool."""
+
+    def is_file(path: Path) -> bool:
+        return str(path) in cpu_files
+
+    def open_file(path: Path, *args: object, **kwargs: object) -> StringIO:
+        return StringIO(cpu_files[str(path)])
+
+    with mock.patch.object(Path, "is_file", is_file), mock.patch(
+        "builtins.open", open_file
+    ):
+        assert _query_cpu() >= 1
+        assert _cpu_count() >= 1

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(pylint/lint/run\.py)' -m pytest --no-header -rA  -p no:cacheprovider tests/lint/test_run.py
cat coverage.cover
git checkout ca80f03a43bc39e4cc2c67dc99817b3c9f13b8a6
git apply /root/pre_state.patch
