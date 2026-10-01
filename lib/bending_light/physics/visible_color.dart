/// `VisibleColor.wavelengthToColor` lookup (`scenery-phet/js/VisibleColor.ts`).
///
/// Wavelength is in nanometers. IR/UV with no fallback color returns null.
/// This is the table white-light strokes and single-color rays use.
int? visibleColorArgb(double wavelengthNm, {bool reduceIntensityAtExtrema = true}) {
  final wavelength = wavelengthNm.round();
  if (wavelength == 0) return 0xFFFFFFFF;
  if (wavelength < 380 || wavelength > 780) return null;

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
  return (0xFF << 24) | (channel(r) << 16) | (channel(g) << 8) | channel(b);
}

(int, int, int) argbChannels(int argb) => (
      (argb >> 16) & 0xFF,
      (argb >> 8) & 0xFF,
      argb & 0xFF,
    );
