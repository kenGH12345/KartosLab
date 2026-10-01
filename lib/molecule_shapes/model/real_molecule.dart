import 'geometry.dart';
import 'molecule.dart';
import 'pair_group.dart';
import 'real_molecule_shape.dart';
import 'vec3.dart';

/// Fills CH4 and SF6 from `ElectronGeometry` unit vectors, matching source.
void ensureRealMoleculeGeometry() {
  _fillFromElectronGeometry(methane, 'H', 4, 0, 1);
  _fillFromElectronGeometry(sulfurHexafluoride, 'F', 6, 3, 1);
}

void _fillFromElectronGeometry(
  RealMoleculeShape shape,
  String symbol,
  int groups,
  int lonePairCount,
  int order,
) {
  if (shape.bonds.isNotEmpty) {
    return;
  }
  final angstrom = shape.bondLengthOverride / 5.5;
  for (final vector in ElectronGeometry.byGroupCount(groups).unitVectors) {
    shape.addRadialAtom(
      RealAtomPosition(symbol, vector.times(angstrom), lonePairCount: lonePairCount),
      order,
    );
  }
}

/// Full-sim combo box order: `RealMoleculeShape.TAB_2_MOLECULES`.
List<RealMoleculeShape> get tab2Molecules {
  ensureRealMoleculeGeometry();
  return _tab2Molecules;
}

/// Defined in source but only listed by Molecule Shapes: Basics.
List<RealMoleculeShape> get basicsOnlyMolecules {
  ensureRealMoleculeGeometry();
  return [berylliumChloride];
}

final List<RealMoleculeShape> _tab2Molecules = [
  water,
  carbonDioxide,
  sulfurDioxide,
  xenonDifluoride,
  boronTrifluoride,
  chlorineTrifluoride,
  ammonia,
  methane,
  sulfurTetrafluoride,
  xenonTetrafluoride,
  brominePentafluoride,
  phosphorusPentachloride,
  sulfurHexafluoride,
];

/// `RealMolecule.js` atom positions, plus central lone pairs seated in the bond frame.
class RealMolecule extends Molecule {
  RealMolecule(this.shape) : super(isReal: true) {
    ensureRealMoleculeGeometry();
    addCentralAtom(
      PairGroup(
        position: Vec3.zero,
        isLonePair: false,
        element: shape.central.symbol,
      ),
    );
    final center = centralAtom!;
    for (final bond in shape.bonds) {
      final atom = bond.other(shape.central);
      final group = PairGroup(
        position: atom.position,
        isLonePair: false,
        element: atom.symbol,
      );
      addGroupAndBond(group, center, bond.order, bond.length);
      addTerminalLonePairs(group, atom.lonePairCount);
    }
    _addCentralLonePairs(shape.central.lonePairCount);
  }

  final RealMoleculeShape shape;

  void _addCentralLonePairs(int count) {
    if (count == 0) {
      return;
    }
    final center = centralAtom!;
    final ideal = VseprConfiguration.get(radialAtoms.length, count).allOrientations;
    final rotation = _bondFrameRotation(ideal.sublist(count));
    for (var i = 0; i < count; i++) {
      final direction = rotation.times(ideal[i]).normalized();
      addGroupAndBond(
        PairGroup(
          position: direction.times(PairGroup.lonePairDistance),
          isLonePair: true,
        ),
        center,
        0,
        PairGroup.lonePairDistance,
      );
    }
  }

  Mat3 _bondFrameRotation(List<Vec3> idealBondDirections) {
    final actual = radialAtoms.map((atom) => atom.orientation).toList();
    if (idealBondDirections.length >= 2 && actual.length >= 2) {
      return Mat3.alignPair(
        idealBondDirections[0],
        idealBondDirections[1],
        actual[0],
        actual[1],
      );
    }
    if (idealBondDirections.isNotEmpty && actual.isNotEmpty) {
      return Mat3.alignPair(
        idealBondDirections[0],
        idealBondDirections[0].cross(const Vec3(0, 1, 0)).magnitude < 1e-6
            ? idealBondDirections[0].cross(const Vec3(1, 0, 0))
            : idealBondDirections[0].cross(const Vec3(0, 1, 0)),
        actual[0],
        actual[0].cross(const Vec3(0, 1, 0)).magnitude < 1e-6
            ? actual[0].cross(const Vec3(1, 0, 0))
            : actual[0].cross(const Vec3(0, 1, 0)),
      );
    }
    return Mat3.identity;
  }
}

/// Model half of Real Molecules: ideal slots, bond orders copied from [shape].
VseprMolecule vseprMoleculeFromShape(RealMoleculeShape shape) {
  ensureRealMoleculeGeometry();
  final molecule = VseprMolecule();
  final center = PairGroup(
    position: Vec3.zero,
    isLonePair: false,
    element: shape.central.symbol,
  );
  molecule.addCentralAtom(center);
  final lonePairs = shape.central.lonePairCount;
  final vectors = ElectronGeometry.byGroupCount(shape.bonds.length + lonePairs).unitVectors;
  for (var i = 0; i < lonePairs; i++) {
    molecule.addGroupAndBond(
      PairGroup(
        position: vectors[i].times(PairGroup.lonePairDistance),
        isLonePair: true,
      ),
      center,
      0,
      PairGroup.lonePairDistance,
    );
  }
  for (var i = 0; i < shape.bonds.length; i++) {
    final bond = shape.bonds[i];
    final atom = bond.other(shape.central);
    final group = PairGroup(
      position: vectors[lonePairs + i].times(bond.length),
      isLonePair: false,
      element: atom.symbol,
    );
    molecule.addGroupAndBond(group, center, bond.order, bond.length);
    molecule.addTerminalLonePairs(group, atom.lonePairCount);
  }
  return molecule;
}
