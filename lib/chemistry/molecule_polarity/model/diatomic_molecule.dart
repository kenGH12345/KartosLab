import 'dart:math' as math;

import '../mp_constants.dart';
import 'atom.dart';
import 'bond.dart';
import 'molecule.dart';
import 'mp_vector2.dart';

/// Make-believe diatomic molecule A–B.
/// Source: `js/twoatoms/model/DiatomicMolecule.ts`
class DiatomicMolecule extends MpMolecule {
  factory DiatomicMolecule({
    MpVector2? position,
    double angle = 0,
    double? electronegativityA,
    double? electronegativityB,
  }) {
    final atomA = createAtomA(electronegativity: electronegativityA);
    final atomB = createAtomB(electronegativity: electronegativityB);
    final bond = MpBond(atomA, atomB);
    return DiatomicMolecule._(
      atomA: atomA,
      atomB: atomB,
      bond: bond,
      position: position ??
          const MpVector2(
            MpConstants.twoAtomsMoleculeX,
            MpConstants.twoAtomsMoleculeY,
          ),
      angle: angle,
    );
  }

  DiatomicMolecule._({
    required this.atomA,
    required this.atomB,
    required this.bond,
    required super.position,
    required super.angle,
  }) : super(
          atoms: [atomA, atomB],
          bonds: [bond],
        );

  final MpAtom atomA;
  final MpAtom atomB;
  final MpBond bond;

  @override
  double get deltaEN =>
      atomB.electronegativity - atomA.electronegativity;

  @override
  void updateGeometry() {
    final radius = MpConstants.bondLength / 2;
    final a = angle;
    atomA.position = MpVector2(
      radius * math.cos(a + math.pi) + position.x,
      radius * math.sin(a + math.pi) + position.y,
    );
    atomB.position = MpVector2(
      radius * math.cos(a) + position.x,
      radius * math.sin(a) + position.y,
    );
  }

  @override
  void updatePartialCharges() {
    final d = deltaEN;
    atomA.partialCharge = d;
    atomB.partialCharge = -d;
  }
}
