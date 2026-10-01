import 'package:kratos/under_pressure/model/under_pressure_math.dart';

/// Display unit system — source `measureUnitsProperty`.
enum MeasureUnits {
  metric,
  atmosphere,
  english,
}

/// Source: `fluid-pressure-and-flow/js/common/model/Units.js`
///
/// Internal pressure is always Pascals.
class UnderPressureUnits {
  UnderPressureUnits._();

  static const double atmospherePerPascal = 9.8692e-6;
  static const double psiPerPascal = 145.04e-6;
  static const double feetPerMeter = 3.2808399;
  static const double gravityEnglishPerMetric = 32.16 / 9.80665;
  static const double fluidDensityEnglishPerMetric = 62.4 / 1000.0;

  static const String kPaLabel = 'kPa';
  static const String atmLabel = 'atm';
  static const String psiLabel = 'psi';
  static const String mPerSPerSLabel = 'm/s²';
  static const String ftPerSPerSLabel = 'ft/s²';
  static const String densityMetricLabel = 'kg/m³';
  static const String densityEnglishLabel = 'lb/ft³';

  static double feetToMeters(double feet) => feet / feetPerMeter;

  static double pascalsToKPa(double pa) => pa / 1000;
  static double pascalsToAtm(double pa) => pa * atmospherePerPascal;
  static double pascalsToPsi(double pa) => pa * psiPerPascal;

  /// `Units.getPressureString(pressure, measureUnits, abbreviated)`.
  static String getPressureString(
    double pressurePa,
    MeasureUnits units, {
    bool abbreviated = false,
  }) {
    switch (units) {
      case MeasureUnits.metric:
        final v = UnderPressureMath.toFixed(
          pascalsToKPa(pressurePa),
          abbreviated ? 1 : 3,
        );
        return '$v $kPaLabel';
      case MeasureUnits.atmosphere:
        final v = UnderPressureMath.toFixed(
          pascalsToAtm(pressurePa),
          abbreviated ? 2 : 4,
        );
        return '$v $atmLabel';
      case MeasureUnits.english:
        final v = UnderPressureMath.toFixed(
          pascalsToPsi(pressurePa),
          abbreviated ? 2 : 4,
        );
        return '$v $psiLabel';
    }
  }

  /// `Units.getGravityString`.
  static String getGravityString(double gravity, MeasureUnits units) {
    if (units == MeasureUnits.english) {
      final v = UnderPressureMath.toFixed(
        gravityEnglishPerMetric * gravity,
        1,
      );
      return '$v $ftPerSPerSLabel';
    }
    final v = UnderPressureMath.toFixed(gravity, 1);
    return '$v $mPerSPerSLabel';
  }

  /// `Units.getFluidDensityString`.
  static String getFluidDensityString(double density, MeasureUnits units) {
    late final double value;
    late final String label;
    if (units == MeasureUnits.english) {
      value = fluidDensityEnglishPerMetric * density;
      label = densityEnglishLabel;
    } else {
      value = density;
      label = densityMetricLabel;
    }
    final decimals = value >= 100 ? 0 : 1;
    final v = UnderPressureMath.toFixed(value, decimals);
    return '$v $label';
  }
}
