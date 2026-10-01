import 'dart:math' as math;
import 'dart:typed_data';

import '../som_constants.dart';
import 'engine/water_molecule_structure.dart';
import 'som_vec2.dart';

/// Parallel arrays for molecule positions/velocities/forces — PhET MoleculeForceAndMotionDataSet.
class MoleculeForceAndMotionDataSet {
  MoleculeForceAndMotionDataSet(this.atomsPerMolecule) {
    final maxNumMolecules =
        (SomConstants.maxNumAtoms / atomsPerMolecule).floor();

    atomPositions = List<SomVec2?>.filled(SomConstants.maxNumAtoms, null);
    moleculeCenterOfMassPositions =
        List<SomVec2?>.filled(maxNumMolecules, null);
    moleculeVelocities = List<SomVec2?>.filled(maxNumMolecules, null);
    moleculeForces = List<SomVec2?>.filled(maxNumMolecules, null);
    nextMoleculeForces = List<SomVec2?>.filled(maxNumMolecules, null);
    insideContainer = List<bool>.filled(maxNumMolecules, false);

    moleculeRotationAngles = Float64List(maxNumMolecules);
    moleculeRotationRates = Float64List(maxNumMolecules);
    moleculeTorques = Float64List(maxNumMolecules);
    nextMoleculeTorques = Float64List(maxNumMolecules);

    if (atomsPerMolecule == 1) {
      moleculeMass = 1;
      moleculeRotationalInertia = 1;
    } else if (atomsPerMolecule == 2) {
      moleculeMass = 2;
      moleculeRotationalInertia = moleculeMass *
          math.pow(SomConstants.diatomicParticleDistance, 2) /
          2;
    } else if (atomsPerMolecule == 3) {
      // Water-only triatomic settings (PhET MoleculeForceAndMotionDataSet).
      moleculeMass = 1.5;
      moleculeRotationalInertia = WaterMoleculeStructure.rotationalInertia;
    } else {
      moleculeMass = 1;
      moleculeRotationalInertia = 1;
    }
  }

  int numberOfAtoms = 0;
  int numberOfMolecules = 0;
  final int atomsPerMolecule;

  late final List<SomVec2?> atomPositions;
  late final List<SomVec2?> moleculeCenterOfMassPositions;
  late final List<SomVec2?> moleculeVelocities;
  late final List<SomVec2?> moleculeForces;
  late final List<SomVec2?> nextMoleculeForces;
  late final List<bool> insideContainer;

  late final Float64List moleculeRotationAngles;
  late final Float64List moleculeRotationRates;
  late final Float64List moleculeTorques;
  late final Float64List nextMoleculeTorques;

  late double moleculeMass;
  late double moleculeRotationalInertia;

  double getTotalKineticEnergy() {
    var translationalKineticEnergy = 0.0;
    var rotationalKineticEnergy = 0.0;
    final particleMass = moleculeMass;
    final numberOfParticles = getNumberOfMolecules();

    if (atomsPerMolecule > 1) {
      final rotationalInertia = moleculeRotationalInertia;
      for (var i = 0; i < numberOfParticles; i++) {
        final v = moleculeVelocities[i]!;
        translationalKineticEnergy +=
            0.5 * particleMass * (v.x * v.x + v.y * v.y);
        rotationalKineticEnergy += 0.5 *
            rotationalInertia *
            moleculeRotationRates[i] *
            moleculeRotationRates[i];
      }
    } else {
      for (var i = 0; i < numberOfParticles; i++) {
        final v = moleculeVelocities[i]!;
        translationalKineticEnergy +=
            0.5 * particleMass * (v.x * v.x + v.y * v.y);
      }
    }

    return translationalKineticEnergy + rotationalKineticEnergy;
  }

  double getTemperature() {
    return (2 / 3) * getTotalKineticEnergy() / getNumberOfMolecules();
  }

  int getNumberOfMolecules() => numberOfAtoms ~/ atomsPerMolecule;

  double getMoleculeRotationalInertia() => moleculeRotationalInertia;

