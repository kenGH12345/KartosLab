import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../som_constants.dart';
import 'atom_type.dart';
import 'engine/abstract_phase_state_changer.dart';
import 'engine/abstract_verlet_algorithm.dart';
import 'engine/kinetic/andersen_thermostat.dart';
import 'engine/kinetic/isokinetic_thermostat.dart';
import 'engine/diatomic_atom_position_updater.dart';
import 'engine/diatomic_phase_state_changer.dart';
import 'engine/diatomic_verlet_algorithm.dart';
import 'engine/monatomic_atom_position_updater.dart';
import 'engine/monatomic_phase_state_changer.dart';
import 'engine/monatomic_verlet_algorithm.dart';
import 'engine/water_atom_position_updater.dart';
import 'engine/water_phase_state_changer.dart';
import 'engine/water_verlet_algorithm.dart';
import 'hydrogen_atom.dart';
import 'molecule_force_and_motion_data_set.dart';
import 'moving_average.dart';
import 'phase_state.dart';
import 'scaled_atom.dart';
import 'som_random.dart';
import 'som_vec2.dart';
import 'substance_type.dart';

/// Main multi-particle LJ simulation model — PhET MultipleParticleModel.
class MultipleParticleModel extends ChangeNotifier {
  MultipleParticleModel({
    Set<SubstanceType>? validSubstances,
    SomRandom? random,
    SubstanceType initialSubstance = SubstanceType.neon,
  })  : validSubstances = validSubstances ??
            {
              SubstanceType.neon,
              SubstanceType.argon,
              SubstanceType.diatomicOxygen,
              SubstanceType.water,
              SubstanceType.adjustableAtom,
            },
        random = random ?? SomRandom() {
    assert(this.validSubstances.contains(initialSubstance));
    _substance = initialSubstance;
    handleSubstanceChanged(_substance);
  }

  final Set<SubstanceType> validSubstances;
  final SomRandom random;

  // Observable-ish state (ChangeNotifier)
  SubstanceType _substance = SubstanceType.neon;
  SubstanceType get substance => _substance;

  double containerHeight = SomConstants.containerInitialHeight;
  bool isExploded = false;
  double temperatureSetPoint = SomConstants.initialTemperature;
  double pressure = 0; // atmospheres (display)
  bool isPlaying = true;
  double heatingCoolingAmount = 0; // -1..1
  int targetNumberOfMolecules = 0;
  int maxNumberOfMolecules = SomConstants.maxNumAtoms;
  int numMoleculesQueuedForInjection = 0;

  final List<ScaledAtom> scaledAtoms = [];

  MoleculeForceAndMotionDataSet? moleculeDataSet;
  double normalizedContainerWidth = SomConstants.containerWidth;
  double gravitationalAcceleration = SomConstants.nominalGravitationalAccel;
  double normalizedContainerHeight = SomConstants.containerInitialHeight;
  double normalizedTotalContainerHeight = SomConstants.containerInitialHeight;
  double normalizedLidVelocityY = 0;

  final SomVec2 injectionPoint = SomVec2(0, 0);

  double particleDiameter = 1;
  double? minModelTemperature;
  double residualTime = 0;
  double moleculeInjectionHoldoffTimer = 0;
  double heightChangeThisStep = 0;
  bool moleculeInjectedThisStep = false;

  void Function(MoleculeForceAndMotionDataSet)? atomPositionUpdater;
  AbstractPhaseStateChanger? phaseStateChanger;
  IsokineticThermostat? isoKineticThermostat;
  AndersenThermostat? andersenThermostat;
  AbstractVerletAlgorithm? moleculeForceAndMotionCalculator;

  final MovingAverage averageTemperatureDifference = MovingAverage(10);
  Object? thermostatRunPreviousStep;

  static const double injectedMoleculeSpeed = 2.0;
  static const double injectedMoleculeAngleSpread = math.pi * 0.25;
  static const double injectionPointHorizProportion = 0.00;
  static const double injectionPointVertProportion = 0.25;
  static const double moleculeInjectionHoldoffTime = 0.25;
  static const int maxMoleculesQueuedForInjection = 3;

