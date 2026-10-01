import 'dart:math' as math;

import '../physics/prism_intersection.dart';
import 'bl_vec2.dart';
import 'intersection.dart';

/// Abstract prism shape interface.
abstract class PrismShape {
  PrismShape getTranslatedInstance(double dx, double dy);
  PrismShape getRotatedInstance(double angle, BlVec2 rotationPoint);
  BlVec2 getRotationCenter();
  BlVec2? getReferencePoint();
  bool containsPoint(BlVec2 point);
  List<Intersection> getIntersections(BlVec2 rayTail, BlVec2 rayDir);
}

/// Polygon prism (`Polygon.ts`); [radius]==0 closed polygon; else diverging lens.
class PolygonShape implements PrismShape {
  PolygonShape({
    required this.referencePointIndex,
    required this.points,
    required this.radius,
  }) : centroid = _centroid(points);

  final int referencePointIndex;
  final List<BlVec2> points;
  final double radius;
  final BlVec2 centroid;
  BlVec2? center; // for diverging lens

  @override
  PolygonShape getTranslatedInstance(double dx, double dy) {
    return PolygonShape(
      referencePointIndex: referencePointIndex,
      points: [for (final p in points) p.plusXY(dx, dy)],
      radius: radius,
    );
  }

  @override
  PolygonShape getRotatedInstance(double angle, BlVec2 rotationPoint) {
    final newPoints = <BlVec2>[];
    for (final p in points) {
      final about = p - rotationPoint;
      newPoints.add(about.rotate(angle) + rotationPoint);
    }
    return PolygonShape(
      referencePointIndex: referencePointIndex,
      points: newPoints,
      radius: radius,
    );
  }

  @override
  BlVec2 getRotationCenter() => centroid;

  @override
  BlVec2? getReferencePoint() => points[referencePointIndex];

  @override
  bool containsPoint(BlVec2 point) {
    if (radius == 0) {
      return _pointInPolygon(point, points);
    }
    // Diverging lens: approximate with polygon + exterior of arc side
    // Use shape.containsPoint semantics: polygonal region with concave arcs.
    // For Phase 1 physics, use polygon winding of the four corners as base,
    // then exclude points outside the arcs (inside the circle caps).
    if (!_pointInPolygon(point, points)) return false;
    final c = points[0] + (points[3] - points[0]) * 0.5;
    // Outside either circular arc means not in lens body for concave lens
    // PhET uses ellipticalArc — we approximate contains via polygon for tests;
    // accurate intersection still uses edges+arcs.
    return point.distance(c) >= radius * 0.99 || _pointInPolygon(point, points);
  }

  @override
  List<Intersection> getIntersections(BlVec2 rayTail, BlVec2 rayDir) {
    if (radius == 0) {
      final edges = <(BlVec2, BlVec2)>[];
      for (var i = 0; i < points.length; i++) {
        edges.add((points[i], points[(i + 1) % points.length]));
      }
      return PrismIntersection.getIntersections(
        edges: edges,
        arcCenter: null,
        arcRadius: null,
        arcStartAngle: null,
        arcEndAngle: null,
        arcAnticlockwise: null,
        rayTail: rayTail,
        rayDirection: rayDir,
      );
    }

    // Diverging lens: one arc + three lines (see Polygon.ts)
    final c = points[0] + (points[3] - points[0]) * 0.5;
    final startAngle = math.atan2(c.y - points[3].y, c.x - points[3].x);
    final edges = <(BlVec2, BlVec2)>[
      (points[3], points[2]),
      (points[2], points[1]),
      (points[1], points[0]),
    ];
    return PrismIntersection.getIntersections(
      edges: edges,
      arcCenter: c,
      arcRadius: radius,
      arcStartAngle: startAngle,
      arcEndAngle: startAngle + math.pi,
      arcAnticlockwise: true,
      rayTail: rayTail,
      rayDirection: rayDir,
    );
  }

  static BlVec2 _centroid(List<BlVec2> p) {
    var cx = 0.0, cy = 0.0;
    for (var i = 0; i < p.length; i++) {
      final j = (i + 1) % p.length;
      final n = (p[i].x * p[j].y) - (p[j].x * p[i].y);
      cx += (p[i].x + p[j].x) * n;
      cy += (p[i].y + p[j].y) * n;
    }
    final a = _area(p);
    final f = 1 / (a * 6);
    return BlVec2(cx * f, cy * f);
  }

  static double _area(List<BlVec2> p) {
    var a = 0.0;
    for (var i = 0; i < p.length; i++) {
      final j = (i + 1) % p.length;
      a += p[i].x * p[j].y - p[j].x * p[i].y;
    }
    return a / 2;
  }
}

bool _pointInPolygon(BlVec2 point, List<BlVec2> poly) {
  var inside = false;
  for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    final xi = poly[i].x, yi = poly[i].y;
    final xj = poly[j].x, yj = poly[j].y;
    final intersect = ((yi > point.y) != (yj > point.y)) &&
        (point.x <
            (xj - xi) * (point.y - yi) / ((yj - yi) == 0 ? 1e-30 : (yj - yi)) +
                xi);
    if (intersect) inside = !inside;
  }
  return inside;
}

/// Full circle (`BendingLightCircle.ts`).
class CircleShape implements PrismShape {
  CircleShape(this.center, this.radius);

