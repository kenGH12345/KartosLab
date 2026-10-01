import 'dart:ui';

/// PhET `RGBPhoton.js` — position, velocity, intensity.
class RgbPhoton {
  RgbPhoton({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.intensity,
  });

  double x;
  double y;
  double vx;
  double vy;

  /// RGB screen: 0–100 percent carried to eye.
  /// Single Bulb: 0–1 alpha intensity after filter.
  double intensity;

  void updateAnimationFrame(double newX, double newY) {
    x = newX;
    y = newY;
  }
}

/// PhET `SingleBulbPhoton.js`.
class SingleBulbPhoton extends RgbPhoton {
  SingleBulbPhoton({
    required super.x,
    required super.y,
    required super.vx,
    required super.vy,
    required super.intensity,
    required this.color,
    required this.isWhite,
    this.wavelength = -1,
  }) : wasWhite = isWhite;

  Color color;
  bool isWhite;

  /// White photons keep full intensity after filter (see SingleBulbPhotonBeam).
  final bool wasWhite;

  /// -1 for black reset photons.
  double wavelength;
  bool passedFilter = false;
}
