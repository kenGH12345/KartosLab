import 'dart:ui';

/// Color scheme relating concentration to color — `SoluteColorScheme.ts`.
///
/// [maxConcentration] is the saturation point (mol/L).
class SoluteColorScheme {
  const SoluteColorScheme({
    required this.minConcentration,
    required this.minColor,
    required this.midConcentration,
    required this.midColor,
    required this.maxConcentration,
    required this.maxColor,
  });

  final double minConcentration; // mol/L
  final Color minColor;
  final double midConcentration; // mol/L
  final Color midColor;
  final double maxConcentration; // mol/L (= saturated)
  final Color maxColor;

  /// Linear RGB interpolation across the three concentration stops.
  Color concentrationToColor(double concentration) {
    if (concentration >= maxConcentration) {
      return maxColor;
    }
    if (concentration <= minConcentration) {
      return minColor;
    }
    if (concentration <= midConcentration) {
      final t = (concentration - minConcentration) /
          (midConcentration - minConcentration);
      return Color.lerp(minColor, midColor, t)!;
    }
    final t = (concentration - midConcentration) /
        (maxConcentration - midConcentration);
    return Color.lerp(midColor, maxColor, t)!;
  }
}
