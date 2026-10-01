/// PhET Switch — a toggle switch for circuits.
library;

import 'package:flutter/material.dart';

class CircuitSwitch {
  Offset position;
  bool isClosed;
  double size;

  CircuitSwitch({
    this.position = Offset.zero,
    this.isClosed = true,
    this.size = 30,
  });

  void toggle() => isClosed = !isClosed;

  void draw(Canvas canvas) {
    final s = size;
    // Left terminal
    canvas.drawCircle(position, 4, Paint()..color = const Color(0xffb0bec5));
    // Right terminal
    final right = Offset(position.dx + s, position.dy);
    canvas.drawCircle(right, 4, Paint()..color = const Color(0xffb0bec5));

    // Wire
    final wirePaint = Paint()
      ..color = const Color(0xffb0bec5)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    if (isClosed) {
      canvas.drawLine(position, right, wirePaint);
    } else {
      // Open: lever up
      final lever = Offset(position.dx + s * 0.8, position.dy - s * 0.7);
      canvas.drawLine(position, lever, wirePaint);
    }
  }
}