  bool get isInjectionAllowed =>
      isPlaying &&
      numMoleculesQueuedForInjection < maxMoleculesQueuedForInjection &&
      !isExploded &&
      targetNumberOfMolecules < maxNumberOfMolecules;

  double? get temperatureInKelvin => getTemperatureInKelvin();

  void setSubstance(SubstanceType substance) {
    if (!validSubstances.contains(substance)) {
      throw ArgumentError('Substance $substance is not valid for this model');
    }
    if (_substance == substance) {
      return;
    }
    _substance = substance;
    handleSubstanceChanged(substance);
    notifyListeners();
  }

  void setTemperature(double newTemperature) {
    if (newTemperature > SomConstants.maxTemperature) {
      temperatureSetPoint = SomConstants.maxTemperature;
    } else if (newTemperature < SomConstants.minTemperature) {
      temperatureSetPoint = SomConstants.minTemperature;
    } else {
      temperatureSetPoint = newTemperature;
    }

    isoKineticThermostat?.targetTemperature = temperatureSetPoint;
    andersenThermostat?.targetTemperature = temperatureSetPoint;
    notifyListeners();
  }

  double? getTemperatureInKelvin() {
    if (scaledAtoms.isEmpty) {
      return null;
    }

    late final double triplePointInKelvin;
    late final double criticalPointInKelvin;
    late final double triplePointInModelUnits;
    late final double criticalPointInModelUnits;

    switch (substance) {
      case SubstanceType.neon:
        triplePointInKelvin = SomConstants.neonTriplePointInKelvin;
        criticalPointInKelvin = SomConstants.neonCriticalPointInKelvin;
        triplePointInModelUnits =
            SomConstants.triplePointMonatomicModelTemperature;
        criticalPointInModelUnits =
            SomConstants.criticalPointMonatomicModelTemperature;
      case SubstanceType.argon:
        triplePointInKelvin = SomConstants.argonTriplePointInKelvin;
        criticalPointInKelvin = SomConstants.argonCriticalPointInKelvin;
        triplePointInModelUnits =
            SomConstants.triplePointMonatomicModelTemperature;
        criticalPointInModelUnits =
            SomConstants.criticalPointMonatomicModelTemperature;
      case SubstanceType.adjustableAtom:
        triplePointInKelvin =
            SomConstants.adjustableAtomTriplePointInKelvin;
        criticalPointInKelvin =
            SomConstants.adjustableAtomCriticalPointInKelvin;
        triplePointInModelUnits =
            SomConstants.triplePointMonatomicModelTemperature;
        criticalPointInModelUnits =
            SomConstants.criticalPointMonatomicModelTemperature;
      case SubstanceType.water:
        triplePointInKelvin = SomConstants.waterTriplePointInKelvin;
        criticalPointInKelvin = SomConstants.waterCriticalPointInKelvin;
        triplePointInModelUnits =
            SomConstants.triplePointWaterModelTemperature;
        criticalPointInModelUnits =
            SomConstants.criticalPointWaterModelTemperature;
      case SubstanceType.diatomicOxygen:
        triplePointInKelvin = SomConstants.o2TriplePointInKelvin;
        criticalPointInKelvin = SomConstants.o2CriticalPointInKelvin;
        triplePointInModelUnits =
            SomConstants.triplePointDiatomicModelTemperature;
        criticalPointInModelUnits =
            SomConstants.criticalPointDiatomicModelTemperature;
    }

    double temperatureInKelvin;
    if (temperatureSetPoint <= minModelTemperature!) {
      temperatureInKelvin = 0;
    } else if (temperatureSetPoint < triplePointInModelUnits) {
      temperatureInKelvin =
          temperatureSetPoint * triplePointInKelvin / triplePointInModelUnits;
      if (temperatureInKelvin < 0.5) {
        temperatureInKelvin = 0.5;
      }
    } else if (temperatureSetPoint < criticalPointInModelUnits) {
      final slope = (criticalPointInKelvin - triplePointInKelvin) /
          (criticalPointInModelUnits - triplePointInModelUnits);
      final offset = triplePointInKelvin - (slope * triplePointInModelUnits);
      temperatureInKelvin = temperatureSetPoint * slope + offset;
    } else {
      temperatureInKelvin = temperatureSetPoint *
          criticalPointInKelvin /
          criticalPointInModelUnits;
    }
    return temperatureInKelvin;
  }

