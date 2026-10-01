import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/concentration_model.dart';
import '../model/solute_particle.dart';

/// Falling shaker particles — beers-law-lab `ShakerParticlesNode` / `ParticlesNode.ts`.
///
/// Rotated squares (diamond via √2 half-extent), one path fill+stroke.
class ShakerParticlesNode extends StatelessWidget {
  const ShakerParticlesNode({super.key, required this.model});

  final ConcentrationModel model;

  @override
  Widget build(BuildContext context) {
    final particles = model.shakerParticles.particles;
    if (particles.isEmpty) return const SizedBox.shrink();

    // Source canvas bounds: beaker left/right, top of layout → beaker bottom.
    final left = model.beaker.left;
    final right = model.beaker.right;
    const top = 0.0;
    final bottom = model.beaker.position.dy;

    return Positioned(
      left: left,
      top: top,
      width: right - left,
      height: bottom - top,
      child: ClipRect(
        child: CustomPaint(
          size: Size(right - left, bottom - top),
          painter: _ShakerParticlesPainter(
            particles: List<SoluteParticle>.from(particles),
            origin: Offset(left, top),
          ),
        ),
      ),
    );
  }
}

class _ShakerParticlesPainter extends CustomPainter {
  _ShakerParticlesPainter({
    required this.particles,
    required this.origin,
  });

  final List<SoluteParticle> particles;
  final Offset origin;

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) return;

    final solute = particles.first.solute;
    final particleSize = solute.particleSize;
    final half = particleSize * math.sqrt2 / 2;

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = solute.resolvedParticleFill;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = solute.resolvedParticleStroke;

    final path = Path();
    for (final p in particles) {
      final x = p.position.dx - origin.dx;
      final y = p.position.dy - origin.dy;
      final cos = p.cos * half;
      final sin = p.sin * half;
      path
        ..moveTo(x + cos, y + sin)
        ..lineTo(x - sin, y + cos)
        ..lineTo(x - cos, y - sin)
        ..lineTo(x + sin, y - cos)
        ..close();
    }
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _ShakerParticlesPainter oldDelegate) => true;
}

/// Stock solution stream from dropper — `StockSolutionNode.ts`.
class StockSolutionNode extends StatelessWidget {
  const StockSolutionNode({
    super.key,
    required this.model,
    required this.color,
  });

  final ConcentrationModel model;
  final Color color;

  static const double tipWidth = 14; // EyeDropperNode.TIP_WIDTH - 1

  @override
  Widget build(BuildContext context) {
    final dropper = model.dropper;
    if (!dropper.isDispensing || dropper.isEmpty || !dropper.isVisible(model.soluteForm)) {
      return const SizedBox.shrink();
    }

    final pos = dropper.position;
    final height = model.beaker.position.dy - pos.dy;
    if (height <= 0) return const SizedBox.shrink();

    final stroke = Color.lerp(color, Colors.black, 0.25)!;

    return Positioned(
      left: pos.dx - tipWidth / 2,
      top: pos.dy,
      width: tipWidth,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: stroke, width: 1),
        ),
      ),
    );
  }
}
