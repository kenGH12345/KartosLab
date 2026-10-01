import 'dart:math' as math;

import '../molecule_force_and_motion_data_set.dart';
import 'water_molecule_structure.dart';

/// Updates atom positions for water molecules — PhET WaterAtomPositionUpdater.
class WaterAtomPositionUpdater {
  WaterAtomPositionUpdater._();

  static final List<double> _structureX =
      WaterMoleculeStructure.moleculeStructureX;
  static final List<double> _structureY =
      WaterMoleculeStructure.moleculeStructureY;

  static void updateAtomPositions(MoleculeForceAndMotionDataSet moleculeDataSet) {
    assert(moleculeDataSet.getAtomsPerMolecule() == 3);

    final atomPositions = moleculeDataSet.getAtomPositions();
    final moleculeCenterOfMassPositions =
        moleculeDataSet.getMoleculeCenterOfMassPositions();
    final moleculeRotationAngles = moleculeDataSet.getMoleculeRotationAngles();

    for (var i = 0; i < moleculeDataSet.getNumberOfMolecules(); i++) {
      final cosineTheta = math.cos(moleculeRotationAngles[i]);
      final sineTheta = math.sin(moleculeRotationAngles[i]);
      for (var j = 0; j < 3; j++) {
        final xOffset =
            (cosineTheta * _structureX[j]) - (sineTheta * _structureY[j]);
        final yOffset =
            (sineTheta * _structureX[j]) + (cosineTheta * _structureY[j]);
        atomPositions[i * 3 + j]!.setXY(
          moleculeCenterOfMassPositions[i]!.x + xOffset,
          moleculeCenterOfMassPositions[i]!.y + yOffset,
        );
      }
    }
  }
}
