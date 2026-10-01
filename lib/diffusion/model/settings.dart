import '../diffusion_constants.dart';

/// DiffusionSettings — one side of the container.
class DiffusionSettings {
  int numberOfParticles = DiffusionConstants.numberOfParticlesDefault;
  int mass = DiffusionConstants.massDefault;
  int radius = DiffusionConstants.radiusDefault;
  int initialTemperature = DiffusionConstants.temperatureDefault;

  void reset() {
    numberOfParticles = DiffusionConstants.numberOfParticlesDefault;
    mass = DiffusionConstants.massDefault;
    radius = DiffusionConstants.radiusDefault;
    initialTemperature = DiffusionConstants.temperatureDefault;
  }

  /// Forces particle array rebuild with same N — DiffusionSettings.restart
  void restart(void Function(int n) applyCount) {
    final n = numberOfParticles;
    applyCount(0);
    applyCount(n);
  }

  static int clampCount(int v) {
    final c = v.clamp(
      DiffusionConstants.numberOfParticlesMin,
      DiffusionConstants.numberOfParticlesMax,
    );
    return (c / DiffusionConstants.numberOfParticlesDelta).round() *
        DiffusionConstants.numberOfParticlesDelta;
  }

  static int clampMass(int v) => v
      .clamp(DiffusionConstants.massMin, DiffusionConstants.massMax)
      .toInt();

  static int clampRadius(int v) {
    final c = v.clamp(DiffusionConstants.radiusMin, DiffusionConstants.radiusMax);
    return (c / DiffusionConstants.radiusDelta).round() *
        DiffusionConstants.radiusDelta;
  }

  static int clampTemperature(int v) {
    final c = v.clamp(
      DiffusionConstants.temperatureMin,
      DiffusionConstants.temperatureMax,
    );
    return (c / DiffusionConstants.temperatureDelta).round() *
        DiffusionConstants.temperatureDelta;
  }
}
