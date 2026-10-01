import '../molecule_force_and_motion_data_set.dart';
import 'abstract_verlet_algorithm.dart';
import 'water_atom_position_updater.dart';

/// Water (H2O) Verlet with coulomb "hollywooding" — PhET WaterVerletAlgorithm.
class WaterVerletAlgorithm extends AbstractVerletAlgorithm {
  WaterVerletAlgorithm(super.multipleParticleModel)
      : massInverse =
            1 / multipleParticleModel.moleculeDataSet!.getMoleculeMass(),
        inertiaInverse = 1 /
            multipleParticleModel.moleculeDataSet!
                .getMoleculeRotationalInertia(),
        normalCharges = List<double>.filled(3, 0),
        alteredCharges = List<double>.filled(3, 0);

  static const double waterFullyMeltedTemperature = 0.3;
  static const double waterFullyMeltedElectrostaticForce = 1.0;
  static const double waterFullyFrozenTemperature = 0.22;
  static const double waterFullyFrozenElectrostaticForce = 4.25;
  static const double maxRepulsiveScalingFactorForWater = 5.25;
  static const double maxRotationRate = 16; // revolutions per second
  static const double temperatureBelowWhichGravityIncreases = 0.10;

  final double massInverse;
  final double inertiaInverse;
  final List<double> normalCharges;
  final List<double> alteredCharges;

  @override
  void updateAtomPositions(MoleculeForceAndMotionDataSet moleculeDataSet) {
    WaterAtomPositionUpdater.updateAtomPositions(moleculeDataSet);
  }

