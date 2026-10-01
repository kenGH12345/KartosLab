/// PhET Coil — a solenoid/inductor coil component.
///
/// Used by electromagnet and generator simulations.
library;

import 'package:flutter/material.dart';

class Coil {
  Offset center;
  int loops;
  double width;
  double height;
  double current;

  Coil({
    this.center = Offset.zero,
    this.loops = 4,
    this.width = 200,
    this.height = 160,
    this.current = 0,
  });

  /// Draw the coil.
  void draw(Canvas canvas) {
    final left = center.dx - width / 2;
    final loopSpacing = width / loops;
    final loopW = loopSpacing * 0.85;
    final loopH = height;

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
    }
  }

  /// Build a wire path for electron animation.
  List<Offset> wirePath(Offset batteryCenter, double batteryW, double batteryH) {
    final pts = <Offset>[];
    final batBL = Offset(batteryCenter.dx - batteryW * 0.3, batteryCenter.dy + batteryH / 2);
    final midL = Offset(batBL.dx, center.dy);
    final coilL = Offset(center.dx - width / 2 + 10, center.dy);
    pts..add(batBL)..add(midL)..add(coilL);
    final loopSpacing = width / loops;
    for (int i = 0; i < loops; i++) {
      final cx = center.dx - width / 2 + (i + 0.5) * loopSpacing;
      pts.add(Offset(cx, center.dy - height / 2));
      pts.add(Offset(cx, center.dy + height / 2));
    }
    final coilR = Offset(center.dx + width / 2 - 10, center.dy);
    final midR = Offset(batteryCenter.dx + batteryW * 0.3, center.dy);
    final batBR = Offset(batteryCenter.dx + batteryW * 0.3, batteryCenter.dy + batteryH / 2);
    pts..add(coilR)..add(midR)..add(batBR);
    return pts;
  }
}
