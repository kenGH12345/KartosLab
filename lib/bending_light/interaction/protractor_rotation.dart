import 'dart:math' as math;
import 'dart:ui';

/// `ProtractorNode` outer-ring drag: angle += atan2(center-end) - atan2(center-start).
double protractorAngleDelta({
  required Offset center,
  required Offset start,
  required Offset end,
}) {
  final a0 = math.atan2(center.dy - start.dy, center.dx - start.dx);
  final a1 = math.atan2(center.dy - end.dy, center.dx - end.dx);
  if (!a0.isFinite || !a1.isFinite) return 0;
  return a1 - a0;
}

/// Outer ring of `protractor_png`: inner ellipse radius is `0.3 * width`
/// = `0.6 * outerRadius`. Inside that disk the node translates.
bool protractorOuterRing(Offset localCenter, Offset localPoint, double radius) {
  return (localPoint - localCenter).distance >= radius * 0.6;
}
