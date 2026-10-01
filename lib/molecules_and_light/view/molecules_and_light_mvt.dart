import 'dart:ui';

/// PhET `ModelViewTransform2.createSinglePointScaleInvertedYMapping`.
class MoleculesAndLightMvt {
  MoleculesAndLightMvt({
    this.modelOriginX = 0,
    this.modelOriginY = 0,
    this.viewOriginX = 275,
    this.viewOriginY = 150,
    this.scale = 0.10,
  });

  final double modelOriginX;
  final double modelOriginY;
  final double viewOriginX;
  final double viewOriginY;
  final double scale;

  static const double observationWidth = 500;
  static const double observationHeight = 300;
  static const double layoutWidth = 768;
  static const double layoutHeight = 504;

  Offset modelToView(double x, double y) {
    return Offset(
      viewOriginX + (x - modelOriginX) * scale,
      viewOriginY - (y - modelOriginY) * scale,
    );
  }

  double modelToViewDelta(double d) => d * scale;
}
