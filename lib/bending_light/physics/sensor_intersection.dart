import 'dart:math' as math;

import '../model/bl_vec2.dart';

/// Ray vs circle hits (`LightRay.getIntersections` + kite arc sensor).
///
/// The intensity sensor shape is a circle of radius 1e-6. A ray can miss,
/// touch once, or cut twice. Two hits use their midpoint (IntroModel).
List<BlVec2> rayCircleHits({
  required BlVec2 origin,
  required double directionAngle,
  required BlVec2 center,
  required double radius,
}) {
  final dx = math.cos(directionAngle);
  final dy = math.sin(directionAngle);
  final fx = origin.x - center.x;
  final fy = origin.y - center.y;
  final b = 2 * (fx * dx + fy * dy);
  final c = fx * fx + fy * fy - radius * radius;
  final disc = b * b - 4 * c;
  if (disc < -1e-30) return const [];

  BlVec2 at(double t) => BlVec2(origin.x + t * dx, origin.y + t * dy);

  if (disc <= 1e-30) {
    final t = -b / 2;
    if (t < -1e-9) return const [];
    return [at(t)];
  }
  final s = math.sqrt(disc);
  final hits = <BlVec2>[];
  final t1 = (-b - s) / 2;
  final t2 = (-b + s) / 2;
  if (t1 >= -1e-9) hits.add(at(t1));
  if (t2 >= -1e-9) hits.add(at(t2));
  return hits;
}

/// Sensor sample point: the single hit, or the midpoint of two hits.
BlVec2? sensorSamplePoint(List<BlVec2> hits) {
  if (hits.isEmpty) return null;
  if (hits.length == 1) return hits.first;
  return BlVec2(
    (hits[0].x + hits[1].x) / 2,
    (hits[0].y + hits[1].y) / 2,
  );
}
