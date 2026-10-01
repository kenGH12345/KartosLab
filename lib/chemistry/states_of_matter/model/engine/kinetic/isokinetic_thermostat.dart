import 'dart:math' as math;

import '../../../som_constants.dart';
import '../../molecule_force_and_motion_data_set.dart';
import '../../som_random.dart';
import '../../som_vec2.dart';

/// Isokinetic thermostat — PhET IsokineticThermostat.
class IsokineticThermostat {
  IsokineticThermostat(
    this.moleculeDataSet,
    this.minModelTemperature, {
    SomRandom? random,
  }) : random = random ?? SomRandom();

  final MoleculeForceAndMotionDataSet moleculeDataSet;
  double targetTemperature = SomConstants.initialTemperature;
  double minModelTemperature;
  SomRandom random;

  double previousTemperatureScaleFactor = 1;
  final SomVec2 previousParticleVelocity = SomVec2(0, 0);
  final SomVec2 totalVelocityChangeThisStep = SomVec2(0, 0);
  final SomVec2 accumulatedAverageVelocityChange = SomVec2(0, 0);

  static const double minPostZeroVelocity = 0.1;
  static const double minXVelWhenFalling = 1.0;
  static const double compensationFactor = 0.9;

  void adjustTemperature(double measuredTemperature) {
    final numberOfParticles = moleculeDataSet.getNumberOfMolecules();

    late final double temperatureScaleFactor;
    if (targetTemperature > minModelTemperature) {
      temperatureScaleFactor =
          math.sqrt(targetTemperature / measuredTemperature);
    } else {
      temperatureScaleFactor = 0;
      accumulatedAverageVelocityChange.setXY(0, 0);
    }

    totalVelocityChangeThisStep.setXY(0, 0);

    final moleculeVelocities = moleculeDataSet.moleculeVelocities;
    final moleculeRotationRates = moleculeDataSet.moleculeRotationRates;

    if (previousTemperatureScaleFactor != 0 ||
        temperatureScaleFactor == 0 ||
        measuredTemperature > minModelTemperature) {
      for (var i = 0; i < numberOfParticles; i++) {
        final moleculeVelocity = moleculeVelocities[i]!;
        previousParticleVelocity.set(moleculeVelocity);

        if (moleculeVelocity.y < 0) {
          if (moleculeVelocity.x.abs() > minXVelWhenFalling) {
            moleculeVelocity.x = moleculeVelocity.x * temperatureScaleFactor;
          }
        } else {
          moleculeVelocity.setXY(
            moleculeVelocity.x * temperatureScaleFactor -
                accumulatedAverageVelocityChange.x * compensationFactor,
            moleculeVelocity.y * temperatureScaleFactor,
          );
        }

        moleculeRotationRates[i] *= temperatureScaleFactor;

        totalVelocityChangeThisStep.addXY(
          moleculeVelocity.x - previousParticleVelocity.x,
          moleculeVelocity.y - previousParticleVelocity.y,
        );
      }
    } else {
      for (var i = 0; i < numberOfParticles; i++) {
        var angle = random.nextDouble() * math.pi;
        if (angle < 0) {
          angle += math.pi;
        }
        moleculeVelocities[i]!.setPolar(minPostZeroVelocity, angle);
      }
    }

    previousTemperatureScaleFactor = temperatureScaleFactor;

    accumulatedAverageVelocityChange.addXY(
      totalVelocityChangeThisStep.x / numberOfParticles,
      totalVelocityChangeThisStep.y / numberOfParticles,
    );
  }

  void clearAccumulatedBias() {
    accumulatedAverageVelocityChange.setXY(0, 0);
  }
}
