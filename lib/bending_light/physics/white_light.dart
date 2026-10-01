import 'dart:math' as math;

import 'cie_tables.dart';
import 'visible_color.dart';

/// Stroke color from `WhiteLightCanvasNode.paintCanvas`.
///
/// The file comment mentions Bresenham. The method that actually runs uses
/// canvas `lighter` strokes: D65 alpha, then `VisibleColor.wavelengthToColor`.
/// Returns null when the source skips the ray (`a <= 1e-5` or D65 missing).
(int, int, int)? whiteLightStrokeRgb({
  required double wavelengthNm,
  required double powerFraction,
}) {
  final wavelength = wavelengthNm.round();
  final d65 = CieTables.d65[wavelength];
  if (d65 == null) return null;
  final a = (d65 * math.sqrt(powerFraction) / 118).clamp(0.0, 1.0) / 8;
  if (a <= 1e-5) return null;
  final argb = visibleColorArgb(wavelength.toDouble());
  if (argb == null) return null;
  final (r, g, b) = argbChannels(argb);
  return (
    (r * a / 0.9829313170995397).round(),
    (g * a).round(),
    (b * a / 0.7144456644926587).round(),
  );
}

/// `BendingLightConstants.XYZ_TO_RGB_MATRIX`. Defined in source, not called by
/// `WhiteLightCanvasNode.paintCanvas`. Kept so tests can check the table.
class XyzToRgb {
  XyzToRgb._();

  static const List<List<double>> matrix = [
    [3.2404542, -1.5371385, -0.4985314],
    [-0.9692660, 1.8760108, 0.0415560],
    [0.0556434, -0.2040259, 1.0572252],
  ];

  /// XYZ * D65 at [nm]. Null if the source tables have no row.
  static (double, double, double)? xyzIntensity(int nm) {
    final xyz = CieTables.xyz[nm];
    final d65 = CieTables.d65[nm];
    if (xyz == null || d65 == null) return null;
    return (xyz.$1 * d65, xyz.$2 * d65, xyz.$3 * d65);
  }

  /// Linear RGB (no sRGB gamma). Can be outside 0–255; source does not clip here.
  static (double, double, double)? linearRgb(int nm) {
    final v = xyzIntensity(nm);
    if (v == null) return null;
    double dot(List<double> row) => row[0] * v.$1 + row[1] * v.$2 + row[2] * v.$3;
    return (dot(matrix[0]), dot(matrix[1]), dot(matrix[2]));
  }
}
