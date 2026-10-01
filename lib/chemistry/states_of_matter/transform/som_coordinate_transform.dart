import 'dart:ui' show Offset, Rect;

import '../som_constants.dart';

/// PhET `ModelViewTransform2.createSinglePointScaleInvertedYMapping` for SOM.
///
/// Model origin (0,0) = particle-container lower-left; Y increases upward.
/// View Y increases downward (Flutter / ScreenView).
class SomCoordinateTransform {
  SomCoordinateTransform({
    this.layoutWidth = layoutBoundsWidth,
    this.layoutHeight = layoutBoundsHeight,
  });

  /// PhET `SOMConstants.SCREEN_VIEW_OPTIONS.layoutBounds` = 834×504.
  static const double layoutBoundsWidth = 834;
  static const double layoutBoundsHeight = 504;

  /// PhET `SOMConstants.VIEW_CONTAINER_WIDTH`.
  static const double viewContainerWidth = 280;

  /// Model → view uniform scale (pm → screen units).
  static const double scale = viewContainerWidth / SomConstants.containerWidth;

  final double layoutWidth;
  final double layoutHeight;

  /// View location of model (0,0).
  double get originX => layoutWidth * 0.325;
  double get originY => layoutHeight * 0.75;

  double modelToViewX(double modelX) => originX + modelX * scale;

  double modelToViewY(double modelY) => originY - modelY * scale;

  double modelToViewDeltaX(double modelDeltaX) => modelDeltaX * scale;

  /// Inverted-Y: positive model ΔY maps to negative view ΔY.
  double modelToViewDeltaY(double modelDeltaY) => -modelDeltaY * scale;

  double viewToModelDeltaY(double viewDeltaY) => -viewDeltaY / scale;

  /// Length / radius mapping (always positive).
  double modelToViewScale(double modelLength) => modelLength * scale;

  Offset modelToView(double modelX, double modelY) =>
      Offset(modelToViewX(modelX), modelToViewY(modelY));

  /// Interior of the particle container at [containerHeight] (model pm).
  Rect particleContainerViewBounds({
    double containerHeight = SomConstants.containerInitialHeight,
  }) {
    final left = modelToViewX(0);
    final bottom = modelToViewY(0);
    final right = modelToViewX(SomConstants.containerWidth);
    final top = modelToViewY(containerHeight);
    return Rect.fromLTRB(left, top, right, bottom);
  }
}
