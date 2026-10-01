import 'dart:math' as math;

import '../../som_constants.dart';
import '../multiple_particle_model.dart';
import '../phase_state.dart';
import '../som_random.dart';
import '../som_vec2.dart';

/// Base phase configuration — PhET AbstractPhaseStateChanger.
abstract class AbstractPhaseStateChanger {
  AbstractPhaseStateChanger(
    this.multipleParticleModel, {
    SomRandom? random,
  }) : random = random ?? SomRandom();

  final MultipleParticleModel multipleParticleModel;
  final SomVec2 moleculePosition = SomVec2(0, 0);
  SomRandom random;
  final SomVec2 reusableVector = SomVec2(0, 0);

  static const double minInitialParticleToWallDistance = 1.5;
  static const int maxPlacementAttempts = 500;
  static const double minInitialGasParticleDistance = 1.1;
  static const double distanceBetweenParticlesInCrystal = 0.12;

  void setPhase(PhaseState phaseID) {
    switch (phaseID) {
      case PhaseState.solid:
        setPhaseSolid();
      case PhaseState.liquid:
        setPhaseLiquid();
      case PhaseState.gas:
        setPhaseGas();
      case PhaseState.unknown:
        throw ArgumentError('invalid phaseID: $phaseID');
    }
  }

  void setParticleConfigurationForPhase(PhaseState phaseID) {
    switch (phaseID) {
      case PhaseState.solid:
        setParticleConfigurationSolid();
      case PhaseState.liquid:
        setParticleConfigurationLiquid();
      case PhaseState.gas:
        setParticleConfigurationGas();
      case PhaseState.unknown:
        throw ArgumentError('invalid phaseID: $phaseID');
    }
  }

  void setTemperatureForPhase(PhaseState phaseID) {
    switch (phaseID) {
      case PhaseState.solid:
        multipleParticleModel.setTemperature(SomConstants.solidTemperature);
      case PhaseState.liquid:
        multipleParticleModel.setTemperature(SomConstants.liquidTemperature);
      case PhaseState.gas:
        multipleParticleModel.setTemperature(SomConstants.gasTemperature);
      case PhaseState.unknown:
        throw ArgumentError('invalid phaseID: $phaseID');
    }
  }

  void setPhaseSolid() {
    setTemperatureForPhase(PhaseState.solid);
    setParticleConfigurationSolid();
  }

  void setPhaseLiquid() {
    setTemperatureForPhase(PhaseState.liquid);
    setParticleConfigurationLiquid();
  }

  void setPhaseGas() {
    setTemperatureForPhase(PhaseState.gas);
    setParticleConfigurationGas();
  }

  void setParticleConfigurationSolid();
  void setParticleConfigurationLiquid();

  SomVec2? findOpenMoleculePosition() {
    final moleculeDataSet = multipleParticleModel.moleculeDataSet!;
    final moleculeCenterOfMassPositions =
        moleculeDataSet.moleculeCenterOfMassPositions;

    const minInitialInterParticleDistance = 1.2;
    final rangeX = multipleParticleModel.normalizedContainerWidth -
        (2 * minInitialParticleToWallDistance);
    final rangeY = multipleParticleModel.normalizedContainerHeight -
        (2 * minInitialParticleToWallDistance);
    for (var i = 0; i < rangeX / minInitialInterParticleDistance; i++) {
      for (var j = 0; j < rangeY / minInitialInterParticleDistance; j++) {
        final posX =
            minInitialParticleToWallDistance + (i * minInitialInterParticleDistance);
        final posY =
            minInitialParticleToWallDistance + (j * minInitialInterParticleDistance);

        var positionAvailable = true;
        for (var k = 0; k < moleculeDataSet.getNumberOfMolecules(); k++) {
          if (moleculeCenterOfMassPositions[k]!
                  .distanceXY(posX, posY) <
              minInitialInterParticleDistance) {
            positionAvailable = false;
            break;
          }
        }
        if (positionAvailable) {
          moleculePosition.setXY(posX, posY);
          return moleculePosition;
        }
      }
    }
    return null;
  }

