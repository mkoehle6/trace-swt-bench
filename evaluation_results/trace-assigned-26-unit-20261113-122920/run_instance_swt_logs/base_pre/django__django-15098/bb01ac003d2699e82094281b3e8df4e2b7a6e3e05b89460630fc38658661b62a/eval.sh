#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD 2c7846d992ca512d36a73f518205015c88ed088c >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff 2c7846d992ca512d36a73f518205015c88ed088c
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git apply -v - <<'EOF_114329324912'
None
EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(django/utils/translation/trans_real\.py)' ./tests/runtests.py --verbosity 2 --settings=test_sqlite --parallel 1 i18n.patterns.tests i18n.tests
cat coverage.cover
git checkout 2c7846d992ca512d36a73f518205015c88ed088c
git apply /root/pre_state.patch
