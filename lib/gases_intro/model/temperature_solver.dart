import '../gases_intro_constants.dart';

/// Port of TemperatureModel @ 10c7c08.
/// T = (2/3) ⟨KE⟩ / k ; null when N = 0.
class TemperatureSolver {
  double? temperature;
  bool controlTemperatureEnabled = false;
  double initialTemperature = GasesIntroConstants.initialTemperatureDefault;

  void reset() {
    temperature = null;
    controlTemperatureEnabled = false;
    initialTemperature = GasesIntroConstants.initialTemperatureDefault;
  }

  void update({
    required int numberOfParticles,
    required double Function() getAverageKineticEnergy,
  }) {
    temperature = compute(
      numberOfParticles: numberOfParticles,
      getAverageKineticEnergy: getAverageKineticEnergy,
    );
  }

  static double? compute({
    required int numberOfParticles,
    required double Function() getAverageKineticEnergy,
  }) {
    if (numberOfParticles <= 0) return null;
    return (2 / 3) * getAverageKineticEnergy() / GasesIntroConstants.boltzmann;
  }

  /// TemperatureModel.getInitialTemperature
  double getInitialTemperature() {
    if (controlTemperatureEnabled) return initialTemperature;
    if (temperature != null) return temperature!;
    return GasesIntroConstants.initialTemperatureDefault;
  }
}
