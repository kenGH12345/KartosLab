import '../gas_properties_constants.dart';

/// Pure Ideal Gas Law helpers — PV = NkT (PhET internal units).
class GasLawSolver {
  GasLawSolver._();

  /// P in kPa = (N k T / V) * PRESSURE_CONVERSION_SCALE
  static double pressureKpa({
    required int n,
    required double temperatureK,
    required double volumePm3,
  }) {
    if (n <= 0 || volumePm3 <= 0 || temperatureK < 0) return 0;
    final p = (n * GasPropertiesConstants.boltzmann * temperatureK) / volumePm3;
    return p * GasPropertiesConstants.pressureConversionScale;
  }

  /// T = (2/3) ⟨KE⟩ / k ; null if N=0
  static double? temperatureFromAverageKe({
    required int n,
    required double averageKe,
  }) {
    if (n <= 0) return null;
    return (2 / 3) * averageKe / GasPropertiesConstants.boltzmann;
  }

  /// V = NkT / P_internal  where P_internal = P_kPa / scale
  static double volumeFromNtp({
    required int n,
    required double temperatureK,
    required double pressureKpa,
  }) {
    assert(n > 0 && pressureKpa > 0);
    final p = pressureKpa / GasPropertiesConstants.pressureConversionScale;
    return (n * GasPropertiesConstants.boltzmann * temperatureK) / p;
  }

  /// T = PV / (Nk) with P in kPa
  static double temperatureFromNpv({
    required int n,
    required double pressureKpa,
    required double volumePm3,
  }) {
    assert(n > 0 && pressureKpa > 0 && volumePm3 > 0);
    final p = pressureKpa / GasPropertiesConstants.pressureConversionScale;
    return (p * volumePm3) / (n * GasPropertiesConstants.boltzmann);
  }

  static double assertFinite(double v, [String label = 'value']) {
    assert(v.isFinite, '$label is not finite: $v');
    return v;
  }
}
