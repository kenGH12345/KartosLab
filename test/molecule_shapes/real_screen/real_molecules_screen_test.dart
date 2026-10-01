import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/molecule_shapes/model/geometry.dart';
import 'package:kratos/molecule_shapes/model/molecule_shapes_model.dart';
import 'package:kratos/molecule_shapes/model/real_molecule.dart';
import 'package:kratos/molecule_shapes/model/vec3.dart';
import 'package:kratos/molecule_shapes/molecule_shapes_strings.dart';
import 'package:kratos/molecule_shapes/view/element_colors.dart';
import 'package:kratos/molecule_shapes/view/real_molecules_screen.dart';

void main() {
  test('source order is exactly the 13 TAB_2 molecules starting with H2O', () {
    expect(tab2Molecules.map((s) => s.displayName).toList(), [
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
    expect(toSubscriptFormula('H2O'), 'H₂O');
    expect(toSubscriptFormula('SF6'), 'SF₆');
  });

  test('H2O Real 104.5° / Model 109.5° survive Real→Model→Real', () {
    final model = RealMoleculesModel();
    expect(model.shape.displayName, 'H2O');
    expect(model.showRealView, isTrue);
    expect(model.molecule.isReal, isTrue);
    expect(model.molecule.bondAngles().single.label, '104.5°');

    model.setShowRealView(false);
    expect(model.shape.displayName, 'H2O');
    expect(model.molecule.isReal, isFalse);
    expect(model.molecule.bondAngles().single.label, '109.5°');
    expect(model.moleculeGeometryId, 'BENT');
    expect(model.electronGeometryId, 'TETRAHEDRAL');

    model.setShowRealView(true);
    expect(model.shape.displayName, 'H2O');
    expect(model.molecule.isReal, isTrue);
    expect(model.molecule.bondAngles().single.label, '104.5°');
  });

  test('every TAB_2 molecule selects with expected geometry ids', () {
    final expected = <String, (String, String)>{
      'H2O': ('BENT', 'TETRAHEDRAL'),
      'CO2': ('LINEAR', 'LINEAR'),
      'SO2': ('BENT', 'TRIGONAL_PLANAR'),
      'XeF2': ('LINEAR', 'TRIGONAL_BIPYRAMIDAL'),
      'BF3': ('TRIGONAL_PLANAR', 'TRIGONAL_PLANAR'),
      'ClF3': ('T_SHAPED', 'TRIGONAL_BIPYRAMIDAL'),
      'NH3': ('TRIGONAL_PYRAMIDAL', 'TETRAHEDRAL'),
      'CH4': ('TETRAHEDRAL', 'TETRAHEDRAL'),
      'SF4': ('SEESAW', 'TRIGONAL_BIPYRAMIDAL'),
      'XeF4': ('SQUARE_PLANAR', 'OCTAHEDRAL'),
      'BrF5': ('SQUARE_PYRAMIDAL', 'OCTAHEDRAL'),
      'PCl5': ('TRIGONAL_BIPYRAMIDAL', 'TRIGONAL_BIPYRAMIDAL'),
      'SF6': ('OCTAHEDRAL', 'OCTAHEDRAL'),
    };
    final model = RealMoleculesModel();
    for (final shape in tab2Molecules) {
      model.selectMolecule(shape);
      final ids = expected[shape.displayName]!;
      expect(model.moleculeGeometryId, ids.$1, reason: shape.displayName);
      expect(model.electronGeometryId, ids.$2, reason: shape.displayName);
      expect(model.molecule.isReal, isTrue);
      expect(model.molecule.radialAtoms, isNotEmpty);
      for (final atom in model.molecule.radialAtoms) {
        expect(atom.position.z.isFinite, isTrue);
        expect(atom.element, isNotNull);
      }
    }
  });

  test('rotation changes quaternion but not local coordinates', () {
    final model = RealMoleculesModel();
    final before = model.molecule.radialAtoms.map((a) => a.position).toList();
    model.rotateByPointer(40, -25);
    expect(model.quaternion, isNot(Quat.identity));
    final after = model.molecule.radialAtoms.map((a) => a.position).toList();
    for (var i = 0; i < before.length; i++) {
      expect(after[i].almostEquals(before[i]), isTrue);
    }
    final worldMoved = model.worldPosition(model.molecule.radialAtoms.first);
    expect(worldMoved.almostEquals(before.first), isFalse);

    model.quaternion = Quat.identity;
    expect(
      model.worldPosition(model.molecule.radialAtoms.first).almostEquals(before.first),
      isTrue,
    );
  });

  test('selecting another molecule resets rotation', () {
    final model = RealMoleculesModel()..rotateByPointer(12, 8);
    model.selectMolecule(tab2Molecules[7]);
    expect(model.shape.displayName, 'CH4');
    expect(model.quaternion.w, closeTo(1, 1e-12));
  });

  test('Real and Model states stay independent across molecules', () {
    final model = RealMoleculesModel()..selectMolecule(tab2Molecules[6]); // NH3
    final realAngle = model.molecule.bondAngles().first.degrees;
    expect(realAngle, closeTo(107.8, 0.05));
    model.setShowRealView(false);
    expect(model.molecule.bondAngles().first.label, '109.5°');
    model.selectMolecule(tab2Molecules.first);
    expect(model.showRealView, isFalse);
    expect(model.shape.displayName, 'H2O');
    expect(model.molecule.bondAngles().single.label, '109.5°');
    model.setShowRealView(true);
    expect(model.molecule.bondAngles().single.label, '104.5°');
  });

  test('outer lone pairs preference does not alter coordinates', () {
    final preferences = MoleculeShapesPreferences();
    final model = RealMoleculesModel(preferences: preferences);
    // Water has no outer LPs on H; CO2 does (2 per O).
    expect(model.molecule.distantLonePairs, isEmpty);
    model.selectMolecule(tab2Molecules[1]);
    final co2Before = model.molecule.radialAtoms.map((a) => a.position).toList();
    expect(model.molecule.distantLonePairs.length, 4);
    preferences.showOuterLonePairs = true;
    expect(model.showOuterLonePairs, isTrue);
    final co2After = model.molecule.radialAtoms.map((a) => a.position).toList();
    for (var i = 0; i < co2Before.length; i++) {
      expect(co2After[i].almostEquals(co2Before[i]), isTrue);
    }
  });

  test('reset returns H2O Real without clearing outer-lone-pair preference', () {
    final preferences = MoleculeShapesPreferences()..showOuterLonePairs = true;
    final model = RealMoleculesModel(preferences: preferences)
      ..selectMolecule(tab2Molecules[12])
      ..setShowRealView(false)
      ..showBondAngles = true
      ..rotateByPointer(3, 3);
    model.reset();
    expect(model.shape.displayName, 'H2O');
    expect(model.showRealView, isTrue);
    expect(model.molecule.bondAngles().single.label, '104.5°');
    expect(preferences.showOuterLonePairs, isTrue);
    expect(model.showBondAngles, isFalse);
  });

  testWidgets('Real Molecules Screen builds selector, Real/Model, options', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RealMoleculesScreen())),
    );
    expect(find.text(MoleculeShapesStrings.molecule), findsOneWidget);
    expect(find.text(MoleculeShapesStrings.realView), findsOneWidget);
    expect(find.text(MoleculeShapesStrings.modelView), findsOneWidget);
    expect(find.text(MoleculeShapesStrings.options), findsOneWidget);
    expect(find.text(MoleculeShapesStrings.showOuterLonePairs), findsOneWidget);
    expect(find.text(toSubscriptFormula('H2O')), findsOneWidget);
  });

  testWidgets('UI Real/Model toggle updates angle readout source', (tester) async {
    final model = RealMoleculesModel();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RealMoleculesScreen(model: model))),
    );
    expect(model.molecule.bondAngles().single.label, '104.5°');
    await tester.tap(find.text(MoleculeShapesStrings.modelView));
    await tester.pump();
    expect(model.showRealView, isFalse);
    expect(model.molecule.bondAngles().single.label, '109.5°');
    await tester.tap(find.text(MoleculeShapesStrings.realView));
    await tester.pump();
    expect(model.molecule.bondAngles().single.label, '104.5°');
  });

  testWidgets('Model Screen and Real Screen do not share molecule state', (tester) async {
    final real = RealMoleculesModel()..selectMolecule(tab2Molecules[7]);
    final modelScreen = ModelMoleculesModel();
    expect(real.shape.displayName, 'CH4');
    expect(modelScreen.molecule.domainCount, 2);
    expect(modelScreen.molecule.isReal, isFalse);
  });

  test('double bonds on CO2 remain order 2 in Real view', () {
    final model = RealMoleculesModel()..selectMolecule(tab2Molecules[1]);
    expect(model.molecule.bonds.where((b) => b.order == 2), hasLength(2));
    model.setShowRealView(false);
    expect(model.molecule.bonds.where((b) => b.order == 2), hasLength(2));
  });

  test('bond angle labels use actual vectors not a hardcoded ideal table', () {
    final model = RealMoleculesModel();
    model.showBondAngles = true;
    final fromVectors = angleDegreesBetween(
      model.molecule.radialAtoms[0].orientation,
      model.molecule.radialAtoms[1].orientation,
    );
    expect(fromVectors, closeTo(104.5, 1e-6));
    expect(formatBondAngleDegrees(fromVectors), '104.5°');
  });
}
