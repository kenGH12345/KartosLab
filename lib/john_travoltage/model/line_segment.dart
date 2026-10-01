import 'jt_vec2.dart';

/// Immutable line segment — PhET `LineSegment.js`.
///
/// Derived values are computed once; do not mutate endpoints.
class LineSegment {
  LineSegment(this.x1, this.y1, this.x2, this.y2)
      : vector = JtVec2(x2 - x1, y2 - y1),
        p0 = JtVec2(x1, y1),
        p1 = JtVec2(x2, y2),
        normalVector =
            JtVec2(x2 - x1, y2 - y1).perpendicular.normalize() {
    const epsilon = 0.01;
    pre0 = p0.blend(p1, epsilon);
    pre1 = p0.blend(p1, 1 - epsilon);
  }

  factory LineSegment.fromPoints(JtVec2 a, JtVec2 b) =>
      LineSegment(a.x, a.y, b.x, b.y);

  final double x1;
  final double y1;
  final double x2;
  final double y2;

  final JtVec2 vector;
  final JtVec2 p0;
  final JtVec2 p1;

  /// Unit normal (perpendicular of direction), matching `normalVector`.
  final JtVec2 normalVector;

  late final JtVec2 pre0;
  late final JtVec2 pre1;

  JtVec2 get center => JtVec2((x1 + x2) / 2, (y1 + y2) / 2);

  /// PhET getter `normal` — recomputed perpendicular normalized.
  JtVec2 get normal =>
      JtVec2(x2 - x1, y2 - y1).normalize().perpendicular;
}
