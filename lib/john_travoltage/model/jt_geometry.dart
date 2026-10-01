import 'dart:math' as math;

import 'jt_vec2.dart';

/// Geometry helpers matching PhET `dot` Utils used by JT model.
abstract final class JtGeometry {
  /// PhET `dot/js/util/lineSegmentIntersection.ts`.
  ///
  /// Returns intersection point, or null if segments do not intersect.
  static JtVec2? lineSegmentIntersection(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
    double x4,
    double y4,
  ) {
    double ccw(double a, double b, double c, double d, double e, double f) =>
        (f - b) * (c - a) - (d - b) * (e - a);

    if (ccw(x1, y1, x3, y3, x4, y4) * ccw(x2, y2, x3, y3, x4, y4) > 0 ||
        ccw(x3, y3, x1, y1, x2, y2) * ccw(x4, y4, x1, y1, x2, y2) > 0) {
      return null;
    }

    final denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if (denom.abs() < 1e-10) {
      return null;
    }

    if ((x1 == x3 && y1 == y3) || (x1 == x4 && y1 == y4)) {
      return JtVec2(x1, y1);
    }
    if ((x2 == x3 && y2 == y3) || (x2 == x4 && y2 == y4)) {
      return JtVec2(x2, y2);
    }

    final intersectionX =
        ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) /
            denom;
    final intersectionY =
        ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) /
            denom;
    return JtVec2(intersectionX, intersectionY);
  }

  /// PhET `Utils.distToSegmentSquared(point, a, b)`.
  static double distToSegmentSquared(JtVec2 p, JtVec2 a, JtVec2 b) {
    final abx = b.x - a.x;
    final aby = b.y - a.y;
    final len2 = abx * abx + aby * aby;
    if (len2 == 0) return p.distanceSquared(a);
    var t = ((p.x - a.x) * abx + (p.y - a.y) * aby) / len2;
    t = t.clamp(0.0, 1.0);
    final cx = a.x + t * abx;
    final cy = a.y + t * aby;
    final dx = p.x - cx;
    final dy = p.y - cy;
    return dx * dx + dy * dy;
  }

  /// Even-odd ray cast for closed polygon (PhET kite Shape.containsPoint).
  static bool polygonContainsPoint(List<JtVec2> vertices, JtVec2 point) {
    var inside = false;
    for (var i = 0, j = vertices.length - 1; i < vertices.length; j = i++) {
      final vi = vertices[i];
      final vj = vertices[j];
      final intersect = ((vi.y > point.y) != (vj.y > point.y)) &&
          (point.x <
              (vj.x - vi.x) * (point.y - vi.y) / (vj.y - vi.y + 0.0) + vi.x);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  /// Avoid division-by-zero when computing polygon edge crossing.
  static bool polygonContainsPointSafe(List<JtVec2> vertices, JtVec2 point) {
    var inside = false;
    for (var i = 0, j = vertices.length - 1; i < vertices.length; j = i++) {
      final yi = vertices[i].y;
      final yj = vertices[j].y;
      final xi = vertices[i].x;
      final xj = vertices[j].x;
      if (((yi > point.y) != (yj > point.y)) &&
          (point.x <
              (xj - xi) * (point.y - yi) / ((yj - yi) == 0 ? 1e-30 : (yj - yi)) +
                  xi)) {
        inside = !inside;
      }
    }
    return inside;
  }

  static double clamp(double value, double min, double max) =>
      math.max(min, math.min(max, value));
}
