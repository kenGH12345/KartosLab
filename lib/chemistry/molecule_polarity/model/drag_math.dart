import 'dart:math' as math;

import '../mp_constants.dart';
import 'mp_vector2.dart';
import 'normalize_angle.dart';

/// Quantize molecule angle drag to 5° steps.
/// Source: `MoleculeAngleDragListener` roundToInterval(..., toRadians(5))
double snapAngleDegrees(double angleRadians, {
  double snapDegrees = MpConstants.angleDragSnapDegrees,
}) {
  final snap = snapDegrees * math.pi / 180;
  final snapped = (angleRadians / snap).round() * snap;
  return normalizeAngle(snapped, MpConstants.angleMin);
}

/// Compute molecule angle from pointer relative to center.
double angleFromPointer({
  required MpVector2 center,
  required MpVector2 pointer,
  bool snap = true,
}) {
  final a = math.atan2(pointer.y - center.y, pointer.x - center.x);
  return snap ? snapAngleDegrees(a) : normalizeAngle(a, MpConstants.angleMin);
}

/// Bond-angle drag: angle of peripheral atom about center B.
double bondAngleFromPointer({
  required MpVector2 center,
  required MpVector2 pointer,
  required double moleculeAngle,
  bool snap = true,
}) {
  final absolute = math.atan2(pointer.y - center.y, pointer.x - center.x);
  // bondAngle is relative to molecule orientation: absolute = moleculeAngle + bondAngle
  var bond = absolute - moleculeAngle;
  if (snap) {
    bond = snapAngleDegrees(bond);
  }
  return bond;
}
