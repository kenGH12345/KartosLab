import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/molecule_shapes/model/geometry.dart';
import 'package:kratos/molecule_shapes/model/molecule_shapes_model.dart';
import 'package:kratos/molecule_shapes/model/pair_group.dart';
import 'package:kratos/molecule_shapes/model/real_molecule.dart';
import 'package:kratos/molecule_shapes/model/vec3.dart';
import 'package:kratos/molecule_shapes/view/model_molecules_screen.dart';
import 'package:kratos/molecule_shapes/view/real_molecules_screen.dart';

void main() {
  group('H2O hard regression', () {
    test('Real 104.5 → Model 109.5 → Real 104.5', () {
      final model = RealMoleculesModel();
      expect(model.molecule.bondAngles().single.label, '104.5°');
      model.setShowRealView(false);
      expect(model.molecule.bondAngles().single.label, '109.5°');
      model.setShowRealView(true);
      expect(model.molecule.bondAngles().single.label, '104.5°');
      // Must never stick at ideal after returning to Real.
      expect(model.molecule.bondAngles().single.degrees, isNot(closeTo(109.5, 0.2)));
    });
  });

  group('Screen isolation', () {
    test('Model edits never appear on a separate RealMoleculesModel', () {
      final modelScreen = ModelMoleculesModel()
        ..removeAll()
        ..addPairGroup(3)
        ..addPairGroup(0)
        ..addPairGroup(0)
        ..rotateByPointer(20, 10)
        ..showBondAngles = true
        ..showElectronGeometry = true;
      final real = RealMoleculesModel();

      expect(real.shape.displayName, 'H2O');
      expect(real.showRealView, isTrue);
      expect(real.molecule.domainCount, 4); // 2 bonds + 2 central LPs
      expect(real.molecule.bonds.where((b) => b.order == 3), isEmpty);
      expect(real.showBondAngles, isFalse);
      expect(real.showElectronGeometry, isFalse);
      expect(real.quaternion, Quat.identity);
      expect(modelScreen.molecule.domainCount, 3);
    });

    test('Real molecule selection never mutates ModelMoleculesModel', () {
      final modelScreen = ModelMoleculesModel();
      final beforeDomains = modelScreen.molecule.domainCount;
      final beforeBonds =
          modelScreen.molecule.bonds.map((b) => b.order).toList();
      final real = RealMoleculesModel()
        ..selectMolecule(tab2Molecules[12]) // SF6
        ..setShowRealView(false)
        ..rotateByPointer(15, -8)
        ..showLonePairs = false;

      expect(modelScreen.molecule.domainCount, beforeDomains);
      expect(modelScreen.molecule.bonds.map((b) => b.order), beforeBonds);
      expect(modelScreen.showLonePairs, isTrue);
      expect(modelScreen.quaternion, Quat.identity);
      expect(real.shape.displayName, 'SF6');
    });
  });

  group('Real / Model data isolation', () {
    test('rotate Real then switch Model keeps Real angle and independent coords', () {
      final model = RealMoleculesModel();
      final realAngle = model.molecule.bondAngles().single.degrees;
      final realBondLen =
          model.molecule.radialAtoms.first.position.magnitude;
      model.rotateByPointer(30, 12);
      expect(model.quaternion, isNot(Quat.identity));

      model.setShowRealView(false);
      expect(model.molecule.bondAngles().single.label, '109.5°');
      expect(model.molecule.isReal, isFalse);
      model.rotateByPointer(-10, 5);

      model.setShowRealView(true);
      expect(model.molecule.isReal, isTrue);
      expect(model.molecule.bondAngles().single.label, '104.5°');
      expect(model.molecule.bondAngles().single.degrees, closeTo(realAngle, 1e-6));
      // Rigid Attractor remap may rotate the frame; bond lengths stay Real.
      expect(
        model.molecule.radialAtoms.first.position.magnitude,
        closeTo(realBondLen, 1e-6),
      );
    });

    test('Model quaternion is independent of Real screen quaternion', () {
      final modelScreen = ModelMoleculesModel()..rotateByPointer(40, 0);
      final real = RealMoleculesModel()..rotateByPointer(0, 40);
      expect(modelScreen.quaternion.x, isNot(closeTo(real.quaternion.x, 1e-9)));
      expect(modelScreen.quaternion.y, isNot(closeTo(real.quaternion.y, 1e-9)));
    });
  });

  group('Reset isolation', () {
    test('Model reset restores two single bonds and option defaults', () {
      final model = ModelMoleculesModel()
        ..removeAll()
        ..addPairGroup(2)
        ..addPairGroup(0)
        ..showBondAngles = true
        ..showLonePairs = false
        ..showMoleculeGeometry = true
        ..rotateByPointer(5, 5);
      model.reset();
      expect(model.molecule.domainCount, 2);
      expect(model.molecule.bonds.map((b) => b.order), [1, 1]);
      expect(model.showBondAngles, isFalse);
      expect(model.showLonePairs, isTrue);
      expect(model.showMoleculeGeometry, isFalse);
      expect(model.quaternion, Quat.identity);
    });

    test('Real reset restores H2O Real without clearing outer-LP preference', () {
      final prefs = MoleculeShapesPreferences()..showOuterLonePairs = true;
      final model = RealMoleculesModel(preferences: prefs)
        ..selectMolecule(tab2Molecules[5])
        ..setShowRealView(false)
        ..showBondAngles = true
        ..rotateByPointer(2, 2);
      model.reset();
      expect(model.shape.displayName, 'H2O');
      expect(model.showRealView, isTrue);
      expect(model.molecule.bondAngles().single.label, '104.5°');
      expect(prefs.showOuterLonePairs, isTrue);
      expect(model.showBondAngles, isFalse);
      expect(model.quaternion, Quat.identity);
    });
  });

  group('Geometry + repulsion stability', () {
    test('domains 2–6 settle with finite positions and source names', () {
      final cases = <(int bonds, int lps, String mol, String ele)>[
        (2, 0, 'LINEAR', 'LINEAR'),
        (3, 0, 'TRIGONAL_PLANAR', 'TRIGONAL_PLANAR'),
        (2, 1, 'BENT', 'TRIGONAL_PLANAR'),
        (4, 0, 'TETRAHEDRAL', 'TETRAHEDRAL'),
        (3, 1, 'TRIGONAL_PYRAMIDAL', 'TETRAHEDRAL'),
        (2, 2, 'BENT', 'TETRAHEDRAL'),
        (5, 0, 'TRIGONAL_BIPYRAMIDAL', 'TRIGONAL_BIPYRAMIDAL'),
        (4, 1, 'SEESAW', 'TRIGONAL_BIPYRAMIDAL'),
        (3, 2, 'T_SHAPED', 'TRIGONAL_BIPYRAMIDAL'),
        (6, 0, 'OCTAHEDRAL', 'OCTAHEDRAL'),
        (5, 1, 'SQUARE_PYRAMIDAL', 'OCTAHEDRAL'),
        (4, 2, 'SQUARE_PLANAR', 'OCTAHEDRAL'),
      ];
      for (final c in cases) {
        final model = ModelMoleculesModel()..removeAll();
        for (var i = 0; i < c.$1; i++) {
          model.addPairGroup(1, position: Vec3(10.0 * (i + 1), i.toDouble(), 1));
        }
        for (var i = 0; i < c.$2; i++) {
          model.addPairGroup(0, position: Vec3(-7.0 - i, i.toDouble(), 2));
        }
        expect(model.moleculeGeometryId, c.$3, reason: '${c.$1},${c.$2}');
        expect(model.electronGeometryId, c.$4, reason: '${c.$1},${c.$2}');
        for (var i = 0; i < 180; i++) {
          model.step(1 / 60);
        }
        for (final group in model.molecule.radialGroups) {
          expect(group.position.x.isFinite, isTrue);
          expect(group.position.y.isFinite, isTrue);
          expect(group.position.z.isFinite, isTrue);
          expect(group.position.magnitude, lessThan(50));
          expect(group.velocity.x.isFinite, isTrue);
        }
        // Drag must not rename.
        if (model.molecule.radialAtoms.isNotEmpty) {
          final name = model.moleculeGeometryId;
          final atom = model.molecule.radialAtoms.first;
          atom.dragToPosition(
            const Vec3(0, 10, 0).withMagnitude(PairGroup.bondedPairDistance),
          );
          expect(model.moleculeGeometryId, name);
        }
      }
    });

    test('long step loop stays finite under dt cap', () {
      final model = ModelMoleculesModel();
      for (var i = 0; i < 600; i++) {
        model.step(0.25); // capped to 0.2 inside step
      }
      for (final group in model.molecule.groups) {
        expect(group.position.x.isNaN, isFalse);
        expect(group.position.y.isNaN, isFalse);
        expect(group.position.z.isNaN, isFalse);
        expect(group.position.x.isInfinite, isFalse);
      }
      expect(model.quaternion.w.isFinite, isTrue);
    });
  });

  group('13 real molecules 3D integrity', () {
    test('all TAB_2 molecules have finite xyz and valid bonds', () {
      final model = RealMoleculesModel();
      for (final shape in tab2Molecules) {
        model.selectMolecule(shape);
        expect(model.molecule.centralAtom, isNotNull, reason: shape.displayName);
        expect(model.molecule.radialAtoms, isNotEmpty, reason: shape.displayName);
        for (final atom in model.molecule.atoms) {
          expect(atom.position.x.isFinite, isTrue, reason: shape.displayName);
          expect(atom.position.y.isFinite, isTrue, reason: shape.displayName);
          expect(atom.position.z.isFinite, isTrue, reason: shape.displayName);
        }
        for (final bond in model.molecule.bonds) {
          if (bond.order == 0) {
            continue;
          }
          expect(bond.length, greaterThan(0), reason: shape.displayName);
          expect(bond.order, anyOf(1, 2, 3), reason: shape.displayName);
        }
        for (final angle in model.molecule.bondAngles()) {
          expect(angle.degrees.isFinite, isTrue, reason: shape.displayName);
          expect(angle.degrees, greaterThan(0));
          expect(angle.degrees, lessThanOrEqualTo(180.05));
        }
      }
    });
  });

  group('Lifecycle dispose', () {
    testWidgets('ModelMoleculesScreen disposes ticker cleanly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ModelMoleculesScreen())),
      );
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    testWidgets('RealMoleculesScreen disposes ticker cleanly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: RealMoleculesScreen())),
      );
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  });

  group('Options isolation', () {
    test('toggling Real options does not flip ModelMoleculesModel flags', () {
      final modelScreen = ModelMoleculesModel();
      final real = RealMoleculesModel()
        ..showBondAngles = true
        ..showLonePairs = false
        ..showMoleculeGeometry = true
        ..showElectronGeometry = true;
      expect(modelScreen.showBondAngles, isFalse);
      expect(modelScreen.showLonePairs, isTrue);
      expect(modelScreen.showMoleculeGeometry, isFalse);
      expect(modelScreen.showElectronGeometry, isFalse);
      expect(real.showBondAngles, isTrue);
    });
  });

  group('Bond order visual domain semantics', () {
    test('single double triple each add one domain', () {
      final model = ModelMoleculesModel()..removeAll();
      model.addPairGroup(1);
      model.addPairGroup(2);
      model.addPairGroup(3);
      expect(model.molecule.domainCount, 3);
      expect(model.molecule.bonds.map((b) => b.order).toList(), [1, 2, 3]);
    });
  });

  test('projection depth ordering uses finite camera depths', () {
    final model = ModelMoleculesModel();
    model.rotateByPointer(25, -18);
    for (final group in model.molecule.radialGroups) {
      final world = model.worldPosition(group);
      expect(world.x.isFinite && world.y.isFinite && world.z.isFinite, isTrue);
      expect(world.magnitude, lessThan(100));
    }
  });

  test('angle format remains one decimal', () {
    expect(formatBondAngleDegrees(109.471), '109.5°');
    expect(formatBondAngleDegrees(104.5), '104.5°');
  });
}
