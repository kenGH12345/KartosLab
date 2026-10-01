import 'dart:math' as math;

import '../model/bl_vec2.dart';
import '../model/intersection.dart';

/// Ray–segment / ray–circle intersections (`PrismIntersection.ts` semantics).
class PrismIntersection {
  PrismIntersection._();

  static List<Intersection> getIntersections({
    required List<(BlVec2 start, BlVec2 end)> edges,
    required BlVec2? arcCenter,
    required double? arcRadius,
    required double? arcStartAngle,
    required double? arcEndAngle,
    required bool? arcAnticlockwise,
    required BlVec2 rayTail,
    required BlVec2 rayDirection,
  }) {
    final intersections = <Intersection>[];

    for (final edge in edges) {
      final hit = _segmentRayIntersection(edge.$1, edge.$2, rayTail, rayDirection);
      if (hit != null) {
        var unitNormal = (edge.$2 - edge.$1).rotate(math.pi / 2).normalize();
        if (unitNormal.dot(rayDirection) > 0) {
          unitNormal = -unitNormal;
        }
        intersections.add(Intersection(unitNormal, hit));
      }
    }

    if (arcCenter != null && arcRadius != null) {
      final hits = _circleRayIntersections(arcCenter, arcRadius, rayTail, rayDirection);
      for (final point in hits) {
        // Optional arc angle filter
        if (arcStartAngle != null && arcEndAngle != null) {
          final a = math.atan2(point.y - arcCenter.y, point.x - arcCenter.x);
          if (!_angleOnArc(a, arcStartAngle, arcEndAngle, arcAnticlockwise ?? false)) {
            continue;
          }
        }
        var unitNormal = (point - arcCenter).normalize();
        if (unitNormal.dot(rayDirection) > 0) {
          unitNormal = -unitNormal;
        }
        intersections.add(Intersection(unitNormal, point));
      }
    }

    return intersections;
  }

  static BlVec2? _segmentRayIntersection(
    BlVec2 a,
    BlVec2 b,
    BlVec2 origin,
    BlVec2 dir,
  ) {
    final ab = b - a;
    // Solve origin + t·dir = a + u·ab, t>=0, u in [0,1]
    final det = dir.x * ab.y - dir.y * ab.x;
    if (det.abs() < 1e-18) return null;
    final ox = a.x - origin.x;
    final oy = a.y - origin.y;
    final t = (ox * ab.y - oy * ab.x) / det;
    final u = (ox * dir.y - oy * dir.x) / det;
    if (t < 1e-12 || u < 0 || u > 1) return null;
    return origin + dir * t;
  }

  static List<BlVec2> _circleRayIntersections(
    BlVec2 center,
    double radius,
    BlVec2 origin,
    BlVec2 dir,
  ) {
    final oc = origin - center;
    final a = dir.dot(dir);
    final b = 2 * oc.dot(dir);
    final c = oc.dot(oc) - radius * radius;
    final disc = b * b - 4 * a * c;
    if (disc < 0) return [];
    final sqrtDisc = math.sqrt(disc);
    final out = <BlVec2>[];
    for (final sign in [-1.0, 1.0]) {
      final t = (-b + sign * sqrtDisc) / (2 * a);
      if (t > 1e-12) {
        out.add(origin + dir * t);
      }
    }
    // Prefer nearest (kite often returns first)
    out.sort((p, q) => p.distance(origin).compareTo(q.distance(origin)));
    if (out.isEmpty) return [];
    return [out.first];
  }

  static bool _angleOnArc(
    double angle,
    double start,
    double end,
    bool anticlockwise,
  ) {
    double norm(double a) {
      var x = a;
      while (x < -math.pi) {
        x += 2 * math.pi;
      }
      while (x > math.pi) {
        x -= 2 * math.pi;
      }
      return x;
    }

    final a = norm(angle);
    final s = norm(start);
    final e = norm(end);
    if (!anticlockwise) {
      // clockwise from s to e spanning π for semicircle typical case
      if (s <= e) return a >= s && a <= e;
      return a >= s || a <= e;
    } else {
      if (e <= s) return a >= e && a <= s;
      return a >= e || a <= s;
    }
  }
}