  final BlVec2 center;
  final double radius;

  @override
  CircleShape getTranslatedInstance(double dx, double dy) =>
      CircleShape(center.plusXY(dx, dy), radius);

  @override
  CircleShape getRotatedInstance(double angle, BlVec2 rotationPoint) => this;

  @override
  BlVec2 getRotationCenter() => center;

  @override
  BlVec2? getReferencePoint() => null;

  @override
  bool containsPoint(BlVec2 point) => point.distance(center) <= radius;

  @override
  List<Intersection> getIntersections(BlVec2 rayTail, BlVec2 rayDir) {
    return PrismIntersection.getIntersections(
      edges: const [],
      arcCenter: center,
      arcRadius: radius,
      arcStartAngle: null,
      arcEndAngle: null,
      arcAnticlockwise: null,
      rayTail: rayTail,
      rayDirection: rayDir,
    );
  }
}

/// Semicircle (`SemiCircle.ts`).
class SemiCircleShape implements PrismShape {
  SemiCircleShape({
    required this.referencePointIndex,
    required this.points,
    required this.radius,
  }) : center = (points[0] + points[1]) * 0.5;

  final int referencePointIndex;
  final List<BlVec2> points;
  final double radius;
  final BlVec2 center;

  @override
  SemiCircleShape getTranslatedInstance(double dx, double dy) => SemiCircleShape(
        referencePointIndex: referencePointIndex,
        points: [for (final p in points) p.plusXY(dx, dy)],
        radius: radius,
      );

  @override
  SemiCircleShape getRotatedInstance(double angle, BlVec2 rotationPoint) {
    final newPoints = <BlVec2>[];
    for (final p in points) {
      newPoints.add((p - rotationPoint).rotate(angle) + rotationPoint);
    }
    return SemiCircleShape(
      referencePointIndex: referencePointIndex,
      points: newPoints,
      radius: radius,
    );
  }

  @override
  BlVec2 getRotationCenter() => center;

  @override
  BlVec2? getReferencePoint() => points[referencePointIndex];

  @override
  bool containsPoint(BlVec2 point) {
    if (point.distance(center) > radius) return false;
    // Half-plane relative to diameter points[0]→points[1]
    final d = points[1] - points[0];
    final n = d.rotate(math.pi / 2).normalize();
    // Arc is on one side — PhET ellipticalArc false direction
    final startAngle =
        math.atan2(points[1].y - center.y, points[1].x - center.x);
    final mid = BlVec2.polar(radius, startAngle + math.pi / 2) + center;
    final side = (mid - center).dot(n);
    return (point - center).dot(n) * side >= 0;
  }

  @override
  List<Intersection> getIntersections(BlVec2 rayTail, BlVec2 rayDir) {
    final startAngle =
        math.atan2(points[1].y - center.y, points[1].x - center.x);
    return PrismIntersection.getIntersections(
      edges: [(points[0], points[1])],
      arcCenter: center,
      arcRadius: radius,
      arcStartAngle: startAngle,
      arcEndAngle: startAngle + math.pi,
      arcAnticlockwise: true,
      rayTail: rayTail,
      rayDirection: rayDir,
    );
  }
}

/// Factory for PhET prism prototypes (`PrismsModel.getPrismPrototypes`).
class PrismPrototypes {
  PrismPrototypes._();

  static List<(PrismShape shape, String typeName)> createAll() {
    final a = 650e-9 * 10; // CHARACTERISTIC_LENGTH * 10
    final radius = a / 2;
    return [
      (
        PolygonShape(
          referencePointIndex: 1,
          points: [
            BlVec2(-a / 2, -a / (2 * math.sqrt(3))),
            BlVec2(a / 2, -a / (2 * math.sqrt(3))),
            BlVec2(0, a / math.sqrt(3)),
          ],
          radius: 0,
        ),
        'triangle',
      ),
      (
        PolygonShape(
          referencePointIndex: 1,
          points: [
            BlVec2(-a / 2, -a * math.sqrt(3) / 4),
            BlVec2(a / 2, -a * math.sqrt(3) / 4),
            BlVec2(a / 4, a * math.sqrt(3) / 4),
            BlVec2(-a / 4, a * math.sqrt(3) / 4),
          ],
          radius: 0,
        ),
        'trapezoid',
      ),
      (
        PolygonShape(
          referencePointIndex: 2,
          points: [
            BlVec2(-a / 2, a / 2),
            BlVec2(a / 2, a / 2),
            BlVec2(a / 2, -a / 2),
            BlVec2(-a / 2, -a / 2),
          ],
          radius: 0,
        ),
        'square',
      ),
      (CircleShape(BlVec2.zero, radius), 'circle'),
      (
        SemiCircleShape(
          referencePointIndex: 1,
          points: [BlVec2(0, radius), BlVec2(0, -radius)],
          radius: radius,
        ),
        'semicircle',
      ),
      (
        PolygonShape(
          referencePointIndex: 2,
          points: [
            BlVec2(-0.6 * radius, radius),
            BlVec2(0.6 * radius, radius),
            BlVec2(0.6 * radius, -radius),
            BlVec2(-0.6 * radius, -radius),
          ],
          radius: radius,
        ),
        'diverging-lens',
      ),
    ];
  }
}
