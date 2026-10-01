import '../transform/som_coordinate_transform.dart';

/// PhET `StatesScreenView` layout anchors (logical 834×504).
class StatesSceneLayout {
  StatesSceneLayout._();

  static const double controlPanelXInset = 15;
  static const double controlPanelYInset = 10;
  static const double controlPanelWidth = 175;

  /// PhET `StatesPhaseControlNode` VBox spacing between Solid/Liquid/Gas.
  static const double phaseButtonSpacing = 10;

  static const double resetRadius = 17;
  static const double resetSideInset = 15;
  static const double resetBottomInset = 5;

  static const double heaterScale = 0.79;
  static const double heaterLogicalWidth = 120;
  static const double heaterTopGap = 30;
  static const double timeControlGapLeftOfHeater = 50;
  static const double timeControlIntrinsicWidth = 70;

  static const double thermometerWidth = 56;
  static const double thermometerTopLift = 55;

  /// Thermometer X offset = −0.3 × containerWidth (model).
  static const double thermometerModelXFraction = 0.3;

  static double heaterHeight() {
    return 140 * heaterScale;
  }

  static double heaterWidth() {
    return (heaterLogicalWidth + 40) * heaterScale;
  }

  static const double layoutWidth = SomCoordinateTransform.layoutBoundsWidth;
  static const double layoutHeight = SomCoordinateTransform.layoutBoundsHeight;
}
