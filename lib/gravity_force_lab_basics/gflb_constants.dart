import 'dart:math' as math;

/// Constants from PhET `GFLBConstants.js`, `GFLBModel.js`, `GFLBMassNode.js`,
/// `GFLBScreenView.js`, and ISLC force-arrow / puller options.
class GflbConstants {
  GflbConstants._();

  // —— Physics ——
  static const double g = 6.67430e-11;
  static const double billionMultiplier = 1e9;
  static const double massMin = 1.0 * billionMultiplier;
  static const double massMax = 10.0 * billionMultiplier;
  static const double massStep = billionMultiplier;
  static const double density = 1.5;

  /// `(3 * 1e9 / (4 * pi * 1.5))^(1/3)` ≈ 541.9261846 m
  static final double constantRadius =
      math.pow((3 * massMin / density) / (4 * math.pi), 1 / 3).toDouble();

  static const double minDistanceBetweenMasses = 200;
  static const double pullPositionMax = 5000;
  static const double massPositionDelta = 100;
  static const double massStepSize = 500;

  static const double initialMass1 = 2 * billionMultiplier;
  static const double initialMass2 = 4 * billionMultiplier;
  static const double initialPosition1 = -2000;
  static const double initialPosition2 = 2000;

  static const bool defaultConstantSize = false;
  static const bool defaultShowDistance = true;
  static const bool defaultShowForceValues = true;

  // —— Layout / MVT ——
  static const double layoutWidth = 768;
  static const double layoutHeight = 464;
  static const double mvtScale = 0.05;

  /// Mass node center Y from top of layout (GFLBMassNode).
  static const double massNodeY = 215;

  /// Distance arrow Y (GFLBScreenView).
  static const double distanceArrowY = 145;

  static const double massControlsY = 385;
  static const double panelSpacing = 50;
  static const double checkboxPanelRightInset = 15;
  static const double resetTopGap = 13.5;

  // —— Force arrow (piecewise linear) ——
  static const double minArrowWidth = 0.1;
  static const double thresholdArrowWidth = 1;
  static const double maxArrowWidth = 400;
  static const double forceThresholdPercent = 7e-4;
  static const double arrowLengthFactor = 8;
  static const double forceArrowHeight1 = 125;
  static const double forceArrowHeight2 = 175;
  static const int forceReadoutDecimalPlaces = 1;

  // —— Pullers ——
  static const double pullerImageScale = 0.45;
  static const double pullerRopeLength = 40;
  static const int pullerFrameCount = 31;
  static const String pullerAssetDir =
      'assets/phet/gravity_force_lab_basics/pullers';

  /// Sphere color brighter factor when constant size is off (Mass.js).
  static const double baseColorModifier = 0.59;
}
