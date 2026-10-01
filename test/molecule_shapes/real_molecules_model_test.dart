import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/molecule_shapes/model/molecule_shapes_model.dart';
import 'package:kratos/molecule_shapes/model/real_molecule.dart';
import 'package:kratos/molecule_shapes/model/real_molecule_shape.dart';

void main() {
  test('the full sim lists 13 molecules and starts on real water', () {
    expect(tab2Molecules, hasLength(13));
    expect(tab2Molecules.map((shape) => shape.displayName), [
      'H2O',
      'CO2',
      'SO2',
      'XeF2',
      'BF3',
      'ClF3',
      'NH3',
      'CH4',
      'SF4',
      'XeF4',
      'BrF5',
      'PCl5',
      'SF6',
    ]);
    expect(basicsOnlyMolecules.single.displayName, 'BeCl2');
    expect(tab2Molecules.contains(berylliumChloride), isFalse);

    final model = RealMoleculesModel();
    expect(model.shape.displayName, 'H2O');
    expect(model.showRealView, isTrue);
    expect(model.molecule.isReal, isTrue);
    expect(model.moleculeGeometryId, 'BENT');
    expect(model.electronGeometryId, 'TETRAHEDRAL');
    expect(model.molecule.bondAngles().single.label, '104.5°');
  });

  test('real and model views keep the molecule and disagree on water angle', () {
    final model = RealMoleculesModel();
    expect(model.molecule.bondAngles().single.degrees, closeTo(104.5, 1e-6));

    model.setShowRealView(false);
    expect(model.shape.displayName, 'H2O');
    expect(model.molecule.isReal, isFalse);
    expect(model.moleculeGeometryId, 'BENT');
    expect(model.electronGeometryId, 'TETRAHEDRAL');
    expect(model.molecule.bondAngles().single.label, '109.5°');
    expect(model.molecule.lonePairDomainCount, 2);
    expect(model.molecule.domainCount, 4);

    model.setShowRealView(true);
    expect(model.shape.displayName, 'H2O');
    expect(model.molecule.isReal, isTrue);
    expect(model.molecule.bondAngles().single.label, '104.5°');
  });

  test('Real↔Model toggle applies Attractor orientation match without data merge', () {
    final model = RealMoleculesModel();
    final before = model.molecule.radialAtoms.map((a) => a.orientation).toList();
    model.setShowRealView(false);
    final modelDirs = model.molecule.radialAtoms.map((a) => a.orientation).toList();
    // Ideal Model orientations should not equal Real 104.5° geometry directions.
    expect(
      modelDirs.every((d) => before.any((b) => b.almostEquals(d))),
      isFalse,
    );
    model.setShowRealView(true);
    expect(model.molecule.bondAngles().single.label, '104.5°');
    // After match, Real atom directions align with the previous Model frame,
    // not the raw published shape frame.
    final after = model.molecule.radialAtoms.map((a) => a.orientation).toList();
    expect(after.length, modelDirs.length);
    for (final d in modelDirs) {
      expect(after.any((a) => a.dot(d) > 0.95), isTrue);
    }
  });

  test('selecting another molecule resets view rotation and real angles', () {
    final model = RealMoleculesModel()..rotateByPointer(20, 5);
    model.selectMolecule(tab2Molecules[7]);
    expect(model.shape.displayName, 'CH4');
    expect(model.quaternion.w, closeTo(1, 1e-12));
    expect(model.moleculeGeometryId, 'TETRAHEDRAL');
    expect(model.molecule.bondAngles(), hasLength(6));
    for (final angle in model.molecule.bondAngles()) {
      expect(angle.label, '109.5°');
    }

    model.selectMolecule(tab2Molecules[1]);
    expect(model.shape.displayName, 'CO2');
    expect(model.molecule.bonds.where((bond) => bond.order == 2), hasLength(2));
    expect(model.molecule.domainCount, 2);
    expect(model.molecule.bondAngles().single.label, '180.0°');
    expect(model.molecule.radialLonePairs, isEmpty);
    expect(
      model.molecule.lonePairs.where((group) => group.isLonePair),
      hasLength(4),
    );
  });

  test('published real angles are not replaced by the ideal VSEPR angles', () {
    _expectReal('SO2', 'BENT', 'TRIGONAL_PLANAR', [119]);
    _expectReal('NH3', 'TRIGONAL_PYRAMIDAL', 'TETRAHEDRAL', [107.8, 107.8, 107.8]);
    _expectReal('ClF3', 'T_SHAPED', 'TRIGONAL_BIPYRAMIDAL', [87.5, 87.5, 175]);
    _expectReal('SF4', 'SEESAW', 'TRIGONAL_BIPYRAMIDAL', [173.1, 101.6]);
    _expectReal('XeF2', 'LINEAR', 'TRIGONAL_BIPYRAMIDAL', [180]);
    _expectReal('XeF4', 'SQUARE_PLANAR', 'OCTAHEDRAL', [90, 180]);
    _expectReal('BF3', 'TRIGONAL_PLANAR', 'TRIGONAL_PLANAR', [120]);
    _expectReal('BrF5', 'SQUARE_PYRAMIDAL', 'OCTAHEDRAL', [84.8, 89.5, 169.6]);
    _expectReal('PCl5', 'TRIGONAL_BIPYRAMIDAL', 'TRIGONAL_BIPYRAMIDAL', [90, 120, 180]);
    _expectReal('SF6', 'OCTAHEDRAL', 'OCTAHEDRAL', [90, 180]);

    final ammonia = RealMoleculesModel()..selectMolecule(_shape('NH3'));
    ammonia.setShowRealView(false);
    expect(ammonia.molecule.bondAngles().map((angle) => angle.label), everyElement('109.5°'));
    expect(ammonia.shape.displayName, 'NH3');
  });

  test('outer lone pairs are a preference gated by Show Lone Pairs', () {
    final preferences = MoleculeShapesPreferences();
    final model = RealMoleculesModel(preferences: preferences);
    expect(model.showOuterLonePairs, isFalse);
    preferences.showOuterLonePairs = true;
    expect(model.showOuterLonePairs, isTrue);
    model.showLonePairs = false;
    expect(model.showOuterLonePairs, isFalse);
    expect(preferences.showOuterLonePairs, isTrue);
  });

  test('reset returns water, real view, and default toggles', () {
    final preferences = MoleculeShapesPreferences()..showOuterLonePairs = true;
    final model = RealMoleculesModel(preferences: preferences)
      ..selectMolecule(_shape('SF6'))
      ..setShowRealView(false)
      ..showBondAngles = true
      ..showMoleculeGeometry = true
      ..rotateByPointer(4, 4);
    model.reset();

    expect(model.shape.displayName, 'H2O');
    expect(model.showRealView, isTrue);
    expect(model.molecule.isReal, isTrue);
    expect(model.molecule.bondAngles().single.label, '104.5°');
    expect(model.showBondAngles, isFalse);
    expect(model.showLonePairs, isTrue);
    expect(model.showMoleculeGeometry, isFalse);
    expect(model.showElectronGeometry, isFalse);
    expect(model.quaternion.w, closeTo(1, 1e-12));
    expect(preferences.showOuterLonePairs, isTrue);
    expect(model.showOuterLonePairs, isTrue);
  });
}

void _expectReal(
  String formula,
  String moleculeId,
  String electronId,
  List<double> expectedAngles,
) {
  final model = RealMoleculesModel()..selectMolecule(_shape(formula));
  expect(model.moleculeGeometryId, moleculeId, reason: formula);
  expect(model.electronGeometryId, electronId, reason: formula);
  final actual = model.molecule.bondAngles().map((angle) => angle.degrees).toList();
  for (final expected in expectedAngles) {
    expect(
      actual.any((angle) => (angle - expected).abs() < 0.05),
      isTrue,
      reason: '$formula missing $expected in $actual',
    );
  }
}

RealMoleculeShape _shape(String formula) =>
    tab2Molecules.firstWhere((shape) => shape.displayName == formula);
