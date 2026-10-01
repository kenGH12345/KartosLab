/// Unit conversion helpers for Quantum Wave Interference.
///
/// PhET property units (source of truth):
/// - wavelength: nm (photons)
/// - slitSeparation / slitWidth: mm
/// - screenDistance: m
/// - particle speed: m/s
/// - mass: kg
class QwiUnits {
  QwiUnits._();

  static const double metersPerNanometer = 1e-9;
  static const double metersPerMicrometer = 1e-6;
  static const double metersPerMillimeter = 1e-3;

  /// PhET HI/SP configs use `MICROMETER_TO_MM = 1e-3` (µm → mm property units).
  static const double millimetersPerMicrometer = 1e-3;

  /// PhET HI/SP configs use `NANOMETER_TO_MM = 1e-6` (nm → mm property units).
  static const double millimetersPerNanometer = 1e-6;

  static double nmToM(double nm) => nm * metersPerNanometer;

  static double mToNm(double m) => m / metersPerNanometer;

  static double mmToM(double mm) => mm * metersPerMillimeter;

  static double mToMm(double m) => m / metersPerMillimeter;

  static double umToMm(double um) => um * millimetersPerMicrometer;

  static double nmToMm(double nm) => nm * millimetersPerNanometer;

  static double umToM(double um) => um * metersPerMicrometer;
}
