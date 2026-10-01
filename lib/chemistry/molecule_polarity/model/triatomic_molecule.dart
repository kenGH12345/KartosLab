import 'dart:math' as math;

import '../mp_constants.dart';
import 'atom.dart';
import 'bond.dart';
import 'molecule.dart';
import 'mp_preferences.dart';
import 'mp_vector2.dart';
import 'normalize_angle.dart';

/// Make-believe triatomic A–B–C (B center).
/// Source: `js/threeatoms/model/TriatomicMolecule.ts`
class TriatomicMolecule extends MpMolecule {
  factory TriatomicMolecule({
    MpVector2? position,
    double angle = 0,
    double? electronegativityA,
    double? electronegativityB,
    double? electronegativityC,
    double? bondAngleAB,
    double? bondAngleBC,
  }) {
    final atomA = createAtomA(electronegativity: electronegativityA);
    final atomB = createAtomB(electronegativity: electronegativityB);
    final atomC = createAtomC(electronegativity: electronegativityC);
    final bondAB = MpBond(atomA, atomB);
    final bondBC = MpBond(atomB, atomC);
    return TriatomicMolecule._(
      atomA: atomA,
      atomB: atomB,
      atomC: atomC,
      bondAB: bondAB,
      bondBC: bondBC,
      position: position ??
          const MpVector2(
            MpConstants.threeAtomsMoleculeX,
            MpConstants.threeAtomsMoleculeY,
          ),
      angle: angle,
      bondAngleAB: bondAngleAB ?? 5 * math.pi / 6,
      bondAngleBC: bondAngleBC ?? math.pi / 6,
    );
  }

  TriatomicMolecule._({
    required this.atomA,
    required this.atomB,
    required this.atomC,
    required this.bondAB,
    required this.bondBC,
    required super.position,
    required super.angle,
    required double bondAngleAB,
    required double bondAngleBC,
  })  : _bondAngleAB = bondAngleAB,
        _bondAngleBC = bondAngleBC,
        super(
          atoms: [atomA, atomB, atomC],
          bonds: [bondAB, bondBC],
        );

  final MpAtom atomA;
  final MpAtom atomB;
  final MpAtom atomC;
  final MpBond bondAB;
  final MpBond bondBC;

  double _bondAngleAB;
  double _bondAngleBC;

  /// Bond angle of A relative to B before molecule rotation. Default ~8 o'clock.
  double get bondAngleAB => _bondAngleAB;
  set bondAngleAB(double value) {
    _bondAngleAB = normalizeAngle(value, MpConstants.angleMin);
    updateGeometry();
  }

  /// Bond angle of C relative to B. Default ~4 o'clock.
  double get bondAngleBC => _bondAngleBC;
  set bondAngleBC(double value) {
    // Source range for BC is [0, 2π); keep via normalize with min 0.
    _bondAngleBC = normalizeAngle(value, 0);
    updateGeometry();
  }

  /// Angle between bonds AB and BC (clockwise positive).
  double get bondAngleABC =>
      normalizeAngle(_bondAngleAB - _bondAngleBC, MpConstants.angleMin);

  @override
  double get deltaEN => dipoleMagnitude();

  @override
  void updateGeometry() {
    atomB.position = position;
    _placePeripheral(atomA, _bondAngleAB);
    _placePeripheral(atomC, _bondAngleBC);
  }

  void _placePeripheral(MpAtom atom, double bondAngle) {
    final radius = MpConstants.bondLength;
    final theta = bondAngle + angle;
    atom.position = MpVector2(
      radius * math.cos(theta) + position.x,
      radius * math.sin(theta) + position.y,
    );
  }

  @override
  void updatePartialCharges() {
    final deltaAB =
        atomA.electronegativity - atomB.electronegativity;
    final deltaCB =
        atomC.electronegativity - atomB.electronegativity;
    atomA.partialCharge = -deltaAB;
    atomC.partialCharge = -deltaCB;
    atomB.partialCharge = deltaAB + deltaCB;
  }

  @override
  void reset() {
    _bondAngleAB = 5 * math.pi / 6;
    _bondAngleBC = math.pi / 6;
    super.reset();
  }

  /// Convenience with preferences direction.
  MpVector2 molecularDipole([
    DipoleDirection direction = DipoleDirection.positiveToNegative,
  ]) =>
      dipole(direction);
}
