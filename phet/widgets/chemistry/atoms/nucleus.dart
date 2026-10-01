/// PhET Nucleus — the nucleus of an atom (protons + neutrons).
library;

import 'dart:math';
import 'package:flutter/material.dart';

class Nucleus {
  final Offset center;
  final int protons;
  final int neutrons;
  final double scale;

  Nucleus({
    this.center = Offset.zero,
    this.protons = 1,
    this.neutrons = 0,
    this.scale = 1,
  });

  void draw(Canvas canvas) {
    final r = 12.0 * scale;
    // Cluster protons and neutrons in a circle
    final total = protons + neutrons;
    if (total == 0) return;

    for (int i = 0; i < total; i++) {
      final angle = 2 * pi * i / total;
      final dist = total > 1 ? r * 0.5 : 0;
      final px = center.dx + cos(angle) * dist;
      final py = center.dy + sin(angle) * dist;
      final isProton = i < protons;
      canvas.drawCircle(
        Offset(px, py),
        5 * scale,
        Paint()..color = isProton ? const Color(0xffef5350) : const Color(0xff90a4ae),
      );
      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: isProton ? '+' : '0',
          style: TextStyle(color: Colors.white, fontSize: 7 * scale, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(px - tp.width / 2, py - tp.height / 2));
    }
  }
}
