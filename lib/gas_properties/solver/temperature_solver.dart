import '../gas_properties_constants.dart';
import 'gas_law_solver.dart';

/// Temperature from particle KE — TemperatureModel.ts
class TemperatureSolver {
  double? temperatureKelvin;
  bool setInjectionTemperatureEnabled = false;
  double injectionTemperature = GasPropertiesConstants.initialTemperatureDefault;

  void reset() {
    temperatureKelvin = null;
    setInjectionTemperatureEnabled = false;
    injectionTemperature = GasPropertiesConstants.initialTemperatureDefault;
  }

  void update({
    required int numberOfParticles,
    required double Function() getAverageKineticEnergy,
  }) {
    temperatureKelvin = GasLawSolver.temperatureFromAverageKe(
      n: numberOfParticles,
      averageKe: numberOfParticles > 0 ? getAverageKineticEnergy() : 0,
    );
  }

  /// Temperature used for injection speed.
  double getInitialTemperature() {
    if (setInjectionTemperatureEnabled) return injectionTemperature;
    if (temperatureKelvin != null) return temperatureKelvin!;
    return GasPropertiesConstants.initialTemperatureDefault;
  }
}
