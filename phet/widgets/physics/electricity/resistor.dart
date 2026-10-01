/// PhET Resistor — a resistor component for circuits.
library;

import 'package:flutter/material.dart';

class Resistor {
  Offset position;
  double resistance;
  double width;
  double height;
  double angle;

  Resistor({
    this.position = Offset.zero,
    this.resistance = 10,
    this.width = 60,
    this.height = 20,
    this.angle = 0,
  });

  void draw(Canvas canvas) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);

    // Body
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(-width / 2, -height / 2, width, height),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, Paint()..color = const Color(0xffd4a373));
    canvas.drawRRect(rect, Paint()
      ..color = const Color(0xff8d6e63)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);

    // Zigzag pattern
    final path = Path()..moveTo(-width / 2 + 8, 0);
    final zigCount = 6;
    final zigLen = (width - 16) / zigCount;
    for (int i = 0; i < zigCount; i++) {
      final x = -width / 2 + 8 + (i + 0.5) * zigLen;
      final y = (i % 2 == 0) ? -height / 4 : height / 4;
      path.lineTo(x, y);
    }
    path.lineTo(width / 2 - 8, 0);
    canvas.drawPath(path, Paint()
      ..color = const Color(0xff5d4037)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke);

    // Wires on both ends
    canvas.drawLine(Offset(-width / 2 - 10, 0), Offset(-width / 2, 0),
        Paint()..color = const Color(0xffb0bec5)..strokeWidth = 3..strokeCap = StrokeCap.round);
    canvas.drawLine(Offset(width / 2, 0), Offset(width / 2 + 10, 0),
        Paint()..color = const Color(0xffb0bec5)..strokeWidth = 3..strokeCap = StrokeCap.round);

    canvas.restore();
  }
}
