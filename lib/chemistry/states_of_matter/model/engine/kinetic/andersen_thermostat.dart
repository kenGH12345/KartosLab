import 'dart:math' as math;

import '../../../som_constants.dart';
import '../../molecule_force_and_motion_data_set.dart';
import '../../som_random.dart';
import '../../som_vec2.dart';

/// Andersen thermostat — PhET AndersenThermostat.
class AndersenThermostat {
  AndersenThermostat(
    this.moleculeDataSet,
    this.minModelTemperature, {
    SomRandom? random,
  }) : random = random ?? SomRandom();

  final MoleculeForceAndMotionDataSet moleculeDataSet;
  double targetTemperature = SomConstants.initialTemperature;
  double minModelTemperature;
  SomRandom random;

  final SomVec2 previousParticleVelocity = SomVec2(0, 0);
  final SomVec2 totalVelocityChangePreviousStep = SomVec2(0, 0);
  final SomVec2 totalVelocityChangeThisStep = SomVec2(0, 0);
  final SomVec2 accumulatedAverageVelocityChange = SomVec2(0, 0);

  static const double proportionCompensationFactor = 0.25;
  static const double integralCompensationFactor = 0.5;

  void adjustTemperature() {
    // Clear per-step accumulator (intended semantics of *ThisStep*; PhET TS
    // omits this reset which would otherwise unbounded-accumulate).
    totalVelocityChangeThisStep.setXY(0, 0);

    late final double gamma;
    var temperature = targetTemperature;
    if (temperature > minModelTemperature) {
      gamma = 0.999;
    } else {
      gamma = 0.5;
      temperature = 0;
    }

    final massInverse = 1 / moleculeDataSet.moleculeMass;
    final inertiaInverse = 1 / moleculeDataSet.moleculeRotationalInertia;
    final scalingFactor = temperature * (1 - math.pow(gamma, 2));
    final velocityScalingFactor = math.sqrt(massInverse * scalingFactor);
    final rotationScalingFactor = math.sqrt(inertiaInverse * scalingFactor);
    final numMolecules = moleculeDataSet.getNumberOfMolecules();

    final xCompensation =
        -totalVelocityChangePreviousStep.x /
                numMolecules *
                proportionCompensationFactor -
            accumulatedAverageVelocityChange.x * integralCompensationFactor;

    final moleculeVelocities = moleculeDataSet.moleculeVelocities;
    final moleculeRotationRates = moleculeDataSet.moleculeRotationRates;

    for (var i = 0; i < numMolecules; i++) {
      final moleculeVelocity = moleculeVelocities[i]!;
      previousParticleVelocity.set(moleculeVelocity);

      final xVel = moleculeVelocity.x * gamma +
          random.nextGaussian() * velocityScalingFactor +
          xCompensation;
      final yVel = moleculeVelocity.y * gamma +
          random.nextGaussian() * velocityScalingFactor;
      moleculeVelocity.setXY(xVel, yVel);
      moleculeRotationRates[i] = gamma * moleculeRotationRates[i] +
          random.nextGaussian() * rotationScalingFactor;
      totalVelocityChangeThisStep.addXY(
        xVel - previousParticleVelocity.x,
        yVel - previousParticleVelocity.y,
      );
    }
    accumulatedAverageVelocityChange.addXY(
      totalVelocityChangeThisStep.x / numMolecules,
      totalVelocityChangeThisStep.y / numMolecules,
    );
    totalVelocityChangePreviousStep.set(totalVelocityChangeThisStep);
  }

  void clearAccumulatedBias() {
    accumulatedAverageVelocityChange.setXY(0, 0);
    totalVelocityChangePreviousStep.setXY(0, 0);
  }
}
