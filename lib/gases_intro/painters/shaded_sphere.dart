import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Port of scenery-phet [ShadedSphereNode].
///
/// RadialGradient centered at (highlightXOffset, highlightYOffset) × radius:
/// stop 0 → highlight, stop [highlightDiameterRatio] → main, stop 1 → shadow.
/// Gradient radius = sphere radius × 2 (source default).
void paintShadedSphere(
  Canvas canvas,
  Offset center,
  double radius, {
  required Color mainColor,
  required Color highlightColor,
  Color shadowColor = const Color(0xFF000000),
  double highlightDiameterRatio = 0.5,
  double highlightXOffset = -0.4,
  double highlightYOffset = -0.4,
}) {
  if (radius <= 0) return;
  final highlight = Offset(
    center.dx + radius * highlightXOffset,
    center.dy + radius * highlightYOffset,
  );
  final mid = highlightDiameterRatio.clamp(0.0, 0.999);
  canvas.drawCircle(
    center,
    radius,
    Paint()
      ..shader = ui.Gradient.radial(
        highlight,
        radius * 2,
        [highlightColor, mainColor, shadowColor],
        [0.0, mid, 1.0],
      ),
  );
}
