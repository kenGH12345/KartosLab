import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/molecule_shapes/model/molecule_shapes_model.dart';
import 'package:kratos/molecule_shapes/model/pair_group.dart';
import 'package:kratos/molecule_shapes/model/vec3.dart';

void main() {
  test('initial state is a central atom and two single bonds', () {
    final model = ModelMoleculesModel();
    expect(model.molecule.centralAtom, isNotNull);
    expect(model.molecule.centralAtom!.isCentralAtom, isTrue);
    expect(model.molecule.domainCount, 2);
    expect(model.molecule.bondedDomainCount, 2);
    expect(model.molecule.lonePairDomainCount, 0);
    expect(model.molecule.bonds.map((bond) => bond.order), [1, 1]);
    for (final atom in model.molecule.radialAtoms) {
      expect(atom.position.magnitude, closeTo(PairGroup.bondedPairDistance, 1e-9));
    }
    expect(model.moleculeGeometryId, 'LINEAR');
    expect(model.electronGeometryId, 'LINEAR');
    expect(model.moleculeGeometryLabel, 'Linear');
    expect(model.showBondAngles, isFalse);
    expect(model.showLonePairs, isTrue);
    expect(model.showMoleculeGeometry, isFalse);
    expect(model.showElectronGeometry, isFalse);
    expect(model.quaternion, Quat.identity);
  });

  test('single double and triple bonds each add one domain', () {
    final model = ModelMoleculesModel()..removeAll();
    expect(model.addPairGroup(1), isTrue);
    expect(model.molecule.domainCount, 1);
    expect(model.addPairGroup(2), isTrue);
    expect(model.addPairGroup(3), isTrue);
    expect(model.molecule.domainCount, 3);
    expect(model.molecule.bonds.map((bond) => bond.order), [1, 2, 3]);
    expect(model.moleculeGeometryId, 'TRIGONAL_PLANAR');
  });

  test('replacing a double bond with a triple bond stays one domain', () {
    final model = ModelMoleculesModel()..removeAll();
    model.addPairGroup(2);
    expect(model.molecule.domainCount, 1);
    expect(model.electronGeometryId, 'DIATOMIC');
    expect(model.removePairGroup(2), isTrue);
    expect(model.molecule.domainCount, 0);
    model.addPairGroup(3);
    expect(model.molecule.domainCount, 1);
    expect(model.molecule.bonds.single.order, 3);
    expect(model.electronGeometryId, 'DIATOMIC');
  });

  test('remove bond and remove all keep the central atom', () {
    final model = ModelMoleculesModel();
    final center = model.molecule.centralAtom;
    expect(model.removePairGroup(1), isTrue);
    expect(model.molecule.domainCount, 1);
    model.removeAll();
    expect(model.molecule.centralAtom, same(center));
    expect(model.molecule.domainCount, 0);
    expect(model.moleculeGeometryId, 'EMPTY');
    expect(model.electronGeometryId, 'EMPTY');
    expect(model.moleculeGeometryLabel, '');
  });

  test('lone pairs change molecule geometry but not the bond-domain rule', () {
    final model = _ideal(2, 0);
    expect(model.moleculeGeometryId, 'LINEAR');
    final bent = _ideal(2, 1);
    expect(bent.moleculeGeometryId, 'BENT');
    expect(bent.electronGeometryId, 'TRIGONAL_PLANAR');
    expect(bent.molecule.domainCount, 3);
    expect(bent.removePairGroup(0), isTrue);
    bent.molecule.placeRadialGroupsAtIdealSlots();
    expect(bent.moleculeGeometryId, 'LINEAR');
    expect(bent.molecule.domainCount, 2);
  });

  test('lone pair button follows Show Lone Pairs, the domain cap does not', () {
    final model = ModelMoleculesModel()..removeAll();
    model.showLonePairs = false;
    expect(model.molecule.wouldAllowBondOrder(0), isTrue);
    expect(model.canAddPairGroup(0), isFalse);
    expect(model.addPairGroup(0), isFalse);
    expect(model.canAddPairGroup(1), isTrue);
    model.showLonePairs = true;
    expect(model.addPairGroup(0), isTrue);
    expect(model.molecule.lonePairDomainCount, 1);
  });

  test('a seventh domain is rejected', () {
    final model = ModelMoleculesModel()..removeAll();
    for (var i = 0; i < 6; i++) {
      expect(model.addPairGroup(1), isTrue);
    }
    expect(model.molecule.domainCount, 6);
    expect(model.molecule.wouldAllowBondOrder(1), isFalse);
    expect(model.addPairGroup(1), isFalse);
    expect(model.addPairGroup(0), isFalse);
    expect(model.molecule.domainCount, 6);
    expect(model.moleculeGeometryId, 'OCTAHEDRAL');
  });

  test('dragging an atom updates the bond angle and not the geometry name', () {
    final model = ModelMoleculesModel()..removeAll();
    model.addPairGroup(1, position: const Vec3(10, 0, 0));
    model.addPairGroup(1, position: const Vec3(-10, 0, 0));
    expect(model.molecule.bondAngles().single.degrees, closeTo(180, 1e-6));
    expect(model.moleculeGeometryId, 'LINEAR');

    model.molecule.radialAtoms[1].dragToPosition(const Vec3(0, 10, 0));
    expect(model.molecule.radialAtoms[1].velocity, Vec3.zero);
    expect(model.molecule.bondAngles().single.degrees, closeTo(90, 1e-6));
    expect(model.moleculeGeometryId, 'LINEAR');
    expect(model.electronGeometryId, 'LINEAR');
  });

  test('rotation is stored on the model and changes world positions only', () {
    final model = ModelMoleculesModel();
    final local = model.molecule.radialAtoms.first.position;
    model.rotateByPointer(30, -12);
    expect(model.quaternion, isNot(Quat.identity));
    expect(model.molecule.radialAtoms.first.position.almostEquals(local), isTrue);
    expect(model.worldPosition(model.molecule.radialAtoms.first).almostEquals(local), isFalse);
  });

  test('reset restores the two single bonds and the display defaults', () {
    final model = ModelMoleculesModel()
      ..removeAll()
      ..addPairGroup(3)
      ..addPairGroup(0);
    model
      ..showBondAngles = true
      ..showLonePairs = false
      ..showMoleculeGeometry = true
      ..showElectronGeometry = true
      ..rotateByPointer(10, 10);
    model.reset();

    expect(model.molecule.domainCount, 2);
    expect(model.molecule.bonds.map((bond) => bond.order), [1, 1]);
    expect(model.moleculeGeometryId, 'LINEAR');
    expect(model.showBondAngles, isFalse);
    expect(model.showLonePairs, isTrue);
    expect(model.showMoleculeGeometry, isFalse);
    expect(model.showElectronGeometry, isFalse);
    expect(model.quaternion, Quat.identity);
    expect(
      model.molecule.radialAtoms[0].position.almostEquals(const Vec3(8, 0, 3).withMagnitude(10)),
      isTrue,
    );
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
