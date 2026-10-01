/// PhET Arrow — draws a directional arrow on canvas.
///
/// Used for field arrows, vector arrows, flow arrows, etc.
library;

import 'dart:math';
import 'package:flutter/material.dart';

class PhetArrow {
  final Offset origin;
  final double angle;
  final double length;
  final Color headColor;
  final Color tailColor;
  final double? width;

  const PhetArrow({
    required this.origin,
    required this.angle,
    required this.length,
    this.headColor = const Color(0xffcc2222),
    this.tailColor = const Color(0xffcccccc),
    this.width,
  });

  /// Draw this arrow on [canvas].
  void draw(Canvas canvas) {
    final half = length / 2;
    final w = width ?? (length / 18.0 * 5.6).clamp(3.0, 5.6);
    final ca = cos(angle);
    final sa = sin(angle);
    final cp = cos(angle + pi / 2);
    final sp = sin(angle + pi / 2);

    final head = Offset(origin.dx + ca * half, origin.dy + sa * half);
    final tail = Offset(origin.dx - ca * half, origin.dy - sa * half);
    final left = Offset(origin.dx + cp * w, origin.dy + sp * w);
    final right = Offset(origin.dx - cp * w, origin.dy - sp * w);

    // Tail half (gray)
    canvas.drawPath(
      Path()..moveTo(tail.dx, tail.dy)..lineTo(left.dx, left.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = tailColor..style = PaintingStyle.fill,
    );
    // Head half (red)
    canvas.drawPath(
      Path()..moveTo(head.dx, head.dy)..lineTo(left.dx, left.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = headColor..style = PaintingStyle.fill,
    );
    // Outline
    canvas.drawPath(
      Path()
        ..moveTo(head.dx, head.dy)
        ..lineTo(left.dx, left.dy)
        ..lineTo(tail.dx, tail.dy)
        ..lineTo(right.dx, right.dy)
        ..close(),
      Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 0.3,
    );
  }
}

/// A painter that draws a grid of field arrows.
class PhetArrowGridPainter extends CustomPainter {
  final double Function(Offset) angleAt;
  final double Function(Offset) magnitudeAt;
  final int cols;
  final int rows;
  final double minLen;
  final double maxLen;
  final Offset? skipCenter;
  final double skipRadius;

  const PhetArrowGridPainter({
    required this.angleAt,
    required this.magnitudeAt,
    this.cols = 34,
    this.rows = 19,
    this.minLen = 8,
    this.maxLen = 36,
    this.skipCenter,
    this.skipRadius = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cw = size.width / cols;
    final ch = size.height / rows;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final p = Offset((col + 0.5) * cw, (row + 0.5) * ch);

        // Skip area around center (e.g. inside a coil/magnet)
        if (skipCenter != null && (p - skipCenter!).distance < skipRadius) continue;

        final mag = magnitudeAt(p);
        if (mag < 1e-6) continue;
        final angle = angleAt(p);
        final len = (log(1 + mag * 0.28) * 100).clamp(minLen, maxLen).toDouble();

        PhetArrow(origin: p, angle: angle, length: len).draw(canvas);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PhetArrowGridPainter old) => true;
}
