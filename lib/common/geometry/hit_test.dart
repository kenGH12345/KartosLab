import 'dart:ui';

/// 点 p 到线段 ab 的最短距离（像素）。
///
/// 数学等价自 circuit_screen.dart 原内联实现与 circuit_canvas.dart 原
/// `_pointToSegmentDistance`（两版逐位等价）。a、b 重合时退化为 p 到 a 的距离。
double pointToSegmentDistance(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final ap = p - a;
  final abLenSq = ab.distanceSquared;
  if (abLenSq == 0) return ap.distance;
  final t = (ap.dx * ab.dx + ap.dy * ab.dy) / abLenSq;
  final projection = a + ab * t.clamp(0.0, 1.0);
  return (p - projection).distance;
}
