#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD 193e3825645d93c73e31cdceb6d742cc6919624d >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff 193e3825645d93c73e31cdceb6d742cc6919624d
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git apply -v - <<'EOF_114329324912'
None
EOF_114329324912
PYTHONWARNINGS='ignore::UserWarning,ignore::SyntaxWarning' python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(sympy/polys/rings\.py)' bin/test -C --verbose sympy/polys/tests/test_rings.p
cat coverage.cover
git checkout 193e3825645d93c73e31cdceb6d742cc6919624d
git apply /root/pre_state.patch