  double getModelPressure() =>
      moleculeForceAndMotionCalculator?.pressure ?? 0;

  void handleSubstanceChanged(SubstanceType substance) {
    final phase = mapTemperatureToPhase();
    removeAllAtoms();
    initializeModelParameters();

    switch (substance) {
      case SubstanceType.neon:
        particleDiameter = SomConstants.neonRadius * 2;
        minModelTemperature = 0.5 *
            SomConstants.triplePointMonatomicModelTemperature /
            SomConstants.neonTriplePointInKelvin;
      case SubstanceType.argon:
        particleDiameter = SomConstants.argonRadius * 2;
        minModelTemperature = 0.5 *
            SomConstants.triplePointMonatomicModelTemperature /
            SomConstants.argonTriplePointInKelvin;
      case SubstanceType.adjustableAtom:
        particleDiameter =
            SomConstants.adjustableAttractionDefaultRadius * 2;
        minModelTemperature = 0.5 *
            SomConstants.triplePointMonatomicModelTemperature /
            SomConstants.adjustableAtomTriplePointInKelvin;
      case SubstanceType.diatomicOxygen:
        particleDiameter = SomConstants.oxygenRadius * 2;
        minModelTemperature = 0.5 *
            SomConstants.triplePointDiatomicModelTemperature /
            SomConstants.o2TriplePointInKelvin;
      case SubstanceType.water:
        // Artificially large so ice crystal structure is visible (PhET).
        particleDiameter = SomConstants.oxygenRadius * 2.9;
        minModelTemperature = 0.5 *
            SomConstants.triplePointWaterModelTemperature /
            SomConstants.waterTriplePointInKelvin;
    }

    containerHeight = SomConstants.containerInitialHeight;
    updateNormalizedContainerDimensions();

    injectionPoint.setXY(
      SomConstants.containerWidth /
          particleDiameter *
          injectionPointHorizProportion,
      SomConstants.containerInitialHeight /
          particleDiameter *
          injectionPointVertProportion,
    );

    initializeAtoms(phase);
    averageTemperatureDifference.reset();

    final atomsPerMolecule = moleculeDataSet!.atomsPerMolecule;
    targetNumberOfMolecules =
        moleculeDataSet!.numberOfAtoms ~/ atomsPerMolecule;
    maxNumberOfMolecules =
        SomConstants.maxNumAtoms ~/ atomsPerMolecule;
  }

  void updatePressure() {
    pressure = getPressureInAtmospheres();
  }

  void reset() {
    final substanceAtStartOfReset = substance;

    containerHeight = SomConstants.containerInitialHeight;
    isExploded = false;
    temperatureSetPoint = SomConstants.initialTemperature;
    pressure = 0;
    _substance = SubstanceType.neon;
    if (!validSubstances.contains(_substance)) {
      _substance = validSubstances.first;
    }
    isPlaying = true;
    heatingCoolingAmount = 0;

    isoKineticThermostat?.clearAccumulatedBias();
    andersenThermostat?.clearAccumulatedBias();

    if (substanceAtStartOfReset == _substance) {
      removeAllAtoms();
      containerHeight = SomConstants.containerInitialHeight;
      // Need to re-init engines for current substance
      handleSubstanceChanged(_substance);
    } else {
      handleSubstanceChanged(_substance);
    }

    gravitationalAcceleration = SomConstants.nominalGravitationalAccel;
    notifyListeners();
  }

  void setPhase(PhaseState phaseState) {
    assert(
      phaseState == PhaseState.solid ||
          phaseState == PhaseState.liquid ||
          phaseState == PhaseState.gas,
      'invalid phase state specified',
    );
    phaseStateChanger!.setPhase(phaseState);
    syncAtomPositions();
    notifyListeners();
  }

  void setHeatingCoolingAmount(double normalizedHeatingCoolingAmount) {
    assert(normalizedHeatingCoolingAmount <= 1.0 &&
        normalizedHeatingCoolingAmount >= -1.0);
    heatingCoolingAmount = normalizedHeatingCoolingAmount;
    notifyListeners();
  }

  void queueMoleculeForInjection() {
    numMoleculesQueuedForInjection++;
  }

