import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/states_of_matter/model/molecule_force_and_motion_data_set.dart';
import 'package:kratos/chemistry/states_of_matter/model/som_vec2.dart';

void main() {
  group('MoleculeForceAndMotionDataSet', () {
    test('KE and temperature for monatomic molecules', () {
      final data = MoleculeForceAndMotionDataSet(1);
      data.addMolecule(
        [SomVec2(0, 0)],
        SomVec2(1, 1),
        SomVec2(2, 0),
        0,
        true,
      );
      data.addMolecule(
        [SomVec2(0, 0)],
        SomVec2(2, 2),
        SomVec2(0, 2),
        0,
        true,
      );

      // KE = 0.5*m*(4) + 0.5*m*(4) = 2+2 = 4 for m=1
      expect(data.getTotalKineticEnergy(), closeTo(4.0, 1e-12));
      // T = (2/3) * KE / N = (2/3)*4/2 = 4/3
      expect(data.getTemperature(), closeTo(4 / 3, 1e-12));
      expect(data.getNumberOfMolecules(), 2);
      expect(data.numberOfAtoms, 2);
    });

    test('addMolecule capacity and removeMolecule', () {
      final data = MoleculeForceAndMotionDataSet(1);
      expect(data.getNumberOfRemainingSlots(), greaterThan(0));
      for (var i = 0; i < 3; i++) {
        expect(
          data.addMolecule(
            [SomVec2(0, 0)],
            SomVec2(i.toDouble(), 0),
            SomVec2(1, 0),
            0,
            true,
          ),
          isTrue,
        );
      }
      expect(data.getNumberOfMolecules(), 3);
      data.removeMolecule(1);
      expect(data.getNumberOfMolecules(), 2);
      expect(data.moleculeCenterOfMassPositions[0]!.x, 0);
      expect(data.moleculeCenterOfMassPositions[1]!.x, 2);
    });
  });
}
