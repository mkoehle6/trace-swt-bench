#!/bin/bash
set -uxo pipefail
source /opt/miniconda3/bin/activate
conda activate testbed
cd /testbed
git diff HEAD 430fb1db88843300fb4baae3edc499bbfe073b0c >> /root/pre_state.patch
git config --global --add safe.directory /testbed
cd /testbed
git status
git show
git diff 430fb1db88843300fb4baae3edc499bbfe073b0c
source /opt/miniconda3/bin/activate
conda activate testbed
python -m pip install -e .
git apply -v - <<'EOF_114329324912'
diff --git a/lib/matplotlib/tests/test_pickle.py b/lib/matplotlib/tests/test_pickle.py
index ec6bdcc2fe..446459f8e4 100644
--- a/lib/matplotlib/tests/test_pickle.py
+++ b/lib/matplotlib/tests/test_pickle.py
@@ -1,6 +1,7 @@
 from io import BytesIO
 import ast
 import pickle
+import threading
 
 import numpy as np
 import pytest
@@ -282,3 +283,28 @@ def test_dynamic_norm():
 def test_vertexselector():
     line, = plt.plot([0, 1], picker=True)
     pickle.loads(pickle.dumps(VertexSelector(line)))
+
+
+def test_pickle_draggable_legend():
+    fig, ax = plt.subplots()
+    ax.plot([0, 1], label="speed")
+    legend = ax.legend()
+    legend.set_draggable(True)
+    # GUI backends generally cannot be pickled.  Figure.__getstate__ drops
+    # figure.canvas, but a draggable artist must not keep a reference to it.
+    fig.canvas._unpicklable = threading.Lock()
+
+    loaded = pickle.loads(pickle.dumps(fig))
+    assert loaded.axes[0].get_legend().get_draggable()
+
+
+def test_pickle_draggable_annotation():
+    fig, ax = plt.subplots()
+    annotation = ax.annotate("foo", (0.5, 0.5))
+    annotation.draggable(True)
+    # GUI backends generally cannot be pickled.  Figure.__getstate__ drops
+    # figure.canvas, but a draggable artist must not keep a reference to it.
+    fig.canvas._unpicklable = threading.Lock()
+
+    loaded = pickle.loads(pickle.dumps(fig))
+    assert loaded.axes[0].texts[0]._draggable is not None

EOF_114329324912
python3 /root/trace.py --count -C coverage.cover --include-pattern '/testbed/(lib/matplotlib/offsetbox\.py)' -m pytest --no-header -rA  -p no:cacheprovider lib/matplotlib/tests/test_pickle.py
cat coverage.cover
git checkout 430fb1db88843300fb4baae3edc499bbfe073b0c
git apply /root/pre_state.patch