  /// Pump action — queue up to [count] molecules and raise [targetNumberOfMolecules].
  ///
  /// Mirrors PhET `targetNumberOfMoleculesProperty` + `numberOfParticlesPerPumpAction: 3`.
  void injectMoleculesFromPump([int count = 3]) {
    if (!isPlaying || isExploded) {
      return;
    }
    final room = maxNumberOfMolecules - targetNumberOfMolecules;
    final queueRoom =
        maxMoleculesQueuedForInjection - numMoleculesQueuedForInjection;
    final toAdd = math.min(count, math.min(room, queueRoom));
    if (toAdd <= 0) {
      return;
    }
    for (var i = 0; i < toAdd; i++) {
      queueMoleculeForInjection();
    }
    targetNumberOfMolecules += toAdd;
    notifyListeners();
  }

  void injectMolecule() {
    assert(numMoleculesQueuedForInjection > 0);
    assert(moleculeDataSet!.getNumberOfRemainingSlots() > 0);

    final injectionAngle =
        (random.nextDouble() - 0.5) * injectedMoleculeAngleSpread;
    final xVel = math.cos(injectionAngle) * injectedMoleculeSpeed;
    final yVel = math.sin(injectionAngle) * injectedMoleculeSpeed;
    final moleculeRotationRate = (random.nextDouble() - 0.5) * (math.pi / 4);

    final atomsPerMolecule = moleculeDataSet!.atomsPerMolecule;
    final moleculeCenterOfMassPosition = injectionPoint.copy();
    final moleculeVelocity = SomVec2(xVel, yVel);
    final atomPositions = <SomVec2>[
      for (var i = 0; i < atomsPerMolecule; i++) SomVec2(0, 0),
    ];

    moleculeDataSet!.addMolecule(
      atomPositions,
      moleculeCenterOfMassPosition,
      moleculeVelocity,
      moleculeRotationRate,
      true,
    );

    if (atomsPerMolecule > 1) {
      moleculeDataSet!.moleculeRotationAngles[
          moleculeDataSet!.getNumberOfMolecules() - 1] =
          random.nextDouble() * 2 * math.pi;
    }

    atomPositionUpdater!(moleculeDataSet!);
    addAtomsForCurrentSubstance(1);
    syncAtomPositions();
    moleculeInjectedThisStep = true;
    numMoleculesQueuedForInjection--;
  }

  void addAtomsForCurrentSubstance(int numMolecules) {
    for (var n = 0; n < numMolecules; n++) {
      switch (substance) {
        case SubstanceType.argon:
          scaledAtoms.add(ScaledAtom(AtomType.argon, 0, 0));
        case SubstanceType.neon:
          scaledAtoms.add(ScaledAtom(AtomType.neon, 0, 0));
        case SubstanceType.adjustableAtom:
          scaledAtoms.add(ScaledAtom(AtomType.adjustable, 0, 0));
        case SubstanceType.diatomicOxygen:
          scaledAtoms.add(ScaledAtom(AtomType.oxygen, 0, 0));
          scaledAtoms.add(ScaledAtom(AtomType.oxygen, 0, 0));
        case SubstanceType.water:
          scaledAtoms.add(ScaledAtom(AtomType.oxygen, 0, 0));
          scaledAtoms.add(HydrogenAtom(0, 0, true));
          scaledAtoms.add(HydrogenAtom(0, 0, random.nextDouble() > 0.5));
      }
    }
  }

  void removeAllAtoms() {
    scaledAtoms.clear();
    moleculeDataSet = null;
  }

  void initializeAtoms(PhaseState phase) {
    switch (substance) {
      case SubstanceType.neon:
      case SubstanceType.argon:
      case SubstanceType.adjustableAtom:
        initializeMonatomic(substance, phase);
      case SubstanceType.diatomicOxygen:
        initializeDiatomic(substance, phase);
      case SubstanceType.water:
        initializeTriatomic(substance, phase);
    }
    updatePressure();
  }

  void initializeModelParameters() {
    gravitationalAcceleration = SomConstants.nominalGravitationalAccel;
    heatingCoolingAmount = 0;
    temperatureSetPoint = SomConstants.initialTemperature;
    isExploded = false;
  }

