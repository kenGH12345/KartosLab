/// Balancing Act — shared constants from PhET `BASharedConstants.ts` / geometry.
library;

import 'dart:math' as math;

/// Source: `js/common/BASharedConstants.ts`
abstract final class BaSharedConstants {
  static const double comparisonTolerance = 1e-6;
  static const double layoutWidth = 768;
  static const double layoutHeight = 504;
  static const double resetAllButtonScale = 0.96;

  /// Intro / Lab MVT scale (px/m). Source: `BasicBalanceScreenView.ts`.
  static const double introLabMvtScale = 105;

  /// Game MVT scale (px/m). Source: `BalanceGameView.ts`.
  static const double gameMvtScale = 115;

  /// Model origin in view for Intro/Lab: `(width*0.375, height*0.79)`.
  static const double introLabOriginViewXFactor = 0.375;
  static const double introLabOriginViewYFactor = 0.79;

  /// Model origin in view for Game: `(width*0.45, height*0.86)`.
  static const double gameOriginViewXFactor = 0.45;
  static const double gameOriginViewYFactor = 0.86;
}

/// Source: `BalanceModel.ts` / `Plank.ts` geometry.
abstract final class BaGeometry {
  static const double fulcrumHeight = 0.85; // m, pivot Y
  static const double plankHeight = 0.75; // m, unrotated plank bottom Y
  static const double plankLength = 4.5; // m
  static const double plankThickness = 0.05; // m
  static const double plankMass = 75; // kg
  static const double interSnapToMarkerDistance = 0.25; // m
  static const int numSnapToPositions =
      17; // floor(4.5/0.25 - 1)

  static final double momentOfInertia = plankMass *
      ((plankLength * plankLength) + (plankThickness * plankThickness)) /
      12;

  static final double maxValidMassDistanceFromCenter =
      (numSnapToPositions - 1) * interSnapToMarkerDistance / 2; // 2.0 m

  /// `asin(plankHeight / (plankLength/2))`
  static final double maxTiltAngle = math.asin(plankHeight / (plankLength / 2));

  static const double supportColumnX = 1.625; // m from center
  static const double supportColumnWidth = 0.35; // m
  static const double fulcrumWidth = 1.0; // m
  static const double legThicknessFactor = 0.09;

  /// Display gravity for force vectors only. Source: `MassForceVector.ts`.
  static const double accelerationDueToGravity = -9.8;

  /// Mass removal animation. Source: `Mass.ts`.
  static const double minAnimationVelocity = 3; // m/s
  static const double maxRemovalAnimationDuration = 0.75; // s

  /// Angular dynamics thresholds. Source: `Plank.step`.
  static const double angularAccelerationEpsilon = 0.00001;
  static const double angularVelocityEpsilon = 0.00001;
  static const double nearLevelAngleEpsilon = 0.0001;
  static const double dampingFactor = 0.91;
}

/// Game scoring constants. Source: `BalanceGameModel.ts`.
abstract final class BaGameConstants {
  static const int maxLevels = 4;
  static const int maxPointsPerProblem = 2;
  static const int challengesPerProblemSet = 6;
  static const int maxScorePerGame =
      maxPointsPerProblem * challengesPerProblemSet; // 12
  static const int defaultMaxAttemptsAllowed = 2;
}
