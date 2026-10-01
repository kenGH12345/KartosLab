import '../bending_light_constants.dart';
import '../physics/visible_color.dart';

/// Wavelength wrapper (`LaserColor.ts`) — single-color path for Phase 1.
class LaserColor {
  const LaserColor(this.wavelength);

  /// Wavelength in meters (vacuum).
  final double wavelength;

  double get wavelengthNm => wavelength * 1e9;
}

/// `LaserColor.getColor` → `VisibleColor.wavelengthToColor`.
int wavelengthToArgb(double wavelengthMeters) {
  return visibleColorArgb(wavelengthMeters * 1e9) ?? 0xFF000000;
}

bool isWavelengthInLaserRange(double meters) {
  final nm = meters * 1e9;
  return nm >= BendingLightConstants.laserMinWavelengthNm &&
      nm <= BendingLightConstants.laserMaxWavelengthNm;
}
