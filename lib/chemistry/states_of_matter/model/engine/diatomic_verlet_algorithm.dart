import '../molecule_force_and_motion_data_set.dart';
import 'abstract_verlet_algorithm.dart';
import 'diatomic_atom_position_updater.dart';

/// Diatomic (two atoms/molecule) LJ Verlet — PhET DiatomicVerletAlgorithm.
class DiatomicVerletAlgorithm extends AbstractVerletAlgorithm {
  DiatomicVerletAlgorithm(super.multipleParticleModel);

  @override
  void updateAtomPositions(MoleculeForceAndMotionDataSet moleculeDataSet) {
    DiatomicAtomPositionUpdater.updateAtomPositions(moleculeDataSet);
  }

  @override
  void initializeForces(MoleculeForceAndMotionDataSet moleculeDataSet) {
    final accelerationDueToGravity =
        multipleParticleModel.gravitationalAcceleration;
    final nextMoleculeForces = moleculeDataSet.nextMoleculeForces;
    final nextMoleculeTorques = moleculeDataSet.nextMoleculeTorques;
    for (var i = 0; i < moleculeDataSet.getNumberOfMolecules(); i++) {
      nextMoleculeForces[i]!.setXY(0, accelerationDueToGravity);
      nextMoleculeTorques[i] = 0;
    }
  }

  @override
  void updateInteractionForces(MoleculeForceAndMotionDataSet moleculeDataSet) {
    final moleculeCenterOfMassPositions =
        moleculeDataSet.getMoleculeCenterOfMassPositions();
    final nextMoleculeForces = moleculeDataSet.getNextMoleculeForces();
    final atomPositions = moleculeDataSet.getAtomPositions();
    final nextMoleculeTorques = moleculeDataSet.getNextMoleculeTorques();
    final numberOfMolecules = moleculeDataSet.numberOfMolecules;

    for (var i = 0; i < numberOfMolecules; i++) {
      final moleculeCenterOfMassIX = moleculeCenterOfMassPositions[i]!.x;
      final moleculeCenterOfMassIY = moleculeCenterOfMassPositions[i]!.y;
      for (var j = i + 1; j < numberOfMolecules; j++) {
        final moleculeCenterOfMassJX = moleculeCenterOfMassPositions[j]!.x;
        final moleculeCenterOfMassJY = moleculeCenterOfMassPositions[j]!.y;
        for (var ii = 0; ii < 2; ii++) {
          final atom1PosX = atomPositions[2 * i + ii]!.x;
          final atom1PosY = atomPositions[2 * i + ii]!.y;
          for (var jj = 0; jj < 2; jj++) {
            final atom2PosX = atomPositions[2 * j + jj]!.x;
            final atom2PosY = atomPositions[2 * j + jj]!.y;

            final dx = atom1PosX - atom2PosX;
            final dy = atom1PosY - atom2PosY;
            var distanceSquared = dx * dx + dy * dy;
            if (distanceSquared <
                AbstractVerletAlgorithm.particleInteractionDistanceThreshSqrd) {
              if (distanceSquared < AbstractVerletAlgorithm.minDistanceSquared) {
                distanceSquared = AbstractVerletAlgorithm.minDistanceSquared;
              }
              final r2inv = 1 / distanceSquared;
              final r6inv = r2inv * r2inv * r2inv;
              final forceScalar = 48 * r2inv * r6inv * (r6inv - 0.5);
              final fx = dx * forceScalar;
              final fy = dy * forceScalar;
              nextMoleculeForces[i]!.addXY(fx, fy);
              nextMoleculeForces[j]!.subtractXY(fx, fy);
              nextMoleculeTorques[i] +=
                  (atom1PosX - moleculeCenterOfMassIX) * fy -
                      (atom1PosY - moleculeCenterOfMassIY) * fx;
              nextMoleculeTorques[j] -=
                  (atom2PosX - moleculeCenterOfMassJX) * fy -
                      (atom2PosY - moleculeCenterOfMassJY) * fx;
              potentialEnergy += 4 * r6inv * (r6inv - 1) + 0.016316891136;
            }
          }
        }
      }
    }
  }

  @override
  void updateVelocitiesAndRotationRates(
    MoleculeForceAndMotionDataSet moleculeDataSet,
    double timeStep,
  ) {
    final moleculeVelocities = moleculeDataSet.getMoleculeVelocities();
    final moleculeForces = moleculeDataSet.getMoleculeForces();
    final nextMoleculeForces = moleculeDataSet.getNextMoleculeForces();
    final numberOfMolecules = moleculeDataSet.getNumberOfMolecules();
    final moleculeRotationRates = moleculeDataSet.getMoleculeRotationRates();
    final moleculeTorques = moleculeDataSet.getMoleculeTorques();
    final nextMoleculeTorques = moleculeDataSet.getNextMoleculeTorques();

    final massInverse = 1 / moleculeDataSet.getMoleculeMass();
    final inertiaInverse = 1 / moleculeDataSet.getMoleculeRotationalInertia();
    final timeStepHalf = timeStep / 2;
    var translationalKineticEnergy = 0.0;
    var rotationalKineticEnergy = 0.0;

    for (var i = 0; i < numberOfMolecules; i++) {
      final xVel = moleculeVelocities[i]!.x +
          timeStepHalf *
              (moleculeForces[i]!.x + nextMoleculeForces[i]!.x) *
              massInverse;
      final yVel = moleculeVelocities[i]!.y +
          timeStepHalf *
              (moleculeForces[i]!.y + nextMoleculeForces[i]!.y) *
              massInverse;
      moleculeVelocities[i]!.setXY(xVel, yVel);
      moleculeRotationRates[i] += timeStepHalf *
          (moleculeTorques[i] + nextMoleculeTorques[i]) *
          inertiaInverse;
      final v = moleculeVelocities[i]!;
      translationalKineticEnergy +=
          0.5 * moleculeDataSet.moleculeMass * (v.x * v.x + v.y * v.y);
      rotationalKineticEnergy += 0.5 *
          moleculeDataSet.moleculeRotationalInertia *
          moleculeRotationRates[i] *
          moleculeRotationRates[i];

      moleculeForces[i]!
          .setXY(nextMoleculeForces[i]!.x, nextMoleculeForces[i]!.y);
      moleculeTorques[i] = nextMoleculeTorques[i];
    }

    if (numberOfMolecules > 0) {
      calculatedTemperature = (2 / 3) *
          (translationalKineticEnergy + rotationalKineticEnergy) /
          numberOfMolecules;
    } else {
      calculatedTemperature = multipleParticleModel.minModelTemperature!;
    }
  }
}
