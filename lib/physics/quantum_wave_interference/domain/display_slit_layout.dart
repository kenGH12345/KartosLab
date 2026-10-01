import '../constants/qwi_constants.dart';

/// PhET `getDisplaySlitLayout.ts` — display-coordinate slit geometry.
class DisplaySlitLayout {
  const DisplaySlitLayout({
    required this.displaySlitSeparation,
    required this.displaySlitWidth,
  });

  final double displaySlitSeparation;
  final double displaySlitWidth;

  static const double minDisplaySlitSeparationPx = 40;
  static const double maxDisplaySlitSeparationPx = 220;
  static const double displaySlitWidthPx = 22;

  /// Maps physical slit separation into display units matching [regionHeight].
  static DisplaySlitLayout compute({
    required double slitSeparation,
    required double slitSeparationMin,
    required double slitSeparationMax,
    required double regionHeight,
  }) {
    final range = slitSeparationMax - slitSeparationMin;
    final fraction = range > 0 ? (slitSeparation - slitSeparationMin) / range : 0.5;
    final displaySeparationPixels = minDisplaySlitSeparationPx +
        (maxDisplaySlitSeparationPx - minDisplaySlitSeparationPx) * fraction.clamp(0.0, 1.0);
    final scale = regionHeight / QwiConstants.waveRegionHeight;
    return DisplaySlitLayout(
      displaySlitSeparation: displaySeparationPixels * scale,
      displaySlitWidth: displaySlitWidthPx * scale,
    );
  }
}
