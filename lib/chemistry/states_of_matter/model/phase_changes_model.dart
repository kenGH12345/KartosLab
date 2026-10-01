import 'dart:math' as math;

import '../som_constants.dart';
import 'atom_type.dart';
import 'interaction_strength_table.dart';
import 'multiple_particle_model.dart';
import 'substance_type.dart';

/// Phase Changes screen model — PhET `PhaseChangesModel`.
class PhaseChangesModel extends MultipleParticleModel {
  PhaseChangesModel({
    super.random,
    super.initialSubstance = SubstanceType.neon,
  }) : super(
          validSubstances: const {
            SubstanceType.neon,
            SubstanceType.argon,
            SubstanceType.diatomicOxygen,
            SubstanceType.water,
            SubstanceType.adjustableAtom,
          },
        ) {
    _phaseChangeModelConstructed = true;
    // Super ctor already ran handleSubstanceChanged; apply epsilon if adjustable.
    if (substance == SubstanceType.adjustableAtom) {
      setEpsilon(adjustableAtomInteractionStrength);
    }
  }

  static const double minAllowableContainerHeight = 1500;
  static const double maxContainerShrinkRate = 1250; // model units / s

  bool phaseDiagramExpanded = true;
  bool interactionPotentialExpanded = true;

  double adjustableAtomInteractionStrength = SomConstants.maxAdjustableEpsilon;
  double targetContainerHeight = SomConstants.containerInitialHeight;

  /// Avoid calling overrides before subclass fields are ready (PhET flag).
  bool _phaseChangeModelConstructed = false;

  bool get lidAboveInjectionPoint =>
      (containerHeight / particleDiameter) > injectionPoint.y;

  /// Pump enabled when playing, not exploded, lid above inject point, room left.
  bool get isPumpEnabled =>
      isPlaying &&
      !isExploded &&
      lidAboveInjectionPoint &&
      targetNumberOfMolecules < maxNumberOfMolecules;

  static final Map<SubstanceType, double> _sigmaTable = {
    SubstanceType.neon: SomConstants.neonRadius * 2,
    SubstanceType.argon: SomConstants.argonRadius * 2,
    SubstanceType.diatomicOxygen: SomConstants.sigmaForDiatomicOxygen,
    SubstanceType.water: SomConstants.sigmaForWater,
    SubstanceType.adjustableAtom:
        SomConstants.adjustableAttractionDefaultRadius * 2,
  };

  static final Map<SubstanceType, double> _epsilonTable = {
    SubstanceType.neon:
        InteractionStrengthTable.getInteractionPotential(AtomType.neon, AtomType.neon),
    SubstanceType.argon:
        InteractionStrengthTable.getInteractionPotential(AtomType.argon, AtomType.argon),
    SubstanceType.diatomicOxygen: SomConstants.epsilonForDiatomicOxygen,
    SubstanceType.water: SomConstants.epsilonForWater,
  };

  double getSigma() => _sigmaTable[substance]!;

  double getEpsilon() {
    if (substance == SubstanceType.adjustableAtom) {
      return adjustableAtomInteractionStrength;
    }
    return _epsilonTable[substance]!;
  }

  void setEpsilon(double epsilon) {
    if (substance != SubstanceType.adjustableAtom) {
      assert(false, 'Epsilon cannot be set when non-configurable molecule is in use.');
      return;
    }
    final clamped = epsilon.clamp(
      SomConstants.minAdjustableEpsilon,
      SomConstants.maxAdjustableEpsilon,
    );
    adjustableAtomInteractionStrength = clamped.toDouble();
    moleculeForceAndMotionCalculator?.setScaledEpsilon(
      convertEpsilonToScaledEpsilon(clamped.toDouble()),
    );
    notifyListeners();
  }

  void setTargetContainerHeight(double desiredContainerHeight) {
    targetContainerHeight = desiredContainerHeight.clamp(
      minAllowableContainerHeight,
      MultipleParticleModel.particleContainerInitialHeight,
    );
    notifyListeners();
  }

  @override
  void handleSubstanceChanged(SubstanceType substance) {
    targetContainerHeight = SomConstants.containerInitialHeight;
    super.handleSubstanceChanged(substance);
    if (substance == SubstanceType.adjustableAtom) {
      setEpsilon(adjustableAtomInteractionStrength);
    }
  }

  @override
  void setContainerExploded(bool exploded) {
    super.setContainerExploded(exploded);
    if (exploded) {
      targetContainerHeight = SomConstants.containerInitialHeight;
    }
  }

  @override
  void updateContainerSize(double dt) {
    if (!_phaseChangeModelConstructed ||
        isExploded ||
        targetContainerHeight == containerHeight) {
      super.updateContainerSize(dt);
      return;
    }

    heightChangeThisStep = targetContainerHeight - containerHeight;
    if (heightChangeThisStep > 0) {
      heightChangeThisStep = math.min(
        heightChangeThisStep,
        MultipleParticleModel.maxContainerExpandRate * dt,
      );
      containerHeight = math.min(
        containerHeight + heightChangeThisStep,
        MultipleParticleModel.particleContainerInitialHeight,
      );
    } else {
      heightChangeThisStep = math.max(
        heightChangeThisStep,
        -maxContainerShrinkRate * dt,
      );
      containerHeight = math.max(
        containerHeight + heightChangeThisStep,
        minAllowableContainerHeight,
      );
    }
    normalizedContainerHeight = containerHeight / particleDiameter;
    normalizedTotalContainerHeight = normalizedContainerHeight;
    normalizedLidVelocityY =
        (heightChangeThisStep / particleDiameter) / dt;
  }

  @override
  void reset() {
    super.reset();
    targetContainerHeight = SomConstants.containerInitialHeight;
    adjustableAtomInteractionStrength = SomConstants.maxAdjustableEpsilon;
    phaseDiagramExpanded = true;
    interactionPotentialExpanded = true;
    notifyListeners();
  }

  /// Empirically matches monatomic LJ scaling (PhET helper).
  static double convertEpsilonToScaledEpsilon(double epsilon) =>
      epsilon / (SomConstants.maxEpsilon / 2);
}
