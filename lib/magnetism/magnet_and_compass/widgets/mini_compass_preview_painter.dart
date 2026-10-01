import 'dart:math';
import 'package:flutter/material.dart';

/// Mini compass preview painter used inside the control panel checkbox row.
///
/// Renamed from `_MiniCompassPreviewPainter` → `MiniCompassPreviewPainter`
/// (private → public).
///
/// Extracted from `simulations/magnet_and_compass.dart:1045-1088`.
class MiniCompassPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawCircle(Offset(cx, cy), cy - 1, Paint()..color = const Color(0xff2a2a2a));
    canvas.drawCircle(Offset(cx, cy), cy - 1,
      Paint()..color = const Color(0xff555555)..style = PaintingStyle.stroke..strokeWidth = 1.5);

    const angle = 0.4;
    final nh = cy - 3;
    final nhw = 2.8;
    final ca = cos(angle - pi / 2);
    final sa = sin(angle - pi / 2);
    final cp = cos(angle);
    final sp = sin(angle);

    final head = Offset(cx + ca * nh, cy + sa * nh);
    final tail = Offset(cx - ca * nh, cy - sa * nh);
    final left = Offset(cx + cp * nhw, cy + sp * nhw);
    final right = Offset(cx - cp * nhw, cy - sp * nhw);

    canvas.drawPath(
      Path()..moveTo(tail.dx, tail.dy)..lineTo(left.dx, left.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = Colors.white70);
    canvas.drawPath(
      Path()..moveTo(head.dx, head.dy)..lineTo(left.dx, left.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = Colors.redAccent);

    _t(canvas, 'S', Offset(3, cy), Colors.black54, 8);
    _t(canvas, 'N', Offset(size.width - 5, cy), Colors.black54, 8);
  }

  void _t(Canvas canvas, String t, Offset c, Color color, double fs) {
    final tp = TextPainter(
      text: TextSpan(text: t, style: TextStyle(color: color, fontSize: fs, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(MiniCompassPreviewPainter o) => false;
}