  void formCrystal(
    int moleculesPerLayer,
    double xSpacing,
    double ySpacing,
    double alternateRowOffset,
    double bottomY,
    bool randomizeRotationalAngle,
  ) {
    final moleculeDataSet = multipleParticleModel.moleculeDataSet!;
    final numberOfMolecules = moleculeDataSet.getNumberOfMolecules();
    final moleculeCenterOfMassPositions =
        moleculeDataSet.moleculeCenterOfMassPositions;
    final moleculeVelocities = moleculeDataSet.moleculeVelocities;
    final moleculeRotationAngles = moleculeDataSet.moleculeRotationAngles;
    final moleculesInsideContainer = moleculeDataSet.insideContainer;

    final temperatureSqrt =
        math.sqrt(multipleParticleModel.temperatureSetPoint);
    final crystalWidth = moleculesPerLayer * xSpacing;
    final startingPosX =
        (multipleParticleModel.normalizedContainerWidth / 2) -
            (crystalWidth / 2);

    var moleculesPlaced = 0;
    reusableVector.setXY(0, 0);
    for (var i = 0; i < numberOfMolecules; i++) {
      for (var j = 0;
          (j < moleculesPerLayer) && (moleculesPlaced < numberOfMolecules);
          j++) {
        var xPos = startingPosX + (j * xSpacing);
        if (i % 2 != 0) {
          xPos += alternateRowOffset;
        }
        final yPos = bottomY + (i * ySpacing);
        final moleculeIndex = (i * moleculesPerLayer) + j;
        moleculeCenterOfMassPositions[moleculeIndex]!.setXY(xPos, yPos);
        moleculeRotationAngles[moleculeIndex] = 0;
        moleculesPlaced++;

        final xVel = temperatureSqrt * random.nextGaussian();
        final yVel = temperatureSqrt * random.nextGaussian();
        moleculeVelocities[moleculeIndex]!.setXY(xVel, yVel);
        reusableVector.addXY(xVel, yVel);

        moleculeRotationAngles[moleculeIndex] = randomizeRotationalAngle
            ? random.nextDouble() * 2 * math.pi
            : 0;

        // Matches PhET: uses layer index i (not moleculeIndex).
        moleculesInsideContainer[i] = true;
      }
    }

    zeroOutCollectiveVelocity();
  }

  void setParticleConfigurationGas() {
    final moleculeDataSet = multipleParticleModel.moleculeDataSet!;
    final moleculeCenterOfMassPositions =
        moleculeDataSet.getMoleculeCenterOfMassPositions();
    final moleculeVelocities = moleculeDataSet.getMoleculeVelocities();
    final moleculeRotationAngles = moleculeDataSet.getMoleculeRotationAngles();
    final moleculeRotationRates = moleculeDataSet.getMoleculeRotationRates();
    final moleculesInsideContainer = moleculeDataSet.insideContainer;

    final temperatureSqrt =
        math.sqrt(multipleParticleModel.temperatureSetPoint);
    final numberOfMolecules = moleculeDataSet.getNumberOfMolecules();

    for (var i = 0; i < numberOfMolecules; i++) {
      moleculeCenterOfMassPositions[i]!.setXY(0, 0);
      moleculeVelocities[i]!.setXY(
        temperatureSqrt * random.nextGaussian(),
        temperatureSqrt * random.nextGaussian(),
      );
      moleculeRotationAngles[i] = random.nextDouble() * math.pi * 2;
      moleculeRotationRates[i] =
          (random.nextDouble() * 2 - 1) * temperatureSqrt * math.pi * 2;
      moleculesInsideContainer[i] = true;
    }

    final rangeX = multipleParticleModel.normalizedContainerWidth -
        (2 * minInitialParticleToWallDistance);
    final rangeY = multipleParticleModel.normalizedContainerHeight -
        (2 * minInitialParticleToWallDistance);
    for (var i = 0; i < numberOfMolecules; i++) {
      for (var j = 0; j < maxPlacementAttempts; j++) {
        final newPosX =
            minInitialParticleToWallDistance + (random.nextDouble() * rangeX);
        final newPosY =
            minInitialParticleToWallDistance + (random.nextDouble() * rangeY);
        var positionAvailable = true;

        for (var k = 0; k < i; k++) {
          if (moleculeCenterOfMassPositions[k]!
                  .distanceXY(newPosX, newPosY) <
              minInitialGasParticleDistance) {
            positionAvailable = false;
            break;
          }
        }
        if (positionAvailable || j == maxPlacementAttempts - 1) {
          moleculeCenterOfMassPositions[i]!.setXY(newPosX, newPosY);
          break;
        } else if (j == maxPlacementAttempts - 2) {
          final openPoint = findOpenMoleculePosition();
          if (openPoint != null) {
            moleculeCenterOfMassPositions[i]!.set(openPoint);
            break;
          }
        }
      }
    }
  }

