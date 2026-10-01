import 'dart:math' as math;

import '../bending_light_constants.dart';
import '../model/bl_vec2.dart';
import '../model/laser.dart';

/// Intro / More Tools body drag: screen point already converted to world.
///
/// Matches `LaserNode` rotation: atan2 around pivot, then Q2 clamp,
/// then wave-mode max (`Laser.setWave`).
void applyQuadrantRotationDrag({
  required Laser laser,
  required BlVec2 worldPoint,
}) {
  var angle = math.atan2(
    worldPoint.y - laser.pivot.y,
    worldPoint.x - laser.pivot.x,
  );
  if (!angle.isFinite) return;
  angle = angle.clamp(math.pi / 2, math.pi);
  if (laser.wave && angle > BendingLightConstants.maxAngleInWaveMode) {
    angle = BendingLightConstants.maxAngleInWaveMode;
  }
  laser.setAngle(angle);
}

/// Prisms knob drag: full circle, no quadrant clamp.
void applyKnobRotationDrag({
  required Laser laser,
  required BlVec2 worldPoint,
}) {
  final angle = math.atan2(
    worldPoint.y - laser.pivot.y,
    worldPoint.x - laser.pivot.x,
  );
  if (!angle.isFinite) return;
  laser.setAngle(angle);
}

/// Prisms body drag. Pivot-then-emission order is inside [Laser.translate].
void applyLaserTranslationDrag({
  required Laser laser,
  required BlVec2 delta,
  required double limit,
}) {
  if (!delta.x.isFinite || !delta.y.isFinite) return;
  laser.translate(delta.x, delta.y);
  final x = laser.pivot.x.clamp(-limit, limit);
  final y = laser.pivot.y.clamp(-limit, limit);
  final dx = x - laser.pivot.x;
  final dy = y - laser.pivot.y;
  if (dx != 0 || dy != 0) {
    laser.translate(dx, dy);
  }
}

/// Signed angle change of a pointer around [center], wrapped to (−π, π].
double? rotationDelta({
  required BlVec2 center,
  required BlVec2 previous,
  required BlVec2 current,
}) {
  final a0 = math.atan2(previous.y - center.y, previous.x - center.x);
  final a1 = math.atan2(current.y - center.y, current.x - center.x);
  if (!a0.isFinite || !a1.isFinite) return null;
  var d = a1 - a0;
  if (d > math.pi) d -= 2 * math.pi;
  if (d < -math.pi) d += 2 * math.pi;
  return d;
}

BlVec2 clampModelPoint(BlVec2 p, double limit) => BlVec2(
      p.x.clamp(-limit, limit).toDouble(),
      p.y.clamp(-limit, limit).toDouble(),
    );
