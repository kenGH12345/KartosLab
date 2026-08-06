import 'dart:ui';

import '../model/filter.dart';

/// Pure-function color model for additive RGB mixing.
class ColorModel {
  ColorModel._();

  /// Mix three color intensities into a single Color.
  static Color mixRGB(double r, double g, double b) {
    int ri = (r / 100 * 255).clamp(0, 255).round();
    int gi = (g / 100 * 255).clamp(0, 255).round();
    int bi = (b / 100 * 255).clamp(0, 255).round();
    return Color.fromARGB(255, ri, gi, bi);
  }

  /// Apply a filter to a photon color. Returns null if all channels blocked.
  static Color? applyFilter(Color photonColor, Filter filter) {
    final (pr, pg, pb) = filter.passRates;
    int r = ((photonColor.r * 255.0).round() * pr).round();
    int g = ((photonColor.g * 255.0).round() * pg).round();
    int b = ((photonColor.b * 255.0).round() * pb).round();
    if (r == 0 && g == 0 && b == 0) return null;
    return Color.fromARGB(255, r, g, b);
  }

  /// Name a color for accessibility labels.
  static String colorName(Color c) {
    int r = (c.r * 255.0).round();
    int g = (c.g * 255.0).round();
    int b = (c.b * 255.0).round();
    if (r > 200 && g < 50 && b < 50) return 'Red';
    if (r < 50 && g > 200 && b < 50) return 'Green';
    if (r < 50 && g < 50 && b > 200) return 'Blue';
    if (r > 200 && g > 200 && b < 50) return 'Yellow';
    if (r > 200 && g < 50 && b > 200) return 'Magenta';
    if (r < 50 && g > 200 && b > 200) return 'Cyan';
    if (r > 200 && g > 200 && b > 200) return 'White';
    if (r < 30 && g < 30 && b < 30) return 'Black';
    return 'Mixed';
  }

  /// Check if a color matches a named target within tolerance.
  static bool colorMatches(Color actual, String targetName, {int tolerance = 30}) {
    int r = (actual.r * 255.0).round();
    int g = (actual.g * 255.0).round();
    int b = (actual.b * 255.0).round();
    switch (targetName.toLowerCase()) {
      case 'red':     return r > 200 && g < tolerance && b < tolerance;
      case 'green':   return r < tolerance && g > 200 && b < tolerance;
      case 'blue':    return r < tolerance && g < tolerance && b > 200;
      case 'yellow':  return r > 200 && g > 200 && b < tolerance;
      case 'magenta': return r > 200 && g < tolerance && b > 200;
      case 'cyan':    return r < tolerance && g > 200 && b > 200;
      case 'white':   return r > 200 && g > 200 && b > 200;
      case 'black':   return r < tolerance && g < tolerance && b < tolerance;
      default: return false;
    }
  }
}
