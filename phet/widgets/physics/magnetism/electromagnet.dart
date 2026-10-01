/// PhET Electromagnet — an electromagnet model (current-driven coil).
///
/// Uses [MagneticField] with strength proportional to current × loops.
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'magnetic_field.dart';

class Electromagnet {
  Offset center;
  double axisAngle;
  double halfLength;
  int loops;
  double current; // Amperes, can be negative

  Electromagnet({
    this.center = Offset.zero,
    this.axisAngle = 0,
    this.halfLength = 80,
    this.loops = 4,
    this.current = 0,
  });

  /// Effective strength = base × |current| × loops.
  double get _strength => (current * loops * 6000).abs();

  /// Sign determines pole orientation.
  int get _sign => current >= 0 ? 1 : -1;

  /// Get the [MagneticDipole] for this electromagnet.
  MagneticDipole get dipole => MagneticDipole(
        center: center,
        axisAngle: _sign > 0 ? axisAngle : axisAngle + pi,
        halfLength: halfLength,
        strength: _strength,
        loops: 1,
      );

  /// Get the [MagneticField].
  MagneticField get field => MagneticField.single(dipole);

  /// Draw the coil (loops) on canvas.
  void drawCoil(Canvas canvas, {double coilW = 200, double coilH = 160}) {
    final left = center.dx - coilW / 2;
    final loopSpacing = coilW / loops;
    final loopW = loopSpacing * 0.85;
    final loopH = coilH;

    for (int i = 0; i < loops; i++) {
      final cx = left + (i + 0.5) * loopSpacing;
      final rect = Rect.fromCenter(center: Offset(cx, center.dy), width: loopW, height: loopH);
      canvas.drawOval(rect, Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: const [Color(0xffa1887f), Color(0xff5d4037)],
        ).createShader(rect));
      canvas.drawOval(rect, Paint()
        ..color = const Color(0xffd7ccc8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
      canvas.drawOval(rect, Paint()
        ..color = const Color(0xff3e2723)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);
    }
  }

  /// Draw the battery above the coil.
  void drawBattery(Canvas canvas, {double voltage = 0}) {
    final w = 60.0;
    final h = 120.0;
    final bx = center.dx - w / 2;
    final by = center.dy - 160 / 2 - h / 2 - 20;

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(bx, by, w, h),
      const Radius.circular(8),
    );

    canvas.drawRRect(body, Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: const [Color(0xff6d4c41), Color(0xff8d6e63), Color(0xff6d4c41)],
      ).createShader(Rect.fromLTWH(bx, by, w, h)));

    // Terminal caps
    final capW = w * 0.5;
    final capH = 10.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - capW / 2, by - capH / 2, capW, capH),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xffd84315),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - capW / 2, by + h - capH / 2, capW, capH),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xff37474f),
    );

    // Voltage text
    final tp = TextPainter(
      text: TextSpan(text: '${voltage.toStringAsFixed(1)} V',
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, by + h / 2 - tp.height / 2));
  }
}
