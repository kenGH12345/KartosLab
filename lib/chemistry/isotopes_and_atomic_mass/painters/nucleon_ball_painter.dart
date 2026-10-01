/// shred ParticleNode shaded sphere for protons / neutrons.
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../iaam_constants.dart';

class NucleonBallPainter {
  const NucleonBallPainter._();

  static void paint(
    Canvas canvas,
    Offset center,
    double r,
    Color base,
  ) {
    final gradientCenter = Offset(center.dx - r * 0.4, center.dy - r * 0.4);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          gradientCenter,
          r * 1.6,
          [Colors.white, base],
        ),
    );
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = base,
    );
  }

  static Color colorForProton() => IaamConstants.proton;
  static Color colorForNeutron() => IaamConstants.neutron;
}
