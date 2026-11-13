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
index 000000000..df1f39492
--- /dev/null
+++ b/tests/lint/test_run.py
@@ -0,0 +1,32 @@
+# Licensed under the GPL: https://www.gnu.org/licenses/old-licenses/gpl-2.0.html
+# For details: https://github.com/PyCQA/pylint/blob/main/LICENSE
+# Copyright (c) https://github.com/PyCQA/pylint/blob/main/CONTRIBUTORS.txt
+
+from __future__ import annotations
+
+from pathlib import Path
+from unittest.mock import mock_open, patch
+
+import pytest
+
+from pylint.lint.run import _cpu_count
+
+
+def test_cpu_count_is_never_zero(monkeypatch: pytest.MonkeyPatch) -> None:
+    """A small cgroup CPU share should not result in zero jobs.
+
+    In a Kubernetes pod ``cpu.shares`` can be very small (for example, 2).
+    Dividing that value by 1024 and casting to an integer produces 0, which
+    must not be passed to multiprocessing as the number of workers.
+    """
+
+    def is_file(path: Path) -> bool:
+        return str(path) == "/sys/fs/cgroup/cpu/cpu.shares"
+
+    monkeypatch.setattr(Path, "is_file", is_file)
+    fake_open = mock_open(read_data="2")
+    with patch("builtins.open", fake_open):
+        assert _cpu_count() >= 1
+    fake_open.assert_called_once_with(
+        "/sys/fs/cgroup/cpu/cpu.shares", encoding="utf-8"
+    )

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(pylint/lint/run\.py)' -m pytest --no-header -rA  -p no:cacheprovider tests/lint/test_run.py
cat coverage.cover
git checkout ca80f03a43bc39e4cc2c67dc99817b3c9f13b8a6
git apply /root/pre_state.patch
