import 'dart:math' as math;

import 'cck_vec.dart';
import 'elements.dart';

/// One visualized charge along an element. `Charge.ts`.
class CckCharge {
  CckCharge({
    required this.element,
    required this.distance,
    required this.sign,
  });

  CckElement element;
  double distance;

  /// `-1` electrons, `+1` conventional. `Charge.ts`.
  final int sign;

  CckVec position = CckVec.zero;
  double angle = 0;

  void updatePositionAndAngle() {
    final length = element.chargePathLength;
    final t = length == 0 ? 0.0 : (distance / length).clamp(0.0, 1.0);
    position = element.start.pos.lerp(element.end.pos, t);
    angle = math.atan2(
      element.end.y - element.start.y,
      element.end.x - element.start.x,
    );
  }
}
