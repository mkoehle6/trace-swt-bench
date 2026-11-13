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
None
EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(django/db/migrations/executor\.py)' ./tests/runtests.py --verbosity 2 --settings=test_sqlite --parallel 1 migrations.test_loader
cat coverage.cover
git checkout 361bb8f786f112ee275be136795c0b1ecefff928
git apply /root/pre_state.patch
