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
None
EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(django/contrib/auth/base_user\.py|django/contrib/auth/__init__\.py)' ./tests/runtests.py --verbosity 2 --settings=test_sqlite --parallel 1 auth_tests.test_basic
cat coverage.cover
git checkout 9b224579875e30203d079cc2fee83b116d98eb78
git apply /root/pre_state.patch
