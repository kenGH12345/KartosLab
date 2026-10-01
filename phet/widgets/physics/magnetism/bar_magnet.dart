/// PhET Bar Magnet — a bar magnet model + painter.
///
/// Uses [MagneticDipole] / [MagneticField] for field calculation.
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'magnetic_field.dart';

class BarMagnet {
  Offset center;
  double angle;
  double length;
  double width;
  double strength;
  bool isFlipped;

  BarMagnet({
    this.center = const Offset(0, 0),
    this.angle = 0,
    this.length = 160,
    this.width = 40,
    this.strength = 100000,
    this.isFlipped = false,
  });

  /// Get the [MagneticDipole] for this magnet.
  MagneticDipole get dipole => MagneticDipole(
        center: center,
        axisAngle: isFlipped ? angle + pi : angle,
        halfLength: length / 2,
        strength: strength,
        loops: 1,
      );

  /// Get the [MagneticField] for this magnet (single source).
  MagneticField get field => MagneticField.single(dipole);

  void draw(Canvas canvas) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final w = length;
    final h = width;
    final left = -w / 2;
    final top = -h / 2;

    // Determine N/S sides based on isFlipped
    final nColor = const Color(0xffee3333);
    final sColor = const Color(0xff888888);

    // Left half
    final leftColor = isFlipped ? sColor : nColor;
    final rightColor = isFlipped ? nColor : sColor;

    // Left half
    canvas.drawRect(
      Rect.fromLTWH(left, top, w / 2, h),
      Paint()..color = leftColor,
    );
    // Right half
    canvas.drawRect(
      Rect.fromLTWH(0, top, w / 2, h),
      Paint()..color = rightColor,
    );
    // Border
    canvas.drawRect(
      Rect.fromLTWH(left, top, w, h),
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // N / S labels
    _drawText(canvas, 'N', Offset(left + w / 4, 0), 18, Colors.white);
    _drawText(canvas, 'S', Offset(w / 4, 0), 18, Colors.white);

    canvas.restore();
  }

  void _drawText(Canvas canvas, String text, Offset pos, double fontSize, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }
}
