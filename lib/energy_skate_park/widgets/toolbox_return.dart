import 'dart:ui';

/// EnergySkateParkScreenView.ts — return-to-toolbox hit test.
///
/// PhET uses `globalBounds.intersectsBounds(toolboxPanel.globalBounds)` with
/// **no distance threshold, no animation, no snap**.
class ToolboxReturn {
  ToolboxReturn._();

  /// AABB intersection (PhET `Bounds2.intersectsBounds`).
  static bool shouldReturn({
    required Rect toolBounds,
    required Rect toolboxBounds,
  }) =>
      toolboxBounds.overlaps(toolBounds);

  /// MeasuringTapeNode.getLocalBaseBounds() → global (base image only).
  static Rect measuringTapeBaseBounds({
    required Offset baseView,
    double imageSize = 51 * 0.8,
  }) {
    return Rect.fromLTWH(
      baseView.dx - imageSize,
      baseView.dy - imageSize,
      imageSize,
      imageSize,
    );
  }

  /// StopwatchNode.globalBounds equivalent in play-area view coords.
  static Rect stopwatchBounds({
    required Offset topLeft,
    required Size size,
  }) =>
      topLeft & size;
}
