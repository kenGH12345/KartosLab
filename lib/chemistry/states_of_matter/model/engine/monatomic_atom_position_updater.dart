import '../molecule_force_and_motion_data_set.dart';
import '../som_vec2.dart';

/// Updates atom positions for monatomic datasets — PhET MonatomicAtomPositionUpdater.
class MonatomicAtomPositionUpdater {
  MonatomicAtomPositionUpdater._();

  /// Optional [xOffset] matches PhET setPhase call site (visual centering).
  static void updateAtomPositions(
    MoleculeForceAndMotionDataSet moleculeDataSet, [
    double xOffset = 0,
  ]) {
    assert(moleculeDataSet.atomsPerMolecule == 1);

    final atomPositions = moleculeDataSet.atomPositions;
    final moleculeCenterOfMassPositions =
        moleculeDataSet.moleculeCenterOfMassPositions;

    for (var i = 0; i < moleculeDataSet.getNumberOfMolecules(); i++) {
      final com = moleculeCenterOfMassPositions[i]!;
      if (xOffset == 0) {
        // Same reference as COM (PhET assigns the vector reference).
        atomPositions[i] = com;
      } else {
        final existing = atomPositions[i];
        if (existing == null || identical(existing, com)) {
          atomPositions[i] = SomVec2(com.x + xOffset, com.y);
        } else {
          existing.setXY(com.x + xOffset, com.y);
        }
      }
    }
  }
}
