import 'dart:math' as math;

import '../../som_constants.dart';
import '../phase_state.dart';
import '../substance_type.dart';
import 'abstract_phase_state_changer.dart';
import 'data/monatomic_liquid_states.dart';
import 'monatomic_atom_position_updater.dart';

/// Monatomic phase configs — PhET MonatomicPhaseStateChanger.
class MonatomicPhaseStateChanger extends AbstractPhaseStateChanger {
  MonatomicPhaseStateChanger(
    super.multipleParticleModel, {
    super.random,
  });

  static const double minInitialInterParticleDistance = 1.12;

  @override
  void setPhase(PhaseState phaseID) {
    super.setPhase(phaseID);

    var offset = 0.0;
    if (multipleParticleModel.substance == SubstanceType.argon) {
      offset = 6;
    } else if (multipleParticleModel.substance ==
        SubstanceType.adjustableAtom) {
      offset = 4;
    }

    MonatomicAtomPositionUpdater.updateAtomPositions(
      multipleParticleModel.moleculeDataSet!,
      offset,
    );

    for (var i = 0; i < 5; i++) {
      multipleParticleModel.stepInTime(SomConstants.nominalTimeStep);
    }
  }

  @override
  void setParticleConfigurationSolid() {
    formCrystal(
      _roundSymmetric(
        math.sqrt(
          multipleParticleModel.moleculeDataSet!.getNumberOfMolecules(),
        ),
      ),
      minInitialInterParticleDistance,
      minInitialInterParticleDistance * 0.866,
      minInitialInterParticleDistance / 2,
      minInitialInterParticleDistance,
      false,
    );
  }

  @override
  void setParticleConfigurationLiquid() {
    final Map<String, dynamic> dataSetToLoad;
    switch (multipleParticleModel.substance) {
      case SubstanceType.neon:
        dataSetToLoad = MonatomicLiquidStates.neon;
      case SubstanceType.argon:
        dataSetToLoad = MonatomicLiquidStates.argon;
      case SubstanceType.adjustableAtom:
        dataSetToLoad = MonatomicLiquidStates.adjustableAttraction;
      default:
        throw StateError(
          'unhandled substance: ${multipleParticleModel.substance}',
        );
    }
    loadSavedState(dataSetToLoad);
  }

  static int _roundSymmetric(num value) {
    return (value + (value >= 0 ? 0.5 : -0.5)).truncate();
  }
}
