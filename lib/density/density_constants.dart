/// SI / range constants from density-buoyancy-common.
///
/// Sources: `DensityBuoyancyCommonConstants.ts`, `Cuboid.ts`, `Material.ts`.
class DensityConstants {
  DensityConstants._();

  static const double litersInCubicMeter = 1000;
  static const double tolerance = 1e-7;

  /// Cuboid volume range (m³) = 1–10 L. `Cuboid.MIN_VOLUME` / `MAX_VOLUME`.
  static const double minVolume = 0.001;
  static const double maxVolume = 0.01;

  static const double minVolumeLiters = 1;
  static const double maxVolumeLiters = 10;

  static const double gravity = 9.8;
  static const double waterDensity = 1000;
  static const double waterViscosity = 8.9e-4;

  /// Default NumberProperty range on Material.density (`Material.ts`).
  static const double materialDensityMin = 0.8;
  static const double materialDensityMax = 27000;

  /// Intro/Compare cuboid NumberControl defaults.
  static const double minMass = 0.1;
  static const double maxMass = 27;
  static const double minCustomMass = 0.5;

  /// Intro ScreenView override. Compare/Mystery keep the 27 default unused.
  static const double introMaxCustomMass = 10;

  static const double numberControlDelta = 0.01;
  static const double volumeSliderSnapLiters = 0.5;

  /// Original PhET `singleCuboidIcon` / `doubleCuboidIcon` (density-buoyancy-common).
  static const String singleCuboidAsset =
      'assets/buoyancy/images/single_cuboid.png';
  static const String doubleCuboidAsset =
      'assets/buoyancy/images/double_cuboid.png';

  static const double poolWidth = 0.9;
  static const double poolDepth = 0.4;
  static const double poolGeometricVolume = 0.15;
  static const double desiredStartingPoolVolume = 0.1;
  static const double velocityCap = 5;

  static double litersFromCubicMeters(double m3) => m3 * litersInCubicMeter;
  static double cubicMetersFromLiters(double liters) =>
      liters / litersInCubicMeter;
}
