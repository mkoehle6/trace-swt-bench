#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD e6588aa4e793b7f56f4cadbfa155b581e0efc59a >> /root/pre_state.patch
sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
export LC_ALL=en_US.UTF-8
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff e6588aa4e793b7f56f4cadbfa155b581e0efc59a
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git apply -v - <<'EOF_114329324912'
None
EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(django/forms/models\.py)' ./tests/runtests.py --verbosity 2 --settings=test_sqlite --parallel 1 model_forms.tests
cat coverage.cover
git checkout e6588aa4e793b7f56f4cadbfa155b581e0efc59a
git apply /root/pre_state.patch
