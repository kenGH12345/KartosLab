/// Wavelengths from PhET `WavelengthConstants` (meters) and motion constants
/// from `PhotonAbsorptionModel` / `Molecule` (picometers).
class MoleculesAndLightConstants {
  static const double microwaveWavelength = 0.2;
  static const double infraredWavelength = 850e-9;
  static const double visibleWavelength = 580e-9;
  static const double ultravioletWavelength = 100e-9;

  static const double photonEmissionX = -1350;
  static const double photonVelocity = 3000;
  static const double emitterOnPeriod = 0.8;
  static const double slowSpeedFactor = 0.5;
  static const double photonAbsorptionDistance = 100;
  static const double minPhotonHoldTime = 1.1;
  static const double maxPhotonHoldTime = 1.3;
  static const double defaultAbsorptionProbability = 0.5;
  static const double largeDtReject = 0.2;
  static const double vibrationFrequency = 5;
  static const double rotationRate = 1.1;
  static const double vibrationMagnitude = 20;
}

enum LightType {
  microwave,
  infrared,
  visible,
  ultraviolet;

  double get wavelength => switch (this) {
        LightType.microwave => MoleculesAndLightConstants.microwaveWavelength,
        LightType.infrared => MoleculesAndLightConstants.infraredWavelength,
        LightType.visible => MoleculesAndLightConstants.visibleWavelength,
        LightType.ultraviolet =>
          MoleculesAndLightConstants.ultravioletWavelength,
      };

  static LightType fromWavelength(double wavelength) {
    for (final type in LightType.values) {
      if (type.wavelength == wavelength) {
        return type;
      }
    }
    throw ArgumentError('unknown wavelength $wavelength');
  }
}

enum MoleculeType {
  carbonMonoxide,
  nitrogen,
  oxygen,
  carbonDioxide,
  methane,
  water,
  nitrogenDioxide,
  ozone,
}

enum TimeSpeed { normal, slow }
