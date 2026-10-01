import '../../som_constants.dart';
import '../molecule_force_and_motion_data_set.dart';
import '../multiple_particle_model.dart';
import '../time_span_data_queue.dart';

/// Base Verlet integrator — PhET AbstractVerletAlgorithm.
abstract class AbstractVerletAlgorithm {
  AbstractVerletAlgorithm(this.multipleParticleModel)
      : pressureAccumulatorQueue =
            TimeSpanDataQueue(SomConstants.pressureCalcTimeWindow) {
    pressure = 0;
  }

  final MultipleParticleModel multipleParticleModel;

  /// Model pressure (not atmospheres).
  double pressure = 0;

  double sideBounceInset = 1;
  double bottomBounceInset = 1;
  double topBounceInset = 1;

  double potentialEnergy = 0;
  double calculatedTemperature = 0;
  bool lidChangedParticleVelocity = false;

  final TimeSpanDataQueue pressureAccumulatorQueue;
  double timeAboveExplosionPressure = 0;

  void updateAtomPositions(MoleculeForceAndMotionDataSet moleculeDataSet);

  bool isNormalizedPositionInContainer(double xPos, double yPos) {
    return xPos >= 0 &&
        xPos <= multipleParticleModel.normalizedContainerWidth &&
        yPos >= 0 &&
        yPos <= multipleParticleModel.normalizedTotalContainerHeight;
  }

  void updateMoleculePositions(
    MoleculeForceAndMotionDataSet moleculeDataSet,
    double timeStep,
  ) {
    final moleculeCenterOfMassPositions =
        moleculeDataSet.getMoleculeCenterOfMassPositions();
    final moleculeVelocities = moleculeDataSet.getMoleculeVelocities();
    final moleculeForces = moleculeDataSet.getMoleculeForces();
    final numberOfMolecules = moleculeDataSet.getNumberOfMolecules();
    final moleculeRotationAngles = moleculeDataSet.getMoleculeRotationAngles();
    final moleculeRotationRates = moleculeDataSet.getMoleculeRotationRates();
    final moleculeTorques = moleculeDataSet.getMoleculeTorques();
    final massInverse = 1 / moleculeDataSet.getMoleculeMass();
    final inertiaInverse = 1 / moleculeDataSet.getMoleculeRotationalInertia();
    final timeStepSqrHalf = timeStep * timeStep * 0.5;
    final pressureAccumulationMinHeight =
        multipleParticleModel.normalizedContainerHeight * 0.3;
    var accumulatedPressure = 0.0;

    final minX = sideBounceInset;
    final minY = bottomBounceInset;
    final maxX =
        multipleParticleModel.normalizedContainerWidth - sideBounceInset;
    final maxY =
        multipleParticleModel.normalizedContainerHeight - topBounceInset;

    for (var i = 0; i < numberOfMolecules; i++) {
      final moleculeVelocity = moleculeVelocities[i]!;
      final moleculeVelocityX = moleculeVelocity.x;
      final moleculeVelocityY = moleculeVelocity.y;
      final moleculeCenterOfMassPosition = moleculeCenterOfMassPositions[i]!;

      var xPos = moleculeCenterOfMassPosition.x +
          (timeStep * moleculeVelocityX) +
          (timeStepSqrHalf * moleculeForces[i]!.x * massInverse);
      var yPos = moleculeCenterOfMassPosition.y +
          (timeStep * moleculeVelocityY) +
          (timeStepSqrHalf * moleculeForces[i]!.y * massInverse);

      if (!moleculeDataSet.insideContainer[i] &&
          isNormalizedPositionInContainer(xPos, yPos)) {
        moleculeDataSet.insideContainer[i] = true;
      }

      if (moleculeDataSet.insideContainer[i]) {
        if (xPos <= minX && moleculeVelocityX < 0) {
          xPos = minX;
          moleculeVelocity.x = -moleculeVelocityX;
          if (yPos > pressureAccumulationMinHeight) {
            accumulatedPressure += -moleculeVelocityX;
          }
        } else if (xPos >= maxX && moleculeVelocityX > 0) {
          xPos = maxX;
          moleculeVelocity.x = -moleculeVelocityX;
          if (yPos > pressureAccumulationMinHeight) {
            accumulatedPressure += moleculeVelocityX;
          }
        }

        if (yPos <= minY && moleculeVelocityY <= 0) {
          yPos = minY;
          moleculeVelocity.y = -moleculeVelocityY;
        } else if (yPos >= maxY) {
          if (!multipleParticleModel.isExploded) {
            yPos = maxY;
            final lidVelocity = multipleParticleModel.normalizedLidVelocityY;

            if (lidVelocity != 0) {
              lidChangedParticleVelocity = true;
            }

            if (moleculeVelocityY > 0) {
              moleculeVelocity.y = -moleculeVelocityY + lidVelocity * 0.3;
            } else if (moleculeVelocityY.abs() < lidVelocity.abs()) {
              moleculeVelocity.y = lidVelocity;
            }
            accumulatedPressure += moleculeVelocity.y.abs();
          } else {
            moleculeDataSet.insideContainer[i] = false;
          }
        }
      }

      moleculeCenterOfMassPositions[i]!.setXY(xPos, yPos);

      final newAngle = (timeStep * moleculeRotationRates[i]) +
          (timeStepSqrHalf * moleculeTorques[i] * inertiaInverse);
      assert(!newAngle.isNaN, 'no NaNs allowed');
      moleculeRotationAngles[i] += newAngle;
    }

    updateAtomPositions(moleculeDataSet);
    updatePressure(accumulatedPressure, timeStep);
  }