  @override
  void initializeForces(MoleculeForceAndMotionDataSet moleculeDataSet) {
    final temperatureSetPoint = multipleParticleModel.temperatureSetPoint;
    var accelerationDueToGravity =
        multipleParticleModel.gravitationalAcceleration;
    if (temperatureSetPoint < temperatureBelowWhichGravityIncreases) {
      accelerationDueToGravity = accelerationDueToGravity *
          (1 +
              (temperatureBelowWhichGravityIncreases - temperatureSetPoint) *
                  0.32);
    }
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
        moleculeDataSet.moleculeCenterOfMassPositions;
    final atomPositions = moleculeDataSet.atomPositions;
    final nextMoleculeForces = moleculeDataSet.nextMoleculeForces;
    final nextMoleculeTorques = moleculeDataSet.nextMoleculeTorques;
    final temperatureSetPoint = multipleParticleModel.temperatureSetPoint;

    assert(moleculeDataSet.getAtomsPerMolecule() == 3);

    late final double q0;
    late final double repulsiveForceScalingFactor;

    if (temperatureSetPoint < waterFullyFrozenTemperature) {
      q0 = waterFullyFrozenElectrostaticForce;
      repulsiveForceScalingFactor = maxRepulsiveScalingFactorForWater;
    } else if (temperatureSetPoint > waterFullyMeltedTemperature) {
      q0 = waterFullyMeltedElectrostaticForce;
      repulsiveForceScalingFactor = 1;
    } else {
      final temperatureFactor = (temperatureSetPoint -
              waterFullyFrozenTemperature) /
          (waterFullyMeltedTemperature - waterFullyFrozenTemperature);
      q0 = waterFullyFrozenElectrostaticForce -
          (temperatureFactor *
              (waterFullyFrozenElectrostaticForce -
                  waterFullyMeltedElectrostaticForce));
      repulsiveForceScalingFactor = maxRepulsiveScalingFactorForWater -
          (temperatureFactor * (maxRepulsiveScalingFactorForWater - 1));
    }
    normalCharges[0] = -2 * q0;
    normalCharges[1] = q0;
    normalCharges[2] = q0;
    alteredCharges[0] = -2 * q0;
    alteredCharges[1] = 1.67 * q0;
    alteredCharges[2] = 0.33 * q0;

    final numberOfMolecules = moleculeDataSet.getNumberOfMolecules();
    for (var i = 0; i < numberOfMolecules; i++) {
      final moleculeCenterOfMassPosition1 = moleculeCenterOfMassPositions[i]!;
      final m1x = moleculeCenterOfMassPosition1.x;
      final m1y = moleculeCenterOfMassPosition1.y;
      final nextMoleculeForceI = nextMoleculeForces[i];

      final chargesA = (i % 2 == 0) ? normalCharges : alteredCharges;

      for (var j = i + 1; j < numberOfMolecules; j++) {
        final moleculeCenterOfMassPosition2 = moleculeCenterOfMassPositions[j]!;
        final m2x = moleculeCenterOfMassPosition2.x;
        final m2y = moleculeCenterOfMassPosition2.y;
        final nextMoleculeForceJ = nextMoleculeForces[j];

        var dx = m1x - m2x;
        var dy = m1y - m2y;
        var distanceSquared = _max(
          dx * dx + dy * dy,
          AbstractVerletAlgorithm.minDistanceSquared,
        );
        if (distanceSquared <
            AbstractVerletAlgorithm.particleInteractionDistanceThreshSqrd) {
          final chargesB = (j % 2 == 0) ? normalCharges : alteredCharges;

          var r2inv = 1 / distanceSquared;
          final r6inv = r2inv * r2inv * r2inv;

          var forceScalar =
              48 * r2inv * r6inv * ((r6inv * repulsiveForceScalingFactor) - 0.5);
          var forceX = dx * forceScalar;
          var forceY = dy * forceScalar;
          nextMoleculeForceI!.addXY(forceX, forceY);
          nextMoleculeForceJ!.subtractXY(forceX, forceY);
          potentialEnergy += 4 * r6inv * (r6inv - 1) + 0.016316891136;

          for (var ii = 0; ii < 3; ii++) {
            final atomIndex1 = 3 * i + ii;
            if ((atomIndex1 + 1) % 6 == 0) {
              continue;
            }

            final chargeAii = chargesA[ii];
            final atomPosition1 = atomPositions[atomIndex1]!;
            final a1x = atomPosition1.x;
            final a1y = atomPosition1.y;

            for (var jj = 0; jj < 3; jj++) {
              final atomIndex2 = 3 * j + jj;
              if ((atomIndex2 + 1) % 6 == 0) {
                continue;
              }

              final atomPosition2 = atomPositions[atomIndex2]!;
              final a2x = atomPosition2.x;
              final a2y = atomPosition2.y;

              dx = atomPosition1.x - atomPosition2.x;
              dy = atomPosition1.y - atomPosition2.y;
              distanceSquared = _max(
                dx * dx + dy * dy,
                AbstractVerletAlgorithm.minDistanceSquared,
              );
              r2inv = 1 / distanceSquared;
              forceScalar = chargeAii * chargesB[jj] * r2inv * r2inv;
              forceX = dx * forceScalar;
              forceY = dy * forceScalar;
              nextMoleculeForceI.addXY(forceX, forceY);
              nextMoleculeForceJ.subtractXY(forceX, forceY);
              nextMoleculeTorques[i] +=
                  (a1x - m1x) * forceY - (a1y - m1y) * forceX;
              nextMoleculeTorques[j] -=
                  (a2x - m2x) * forceY - (a2y - m2y) * forceX;
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
    final numberOfMolecules = moleculeDataSet.getNumberOfMolecules();
    final moleculeVelocities = moleculeDataSet.moleculeVelocities;
    final moleculeForces = moleculeDataSet.moleculeForces;
    final nextMoleculeForces = moleculeDataSet.nextMoleculeForces;
    final moleculeRotationRates = moleculeDataSet.moleculeRotationRates;
    final moleculeTorques = moleculeDataSet.moleculeTorques;
    final nextMoleculeTorques = moleculeDataSet.nextMoleculeTorques;
    final moleculeMass = moleculeDataSet.getMoleculeMass();
    final moleculeRotationalInertia =
        moleculeDataSet.getMoleculeRotationalInertia();

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
      var rotationRate = moleculeRotationRates[i] +
          timeStepHalf *
              (moleculeTorques[i] + nextMoleculeTorques[i]) *
              inertiaInverse;

      if (rotationRate > maxRotationRate) {
        rotationRate = maxRotationRate;
      } else if (rotationRate < -maxRotationRate) {
        rotationRate = -maxRotationRate;
      }
      moleculeRotationRates[i] = rotationRate;

      final v = moleculeVelocities[i]!;
      translationalKineticEnergy +=
          0.5 * moleculeMass * (v.x * v.x + v.y * v.y);
      rotationalKineticEnergy += 0.5 *
          moleculeRotationalInertia *
          moleculeRotationRates[i] *
          moleculeRotationRates[i];

      moleculeForces[i]!
          .setXY(nextMoleculeForces[i]!.x, nextMoleculeForces[i]!.y);
      moleculeTorques[i] = nextMoleculeTorques[i];
    }

    if (numberOfMolecules > 0) {
      calculatedTemperature =
          (translationalKineticEnergy + rotationalKineticEnergy) /
              numberOfMolecules;
    } else {
      calculatedTemperature = multipleParticleModel.minModelTemperature!;
    }
  }

  static double _max(double a, double b) => a > b ? a : b;
}
