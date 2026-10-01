import 'dart:ui';

/// PhET `scenery-phet/js/VisibleColor.ts` — wavelength ↔ Color lookup.
class VisibleColor {
  VisibleColor._();

  static const double minWavelength = 380;
  static const double maxWavelength = 780;
  static const double whiteWavelength = 0;

  /// Converts wavelength (nm) to a Flutter [Color].
  ///
  /// Matches scenery-phet with `reduceIntensityAtExtrema: true` by default.
  static Color wavelengthToColor(
    double wavelengthNm, {
    bool reduceIntensityAtExtrema = true,
  }) {
    final wavelength = wavelengthNm.round();
    if (wavelength == whiteWavelength) {
      return const Color(0xFFFFFFFF);
    }
    if (wavelength < minWavelength || wavelength > maxWavelength) {
      return const Color(0xFF000000);
    }

    var r = 0.0;
    var g = 0.0;
    var b = 0.0;
    if (wavelength >= 380 && wavelength <= 440) {
      r = -1 * (wavelength - 440) / (440 - 380);
      b = 1;
    } else if (wavelength > 440 && wavelength <= 490) {
      g = (wavelength - 440) / (490 - 440);
      b = 1;
    } else if (wavelength > 490 && wavelength <= 510) {
      g = 1;
      b = -1 * (wavelength - 510) / (510 - 490);
    } else if (wavelength > 510 && wavelength <= 580) {
      r = (wavelength - 510) / (580 - 510);
      g = 1;
    } else if (wavelength > 580 && wavelength <= 645) {
      r = 1;
      g = -1 * (wavelength - 645) / (645 - 580);
    } else if (wavelength > 645 && wavelength <= 780) {
      r = 1;
    }

    var intensity = 1.0;
    if (reduceIntensityAtExtrema && wavelength > 645) {
      intensity = 0.3 + 0.7 * (780 - wavelength) / (780 - 645);
    } else if (reduceIntensityAtExtrema && wavelength < 420) {
      intensity = 0.3 + 0.7 * (wavelength - 380) / (420 - 380);
    }

    int channel(double v) => (255 * (intensity * v)).round().clamp(0, 255);
    return Color.fromARGB(255, channel(r), channel(g), channel(b));
  }

  static bool isVisibleWavelength(double wavelength) =>
      wavelength >= minWavelength && wavelength <= maxWavelength;
}
