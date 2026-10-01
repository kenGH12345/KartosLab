/// Chart window from `ChartNode.ts`.
class WaveChartWindow {
  WaveChartWindow._();

  /// Horizontal span in seconds.
  static const double timeWidth = 72e-16;

  static const double yMin = -1;
  static const double yMax = 1;

  /// Four vertical grid intervals.
  static const int verticalDivisions = 4;

  static double minTime(double time) => time - timeWidth;

  static double verticalSpacing() => timeWidth / verticalDivisions;

  /// `ChartNode.getDelta`.
  static double gridPhase(double time) {
    final spacing = verticalSpacing();
    final frac = (time / spacing) % 1;
    return (frac < 0 ? frac + 1 : frac) * spacing;
  }
}