  void zeroOutCollectiveVelocity() {
    final moleculeDataSet = multipleParticleModel.moleculeDataSet!;
    final numberOfMolecules = moleculeDataSet.getNumberOfMolecules();
    final moleculeVelocities = moleculeDataSet.getMoleculeVelocities();
    reusableVector.setXY(0, 0);
    for (var i = 0; i < numberOfMolecules; i++) {
      reusableVector.add(moleculeVelocities[i]!);
    }
    final xAdjustment = -reusableVector.x / numberOfMolecules;
    final yAdjustment = -reusableVector.y / numberOfMolecules;
    for (var i = 0; i < numberOfMolecules; i++) {
      moleculeVelocities[i]!.addXY(xAdjustment, yAdjustment);
    }
  }

  void loadSavedState(Map<String, dynamic> savedState) {
    final moleculeDataSet = multipleParticleModel.moleculeDataSet!;
    assert(
      moleculeDataSet.numberOfMolecules == savedState['numberOfMolecules'],
      'unexpected number of particles in saved data set',
    );

    final numberOfMolecules = moleculeDataSet.numberOfMolecules;
    final moleculeCenterOfMassPositions =
        moleculeDataSet.moleculeCenterOfMassPositions;
    final moleculeVelocities = moleculeDataSet.moleculeVelocities;
    final moleculeRotationAngles = moleculeDataSet.moleculeRotationAngles;
    final moleculeRotationRates = moleculeDataSet.moleculeRotationRates;
    final moleculesInsideContainer = moleculeDataSet.insideContainer;

    final positions =
        savedState['moleculeCenterOfMassPositions'] as List<dynamic>;
    final velocities = savedState['moleculeVelocities'] as List<dynamic>;
    final rotationAngles = savedState['moleculeRotationAngles'] as List?;
    final rotationRates = savedState['moleculeRotationRates'] as List?;

    for (var i = 0; i < numberOfMolecules; i++) {
      final pos = positions[i] as Map;
      final vel = velocities[i] as Map;
      moleculeCenterOfMassPositions[i]!.setXY(
        (pos['x'] as num).toDouble(),
        (pos['y'] as num).toDouble(),
      );
      moleculeVelocities[i]!.setXY(
        (vel['x'] as num).toDouble(),
        (vel['y'] as num).toDouble(),
      );
      if (rotationAngles != null) {
        moleculeRotationAngles[i] = (rotationAngles[i] as num).toDouble();
      }
      // Matches PhET: gated on moleculeRotationAngles presence.
      if (rotationAngles != null && rotationRates != null) {
        moleculeRotationRates[i] = (rotationRates[i] as num).toDouble();
      }
      moleculesInsideContainer[i] = true;
    }
  }
}
