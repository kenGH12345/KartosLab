import 'dart:math' as math;

import '../molecules_and_light_constants.dart';
import 'micro_photon.dart';
import 'molecule.dart';

/// PhET `PhotonAbsorptionStrategy`.
abstract class PhotonAbsorptionStrategy {
  PhotonAbsorptionStrategy(this.molecule);

  final Molecule molecule;
  double absorptionProbability =
      MoleculesAndLightConstants.defaultAbsorptionProbability;
  bool isPhotonAbsorbed = false;
  double photonHoldCountdownTime = 0;

  bool queryAndAbsorbPhoton(MicroPhoton photon, double Function() nextDouble) {
    final absorbed = !isPhotonAbsorbed && nextDouble() < absorptionProbability;
    if (absorbed) {
      isPhotonAbsorbed = true;
      photonHoldCountdownTime = MoleculesAndLightConstants.minPhotonHoldTime +
          nextDouble() *
              (MoleculesAndLightConstants.maxPhotonHoldTime -
                  MoleculesAndLightConstants.minPhotonHoldTime);
    }
    return absorbed;
  }

  void step(double dt);

  void reset() {
    isPhotonAbsorbed = false;
    photonHoldCountdownTime = 0;
  }
}

class NullPhotonAbsorptionStrategy extends PhotonAbsorptionStrategy {
  NullPhotonAbsorptionStrategy(super.molecule);

  @override
  bool queryAndAbsorbPhoton(MicroPhoton photon, double Function() nextDouble) {
    return false;
  }

  @override
  void step(double dt) {}
}

/// PhET `PhotonHoldStrategy` — remembers the absorbed photon wavelength.
abstract class PhotonHoldStrategy extends PhotonAbsorptionStrategy {
  PhotonHoldStrategy(super.molecule);

  double? absorbedWavelength;

  @override
  bool queryAndAbsorbPhoton(MicroPhoton photon, double Function() nextDouble) {
    final absorbed = super.queryAndAbsorbPhoton(photon, nextDouble);
    if (absorbed) {
      absorbedWavelength = photon.wavelength;
      photonAbsorbed();
    }
    return absorbed;
  }

  void photonAbsorbed();

  void reemitPhoton() {
    molecule.emitPhoton(absorbedWavelength!);
    molecule.activeStrategy = NullPhotonAbsorptionStrategy(molecule);
    isPhotonAbsorbed = false;
  }

  @override
  void step(double dt) {
    photonHoldCountdownTime -= dt;
    if (photonHoldCountdownTime <= 0) {
      reemitPhoton();
    }
  }
}

class VibrationStrategy extends PhotonHoldStrategy {
  VibrationStrategy(super.molecule);

  @override
  void photonAbsorbed() {
    molecule.vibrating = true;
  }

  @override
  void reemitPhoton() {
    super.reemitPhoton();
    molecule.vibrating = false;
  }
}

class RotationStrategy extends PhotonHoldStrategy {
  RotationStrategy(super.molecule);

  @override
  void photonAbsorbed() {
    molecule.rotatingClockwise = molecule.nextDouble() < 0.5;
    molecule.rotating = true;
  }

  @override
  void reemitPhoton() {
    super.reemitPhoton();
    molecule.rotating = false;
  }
}

class ExcitationStrategy extends PhotonHoldStrategy {
  ExcitationStrategy(super.molecule);

  @override
  void photonAbsorbed() {
    molecule.highElectronicEnergy = true;
  }

  @override
  void reemitPhoton() {
    super.reemitPhoton();
    molecule.highElectronicEnergy = false;
  }
}

class BreakApartStrategy extends PhotonAbsorptionStrategy {
  BreakApartStrategy(super.molecule);

  @override
  void step(double dt) {
    molecule.brokenApart = true;
    molecule.activeStrategy = NullPhotonAbsorptionStrategy(molecule);
  }
}

PhotonAbsorptionStrategy? strategyFor(MoleculeType type, LightType light, Molecule molecule) {
  PhotonAbsorptionStrategy? s(PhotonAbsorptionStrategy strategy) => strategy;
  switch (type) {
    case MoleculeType.carbonMonoxide:
    case MoleculeType.water:
      return switch (light) {
        LightType.microwave => s(RotationStrategy(molecule)),
        LightType.infrared => s(VibrationStrategy(molecule)),
        _ => null,
      };
    case MoleculeType.carbonDioxide:
    case MoleculeType.methane:
      return light == LightType.infrared ? s(VibrationStrategy(molecule)) : null;
    case MoleculeType.nitrogenDioxide:
      return switch (light) {
        LightType.microwave => s(RotationStrategy(molecule)),
        LightType.infrared => s(VibrationStrategy(molecule)),
        LightType.visible => s(ExcitationStrategy(molecule)),
        LightType.ultraviolet => s(BreakApartStrategy(molecule)),
      };
    case MoleculeType.ozone:
      return switch (light) {
        LightType.microwave => s(RotationStrategy(molecule)),
        LightType.infrared => s(VibrationStrategy(molecule)),
        LightType.ultraviolet => s(BreakApartStrategy(molecule)),
        LightType.visible => null,
      };
    case MoleculeType.nitrogen:
    case MoleculeType.oxygen:
      return null;
  }
}

double distance(double x1, double y1, double x2, double y2) {
  final dx = x1 - x2;
  final dy = y1 - y2;
  return math.sqrt(dx * dx + dy * dy);
}
