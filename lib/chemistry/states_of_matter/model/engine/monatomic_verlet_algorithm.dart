import '../molecule_force_and_motion_data_set.dart';
import '../som_vec2.dart';
import 'abstract_verlet_algorithm.dart';
import 'monatomic_atom_position_updater.dart';

/// Monatomic normalized LJ Verlet — PhET MonatomicVerletAlgorithm.
class MonatomicVerletAlgorithm extends AbstractVerletAlgorithm {
  MonatomicVerletAlgorithm(super.multipleParticleModel);

  double epsilon = 1;
  final SomVec2 _velocityVector = SomVec2(0, 0);

  @override
  void setScaledEpsilon(double scaledEpsilon) {
    epsilon = scaledEpsilon;
  }

  @override
  double getScaledEpsilon() => epsilon;

  @override
  void updateAtomPositions(MoleculeForceAndMotionDataSet moleculeDataSet) {
    MonatomicAtomPositionUpdater.updateAtomPositions(moleculeDataSet);
  }

  @override
  void initializeForces(MoleculeForceAndMotionDataSet moleculeDataSet) {
    final accelerationDueToGravity =
        multipleParticleModel.gravitationalAcceleration;
    final nextAtomForces = moleculeDataSet.nextMoleculeForces;
    for (var i = 0; i < moleculeDataSet.getNumberOfMolecules(); i++) {
      nextAtomForces[i]!.setXY(0, accelerationDueToGravity);
    }
  }

  @override
  void updateInteractionForces(MoleculeForceAndMotionDataSet moleculeDataSet) {
    final numberOfAtoms = moleculeDataSet.numberOfMolecules;
    final atomCenterOfMassPositions =
        moleculeDataSet.moleculeCenterOfMassPositions;
    final nextAtomForces = moleculeDataSet.nextMoleculeForces;

    for (var i = 0; i < numberOfAtoms; i++) {
      final atomCenterOfMassPositionsIX = atomCenterOfMassPositions[i]!.x;
      final atomCenterOfMassPositionsIY = atomCenterOfMassPositions[i]!.y;
      final nextAtomForcesI = nextAtomForces[i]!;

      for (var j = i + 1; j < numberOfAtoms; j++) {
        var dx =
            atomCenterOfMassPositionsIX - atomCenterOfMassPositions[j]!.x;
        var dy =
            atomCenterOfMassPositionsIY - atomCenterOfMassPositions[j]!.y;
        var distanceSqrd = dx * dx + dy * dy;
        if (distanceSqrd < AbstractVerletAlgorithm.minDistanceSquared) {
          distanceSqrd = AbstractVerletAlgorithm.minDistanceSquared;
        }

        if (distanceSqrd == 0) {
          dx = 1;
          dy = 1;
          distanceSqrd = 2;
        }

        if (distanceSqrd <
            AbstractVerletAlgorithm.particleInteractionDistanceThreshSqrd) {
          final r2inv = 1 / distanceSqrd;
          final r6inv = r2inv * r2inv * r2inv;
          final forceScalar =
              48 * r2inv * r6inv * (r6inv - 0.5) * epsilon;
          final forceX = dx * forceScalar;
          final forceY = dy * forceScalar;
          nextAtomForcesI.addXY(forceX, forceY);
          nextAtomForces[j]!.subtractXY(forceX, forceY);
        }
      }
    }
  }

  @override
  void updateVelocitiesAndRotationRates(
    MoleculeForceAndMotionDataSet moleculeDataSet,
    double timeStep,
  ) {
    final numberOfAtoms = moleculeDataSet.numberOfAtoms;
    final atomVelocities = moleculeDataSet.moleculeVelocities;
    final atomForces = moleculeDataSet.moleculeForces;
    final nextAtomForces = moleculeDataSet.nextMoleculeForces;
    final timeStepHalf = timeStep / 2;
    var totalKineticEnergy = 0.0;
    var velocityVector = _velocityVector;

    for (var i = 0; i < numberOfAtoms; i++) {
      final atomVelocity = atomVelocities[i]!;
      final moleculeForce = atomForces[i]!;
      velocityVector = velocityVector
        ..setXY(
          atomVelocity.x +
              timeStepHalf * (moleculeForce.x + nextAtomForces[i]!.x),
          atomVelocity.y +
              timeStepHalf * (moleculeForce.y + nextAtomForces[i]!.y),
        );
      if (velocityVector.magnitude > 10) {
        velocityVector.setMagnitude(10);
      }

      atomVelocity.set(velocityVector);
      totalKineticEnergy +=
          ((atomVelocity.x * atomVelocity.x) +
              (atomVelocity.y * atomVelocity.y)) /
          2;

      moleculeForce.setXY(nextAtomForces[i]!.x, nextAtomForces[i]!.y);
    }

    if (numberOfAtoms > 0) {
      calculatedTemperature = (2 / 3) * (totalKineticEnergy / numberOfAtoms);
    } else {
      calculatedTemperature = multipleParticleModel.minModelTemperature!;
    }
  }
}
