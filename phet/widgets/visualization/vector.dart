/// PhET Vector — 2D vector with magnitude, direction, and label support.
///
/// Used for force, velocity, acceleration, field, and momentum vectors.
library;

import 'dart:math';
import 'package:flutter/material.dart';
import '../core/phet_types.dart';

export '../core/phet_types.dart' show PhetVector;

/// A displayable vector with visual properties.
class Vector {
  final Offset start;
  final PhetVector direction; // normalized
  final double magnitude;
  final double displayScale;
  final String? label;
  final Color color;

  const Vector({
    required this.start,
    required this.direction,
    required this.magnitude,
    this.displayScale = 1,
    this.label,
    this.color = const Color(0xffcc2222),
  });

  /// Compute the end point of the arrow.
  Offset get end => start + (direction * (magnitude * displayScale)).toOffset();

  /// Draw this vector as an arrow on canvas.
  void draw(Canvas canvas) {
    final e = end;
    canvas.drawLine(start, e, Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round);

    // Arrowhead
    final angle = direction.angle;
    final ah = 8.0;
    canvas.drawPath(
      Path()
        ..moveTo(e.dx, e.dy)
        ..lineTo(e.dx - cos(angle - 0.4) * ah, e.dy - sin(angle - 0.4) * ah)
        ..lineTo(e.dx - cos(angle + 0.4) * ah, e.dy - sin(angle + 0.4) * ah)
        ..close(),
      Paint()..color = color,
    );

    // Label
    if (label != null) {
      final tp = TextPainter(
        text: TextSpan(text: label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, e + const Offset(6, -6));
    }
  }
}
