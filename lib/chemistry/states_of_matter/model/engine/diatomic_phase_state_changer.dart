import 'dart:math' as math;

import '../../som_constants.dart';
import '../phase_state.dart';
import '../substance_type.dart';
import 'abstract_phase_state_changer.dart';
import 'data/diatomic_liquid_states.dart';
import 'diatomic_atom_position_updater.dart';

/// Phase configs for diatomic molecules — PhET DiatomicPhaseStateChanger.
class DiatomicPhaseStateChanger extends AbstractPhaseStateChanger {
  DiatomicPhaseStateChanger(
    super.multipleParticleModel, {
    super.random,
  }) {
    assert(multipleParticleModel.moleculeDataSet!.getAtomsPerMolecule() == 2);
  }

  static const double minInitialDiameterDistance = 2.02;

  @override
  void setPhase(PhaseState phaseID) {
    var postChangeModelSteps = 0;
    switch (phaseID) {
      case PhaseState.solid:
        setPhaseSolid();
        postChangeModelSteps = 0;
      case PhaseState.liquid:
        setPhaseLiquid();
        postChangeModelSteps = 20;
      case PhaseState.gas:
        setPhaseGas();
        postChangeModelSteps = 0;
      case PhaseState.unknown:
        throw ArgumentError('invalid phaseState: $phaseID');
    }

    final moleculeDataSet = multipleParticleModel.moleculeDataSet!;
    DiatomicAtomPositionUpdater.updateAtomPositions(moleculeDataSet);

    for (var i = 0; i < postChangeModelSteps; i++) {
      multipleParticleModel.stepInTime(SomConstants.nominalTimeStep);
    }
  }

  @override
  void setParticleConfigurationSolid() {
    formCrystal(
      _roundSymmetric(
            math.sqrt(
              multipleParticleModel.moleculeDataSet!.getNumberOfMolecules() * 2,
            ),
          ) ~/
          2,
      minInitialDiameterDistance,
      minInitialDiameterDistance * 0.5,
      0.5,
      1.4, // empirically determined to minimize bounce
      false,
    );
  }

  @override
  void setParticleConfigurationLiquid() {
    if (multipleParticleModel.substance != SubstanceType.diatomicOxygen) {
      throw StateError(
        'unhandled substance: ${multipleParticleModel.substance}',
      );
    }
    loadSavedState(DiatomicLiquidStates.oxygen);
  }

  static int _roundSymmetric(num value) {
    return (value + (value >= 0 ? 0.5 : -0.5)).truncate();
  }
}
