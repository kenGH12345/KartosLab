/// Constants from PhET `VectorAdditionConstants` + `VectorAdditionQueryParameters` defaults.
/// Local source: vector-addition `1.3.0-dev.0`.
class VectorAdditionConstants {
  VectorAdditionConstants._();

  static const double modelToViewScale = 14.5;

  /// Default graph bounds: (-5,-5)-(45,25) → 50×30 (even dimensions required).
  static const double defaultGraphMinX = -5;
  static const double defaultGraphMinY = -5;
  static const double defaultGraphMaxX = 45;
  static const double defaultGraphMaxY = 25;

  static const double axesArrowXExtension = 20;
  static const double axesArrowYExtension = 15;

  static const double layoutWidth = 1024;
  static const double layoutHeight = 618;
  static const double screenViewXMargin = 20;
  static const double screenViewYMargin = 16;
  static const double spaceBelowVectorToolbox = 15;

  /// Right GraphControlPanel / Base Vectors content width (PhET RIGHT_PANEL_WIDTH).
  static const double rightPanelWidth = 175;

  /// Vector Values FixedSizeAccordionBox content (PhET Dimension2(500, 45)).
  static const double vectorValuesContentWidth = 500;
  static const double vectorValuesContentHeight = 45;

  /// Equation FixedSizeAccordionBox content (PhET Dimension2(670, 50)).
  static const double equationContentWidth = 670;
  static const double equationContentHeight = 50;

  /// Outer chrome around fixed accordion content (margins + expand button row).
  static const double accordionChromePad = 18;

  /// Extra vertical room so VaNumberPicker fits Equation bar (PhET scales content).
  static const double equationBarMinHeight = 78;

  static const double polarAngleIntervalDegrees = 5;
  static const double vectorTailDragMargin = 1;
  static const double zeroThreshold = 1e-10;

  static const double vectorDragThreshold = 10;
  static const double polarSnapDistance = 1;

  static const double headWidth = 12;
  static const double headHeight = 14;
  static const double tailWidth = 3.5;
  static const double fractionalHeadHeight = 0.5;
  static const double componentTailWidth = 3;
  static const List<double> componentTailDash = [6, 3];

  static const double vectorMouseAreaDilation = 3;
  static const double vectorTouchAreaDilation = 3;
  static const double tipMouseAreaDilation = 6;
  static const double tipTouchAreaDilation = 8;
  static const double shortMagnitude = 3;
  static const double smallHeadScale = 0.65;

  static const double animationSpeed = 75; // model units / second

  static const double baseVectorLineWidth = 1.5;

  /// Equations coefficient — PhET `COEFFICIENT_RANGE` / default 1.
  static const int coefficientMin = -5;
  static const int coefficientMax = 5;
  static const int coefficientDefault = 1;

  static const int xyComponentMin = -10;
  static const int xyComponentMax = 10;
  static const int magnitudeMin = -10;
  static const int magnitudeMax = 10;
  static const int signedAngleMin = -180;
  static const int signedAngleMax = 180;

  /// Unsigned picker max — PhET uses `360 - POLAR_ANGLE_INTERVAL` (355).
  /// 0 and 360 are the same; UI never displays 360.
  static const int unsignedAngleMin = 0;
  static const int unsignedAngleMax = 355;

  /// Angle arc (VectorAngleNode / CurvedArrowNode)
  static const double maxCurvedArrowRadius = 25;
  static const double maxRadiusScale = 0.79;

  static const int labVectorsPerVectorSet = 10;
  static const int vectorValueDecimalPlaces = 1;

  static const double majorGridSpacing = 5;
  static const double minorGridSpacing = 1;
  static const double tickLabelSpacing = 10;

  /// Joist ScreenView.DEFAULT_LAYOUT_BOUNDS assumed 1024×618 for DEFAULT_BOTTOM_LEFT.
  static const double defaultGraphBottomLeftX =
      0 + axesArrowXExtension + 10; // 30
  static const double defaultGraphBottomLeftY =
      layoutHeight - axesArrowYExtension - 45; // 558
}
