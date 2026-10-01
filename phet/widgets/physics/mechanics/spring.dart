/// PhET Spring — a spring object with rest length and stiffness.
library;

import 'dart:math';
import 'package:flutter/material.dart';
import '../physics_object.dart';
import '../force.dart';
import '../../core/phet_types.dart';

class Spring {
  Offset anchor;
  double restLength;
  double stiffness;
  int coils;

  Spring({
    required this.anchor,
    this.restLength = 100,
    this.stiffness = 10,
    this.coils = 8,
  });

  /// Compute spring force on an object at [position].
  PhetVector forceOn(PhysicsObject obj) {
    return SpringForce(anchor: anchor, restLength: restLength, k: stiffness)
        .compute(obj.position);
  }

  /// Draw the spring as a zigzag from anchor to [end].
  void draw(Canvas canvas, Offset end) {
    final dx = end.dx - anchor.dx;
    final dy = end.dy - anchor.dy;
    final len = sqrt(dx * dx + dy * dy);
    if (len < 1e-9) return;
    final ux = dx / len;
    final uy = dy / len;
    final px = -uy; // perpendicular
    final py = ux;
    final amp = 8.0;

    final path = Path()..moveTo(anchor.dx, anchor.dy);
    // Straight section at start
    final startLen = 10.0;
    path.lineTo(anchor.dx + ux * startLen, anchor.dy + uy * startLen);

    final zigLen = len - 2 * startLen;
    final step = zigLen / coils;
    for (int i = 0; i < coils; i++) {
      final t1 = startLen + (i + 0.25) * step;
      final t2 = startLen + (i + 0.75) * step;
      final sign = (i % 2 == 0) ? 1.0 : -1.0;
      path.lineTo(anchor.dx + ux * t1 + px * amp * sign, anchor.dy + uy * t1 + py * amp * sign);
      path.lineTo(anchor.dx + ux * t2 + px * amp * sign, anchor.dy + uy * t2 + py * amp * sign);
    }

    // Straight section at end
    path.lineTo(end.dx - ux * startLen, end.dy - uy * startLen);
    path.lineTo(end.dx, end.dy);

    canvas.drawPath(path, Paint()
      ..color = const Color(0xffb0bec5)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);
  }
}
