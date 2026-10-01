import 'dart:ui' show Offset, Size;

import '../gas_properties_constants.dart';

/// PhET ModelViewTransform2.createOffsetXYScaleMapping
/// BaseModel: origin (645,475), scale +0.040 / −0.040.
class GasCoordinateTransform {
  const GasCoordinateTransform({
    this.originX = GasPropertiesConstants.modelOriginOffsetX,
    this.originY = GasPropertiesConstants.modelOriginOffsetY,
    this.scale = GasPropertiesConstants.mvtScale,
  });

  /// Diffusion uses (670, 520).
  static const GasCoordinateTransform diffusion = GasCoordinateTransform(
    originX: GasPropertiesConstants.diffusionModelOriginOffsetX,
    originY: GasPropertiesConstants.diffusionModelOriginOffsetY,
  );

  final double originX;
  final double originY;
  final double scale;

  double modelToViewX(double pm) => originX + pm * scale;
  double modelToViewY(double pm) => originY - pm * scale;
  double modelToViewDelta(double pm) => pm * scale;

  Offset modelToView(double xPm, double yPm) =>
      Offset(modelToViewX(xPm), modelToViewY(yPm));

  double viewToModelX(double vx) => (vx - originX) / scale;
  double viewToModelY(double vy) => (originY - vy) / scale;

  Offset viewToModel(Offset view) =>
      Offset(viewToModelX(view.dx), viewToModelY(view.dy));
}

/// Logical ScreenView layoutBounds + uniform fit.
class GasLayoutPolicy {
  GasLayoutPolicy._();

  static const double logicalWidth = 1008;
  static const double logicalHeight = 618;
  static const double rightPanelWidth = GasPropertiesConstants.rightPanelWidth;
  static const double leftEnergyPanelWidth = 205;
  static const double screenMargin = GasPropertiesConstants.screenViewMargin;

  static double fitScale(double maxWidth, double maxHeight) {
    if (maxWidth <= 0 || maxHeight <= 0) return 1;
    final s = (maxWidth / logicalWidth < maxHeight / logicalHeight)
        ? maxWidth / logicalWidth
        : maxHeight / logicalHeight;
    if (s > 1) return 1;
    if (s < 0.55) return 0.55;
    return s;
  }

  static Size physicalSize(double scale) =>
      Size(logicalWidth * scale, logicalHeight * scale);
}
