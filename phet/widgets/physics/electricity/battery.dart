/// PhET Battery — a DC voltage source component.
library;

import 'package:flutter/material.dart';

class Battery {
  Offset center;
  double voltage;
  double width;
  double height;

  Battery({
    this.center = Offset.zero,
    this.voltage = 1.5,
    this.width = 60,
    this.height = 120,
  });

  bool get isPositive => voltage >= 0;

  void draw(Canvas canvas) {
    final w = width;
    final h = height;
    final left = center.dx - w / 2;
    final top = center.dy - h / 2;

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, w, h),
      const Radius.circular(8),
    );
    canvas.drawRRect(body, Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: const [Color(0xff6d4c41), Color(0xff8d6e63), Color(0xff6d4c41)],
      ).createShader(Rect.fromLTWH(left, top, w, h)));

    // Terminal caps
    final capW = w * 0.5;
    final capH = 10.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - capW / 2, top - capH / 2, capW, capH),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xffd84315),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - capW / 2, top + h - capH / 2, capW, capH),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xff37474f),
    );

    // + and - labels
    _text(canvas, '+', Offset(center.dx, top + 12), 14, Colors.white);
    _text(canvas, '−', Offset(center.dx, top + h - 12), 14, Colors.white);

    // Voltage text
    _text(canvas, '${voltage.toStringAsFixed(1)} V', Offset(center.dx, center.dy), 12, Colors.white);
  }

  void _text(Canvas c, String s, Offset pos, double fs, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(color: color, fontSize: fs, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, pos - Offset(tp.width / 2, tp.height / 2));
  }
}
