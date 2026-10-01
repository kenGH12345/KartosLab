import 'dart:math' as math;

import 'atom.dart';
import 'mp_preferences.dart';
import 'mp_vector2.dart';

/// Bond between two atoms with simplified dipole from ΔEN.
/// Source: `js/common/model/Bond.ts`
class MpBond {
  MpBond(this.atom1, this.atom2)
      : assert(atom1.label != atom2.label),
        label = '${atom1.label}${atom2.label}';

  final MpAtom atom1;
  final MpAtom atom2;
  final String label;

  /// EN(atom2) − EN(atom1)
  double get deltaEN => atom2.electronegativity - atom1.electronegativity;

  MpVector2 get center => atom1.position.average(atom2.position);

  double get length => atom1.position.distance(atom2.position);

  /// Angle of atom2 relative to bond center (radians).
  double get angle => math.atan2(
        atom2.position.y - center.y,
        atom2.position.x - center.x,
      );

  double get dipoleMagnitude => dipole().magnitude;

  /// Qualitative dipole vector. +x right, +y down, +rotation clockwise.
  MpVector2 dipole([
    DipoleDirection direction = DipoleDirection.positiveToNegative,
  ]) {
    final dEn = deltaEN;
    final magnitude = dEn.abs();
    var a = angle;
    if (dEn < 0) {
      a += math.pi;
    }
    var d = MpVector2.polar(magnitude, a);
    if (direction == DipoleDirection.negativeToPositive) {
      d = d.rotated(math.pi);
    }
    return d;
  }
}
