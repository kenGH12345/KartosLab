import 'dart:math' as math;

import '../../som_constants.dart';
import '../molecule_force_and_motion_data_set.dart';

/// Updates atom positions for diatomic molecules (e.g. O2) — PhET DiatomicAtomPositionUpdater.
class DiatomicAtomPositionUpdater {
  DiatomicAtomPositionUpdater._();

  static void updateAtomPositions(MoleculeForceAndMotionDataSet moleculeDataSet) {
    assert(moleculeDataSet.atomsPerMolecule == 2);

    final atomPositions = moleculeDataSet.atomPositions;
    final moleculeCenterOfMassPositions =
        moleculeDataSet.moleculeCenterOfMassPositions;
    final moleculeRotationAngles = moleculeDataSet.moleculeRotationAngles;
    final halfDist = SomConstants.diatomicParticleDistance / 2;

    for (var i = 0; i < moleculeDataSet.getNumberOfMolecules(); i++) {
      final cosineTheta = math.cos(moleculeRotationAngles[i]);
      final sineTheta = math.sin(moleculeRotationAngles[i]);
      final cm = moleculeCenterOfMassPositions[i]!;
      atomPositions[i * 2]!.setXY(
        cm.x + cosineTheta * halfDist,
        cm.y + sineTheta * halfDist,
      );
      atomPositions[i * 2 + 1]!.setXY(
        cm.x - cosineTheta * halfDist,
        cm.y - sineTheta * halfDist,
      );
    }
  }
}
