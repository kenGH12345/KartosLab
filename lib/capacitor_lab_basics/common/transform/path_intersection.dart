import 'dart:math' as math;
import 'dart:ui' show Offset, Path, PathOperation, Radius, Rect;

/// Closed-path intersection helpers for probe tip hit-testing.
class PathIntersection {
  PathIntersection._();

  /// Bounds overlap + non-empty Path.combine intersect —
  /// mirrors kite `shapeIntersection(...).getNonoverlappingArea() > 0`.
  static bool intersects(Path a, Path b) {
    final ab = a.getBounds();
    final bb = b.getBounds();
    if (ab.isEmpty || bb.isEmpty || !ab.overlaps(bb)) return false;
    final combined = Path.combine(PathOperation.intersect, a, b);
    final cb = combined.getBounds();
    return !cb.isEmpty && cb.width * cb.height > 0;
  }

  /// Stadium (capsule) around a wire segment — stroke width 7 (half=3.5).
  static Path wireSegmentCapsule(
    Offset start,
    Offset end, {
    double halfWidth = 3.5,
  }) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 1e-9) {
      return Path()..addOval(Rect.fromCircle(center: start, radius: halfWidth));
    }
    final nx = -dy / len * halfWidth;
    final ny = dx / len * halfWidth;
    return Path()
      ..moveTo(start.dx + nx, start.dy + ny)
      ..lineTo(end.dx + nx, end.dy + ny)
      ..arcToPoint(
        Offset(end.dx - nx, end.dy - ny),
        radius: Radius.circular(halfWidth),
        clockwise: true,
      )
      ..lineTo(start.dx - nx, start.dy - ny)
      ..arcToPoint(
        Offset(start.dx + nx, start.dy + ny),
        radius: Radius.circular(halfWidth),
        clockwise: true,
      )
      ..close();
  }
}
