import 'dart:ui';

import '../model/gravity_force_constants.dart';

/// Model ↔ view transform.
///
/// PhET `ModelViewTransform2.createSinglePointScaleInvertedYMapping`:
/// model (0,0) → layout center, scale 50, +y model → −y view.
class MathCoordinateTransform {
  const MathCoordinateTransform({
    required this.viewOrigin,
    this.scale = GravityForceConstants.mvtScale,
  });

  final Offset viewOrigin;
  final double scale;

  factory MathCoordinateTransform.forLayout({
    double width = GravityForceConstants.layoutWidth,
    double height = GravityForceConstants.layoutHeight,
    double scale = GravityForceConstants.mvtScale,
  }) {
    return MathCoordinateTransform(
      viewOrigin: Offset(width / 2, height / 2),
      scale: scale,
    );
  }

  Offset modelToView(Offset p) =>
      Offset(viewOrigin.dx + p.dx * scale, viewOrigin.dy - p.dy * scale);

  Offset viewToModel(Offset p) => Offset(
        (p.dx - viewOrigin.dx) / scale,
        (viewOrigin.dy - p.dy) / scale,
      );

  double modelToViewX(double x) => viewOrigin.dx + x * scale;
  double viewToModelX(double x) => (x - viewOrigin.dx) / scale;

  double modelToViewY(double y) => viewOrigin.dy - y * scale;
  double viewToModelY(double y) => (viewOrigin.dy - y) / scale;

  double modelToViewDeltaX(double dx) => dx * scale;
  double viewToModelDeltaX(double dx) => dx / scale;
}
