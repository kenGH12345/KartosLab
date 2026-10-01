import 'dart:ui' show Offset, Size;

import '../masb_constants.dart';

/// Model (m, y-up) ↔ view (px, y-down) transform.
class MasbCoordinateTransform {
  const MasbCoordinateTransform({
    this.originX = MasbConstants.mvtOffsetX,
    this.originY = MasbConstants.mvtOffsetY,
    this.scale = MasbConstants.mvtScale,
  });

  final double originX;
  final double originY;
  final double scale;

  double modelToViewX(double m) => originX + m * scale;
  double modelToViewY(double m) => originY - m * scale;
  double modelToViewDeltaY(double m) => -m * scale;
  double modelToViewDeltaX(double m) => m * scale;

  Offset modelToView(double x, double y) =>
      Offset(modelToViewX(x), modelToViewY(y));

  double viewToModelX(double vx) => (vx - originX) / scale;
  double viewToModelY(double vy) => (originY - vy) / scale;

  Offset viewToModel(Offset view) =>
      Offset(viewToModelX(view.dx), viewToModelY(view.dy));
}

class MasbLayoutPolicy {
  MasbLayoutPolicy._();

  static const double logicalWidth = MasbConstants.layoutWidth;
  static const double logicalHeight = MasbConstants.layoutHeight;

  /// Uniform scale so the 768×504 logical sim fills the available viewport.
  /// No upper clamp at 1.0 — that caused a small inset “card” on large screens.
  static double fitScale(double maxWidth, double maxHeight) {
    if (maxWidth <= 0 || maxHeight <= 0) return 1;
    final s = maxWidth / logicalWidth < maxHeight / logicalHeight
        ? maxWidth / logicalWidth
        : maxHeight / logicalHeight;
    return s.clamp(0.55, 3.0);
  }

  static Size physicalSize(double scale) =>
      Size(logicalWidth * scale, logicalHeight * scale);
}
