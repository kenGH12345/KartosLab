import 'package:flutter/rendering.dart';

/// `IntroScreenView.bumpLeft`: if a tool overlaps a right panel, shift it left
/// by the overlap plus 20 view pixels. Only the first overlapping panel applies.
double bumpLeftViewDx(Rect node, List<Rect> panels, {double pad = 20}) {
  for (final panel in panels) {
    if (!node.overlaps(panel)) continue;
    final tooFar = node.right - panel.left;
    if (tooFar <= 0) continue;
    return -(tooFar + pad);
  }
  return 0;
}

/// Drop is a placement only when the pointer has left the toolbox.
/// One tool instance: the icon hides while [enabled] (no duplicates).
bool droppedOutsideToolbox(Offset local, Rect toolbox) =>
    !toolbox.contains(local);

/// Pointer deltas are global logical pixels. Convert them into the stage's
/// local pixels (already the display size when the viewport has scaled layout).
Offset stageDelta(RenderBox stage, Offset globalDelta) =>
    stage.globalToLocal(globalDelta) - stage.globalToLocal(Offset.zero);

/// Toolbox rectangle in the stage's 834×504 coordinates.
Rect? toolboxInStage(RenderBox stage, RenderBox toolbox) {
  if (!stage.attached || !toolbox.attached || !toolbox.hasSize) return null;
  final origin = stage.globalToLocal(toolbox.localToGlobal(Offset.zero));
  return origin & toolbox.size;
}