  double getMoleculeMass() => moleculeMass;

  double getMoleculeKineticEnergy(int moleculeIndex) {
    assert(moleculeIndex >= 0 && moleculeIndex < numberOfMolecules);
    final v = moleculeVelocities[moleculeIndex]!;
    final translational =
        0.5 * moleculeMass * (v.x * v.x + v.y * v.y);
    final rotational = 0.5 *
        moleculeRotationalInertia *
        moleculeRotationRates[moleculeIndex] *
        moleculeRotationRates[moleculeIndex];
    return translational + rotational;
  }

  int getNumberOfRemainingSlots() {
    return (SomConstants.maxNumAtoms / atomsPerMolecule).floor() -
        (numberOfAtoms ~/ atomsPerMolecule);
  }

  int getAtomsPerMolecule() => atomsPerMolecule;

  List<SomVec2?> getAtomPositions() => atomPositions;

  int getNumberOfAtoms() => numberOfAtoms;

  List<SomVec2?> getMoleculeCenterOfMassPositions() =>
      moleculeCenterOfMassPositions;

  List<SomVec2?> getMoleculeVelocities() => moleculeVelocities;

  List<SomVec2?> getMoleculeForces() => moleculeForces;

  List<SomVec2?> getNextMoleculeForces() => nextMoleculeForces;

  Float64List getMoleculeRotationAngles() => moleculeRotationAngles;

  Float64List getMoleculeRotationRates() => moleculeRotationRates;

  Float64List getMoleculeTorques() => moleculeTorques;

  Float64List getNextMoleculeTorques() => nextMoleculeTorques;

  bool addMolecule(
    List<SomVec2> atomPos,
    SomVec2 moleculeCenterOfMassPosition,
    SomVec2 moleculeVelocity,
    double moleculeRotationRate,
    bool inside,
  ) {
    if (getNumberOfRemainingSlots() == 0) {
      return false;
    }

    for (var i = 0; i < atomsPerMolecule; i++) {
      atomPositions[i + numberOfAtoms] = atomPos[i].copy();
    }
    final numMolecules = numberOfAtoms ~/ atomsPerMolecule;
    moleculeCenterOfMassPositions[numMolecules] = moleculeCenterOfMassPosition;
    moleculeVelocities[numMolecules] = moleculeVelocity;
    moleculeRotationRates[numMolecules] = moleculeRotationRate;
    insideContainer[numMolecules] = inside;
    moleculeForces[numMolecules] = SomVec2(0, 0);
    nextMoleculeForces[numMolecules] = SomVec2(0, 0);

    numberOfAtoms += atomsPerMolecule;
    numberOfMolecules++;
    return true;
  }

  void removeMolecule(int moleculeIndex) {
    assert(moleculeIndex < numberOfAtoms / atomsPerMolecule);

    for (var i = moleculeIndex;
        i < numberOfAtoms / atomsPerMolecule - 1;
        i++) {
      moleculeCenterOfMassPositions[i] =
          moleculeCenterOfMassPositions[i + 1];
      moleculeVelocities[i] = moleculeVelocities[i + 1];
      moleculeForces[i] = moleculeForces[i + 1];
      nextMoleculeForces[i] = nextMoleculeForces[i + 1];
      moleculeRotationAngles[i] = moleculeRotationAngles[i + 1];
      moleculeRotationRates[i] = moleculeRotationRates[i + 1];
      moleculeTorques[i] = moleculeTorques[i + 1];
      nextMoleculeTorques[i] = nextMoleculeTorques[i + 1];
      insideContainer[i] = insideContainer[i + 1];
    }

    for (var i = moleculeIndex * atomsPerMolecule;
        i < (numberOfAtoms - atomsPerMolecule);
        i += atomsPerMolecule) {
      for (var j = 0; j < atomsPerMolecule; j++) {
        atomPositions[i + j] =
            atomPositions[i + atomsPerMolecule + j];
      }
    }

    numberOfAtoms -= atomsPerMolecule;
    numberOfMolecules--;
  }
}
