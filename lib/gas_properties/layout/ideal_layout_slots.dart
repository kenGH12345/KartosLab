import '../gas_properties_constants.dart';
import '../transform/gas_coordinate_transform.dart';

/// Ideal / Explore / Energy ScreenView layout slots in PhET reference space
/// (layoutBounds ≈ 1008×618 from GasProperties ScreenView usage).
///
/// Measured from IdealGasLawScreenView.ts + IdealScreenView.ts:
/// - RIGHT_PANEL_WIDTH 225, SCREEN_VIEW margins 20
/// - thermometer: centerX = container.right−50, bottom = topY+60
/// - pressureGauge: left = container.right−2, centerY = topY+30
/// - bicyclePump: left = container.right, bottom = layoutBottom−margin
/// - heaterCooler: left ≈ container.right − Δ(widthMin), bottom = layoutBottom−margin
/// - timeControl: left ≈ container.right − Δ(defaultWidth), bottom = layoutBottom−margin
/// - resetAll: right = layoutRight−margin, bottom = layoutBottom−margin
class IdealLayoutSlots {
  IdealLayoutSlots._();

  static const double width = GasLayoutPolicy.logicalWidth;
  static const double height = GasLayoutPolicy.logicalHeight;
  static const double margin = GasPropertiesConstants.screenViewMargin;
  static const double rightPanelWidth = GasPropertiesConstants.rightPanelWidth;
  static const double panelsYSpacing = 8;

  /// Right edge of right control rail.
  static double get panelsRight => width - margin;

  /// Left edge of right control rail (must not be overlapped by scene instruments).
  static double get panelsLeft => panelsRight - rightPanelWidth;

  static double get panelsTop => margin;
  static double get panelsMaxHeight =>
      height - 2 * margin - 70; // leave room for reset / time controls

  /// Container right wall in view coords (model x=0).
  static double containerRightX(GasCoordinateTransform t) => t.modelToViewX(0);

  static double containerTopY(GasCoordinateTransform t, double topPm) =>
      t.modelToViewY(topPm);

  static double containerBottomY(GasCoordinateTransform t, double bottomPm) =>
      t.modelToViewY(bottomPm);

  static double containerLeftX(GasCoordinateTransform t, double leftPm) =>
      t.modelToViewX(leftPm);

  /// Thermometer: [centerX, bottom] — IdealGasLawScreenView L218–220.
  static (double centerX, double bottom) thermometerAnchor(
    GasCoordinateTransform t,
    double containerTopPm,
  ) {
    final right = containerRightX(t);
    final topY = containerTopY(t, containerTopPm);
    return (right - 50, topY + 60);
  }

  /// Pressure gauge: [left, centerY] — IdealGasLawScreenView L230–232.
  static (double left, double centerY) pressureGaugeAnchor(
    GasCoordinateTransform t,
    double containerTopPm,
  ) {
    final right = containerRightX(t);
    final topY = containerTopY(t, containerTopPm);
    return (right - 2, topY + 30);
  }

  /// Bicycle pump left/bottom — IdealGasLawScreenView L206–207.
  static (double left, double bottom) pumpAnchor(GasCoordinateTransform t) {
    return (containerRightX(t), height - margin);
  }

  /// Heater/cooler left for Ideal (variable width) — uses widthMin.
  static (double left, double bottom) heaterAnchor(GasCoordinateTransform t) {
    final right = containerRightX(t);
    final left =
        right - t.modelToViewDelta(GasPropertiesConstants.widthMin);
    return (left, height - margin);
  }

  /// Time control (Pause/Step) left/bottom — IdealGasLawScreenView L309–310.
  static (double left, double bottom) timeControlAnchor(
    GasCoordinateTransform t,
  ) {
    final right = containerRightX(t);
    final left =
        right - t.modelToViewDelta(GasPropertiesConstants.widthDefault);
    return (left, height - margin);
  }

  static (double right, double bottom) resetAnchor() =>
      (width - margin, height - margin);
}