  void dampUpwardMotion(double dt) {
    for (var i = 0; i < moleculeDataSet!.getNumberOfMolecules(); i++) {
      if (moleculeDataSet!.moleculeVelocities[i]!.y > 0) {
        moleculeDataSet!.moleculeVelocities[i]!.y *= 1 - (dt * 0.9);
      }
    }
  }

  void updateNormalizedContainerDimensions() {
    normalizedContainerWidth = SomConstants.containerWidth / particleDiameter;
    final nonNormalizedContainerHeight = math.min(
      containerHeight,
      SomConstants.containerInitialHeight,
    );
    normalizedContainerHeight =
        nonNormalizedContainerHeight / particleDiameter;
    normalizedTotalContainerHeight =
        nonNormalizedContainerHeight / particleDiameter;
  }

  /// Advance simulation by [dt] seconds (ignores play/pause).
  void stepInTime(double dt) {
    moleculeInjectedThisStep = false;
    updateContainerSize(dt);

    final pressureBeforeAlgorithm = getModelPressure();
    final particleMotionAdvancementTime =
        dt * SomConstants.particleSpeedUpFactor;

    var numParticleEngineSteps = 1;
    late final double particleMotionTimeStep;
    if (particleMotionAdvancementTime >
        SomConstants.maxParticleMotionTimeStep) {
      particleMotionTimeStep = SomConstants.maxParticleMotionTimeStep;
      numParticleEngineSteps = (particleMotionAdvancementTime /
              SomConstants.maxParticleMotionTimeStep)
          .floor();
      residualTime = particleMotionAdvancementTime -
          (numParticleEngineSteps * particleMotionTimeStep);
    } else {
      particleMotionTimeStep = particleMotionAdvancementTime;
    }

    if (residualTime > particleMotionTimeStep) {
      numParticleEngineSteps++;
      residualTime -= particleMotionTimeStep;
    }

    if (numMoleculesQueuedForInjection > 0 &&
        moleculeInjectionHoldoffTimer == 0) {
      injectMolecule();
      moleculeInjectionHoldoffTimer = moleculeInjectionHoldoffTime;
    } else if (moleculeInjectionHoldoffTimer > 0) {
      moleculeInjectionHoldoffTimer =
          math.max(moleculeInjectionHoldoffTimer - dt, 0);
    }

    for (var i = 0; i < numParticleEngineSteps; i++) {
      moleculeForceAndMotionCalculator!
          .updateForcesAndMotion(particleMotionTimeStep);
    }

    syncAtomPositions();
    runThermostat();

    if (getModelPressure() != pressureBeforeAlgorithm) {
      updatePressure();
    }

    final currentTemperature = temperatureSetPoint;
    if (heatingCoolingAmount != 0) {
      late final double newTemperature;

      if (currentTemperature <
              SomConstants.approachingAbsoluteZeroTemperature &&
          heatingCoolingAmount < 0) {
        final adjustmentFactor = math.pow(
          currentTemperature /
              SomConstants.approachingAbsoluteZeroTemperature,
          1.35,
        );
        newTemperature = currentTemperature +
            heatingCoolingAmount *
                SomConstants.temperatureChangeRate *
                dt *
                adjustmentFactor;
      } else {
        final temperatureChange =
            heatingCoolingAmount * SomConstants.temperatureChangeRate * dt;
        newTemperature = math.min(
          currentTemperature + temperatureChange,
          SomConstants.maxTemperature,
        );
      }

      if (currentTemperature < SomConstants.liquidTemperature &&
          heatingCoolingAmount > 0) {
        dampUpwardMotion(dt);
      }

      var tempToSet = newTemperature;
      if (heatingCoolingAmount <= 0 &&
          getTemperatureInKelvin() == 0 &&
          newTemperature > SomConstants.minTemperature) {
        tempToSet = SomConstants.minTemperature;
      }

      temperatureSetPoint = tempToSet;
      isoKineticThermostat!.targetTemperature = tempToSet;
      andersenThermostat!.targetTemperature = tempToSet;
    }

    notifyListeners();
  }

