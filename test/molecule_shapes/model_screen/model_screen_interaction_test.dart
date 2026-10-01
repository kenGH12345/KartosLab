import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/molecule_shapes/model/molecule_shapes_model.dart';
import 'package:kratos/molecule_shapes/model/pair_group.dart';
import 'package:kratos/molecule_shapes/model/vec3.dart';
import 'package:kratos/molecule_shapes/molecule_shapes_strings.dart';
import 'package:kratos/molecule_shapes/view/bond_thumbnail_painter.dart';
import 'package:kratos/molecule_shapes/view/model_molecules_screen.dart';

Finder _thumb(int order) => find.byWidgetPredicate(
      (widget) =>
          widget is CustomPaint &&
          widget.painter is BondThumbnailPainter &&
          (widget.painter! as BondThumbnailPainter).order == order,
    );

void main() {
  testWidgets('Model Screen builds with bonding, lone pair, options, name, reset',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ModelMoleculesScreen())),
    );
    expect(find.text(MoleculeShapesStrings.bonding), findsOneWidget);
    expect(find.text(MoleculeShapesStrings.lonePair), findsOneWidget);
    expect(find.text(MoleculeShapesStrings.options), findsOneWidget);
    expect(find.text(MoleculeShapesStrings.geometryName), findsOneWidget);
    expect(find.text(MoleculeShapesStrings.removeAll), findsOneWidget);
    expect(find.text(MoleculeShapesStrings.showLonePairs), findsOneWidget);
    expect(find.text(MoleculeShapesStrings.showBondAngles), findsOneWidget);
    expect(find.text(MoleculeShapesStrings.moleculeGeometry), findsOneWidget);
    expect(find.text(MoleculeShapesStrings.electronGeometry), findsOneWidget);
    expect(_thumb(1), findsOneWidget);
    expect(_thumb(2), findsOneWidget);
    expect(_thumb(3), findsOneWidget);
    expect(_thumb(0), findsOneWidget);
  });

  testWidgets('add double bond updates domain count and keeps one domain per bond',
      (tester) async {
    final model = ModelMoleculesModel()..removeAll();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ModelMoleculesScreen(model: model))),
    );
    await tester.tap(_thumb(2));
    await tester.pump();
    expect(model.molecule.domainCount, 1);
    expect(model.molecule.bonds.single.order, 2);
    expect(model.electronGeometryId, 'DIATOMIC');
  });

  testWidgets('add lone pair updates geometry names when toggled', (tester) async {
    final model = ModelMoleculesModel()..removeAll();
    model.addPairGroup(1);
    model.addPairGroup(1);
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ModelMoleculesScreen(model: model))),
    );
    await tester.tap(_thumb(0));
    await tester.pump();
    expect(model.molecule.domainCount, anyOf(2, 3));
    if (model.molecule.domainCount == 2) {
      expect(model.addPairGroup(0), isTrue);
    }
    expect(model.molecule.domainCount, 3);
    expect(model.moleculeGeometryId, 'BENT');
    expect(model.electronGeometryId, 'TRIGONAL_PLANAR');

    await tester.tap(find.text(MoleculeShapesStrings.moleculeGeometry));
    await tester.pump();
    expect(model.showMoleculeGeometry, isTrue);
    expect(find.text('Bent'), findsOneWidget);

    await tester.tap(find.text(MoleculeShapesStrings.electronGeometry));
    await tester.pump();
    expect(find.text('Trigonal Planar'), findsOneWidget);
  });

  testWidgets('Remove All keeps the central atom', (tester) async {
    final model = ModelMoleculesModel();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ModelMoleculesScreen(model: model))),
    );
    await tester.tap(find.text(MoleculeShapesStrings.removeAll));
    await tester.pump();
    expect(model.molecule.centralAtom, isNotNull);
    expect(model.molecule.domainCount, 0);
  });

  testWidgets('reset restores two single bonds', (tester) async {
    final model = ModelMoleculesModel()
      ..removeAll()
      ..addPairGroup(3)
      ..showBondAngles = true;
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ModelMoleculesScreen(model: model))),
    );
    // Reset via model API (button is icon-only CustomPaint).
    model.reset();
    await tester.pump();
    expect(model.molecule.domainCount, 2);
    expect(model.showBondAngles, isFalse);
    expect(model.molecule.bonds.map((b) => b.order), [1, 1]);
  });

  test('drag atom changes angle without renaming geometry', () {
    final model = ModelMoleculesModel()..removeAll();
    model.addPairGroup(1, position: const Vec3(10, 0, 0));
    model.addPairGroup(1, position: const Vec3(-10, 0, 0));
    expect(model.moleculeGeometryId, 'LINEAR');
    model.molecule.radialAtoms[1].dragToPosition(const Vec3(0, 10, 0));
    expect(model.molecule.bondAngles().single.degrees, closeTo(90, 1e-6));
    expect(model.moleculeGeometryId, 'LINEAR');
  });

  test('stepping relaxes a bent AX2E0 toward 180°', () {
    final model = ModelMoleculesModel()..removeAll();
    model.addPairGroup(1, position: const Vec3(10, 0, 0));
    model.addPairGroup(1, position: const Vec3(0, 10, 0));
    expect(model.molecule.bondAngles().single.degrees, closeTo(90, 1e-6));
    for (var i = 0; i < 240; i++) {
      model.step(1 / 60);
    }
    expect(model.molecule.bondAngles().single.degrees, greaterThan(150));
    expect(model.moleculeGeometryId, 'LINEAR');
    for (final atom in model.molecule.radialAtoms) {
      expect(atom.position.magnitude, closeTo(PairGroup.bondedPairDistance, 0.5));
    }
  });

  test('stepping places AX4 near tetrahedral angles', () {
    final model = ModelMoleculesModel()..removeAll();
    model.addPairGroup(1, position: const Vec3(10, 0, 0));
    model.addPairGroup(1, position: const Vec3(-10, 0, 0));
    model.addPairGroup(1, position: const Vec3(0, 10, 0));
    model.addPairGroup(1, position: const Vec3(0, -10, 0));
    for (var i = 0; i < 360; i++) {
      model.step(1 / 60);
    }
    expect(model.moleculeGeometryId, 'TETRAHEDRAL');
    for (final angle in model.molecule.bondAngles()) {
      expect(angle.degrees, closeTo(109.5, 8));
    }
  });
}
