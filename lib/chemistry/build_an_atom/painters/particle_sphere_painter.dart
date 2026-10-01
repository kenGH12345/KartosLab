/// shred ParticleNode shaded sphere for proton / neutron / electron.
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../constants/baa_constants.dart';
import '../model/baa_particle.dart';

class ParticleSpherePainter {
  const ParticleSpherePainter._();

  static Color colorFor(BaaParticleType type) {
    switch (type) {
      case BaaParticleType.proton:
        return const Color(BAAConstants.protonColorValue);
      case BaaParticleType.neutron:
        return const Color(BAAConstants.neutronColorValue);
      case BaaParticleType.electron:
        return const Color(BAAConstants.electronColorValue);
    }
  }

  static double radiusFor(BaaParticleType type) {
    return type == BaaParticleType.electron
        ? BAAConstants.electronRadius
        : BAAConstants.nucleonRadius;
  }

  static void paint(Canvas canvas, Offset center, double r, Color base) {
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
        ..color = base.withValues(alpha: 0.85),
    );
  }
}

class ParticleSphereWidget extends StatelessWidget {
  const ParticleSphereWidget({
    super.key,
    required this.type,
    this.scale = 1.0,
    this.dragging = false,
  });

  final BaaParticleType type;
  final double scale;
  final bool dragging;

  @override
  Widget build(BuildContext context) {
    final r = ParticleSpherePainter.radiusFor(type) * scale;
    final d = r * 2;
    return CustomPaint(
      size: Size(d, d),
      painter: _SpherePainter(
        color: ParticleSpherePainter.colorFor(type),
        dragging: dragging,
      ),
    );
  }
}

class _SpherePainter extends CustomPainter {
  _SpherePainter({required this.color, required this.dragging});

  final Color color;
  final bool dragging;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    if (dragging) {
      canvas.drawCircle(
        c.translate(1.5, 2),
        r,
        Paint()..color = Colors.black.withValues(alpha: 0.25),
      );
    }
    ParticleSpherePainter.paint(canvas, c, r, color);
  }

  @override
  bool shouldRepaint(covariant _SpherePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dragging != dragging;
}
