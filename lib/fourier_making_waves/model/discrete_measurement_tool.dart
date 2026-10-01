import '../fmw_constants.dart';

/// Discrete λ / T measurement tool. PhET `DiscreteMeasurementTool.ts`
class DiscreteMeasurementTool {
  DiscreteMeasurementTool({this.symbol = 'λ'});

  final String symbol;

  /// Checkbox selected. Default false.
  bool isSelected = false;

  /// Harmonic order n (1-based). Default 1.
  int order = 1;

  /// Left-jaw / clock-center position in **view coordinates** of the
  /// harmonics chart local space (origin = chart top-left). PhET uses
  /// ScreenView coords; we keep chart-local + screen overlay mapping.
  double positionX = FmwConstants.chartWidth * 0.15;
  double positionY = FmwConstants.chartHeight * 0.5;

  void resetSelection() {
    isSelected = false;
    order = 1;
  }

  void resetPosition() {
    positionX = FmwConstants.chartWidth * 0.15;
    positionY = FmwConstants.chartHeight * 0.5;
  }

  void reset() {
    resetSelection();
    resetPosition();
  }

  /// Clamp order when number of harmonics shrinks. PhET link behavior.
  void syncWithNumberOfHarmonics(int numberOfHarmonics) {
    if (order > numberOfHarmonics) {
      isSelected = false;
      order = numberOfHarmonics.clamp(1, FmwConstants.maxHarmonics);
    }
  }
}
