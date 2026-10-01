import 'dart:math' as math;

import '../molecules_and_light_constants.dart';
import 'micro_photon.dart';
import 'molecule.dart';

/// PhET `PhotonAbsorptionModel` used by Molecules and Light.
///
/// Default: infrared, emitter off, carbon monoxide, running, normal speed.
class MoleculesAndLightModel {
  MoleculesAndLightModel({math.Random? random}) : _random = random ?? math.Random() {
    _installMolecule(MoleculeType.carbonMonoxide);
  }

  final math.Random _random;
  final List<MicroPhoton> photons = [];

  bool emitterOn = false;
  LightType light = LightType.infrared;
  MoleculeType moleculeType = MoleculeType.carbonMonoxide;
  bool running = true;
  TimeSpeed timeSpeed = TimeSpeed.normal;

  late Molecule molecule;

  double _emissionCountdown = double.infinity;
  double _emissionPeriod = double.infinity;

  double nextDouble() => _random.nextDouble();

  void setEmitterOn(bool on) {
    emitterOn = on;
    final period = on
        ? MoleculesAndLightConstants.emitterOnPeriod
        : double.infinity;
    if (_emissionPeriod == double.infinity &&
        period != double.infinity &&
        photons.isEmpty) {
      _emissionCountdown = 0;
    } else if (period == double.infinity) {
      _emissionCountdown = double.infinity;
    } else if (period < _emissionCountdown) {
      _emissionCountdown = period;
    }
    _emissionPeriod = period;
  }

  /// Changing the selected wavelength clears flying photons only.
  /// An already absorbed photon keeps the wavelength stored on its strategy.
  void setLight(LightType next) {
    if (next == light) {
      return;
    }
    light = next;
    photons.clear();
    if (emitterOn) {
      _emissionCountdown = 0;
    }
  }

  void setMolecule(MoleculeType next) {
    if (next == moleculeType) {
      return;
    }
    moleculeType = next;
    _installMolecule(next);
  }

  void _installMolecule(MoleculeType type) {
    moleculeType = type;
    molecule = Molecule.create(
      type,
      nextDouble: nextDouble,
      onEmit: photons.add,
    );
  }

  void step(double dt) {
    if (dt > MoleculesAndLightConstants.largeDtReject) {
      return;
    }
    if (!running) {
      return;
    }
    final scaled =
        timeSpeed == TimeSpeed.slow ? dt * MoleculesAndLightConstants.slowSpeedFactor : dt;
    _stepBody(scaled);
  }

  void manualStep([double dt = 1 / 60]) {
    _stepBody(dt);
  }

  void _stepBody(double dt) {
    final absorbed = <MicroPhoton>[];
    for (final photon in photons) {
      if (molecule.queryAbsorbPhoton(photon)) {
        absorbed.add(photon);
      }
      photon.step(dt);
    }
    photons.removeWhere(absorbed.contains);
    photons.removeWhere(
      (p) => p.x > 2000 || p.x < -2000 || p.y.abs() > 1500,
    );
    if (_emissionCountdown != double.infinity) {
      _emissionCountdown -= dt;
      if (_emissionCountdown <= 0) {
        _emit(_emissionCountdown.abs());
        _emissionCountdown = _emissionPeriod;
      }
    }
    molecule.step(dt);
  }

  void _emit(double advance) {
    final photon = MicroPhoton(light.wavelength);
    photon.x = MoleculesAndLightConstants.photonEmissionX +
        MoleculesAndLightConstants.photonVelocity * advance;
    photon.y = 0;
    photon.setVelocity(MoleculesAndLightConstants.photonVelocity, 0);
    photons.add(photon);
  }

  void reset() {
    photons.clear();
    emitterOn = false;
    light = LightType.infrared;
    running = true;
    timeSpeed = TimeSpeed.normal;
    _emissionCountdown = double.infinity;
    _emissionPeriod = double.infinity;
    _installMolecule(MoleculeType.carbonMonoxide);
  }
}
