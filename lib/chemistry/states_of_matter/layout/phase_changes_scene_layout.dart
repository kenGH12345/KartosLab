import '../transform/som_coordinate_transform.dart';

/// PhET `PhaseChangesScreenView` + `ParticleContainerNode` layout anchors.
class PhaseChangesSceneLayout {
  PhaseChangesSceneLayout._();

  /// Prefer [RightPanelLayout] for the stacked accordion column.
  static const double panelWidth = 170;
  static const double panelXInset = 15;
  static const double interPanelSpacing = 8;

  static const double heaterScale = 0.79;
  static const double heaterLogicalWidth = 120;
  static const double heaterTopGap = 30;
  static const double timeControlGapLeftOfHeater = 50;
  static const double timeControlIntrinsicWidth = 70;

  static const double thermometerWidth = 56;
  static const double thermometerTopLift = 55;
  static const double thermometerModelXFraction = 0.15;

  /// PhET `pumpPosition = Vector2(106, 466)` — node translation.
  static const double pumpTranslationX = 106;
  static const double pumpTranslationY = 466;
  /// PhET `BicyclePumpNode` default ~200×250; scaled to scene.
  static const double pumpWidth = 100;
  static const double pumpHeight = 130;

  /// Hose attaches at container left, bottom − 70 (PhET).
  static const double hoseAttachYAboveBottom = 70;

  /// Gauge: `right = area.minX + area.width * 0.2`, `top = area.top − 75`.
  static const double gaugeRightFractionOfWidth = 0.2;
  static const double gaugeTopAboveArea = 75;

  /// Dial Ø80 + collar + elbow pipe (PhET DialGaugeNode extents).
  static const double gaugeWidth = 165;

  /// Dial + readout base height; add [elbowHeight] for vertical pipe.
  static const double gaugeDialBlockHeight = 100;

  /// PhET `PRESSURE_GAUGE_ELBOW_OFFSET`.
  static const double gaugeElbowOffset = 30;

  /// PhET `PointingHandNode.WIDTH` (screen coords).
  static const double pointingHandWidth = 150;

  /// PhET `ParticleContainerNode`: hand.centerX = area.centerX + 30.
  static const double pointingHandCenterXOffset = 30;

  static const double resetRadius = 17;
  static const double resetSideInset = 15;
  static const double resetBottomInset = 5;

  static double heaterHeight() {
    // Match Gases Intro stove stack height (~140 × scale).
    return 140 * heaterScale;
  }

  static double heaterWidth() {
    // Stove (120) + slider column (40), same as Gases Intro layout.
    return (heaterLogicalWidth + 40) * heaterScale;
  }

  /// Pump [Positioned] top-left so base sits near PhET translation.
  static double pumpLeft() => pumpTranslationX - pumpWidth * 0.5;
  static double pumpTop() => pumpTranslationY - pumpHeight;

  static const double layoutWidth = SomCoordinateTransform.layoutBoundsWidth;
  static const double layoutHeight = SomCoordinateTransform.layoutBoundsHeight;
}
