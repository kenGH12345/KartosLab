import 'dart:math' as math;

import '../mp_constants.dart';
import 'mp_vector2.dart';
import 'normalize_angle.dart';

/// Exponential-ish follow: move [from] toward [to] by [t], wrapping ±π.
double lerpAngle(double from, double to, double t) {
  var d = to - from;
  while (d > math.pi) {
    d -= 2 * math.pi;
  }
  while (d < -math.pi) {
    d += 2 * math.pi;
  }
  return normalizeAngle(from + d * t.clamp(0.0, 1.0), MpConstants.angleMin);
}

/// Quantize molecule angle to 5° steps. Source: MoleculeAngleDragListener.
double snapAngleDegrees(
  double angleRadians, {
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
