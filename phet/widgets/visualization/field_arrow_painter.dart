/// PhET Field Arrow Painter — renders a grid of field arrows for any [Field].
library;

import 'dart:math';
import 'package:flutter/material.dart';
import '../shapes/phet_arrow.dart';
import 'field.dart';

class FieldArrowPainter extends CustomPainter {
  final Field field;
  final int cols;
  final int rows;
  final double minLen;
  final double maxLen;
  final Offset? skipCenter;
  final double skipRadius;

  const FieldArrowPainter({
    required this.field,
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
        if (skipCenter != null && (p - skipCenter!).distance < skipRadius) continue;

        final mag = field.magnitudeAt(p);
        if (mag < 1e-6) continue;
        final angle = field.angleAt(p);
        final len = (log(1 + mag * 0.28) * 100).clamp(minLen, maxLen).toDouble();

        PhetArrow(origin: p, angle: angle, length: len).draw(canvas);
      }
    }
  }

  @override
  bool shouldRepaint(FieldArrowPainter old) => true;
}
