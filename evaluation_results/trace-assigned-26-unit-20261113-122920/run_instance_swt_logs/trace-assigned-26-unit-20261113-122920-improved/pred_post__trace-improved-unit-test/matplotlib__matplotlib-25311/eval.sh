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
diff --git a/lib/matplotlib/offsetbox.py b/lib/matplotlib/offsetbox.py
--- a/lib/matplotlib/offsetbox.py
+++ b/lib/matplotlib/offsetbox.py
@@ -1505,7 +1505,6 @@ def __init__(self, ref_artist, use_blit=False):
         if not ref_artist.pickable():
             ref_artist.set_picker(True)
         self.got_artist = False
-        self.canvas = self.ref_artist.figure.canvas
         self._use_blit = use_blit and self.canvas.supports_blit
         self.cids = [
             self.canvas.callbacks._connect_picklable(
@@ -1514,6 +1513,9 @@ def __init__(self, ref_artist, use_blit=False):
                 'button_release_event', self.on_release),
         ]
 
+    # A property, not an attribute, to maintain picklability.
+    canvas = property(lambda self: self.ref_artist.figure.canvas)
+
     def on_motion(self, evt):
         if self._check_still_parented() and self.got_artist:
             dx = evt.x - self.mouse_x

EOF_114329324912
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
