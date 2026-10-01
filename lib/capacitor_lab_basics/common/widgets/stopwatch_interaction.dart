import 'dart:ui' show Offset, Rect;

import '../model/clb_model.dart';

/// Stopwatch play-area layout — mirrors scenery-phet `StopwatchNode` size approx.
class ClbStopwatchLayout {
  ClbStopwatchLayout._();

  static const double width = 140;
  static const double height = 88;

  static Rect boundsOf(ClbModel model) => Rect.fromLTWH(
        model.stopwatchX,
        model.stopwatchY,
        width,
        height,
      );

  /// PhET ToolboxPanel extract: pointer − (width/2, height/2).
  static Offset topLeftCenteredOn(Offset pointerCanvas) => Offset(
        pointerCanvas.dx - width / 2,
        pointerCanvas.dy - height / 2,
      );
}

/// `CLBLightBulbScreenView.js:65-66` — full bounds ∩ toolbox (not eroded).
/// Calls [ClbModel.returnStopwatchToToolbox] (`Stopwatch.reset`).
bool maybeReturnStopwatchToToolbox({
  required ClbModel model,
  required Rect toolboxBounds,
}) {
  if (!model.stopwatchVisible) return false;
  if (!toolboxBounds.overlaps(ClbStopwatchLayout.boundsOf(model))) {
    return false;
  }
  model.returnStopwatchToToolbox();
  return true;
}