  void updateContainerSize(double dt) {
    if (isExploded) {
      heightChangeThisStep =
          SomConstants.postExplosionContainerExpansionRate * dt;
      if (containerHeight < SomConstants.containerInitialHeight * 3) {
        containerHeight +=
            SomConstants.postExplosionContainerExpansionRate * dt;
      }
    } else {
      heightChangeThisStep = 0;
      normalizedLidVelocityY = 0;
    }
  }

  /// PhET framework step — respects [isPlaying].
  void step(double dt) {
    if (isPlaying) {
      stepInTime(dt);
    }
  }

  void runThermostat() {
    if (isExploded) {
      return;
    }

    final calculatedTemperature =
        moleculeForceAndMotionCalculator!.calculatedTemperature;
    final temperatureSetPointLocal = temperatureSetPoint;
    var temperatureAdjustmentNeeded = false;
    Object? thermostatRunThisStep;

    if ((heatingCoolingAmount > 0 &&
            calculatedTemperature < temperatureSetPointLocal) ||
        (heatingCoolingAmount < 0 &&
            calculatedTemperature > temperatureSetPointLocal) ||
        (calculatedTemperature - temperatureSetPointLocal).abs() >
            SomConstants.temperatureClosenessRange) {
      temperatureAdjustmentNeeded = true;
    }

    if (moleculeInjectedThisStep) {
      final numMolecules = moleculeDataSet!.getNumberOfMolecules();
      final injectedParticleTemperature = (2 / 3) *
          moleculeDataSet!.getMoleculeKineticEnergy(numMolecules - 1);
      final newTemperature = temperatureSetPointLocal *
              (numMolecules - 1) /
              numMolecules +
          injectedParticleTemperature / numMolecules;
      setTemperature(newTemperature);
    } else if (moleculeForceAndMotionCalculator!.lidChangedParticleVelocity) {
      if ((heightChangeThisStep > 0 &&
              calculatedTemperature < temperatureSetPointLocal) ||
          (heightChangeThisStep < 0 &&
              calculatedTemperature > temperatureSetPointLocal)) {
        setTemperature(
          calculatedTemperature + averageTemperatureDifference.average,
        );
      }
      moleculeForceAndMotionCalculator!.lidChangedParticleVelocity = false;
    } else if (temperatureAdjustmentNeeded ||
        temperatureSetPointLocal > SomConstants.liquidTemperature ||
        temperatureSetPointLocal < SomConstants.solidTemperature / 5) {
      if (thermostatRunPreviousStep != isoKineticThermostat) {
        isoKineticThermostat!.clearAccumulatedBias();
      }
      isoKineticThermostat!.adjustTemperature(calculatedTemperature);
      thermostatRunThisStep = isoKineticThermostat;
    } else if (!temperatureAdjustmentNeeded) {
      if (thermostatRunPreviousStep != andersenThermostat) {
        andersenThermostat!.clearAccumulatedBias();
      }
      andersenThermostat!.adjustTemperature();
      thermostatRunThisStep = andersenThermostat;
    }

    thermostatRunPreviousStep = thermostatRunThisStep;

    if (!temperatureAdjustmentNeeded &&
        !moleculeInjectedThisStep &&
        !(moleculeForceAndMotionCalculator?.lidChangedParticleVelocity ??
            false)) {
      averageTemperatureDifference.addValue(
        temperatureSetPointLocal - calculatedTemperature,
      );
    }
  }

