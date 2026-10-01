import '../../som_constants.dart';
import '../phase_state.dart';
import '../substance_type.dart';
import 'abstract_phase_state_changer.dart';
import 'data/water_phase_states.dart';
import 'water_atom_position_updater.dart';

/// Phase configs for water — PhET WaterPhaseStateChanger.
class WaterPhaseStateChanger extends AbstractPhaseStateChanger {
  WaterPhaseStateChanger(
    super.multipleParticleModel, {
    super.random,
  }) {
    assert(multipleParticleModel.moleculeDataSet!.getAtomsPerMolecule() == 3);
  }

  @override
  void setPhase(PhaseState phaseID) {
    super.setPhase(phaseID);

    WaterAtomPositionUpdater.updateAtomPositions(
      multipleParticleModel.moleculeDataSet!,
    );

    for (var i = 0; i < 5; i++) {
      multipleParticleModel.stepInTime(SomConstants.nominalTimeStep);
    }
  }

  @override
  void setParticleConfigurationSolid() {
    if (multipleParticleModel.substance != SubstanceType.water) {
      throw StateError(
        'unhandled substance: ${multipleParticleModel.substance}',
      );
    }
    loadSavedState(WaterPhaseStates.solid);
    zeroOutCollectiveVelocity();
  }

  @override
  void setParticleConfigurationLiquid() {
    if (multipleParticleModel.substance != SubstanceType.water) {
      throw StateError(
        'unhandled substance: ${multipleParticleModel.substance}',
      );
    }
    loadSavedState(WaterPhaseStates.liquid);
  }
}