  void updateForcesAndMotion(double timeStep) {
    final moleculeDataSet = multipleParticleModel.moleculeDataSet!;
    updateMoleculePositions(moleculeDataSet, timeStep);
    initializeForces(moleculeDataSet);
    updateInteractionForces(moleculeDataSet);
    updateVelocitiesAndRotationRates(moleculeDataSet, timeStep);
  }

  void initializeForces(MoleculeForceAndMotionDataSet moleculeDataSet);

  void updateInteractionForces(MoleculeForceAndMotionDataSet moleculeDataSet);

  void updateVelocitiesAndRotationRates(
    MoleculeForceAndMotionDataSet moleculeDataSet,
    double timeStep,
  );

  void setScaledEpsilon(double scaledEpsilon) {
    throw UnsupportedError('Setting epsilon is not implemented for this class');
  }

  double getScaledEpsilon() {
    throw UnsupportedError(
      'Getting scaled epsilon is not implemented for this class',
    );
  }

  void updatePressure(double pressureThisStep, double dt) {
    assert(pressureThisStep >= 0, "pressure value can't be negative");

    if (multipleParticleModel.isExploded) {
      pressureAccumulatorQueue.clear();
      pressure = 0;
    } else {
      var stepPressure = pressureThisStep;
      if (stepPressure > 0 &&
          multipleParticleModel.temperatureSetPoint <=
              multipleParticleModel.minModelTemperature!) {
        stepPressure = 0;
      }

      pressureAccumulatorQueue.add(stepPressure, dt);

      final newPressure = mathMax(
        pressureAccumulatorQueue.total / SomConstants.pressureCalcTimeWindow,
        0,
      );

      if (newPressure > SomConstants.explosionPressure) {
        timeAboveExplosionPressure += dt;
        if (timeAboveExplosionPressure > SomConstants.explosionTime) {
          multipleParticleModel.setContainerExploded(true);
          pressure = 0;
        } else {
          pressure = newPressure;
        }
      } else {
        pressure = newPressure;
        timeAboveExplosionPressure = 0;
      }
    }
  }

  void presetPressure(double pressureValue) {
    pressureAccumulatorQueue.clear();
    final numberOfSamples =
        SomConstants.pressureCalcTimeWindow / SomConstants.nominalTimeStep;
    final pressureSampleInstantaneousValue =
        pressureValue * SomConstants.pressureCalcTimeWindow / numberOfSamples;
    for (var i = 0; i < numberOfSamples; i++) {
      pressureAccumulatorQueue.add(
        pressureSampleInstantaneousValue,
        SomConstants.nominalTimeStep,
      );
    }
  }

  static const double particleInteractionDistanceThreshSqrd =
      SomConstants.particleInteractionDistanceThreshSqrd;
  static const double minDistanceSquared = SomConstants.minDistanceSquared;
}

double mathMax(double a, double b) => a > b ? a : b;
