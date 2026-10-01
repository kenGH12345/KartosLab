import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/abs_beaker.dart';
import '../model/abs_colors.dart';
import '../model/abs_particle_field.dart';
import 'abs_assets.dart';
import 'abs_beaker_painter.dart';
import 'abs_particle_painter.dart';

/// Magnifying glass + particles — PhET `ParticlesNode.ts`.
class AbsParticlesLayer extends StatelessWidget {
  const AbsParticlesLayer({
    super.key,
    required this.beaker,
    required this.particles,
    required this.showSolvent,
    required this.visible,
  });

  final AbsBeaker beaker;
  final List<AbsParticleInstance> particles;
  final bool showSolvent;
  final bool visible;

  static const double lensLineWidth = 8;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final lensRadius = absLensRadius(beaker);
    final center = absLensCenter(beaker);

    return Positioned.fill(
      child: CustomPaint(
        painter: _MagnifierChromePainter(center: center, radius: lensRadius),
        child: Stack(
          children: [
            Positioned(
              left: center.dx - lensRadius,
              top: center.dy - lensRadius,
              width: lensRadius * 2,
              height: lensRadius * 2,
              child: ClipOval(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: AbsColors.opaqueSolutionColor),
                    if (showSolvent)
                      Opacity(
                        opacity: 0.6,
                        child: Image.asset(
                          AbsAssets.solvent,
                          fit: BoxFit.cover,
                        ),
                      ),
                    CustomPaint(
                      painter: _ParticlesCanvasPainter(
                        particles: particles,
                        lensRadius: lensRadius,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MagnifierChromePainter extends CustomPainter {
  _MagnifierChromePainter({required this.center, required this.radius});

  final Offset center;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Handle
    final handle = RRect.fromRectAndRadius(
      Rect.fromLTWH(radius + 2, -radius / 7, radius * 0.9, radius / 4),
      const Radius.circular(5),
    );
    canvas.save();
    canvas.rotate(math.pi / 6);
    canvas.drawRRect(
      handle,
      Paint()..color = AbsColors.magnifyingGlassHandleFill,
    );
    canvas.drawRRect(
      handle,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.restore();

    // Lens stroke
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = AbsParticlesLayer.lensLineWidth,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MagnifierChromePainter oldDelegate) =>
      oldDelegate.center != center || oldDelegate.radius != radius;
}

class _ParticlesCanvasPainter extends CustomPainter {
  _ParticlesCanvasPainter({
    required this.particles,
    required this.lensRadius,
  });

  final List<AbsParticleInstance> particles;
  final double lensRadius;

  @override
  void paint(Canvas canvas, Size size) {
    // Local origin at lens center.
    canvas.translate(lensRadius, lensRadius);
    for (final p in particles) {
      AbsParticlePainter.paintKey(canvas, p.key, p.position);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesCanvasPainter oldDelegate) =>
      !identical(oldDelegate.particles, particles);
}