  void initializeMonatomic(SubstanceType substance, PhaseState phase) {
    assert(
      substance == SubstanceType.adjustableAtom ||
          substance == SubstanceType.neon ||
          substance == SubstanceType.argon,
    );

    late final double localParticleDiameter;
    if (substance == SubstanceType.neon) {
      localParticleDiameter = SomConstants.neonRadius * 2;
    } else if (substance == SubstanceType.argon) {
      localParticleDiameter = SomConstants.argonRadius * 2;
    } else {
      localParticleDiameter =
          SomConstants.adjustableAttractionDefaultRadius * 2;
    }

    final numberOfAtoms = math
        .pow(
          _roundSymmetric(
            SomConstants.containerWidth /
                ((localParticleDiameter * 1.05) * 3),
          ),
          2,
        )
        .toInt();

    moleculeDataSet = MoleculeForceAndMotionDataSet(1);
    phaseStateChanger =
        MonatomicPhaseStateChanger(this, random: random);
    atomPositionUpdater = MonatomicAtomPositionUpdater.updateAtomPositions;
    moleculeForceAndMotionCalculator = MonatomicVerletAlgorithm(this);
    isoKineticThermostat = IsokineticThermostat(
      moleculeDataSet!,
      minModelTemperature!,
      random: random,
    );
    andersenThermostat = AndersenThermostat(
      moleculeDataSet!,
      minModelTemperature!,
      random: random,
    );

    final atomPositions = [SomVec2(0, 0)];
    for (var i = 0; i < numberOfAtoms; i++) {
      moleculeDataSet!.addMolecule(
        atomPositions,
        SomVec2(0, 0),
        SomVec2(0, 0),
        0,
        true,
      );

      late final ScaledAtom atom;
      if (substance == SubstanceType.neon) {
        atom = ScaledAtom(AtomType.neon, 0, 0);
      } else if (substance == SubstanceType.argon) {
        atom = ScaledAtom(AtomType.argon, 0, 0);
      } else {
        atom = ScaledAtom(AtomType.adjustable, 0, 0);
      }
      scaledAtoms.add(atom);
    }

    targetNumberOfMolecules = moleculeDataSet!.numberOfMolecules;
    setPhase(phase);
  }

  void initializeDiatomic(SubstanceType substance, PhaseState phase) {
    assert(substance == SubstanceType.diatomicOxygen);

    var numberOfAtoms = math
        .pow(
          _roundSymmetric(
            SomConstants.containerWidth /
                ((SomConstants.oxygenRadius * 2.1) * 3),
          ),
          2,
        )
        .toInt();
    if (numberOfAtoms % 2 != 0) {
      numberOfAtoms--;
    }

    moleculeDataSet = MoleculeForceAndMotionDataSet(2);
    phaseStateChanger = DiatomicPhaseStateChanger(this, random: random);
    atomPositionUpdater = DiatomicAtomPositionUpdater.updateAtomPositions;
    moleculeForceAndMotionCalculator = DiatomicVerletAlgorithm(this);
    isoKineticThermostat = IsokineticThermostat(
      moleculeDataSet!,
      minModelTemperature!,
      random: random,
    );
    andersenThermostat = AndersenThermostat(
      moleculeDataSet!,
      minModelTemperature!,
      random: random,
    );

    final numberOfMolecules = numberOfAtoms ~/ 2;
    final atomPositions = [SomVec2(0, 0), SomVec2(0, 0)];
    for (var i = 0; i < numberOfMolecules; i++) {
      moleculeDataSet!.addMolecule(
        atomPositions,
        SomVec2(0, 0),
        SomVec2(0, 0),
        0,
        true,
      );
      scaledAtoms.add(ScaledAtom(AtomType.oxygen, 0, 0));
      scaledAtoms.add(ScaledAtom(AtomType.oxygen, 0, 0));
    }

    targetNumberOfMolecules = moleculeDataSet!.numberOfMolecules;
    setPhase(phase);
  }

  void initializeTriatomic(SubstanceType substance, PhaseState phase) {
    assert(substance == SubstanceType.water);

    final waterMoleculeDiameter = SomConstants.oxygenRadius * 2.1;
    final moleculesAcrossBottom = _roundSymmetric(
      SomConstants.containerWidth / (waterMoleculeDiameter * 1.2),
    );
    // PhET uses Math.pow(across/3, 2) as a float (~75.11); ceil matches the
    // 76-molecule solid/liquid snapshot dumps used by WaterPhaseStateChanger.
    final numberOfMolecules =
        math.pow(moleculesAcrossBottom / 3, 2).ceil();

    moleculeDataSet = MoleculeForceAndMotionDataSet(3);
    phaseStateChanger = WaterPhaseStateChanger(this, random: random);
    atomPositionUpdater = WaterAtomPositionUpdater.updateAtomPositions;
    moleculeForceAndMotionCalculator = WaterVerletAlgorithm(this);
    isoKineticThermostat = IsokineticThermostat(
      moleculeDataSet!,
      minModelTemperature!,
      random: random,
    );
    andersenThermostat = AndersenThermostat(
      moleculeDataSet!,
      minModelTemperature!,
      random: random,
    );

    final atomPositions = [SomVec2(0, 0), SomVec2(0, 0), SomVec2(0, 0)];
    for (var i = 0; i < numberOfMolecules; i++) {
      moleculeDataSet!.addMolecule(
        atomPositions,
        SomVec2(0, 0),
        SomVec2(0, 0),
        0,
        true,
      );
      scaledAtoms.add(ScaledAtom(AtomType.oxygen, 0, 0));
      scaledAtoms.add(HydrogenAtom(0, 0, true));
      scaledAtoms.add(HydrogenAtom(0, 0, i % 2 == 0));
    }

    targetNumberOfMolecules = moleculeDataSet!.numberOfMolecules;
    setPhase(phase);
  }

