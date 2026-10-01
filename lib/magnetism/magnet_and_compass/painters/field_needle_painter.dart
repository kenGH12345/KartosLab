import 'dart:math';
import 'package:flutter/material.dart';

import '../model/magnetic_field.dart';

/// Paints the full-screen magnetic-field arrow grid (34 × 19 needles).
///
/// Class name unchanged.
///
/// Extracted from `simulations/magnet_and_compass.dart:699-788`.
class FieldNeedlePainter extends CustomPainter {
  final Offset magnetPos;
  final double magnetAngle;
  final double strength;
  final bool flipped;
  final bool earthField;
  final double magnetW;
  final double magnetH;
  final bool skipCircle;
  final Offset circleCenter;
  final double circleRadius;

  const FieldNeedlePainter({
    required this.magnetPos,
    required this.magnetAngle,
    required this.strength,
    required this.flipped,
    required this.earthField,
    required this.magnetW,
    required this.magnetH,
    this.skipCircle = false,
    this.circleCenter = Offset.zero,
    this.circleRadius = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const cols = 34;
    const rows = 19;
    final cw = size.width / cols;
    final ch = size.height / rows;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final px = (col + 0.5) * cw;
        final py = (row + 0.5) * ch;
        final p = Offset(px, py);

        if (!earthField) {
          final d = p - magnetPos;
          final ca = cos(-magnetAngle);
          final sa = sin(-magnetAngle);
          final lx = (d.dx * ca - d.dy * sa).abs();
          final ly = (d.dx * sa + d.dy * ca).abs();
          if (lx < magnetW / 2 + 5 && ly < magnetH / 2 + 5) continue;
        }

        if (skipCircle) {
          final d = p - circleCenter;
          if (d.dx * d.dx + d.dy * d.dy < circleRadius * circleRadius) continue;
        }

        final b = MagneticField.compute(p, magnetPos, magnetAngle, magnetW / 2, strength, flipped, earthField);
        final mag = MagneticField.magnitude(b);
        if (mag < 1e-6) continue;

        final angle = MagneticField.fieldAngle(b);
        final len = (log(1 + mag * 0.28) * 100).clamp(8.0, 36.0).toDouble();
        _drawNeedle(canvas, p, angle, len);
      }
    }
  }

  void _drawNeedle(Canvas canvas, Offset c, double angle, double len) {
    final half = len / 2;
    final hw = (len / 18.0 * 5.6).clamp(3.0, 5.6);
    final ca = cos(angle);
    final sa = sin(angle);
    final cp = cos(angle + pi / 2);
    final sp = sin(angle + pi / 2);

    final head = Offset(c.dx + ca * half, c.dy + sa * half);
    final tail = Offset(c.dx - ca * half, c.dy - sa * half);
    final left = Offset(c.dx + cp * hw, c.dy + sp * hw);
    final right = Offset(c.dx - cp * hw, c.dy - sp * hw);

    canvas.drawPath(
      Path()..moveTo(tail.dx, tail.dy)..lineTo(left.dx, left.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = const Color(0xffcccccc)..style = PaintingStyle.fill);
    canvas.drawPath(
      Path()..moveTo(head.dx, head.dy)..lineTo(left.dx, left.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = const Color(0xffcc2222)..style = PaintingStyle.fill);
    canvas.drawPath(
      Path()..moveTo(head.dx, head.dy)..lineTo(left.dx, left.dy)..lineTo(tail.dx, tail.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 0.3);
  }

  @override
  bool shouldRepaint(FieldNeedlePainter o) => true;
}
