/// SI unit labels for Buoyancy shared domain.
///
/// Length m, mass kg, density kg/m³, force N, time s, volume m³.
class BuoyancyUnits {
  BuoyancyUnits._();

  static const double litersInCubicMeter = 1000;

  static double litersFromCubicMeters(double m3) => m3 * litersInCubicMeter;
  static double cubicMetersFromLiters(double liters) =>
      liters / litersInCubicMeter;
}
