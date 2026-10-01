import 'dart:ui';

/// Constants from PhET `CurveFittingConstants.js` + ScreenView / BucketNode /
/// PointNode layout & interaction values.
class CurveFittingConstants {
  CurveFittingConstants._();

  // —— Screen / MVT ——
  static const double layoutWidth = 1024;
  static const double layoutHeight = 618;
  static const double mvtScale = 25.5;

  /// Model span of white graph background [-10, 10] (width = height = 20).
  static const double graphBackgroundSpan = 20;

  /// Left/right column outer width ≈ panelMaxWidth + margins.
  static const double columnOuterWidth = 210;

  // —— Animation ——
  /// Model units per second (return-to-bucket).
  static const double animationSpeed = 65;

  static const int maxOrderOfFit = 3;

  // —— Barometers ——
  static const double barometerBarWidth = 10;
  static const double barometerAxisHeight = 270;
  static const double barometerTickWidth = 15;
  /// χ² barometer tick width (BarometerX2Node).
  static const double barometerX2TickWidth = 10;
  /// r² barometer tick width (BarometerR2Node).
  static const double barometerR2TickWidth = 20;
  static const double barometerArrowOffset = 6;
  static const double barometerArrowHeadHeight = 12;
  static const double barometerArrowHeadWidth = 8;
  static const double barometerArrowTailWidth = 0.5;
  /// χ² axis height after reserving room for top arrow.
  static double get barometerX2AxisHeight =>
      barometerAxisHeight - barometerArrowHeadHeight - barometerArrowOffset;

  // —— Points ——
  static const double pointRadius = 8;
  /// PhET `PointNode`: `circleView.bounds.dilated(5)` for mouse/touch.
  static const double pointHitDilation = 5;
  static const double pointLineWidth = 1;
  static const double defaultDelta = 0.8;
  static const double minDelta = 1e-3;
  static const double maxDelta = 10;

  // —— Panels ——
  static const double panelCornerRadius = 5;
  static const double panelMaxWidth = 180;
  static const double panelMinWidth = 180;
  static const double panelMargin = 10;

  // —— Sliders (ascending: d, c, b, a) ——
  static const double constantMin = -10;
  static const double constantMax = 10;
  static const double constantDefault = 2.7;

  static const double linearMin = -2;
  static const double linearMax = 2;
  static const double linearDefault = 0;

  static const double quadraticMin = -1;
  static const double quadraticMax = 1;
  static const double quadraticDefault = 0;

  static const double cubicMin = -1;
  static const double cubicMax = 1;
  static const double cubicDefault = 0;

  /// Default slider values ascending [a0, a1, a2, a3] = [d, c, b, a].
  static const List<double> defaultSliderValues = [
    constantDefault,
    linearDefault,
    quadraticDefault,
    cubicDefault,
  ];

  // —— Graph model bounds ——
  /// Graph node (incl. axes/labels): x,y ∈ [-12, 12].
  static const Rect graphNodeModelBounds = Rect.fromLTRB(-12, -12, 12, 12);

  /// Axes extent.
  static const Rect graphAxesBounds = Rect.fromLTRB(-10.75, -10.75, 10.75, 10.75);

  /// White graph background (point inside-graph test).
  static const Rect graphBackgroundModelBounds =
      Rect.fromLTRB(-10, -10, 10, 10);

  /// Curve clip bounds.
  static const Rect curveClipBounds = Rect.fromLTRB(-10, -10, 10, 10);

  // —— Curve sampling (CurveShape.js) ——
  static const int numberSteps = 220;

  // —— Math epsilons (Curve.js) ——
  static const double epsilon = 1.0e-10;
  static const double determinantEpsilon = 1.0e-30;

  // —— Margins / spacing ——
  static const double screenViewXMargin = 20;
  static const double screenViewYMargin = 12;
  static const double controlsYSpacing = 12;
  static const double slidersXSpacing = 15;

  // —— Bucket (BucketNode.js, model coords) ——
  static const double bucketWidth = 4.45;
  static const double bucketHeight = bucketWidth * 0.50;
  static const double bucketPositionX = -12 - 1.5; // GRAPH_NODE minX - 1.5
  static const double bucketPositionY = -12 + 4; // GRAPH_NODE minY + 4

  /// Decorative point offsets inside the bucket (view-ish relative positions
  /// from BucketNode POINT_POSITIONS — for view only; no model points on start).
  static const List<Offset> bucketDecorativePointOffsets = [
    Offset(-41.25, 10),
    Offset(-31.25, 12.5),
    Offset(-31.25, -1.25),
    Offset(-25, 3.75),
    Offset(-23.75, -5),
    Offset(-18.75, 10),
    Offset(-15, -12.5),
    Offset(-12.5, -3.75),
    Offset(-6.25, 10),
    Offset(-6.25, -15),
    Offset(-3.75, 12.5),
    Offset(0, -12.5),
    Offset(2.5, -2.5),
    Offset(6.25, 2.5),
    Offset(6.25, 11.25),
    Offset(12.5, -6.25),
    Offset(10, -15),
    Offset(22.5, 2.5),
    Offset(28.75, 11.25),
    Offset(0, 5),
    Offset(21.25, -10),
    Offset(12.5, 11.25),
    Offset(30, -1.25),
    Offset(18.75, 11.25),
    Offset(15, -12.5),
    Offset(12.5, 2.5),
    Offset(-8.75, 2.5),
    Offset(41.25, 11.25),
    Offset(41.25, 5),
  ];

  // —— Chi-squared display ——
  static const double maxChiSquareDisplayValue = 1000;
  static const double maxChiSquaredBarometerValue = 100;
}
