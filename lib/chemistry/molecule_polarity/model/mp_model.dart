import 'dart:math' as math;

import '../mp_constants.dart';
import 'molecule.dart';
import 'mp_preferences.dart';
import 'normalize_angle.dart';

double _linear(double x1, double x2, double y1, double y2, double x) {
  if (x2 == x1) return y1;
  return y1 + (x - x1) * (y2 - y1) / (x2 - x1);
}

/// Base for 2D screens: E-field + molecule orientation animation.
/// Source: `js/common/model/MPModel.ts`
abstract class MpModel {
  MpModel(this.molecule, {this.preferences});

  final MpMolecule molecule;
  final MpPreferences? preferences;

  bool eFieldEnabled = false;

  DipoleDirection get _dipoleDirection =>
      preferences?.dipoleDirection ?? DipoleDirection.positiveToNegative;

  void reset() {
    eFieldEnabled = false;
  }

  /// Advance one frame. PhET uses fixed max step (dt unused for angle).
  void step(double dt) {
    if (eFieldEnabled && !molecule.isDragging) {
      updateMoleculeOrientation();
    } else {
      molecule.isRotatingDueToEField = false;
    }
  }

  void updateMoleculeOrientation() {
    var dipole = molecule.dipole(_dipoleDirection);

    if (_dipoleDirection == DipoleDirection.negativeToPositive) {
      dipole = dipole.rotated(math.pi);
    }

    final deltaDipoleAngle = _linear(
      0,
      MpConstants.electronegativityRangeLength,
      0,
      MpConstants.maxRadiansPerStep,
      dipole.magnitude,
    ).abs();

    final dipoleAngle = normalizeAngle(dipole.angle);
    late final double newDipoleAngle;

    if (dipoleAngle == 0) {
      newDipoleAngle = dipoleAngle;
      molecule.isRotatingDueToEField = false;
    } else if (dipoleAngle > 0 && dipoleAngle < math.pi) {
      var next = dipoleAngle - deltaDipoleAngle;
      if (next < 0) next = 0;
      newDipoleAngle = next;
      molecule.isRotatingDueToEField = true;
    } else {
      var next = dipoleAngle + deltaDipoleAngle;
      if (next > 2 * math.pi) next = 0;
      newDipoleAngle = next;
      molecule.isRotatingDueToEField = true;
    }

    final deltaMoleculeAngle = newDipoleAngle - dipoleAngle;
    var angle = molecule.angle + deltaMoleculeAngle;

    if (newDipoleAngle == 0 && angle.abs() < 1e-5) {
      angle = 0;
    }

    molecule.angle = normalizeAngle(angle, MpConstants.angleMin);
  }
}
