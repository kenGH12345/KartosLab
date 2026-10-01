import 'dart:math';
import 'package:flutter/material.dart';

/// Paints the atmospheric glow ring around the Earth visual in earth-field mode.
///
/// Renamed from `_EarthGlowPainter` → `EarthGlowPainter` (private → public).
///
/// Extracted from `simulations/magnet_and_compass.dart:528-550`.
class EarthGlowPainter extends CustomPainter {
  const EarthGlowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy);
    final c = Offset(cx, cy);

    canvas.drawCircle(c, r - 1,
      Paint()..color = const Color(0xff607d8b)..style = PaintingStyle.stroke..strokeWidth = 3.0);
    canvas.drawCircle(c, r - 2,
      Paint()..shader = RadialGradient(
        center: const Alignment(-0.45, -0.50),
        radius: 0.65,
        colors: [Colors.white.withValues(alpha: 0.18), Colors.transparent],
      ).createShader(Rect.fromCircle(center: c, radius: r)));
  }

  @override
  bool shouldRepaint(EarthGlowPainter o) => false;
}
