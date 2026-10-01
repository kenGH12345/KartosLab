/// Source: `fluid-pressure-and-flow/js/common/Constants.js`
class UnderPressureConstants {
  UnderPressureConstants._();

  /// Joist layout bounds — `Bounds2(0, 0, 768, 504)`.
  static const double layoutWidth = 768;
  static const double layoutHeight = 504;

  static const double earthGravity = 9.8; // m/s^2
  static const double marsGravity = 3.71; // m/s^2
  static const double jupiterGravity = 24.79; // m/s^2

  /// Gauge dial range (Pa).
  static const double minPressure = 50000;
  static const double maxPressure = 250000;

  static const double maxPoolHeight = 3; // m

  static const double gasolineDensity = 700; // kg/m^3
  static const double honeyDensity = 1420; // kg/m^3
  static const double waterDensity = 1000; // kg/m^3

  /// Atmospheric pressure at ground (Pa).
  static const double earthAirPressure = 101325;

  /// Linear map target at model height 150 m (labeled 500 ft in source).
  static const double earthAirPressureAt500Ft = 99490;

  static const int numBarometers = 4;

  /// Initial barometer dock position (model meters).
  static const double barometerDockX = 7.75;
  static const double barometerDockY = 2.5;

  /// Ruler initial position in **view** coordinates.
  static const double rulerInitialX = 300;
  static const double rulerInitialY = 100;
}
