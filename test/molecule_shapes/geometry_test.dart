import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/molecule_shapes/model/geometry.dart';
import 'package:kratos/molecule_shapes/model/molecule_shapes_model.dart';
import 'package:kratos/molecule_shapes/model/pair_group.dart';
import 'package:kratos/molecule_shapes/model/vec3.dart';

void main() {
  test('every domain count maps to the source electron geometry', () {
    expect(ElectronGeometry.byGroupCount(0).id, 'EMPTY');
    expect(ElectronGeometry.byGroupCount(1).label, 'Linear');
    expect(ElectronGeometry.byGroupCount(2).id, 'LINEAR');
    expect(ElectronGeometry.byGroupCount(3).id, 'TRIGONAL_PLANAR');
    expect(ElectronGeometry.byGroupCount(4).id, 'TETRAHEDRAL');
    expect(ElectronGeometry.byGroupCount(5).id, 'TRIGONAL_BIPYRAMIDAL');
    expect(ElectronGeometry.byGroupCount(6).id, 'OCTAHEDRAL');
    expect(() => ElectronGeometry.byGroupCount(7), throwsStateError);
  });

  test('molecule geometry names follow the AXE table, including nonphysical rows', () {
    expect(MoleculeGeometry.configuration(0, 4).id, 'EMPTY');
    expect(MoleculeGeometry.configuration(1, 0).label, 'Linear');
    expect(MoleculeGeometry.configuration(1, 5).id, 'DIATOMIC');
    expect(MoleculeGeometry.configuration(2, 0).id, 'LINEAR');
    expect(MoleculeGeometry.configuration(2, 1).id, 'BENT');
    expect(MoleculeGeometry.configuration(2, 2).id, 'BENT');
    expect(MoleculeGeometry.configuration(2, 3).id, 'LINEAR');
    expect(MoleculeGeometry.configuration(2, 4).id, 'LINEAR');
    expect(MoleculeGeometry.configuration(3, 0).id, 'TRIGONAL_PLANAR');
    expect(MoleculeGeometry.configuration(3, 1).id, 'TRIGONAL_PYRAMIDAL');
    expect(MoleculeGeometry.configuration(3, 2).id, 'T_SHAPED');
    expect(MoleculeGeometry.configuration(3, 3).id, 'T_SHAPED');
    expect(MoleculeGeometry.configuration(4, 0).id, 'TETRAHEDRAL');
    expect(MoleculeGeometry.configuration(4, 1).id, 'SEESAW');
    expect(MoleculeGeometry.configuration(4, 2).id, 'SQUARE_PLANAR');
    expect(MoleculeGeometry.configuration(5, 0).id, 'TRIGONAL_BIPYRAMIDAL');
    expect(MoleculeGeometry.configuration(5, 1).id, 'SQUARE_PYRAMIDAL');
    expect(MoleculeGeometry.configuration(6, 0).id, 'OCTAHEDRAL');
    expect(() => MoleculeGeometry.configuration(4, 3), throwsStateError);
    expect(() => MoleculeGeometry.configuration(7, 0), throwsStateError);
  });

  test('ideal slot angles match ElectronGeometry, not a separate table', () {
    expect(_labels(2, 0), ['180.0°']);
    expect(_labels(3, 0), ['120.0°', '120.0°', '120.0°']);
    expect(_labels(4, 0), List.filled(6, '109.5°'));
    expect(_labels(2, 1), ['120.0°']);
    expect(_labels(2, 2), ['109.5°']);
    expect(_labels(2, 3), ['180.0°']);
    expect(_labels(3, 1), List.filled(3, '109.5°'));
    expect(_sorted(_labels(3, 2)), ['180.0°', '90.0°', '90.0°']);
    expect(_sorted(_labels(4, 1)), ['120.0°', '180.0°', '90.0°', '90.0°', '90.0°', '90.0°']);
    expect(_sorted(_labels(4, 2)), ['180.0°', '180.0°', '90.0°', '90.0°', '90.0°', '90.0°']);
    expect(_count(_labels(5, 0), '90.0°'), 6);
    expect(_count(_labels(5, 0), '120.0°'), 3);
    expect(_count(_labels(5, 0), '180.0°'), 1);
    expect(_count(_labels(5, 1), '90.0°'), 8);
    expect(_count(_labels(5, 1), '180.0°'), 2);
    expect(_count(_labels(6, 0), '90.0°'), 12);
    expect(_count(_labels(6, 0), '180.0°'), 3);

    final tetra = _ideal(4, 0);
    expect(tetra.moleculeGeometryLabel, 'Tetrahedral');
    expect(tetra.electronGeometryLabel, 'Tetrahedral');
    final seesaw = _ideal(4, 1);
    expect(seesaw.moleculeGeometryLabel, 'Seesaw');
    expect(seesaw.electronGeometryLabel, 'Trigonal Bipyramidal');
    final square = _ideal(4, 2);
    expect(square.moleculeGeometryLabel, 'Square Planar');
    expect(square.electronGeometryLabel, 'Octahedral');
    final pyramidal = _ideal(5, 1);
    expect(pyramidal.moleculeGeometryLabel, 'Square Pyramidal');
  });

  test('bond angle text uses one decimal and pads short labels', () {
    expect(formatBondAngleDegrees(180), '180.0°');
    expect(formatBondAngleDegrees(109.471220333), '109.5°');
    expect(formatBondAngleDegrees(90), '90.0°');
    expect(formatBondAngleDegrees(9), '09.0°');
  });

  test('lone pair distance stays shorter than a bond', () {
    final model = _ideal(1, 1);
    expect(model.molecule.radialAtoms.single.position.magnitude, PairGroup.bondedPairDistance);
    expect(model.molecule.radialLonePairs.single.position.magnitude, PairGroup.lonePairDistance);
    expect(model.molecule.radialLonePairs.single.position.almostEquals(const Vec3(7, 0, 0)), isTrue);
  });
}

ModelMoleculesModel _ideal(int bonds, int lonePairs) {
  final model = ModelMoleculesModel()..removeAll();
  for (var i = 0; i < bonds; i++) {
    model.addPairGroup(1);
  }
  for (var i = 0; i < lonePairs; i++) {
    model.addPairGroup(0);
  }
  model.molecule.placeRadialGroupsAtIdealSlots();
  return model;
}

List<String> _labels(int bonds, int lonePairs) =>
    _ideal(bonds, lonePairs).molecule.bondAngles().map((angle) => angle.label).toList();

List<String> _sorted(List<String> labels) {
  final copy = [...labels]..sort();
  return copy;
}

int _count(List<String> labels, String label) => labels.where((item) => item == label).length;