  void syncAtomPositions() {
    assert(
      moleculeDataSet!.numberOfAtoms == scaledAtoms.length,
      'Inconsistent number of normalized versus non-normalized atoms',
    );
    final positionMultiplier = particleDiameter;
    final atomPositions = moleculeDataSet!.atomPositions;

    for (var i = 0; i < scaledAtoms.length; i++) {
      scaledAtoms[i].setPosition(
        atomPositions[i]!.x * positionMultiplier,
        atomPositions[i]!.y * positionMultiplier,
      );
    }
  }

  double getPressureInAtmospheres() {
    return SomConstants.pressureDisplayMultiplier * getModelPressure();
  }

  PhaseState mapTemperatureToPhase() {
    if (temperatureSetPoint <
        SomConstants.solidTemperature +
            ((SomConstants.liquidTemperature -
                    SomConstants.solidTemperature) /
                2)) {
      return PhaseState.solid;
    } else if (temperatureSetPoint <
        SomConstants.liquidTemperature +
            ((SomConstants.gasTemperature - SomConstants.liquidTemperature) /
                2)) {
      return PhaseState.liquid;
    }
    return PhaseState.gas;
  }

  void setContainerExploded(bool exploded) {
    if (isExploded != exploded) {
      isExploded = exploded;
      if (!exploded) {
        containerHeight = SomConstants.containerInitialHeight;
      }
      notifyListeners();
    }
  }

  void returnLid() {
    if (!isExploded) {
      return;
    }

    var numMoleculesOutsideContainer = 0;
    var firstOutsideMoleculeIndex = 0;
    do {
      for (firstOutsideMoleculeIndex = 0;
          firstOutsideMoleculeIndex < moleculeDataSet!.getNumberOfMolecules();
          firstOutsideMoleculeIndex++) {
        final pos = moleculeDataSet!
            .getMoleculeCenterOfMassPositions()[firstOutsideMoleculeIndex]!;
        if (pos.x < 0 ||
            pos.x > normalizedContainerWidth ||
            pos.y < 0 ||
            pos.y >
                SomConstants.containerInitialHeight / particleDiameter) {
          break;
        }
      }
      if (firstOutsideMoleculeIndex <
          moleculeDataSet!.getNumberOfMolecules()) {
        moleculeDataSet!.removeMolecule(firstOutsideMoleculeIndex);
        numMoleculesOutsideContainer++;
      }
    } while (firstOutsideMoleculeIndex !=
        moleculeDataSet!.getNumberOfMolecules());

    for (var i = 0;
        i <
            numMoleculesOutsideContainer *
                moleculeDataSet!.getAtomsPerMolecule();
        i++) {
      if (scaledAtoms.isNotEmpty) {
        scaledAtoms.removeLast();
      }
    }

    setContainerExploded(false);

    if (numMoleculesOutsideContainer > 0 &&
        moleculeForceAndMotionCalculator!.calculatedTemperature >
            SomConstants.gasTemperature) {
      phaseStateChanger!.setPhase(PhaseState.gas);
    }

    targetNumberOfMolecules = moleculeDataSet!.numberOfMolecules;
    notifyListeners();
  }

  static int _roundSymmetric(num value) {
    return (value + (value >= 0 ? 0.5 : -0.5)).truncate();
  }

  static const double particleContainerWidth = SomConstants.containerWidth;
  static const double particleContainerInitialHeight =
      SomConstants.containerInitialHeight;
  static const double maxContainerExpandRate =
      SomConstants.maxContainerExpandRate;
}
