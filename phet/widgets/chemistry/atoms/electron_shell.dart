/// PhET Electron Shell — an electron orbital shell.
library;

import 'dart:math';
import 'package:flutter/material.dart';

class ElectronShell {
  final int shellNumber; // 1, 2, 3, ...
  final int electronCount;
  final double radius;
  final Offset center;
  final double rotation;

  ElectronShell({
    required this.shellNumber,
    required this.electronCount,
    this.radius = 40,
    this.center = Offset.zero,
    this.rotation = 0,
  });

  void draw(Canvas canvas, {double animTime = 0}) {
    // Orbit ring
    canvas.drawCircle(center, radius, Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5);

    // Electrons orbiting
    for (int i = 0; i < electronCount; i++) {
      final angle = 2 * pi * i / electronCount + rotation + animTime * (0.5 / shellNumber);
      final ex = center.dx + cos(angle) * radius;
      final ey = center.dy + sin(angle) * radius;
      // Glow
      canvas.drawCircle(Offset(ex, ey), 5, Paint()..color = const Color(0xff64b5f6).withValues(alpha: 0.3));
      // Electron
      canvas.drawCircle(Offset(ex, ey), 3, Paint()..color = const Color(0xff42a5f5));
      // Highlight
      canvas.drawCircle(Offset(ex - 1, ey - 1), 1, Paint()..color = Colors.white.withValues(alpha: 0.6));
    }
  }
}
