import 'package:flutter/material.dart';

import '../model/concentration_model.dart';
import '../model/solute_particle.dart';

/// Beaker-bottom precipitate — `PrecipitateParticlesNode` / `ParticlesNode.ts`.
///
/// Canvas bounds match source: beaker left/right, `beaker.y - 100` → `beaker.y`.
class PrecipitateParticlesNode extends StatelessWidget {
  const PrecipitateParticlesNode({super.key, required this.model});

  final ConcentrationModel model;

  /// Source canvas height above beaker bottom.
  static const double canvasHeightAboveBottom = 100;

  @override
  Widget build(BuildContext context) {
    final particles = model.precipitateParticles.particles;
    if (particles.isEmpty) return const SizedBox.shrink();

    final left = model.beaker.left;
    final right = model.beaker.right;
    final bottom = model.beaker.position.dy;
    final top = bottom - canvasHeightAboveBottom;

    return Positioned(
      left: left,
      top: top,
      width: right - left,
      height: canvasHeightAboveBottom,
      child: ClipRect(
        child: CustomPaint(
          size: Size(right - left, canvasHeightAboveBottom),
          painter: _PrecipitatePainter(
            particles: List<SoluteParticle>.from(particles),
            origin: Offset(left, top),
            signature: _signature(particles),
          ),
        ),
      ),
    );
  }

  static int _signature(List<SoluteParticle> particles) {
    if (particles.isEmpty) return 0;
    // Count + endpoint ids — stable when middle particles unchanged.
    return Object.hash(
      particles.length,
      particles.first.id,
      particles.last.id,
    );
  }
}

class _PrecipitatePainter extends CustomPainter {
  _PrecipitatePainter({
    required this.particles,
    required this.origin,
    required this.signature,
  });

  final List<SoluteParticle> particles;
  final Offset origin;
  final int signature;

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) return;

    final solute = particles.first.solute;
    final half = solute.particleSize * 1.41421356237 / 2; // √2/2

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
  bool shouldRepaint(covariant _PrecipitatePainter oldDelegate) =>
      oldDelegate.signature != signature || oldDelegate.origin != origin;
}
