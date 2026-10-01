/// Constants from `DensityBuoyancyCommonConstants.ts` and
/// `DensityBuoyancyCommonQueryParameters.ts`.
///
/// LOCAL SOURCE SNAPSHOT: density-buoyancy-common HEAD `0c835c64`.
/// PINNED_LOCKFILE_SHA `0295f8f6` — PROVENANCE MISMATCH OPEN P1.
class BuoyancyPhysicsConstants {
  BuoyancyPhysicsConstants._();

  static const double tolerance = 1e-7;
  static const double litersInCubicMeter = 1000;

  static const double poolVolume = 0.15;
  static const double poolWidth = 0.9;
  static const double poolDepth = 0.4;
  static double get poolHeight => poolVolume / poolWidth / poolDepth;

  /// Target fluid volume including displacement of immersed solids at start.
  static const double desiredStartingPoolVolume = 0.1;

  static const double slip = 0.01;
  static const double velocityCap = 5;

  /// p2FixedTimeStep default.
  static const double fixedTimeStep = 1 / 120;

  /// p2MaxSubSteps default.
  static const int maxSubSteps = 30;

  /// p2PointerBaseForce. p2PointerMassForce default is 0.
  static const double pointerBaseForce = 2500;
  static const double pointerMassForce = 0;

  /// Mass.startDrag lift before constraint.
  static const double startDragOffset = 0.0001;

  static const double p2Restitution = 0;

  static const double viscosityMultiplier = 1;
  static const double viscositySubmergedRatio = 0;
  static const double viscosityMassCutoff = 0.5;

  static const double fluidDensityMinKgPerM3 = 500;
  static const double fluidDensityMaxKgPerM3 = 15000;

  static const double materialDensityMin = 0.8;
  static const double materialDensityMax = 27000;

  static const double gravityMin = 0.1;
  static const double gravityMax = 25;
  static const double gEarth = 9.8;
}
