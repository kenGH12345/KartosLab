import 'dart:math' as math;

import '../molecules_and_light_constants.dart';
import 'micro_photon.dart';
import 'molecule_geometry.dart';
import 'photon_absorption_strategy.dart';

/// PhET `Molecule` absorption map + geometry for view.
class Molecule {
  Molecule._(this.type, {required this.nextDouble, required this.onEmit})
      : geometry = geometryFor(type);

  final MoleculeType type;
  final MoleculeGeometry geometry;
  final double Function() nextDouble;
  final void Function(MicroPhoton photon) onEmit;

  final Map<double, PhotonAbsorptionStrategy> strategies = {};
  late PhotonAbsorptionStrategy activeStrategy;

  double centerX = 0;
  double centerY = 0;
  double vibrationRadians = 0;
  double rotationRadians = 0;
  bool vibrating = false;
  bool rotating = false;
  bool rotatingClockwise = true;
  bool highElectronicEnergy = false;
  bool brokenApart = false;

  factory Molecule.create(
    MoleculeType type, {
    required double Function() nextDouble,
    required void Function(MicroPhoton photon) onEmit,
  }) {
    final molecule = Molecule._(type, nextDouble: nextDouble, onEmit: onEmit);
    molecule.activeStrategy = NullPhotonAbsorptionStrategy(molecule);
    for (final light in LightType.values) {
      final strategy = strategyFor(type, light, molecule);
      if (strategy != null) {
        molecule.strategies[light.wavelength] = strategy;
      }
    }
    return molecule;
  }

  bool get isHoldingPhoton =>
      activeStrategy is PhotonHoldStrategy && activeStrategy.isPhotonAbsorbed;

  /// Atom offsets after vibration stretch and whole-molecule rotation.
  List<(double x, double y)> atomPositions() {
    final mag = vibrating
        ? MoleculesAndLightConstants.vibrationMagnitude *
            math.sin(vibrationRadians)
        : 0.0;
    final cosR = math.cos(rotationRadians);
    final sinR = math.sin(rotationRadians);
    final result = <(double, double)>[];
    for (final atom in geometry.atoms) {
      var ox = atom.offsetX;
      var oy = atom.offsetY;
      if (vibrating && (ox != 0 || oy != 0)) {
        final len = math.sqrt(ox * ox + oy * oy);
        ox += (ox / len) * mag;
        oy += (oy / len) * mag;
      }
      result.add((
        centerX + ox * cosR - oy * sinR,
        centerY + ox * sinR + oy * cosR,
      ));
    }
    return result;
  }

  bool queryAbsorbPhoton(MicroPhoton photon) {
    if (brokenApart) {
      return false;
    }
    if (distance(photon.x, photon.y, centerX, centerY) >=
        MoleculesAndLightConstants.photonAbsorptionDistance) {
      return false;
    }
    if (isHoldingPhoton) {
      return false;
    }
    final candidate = strategies[photon.wavelength];
    if (candidate == null) {
      return false;
    }
    if (candidate.queryAndAbsorbPhoton(photon, nextDouble)) {
      activeStrategy = candidate;
      return true;
    }
    return false;
  }

  void emitPhoton(double wavelength) {
    final photon = MicroPhoton(wavelength);
    final angle = nextDouble() * math.pi * 2;
    photon.setVelocity(
      MoleculesAndLightConstants.photonVelocity * math.cos(angle),
      MoleculesAndLightConstants.photonVelocity * math.sin(angle),
    );
    photon.x = centerX;
    photon.y = centerY;
    onEmit(photon);
  }

  void step(double dt) {
    if (activeStrategy.isPhotonAbsorbed ||
        (activeStrategy is BreakApartStrategy &&
            activeStrategy.isPhotonAbsorbed)) {
      activeStrategy.step(dt);
    }
    if (vibrating) {
      vibrationRadians +=
          dt * MoleculesAndLightConstants.vibrationFrequency * 2 * math.pi;
    }
    if (rotating) {
      final dir = rotatingClockwise ? -1.0 : 1.0;
      rotationRadians +=
          dt * MoleculesAndLightConstants.rotationRate * 2 * math.pi * dir;
    }
  }

  void reset() {
    vibrating = false;
    rotating = false;
    highElectronicEnergy = false;
    brokenApart = false;
    vibrationRadians = 0;
    rotationRadians = 0;
    for (final strategy in strategies.values) {
      strategy.reset();
    }
    activeStrategy = NullPhotonAbsorptionStrategy(this);
  }
}
