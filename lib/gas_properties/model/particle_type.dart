import '../gas_properties_constants.dart';

/// Heavy / Light species — mass & radius from PhET constants.
enum ParticleType {
  heavy,
  light;

  double get mass => switch (this) {
        ParticleType.heavy => GasPropertiesConstants.heavyMass,
        ParticleType.light => GasPropertiesConstants.lightMass,
      };

  double get radius => switch (this) {
        ParticleType.heavy => GasPropertiesConstants.heavyRadius,
        ParticleType.light => GasPropertiesConstants.lightRadius,
      };
}
