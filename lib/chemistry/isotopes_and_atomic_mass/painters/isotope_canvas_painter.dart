/// Single Canvas painter for small / Nature Mix isotopes — PhET IsotopeCanvasNode.
library;

import 'package:flutter/material.dart';

import '../model/get_isotope_color.dart';
import '../model/mix_particle.dart';
import '../transform/iaam_transform.dart';

class IsotopeCanvasPainter extends CustomPainter {
  IsotopeCanvasPainter({
    required this.particles,
    required this.atomicNumber,
    required this.transform,
    required this.chamberViewRect,
  });

  final List<MixParticle> particles;
  final int atomicNumber;
  final IaamTransform transform;
  final Rect chamberViewRect;

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) return;

    canvas.save();
    canvas.clipRect(chamberViewRect);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black;

    // Assume uniform radius within a frame (PhET).
    final r = transform.modelToViewDelta(particles.first.radius);

    for (final p in particles) {
      final v = transform.modelToView(p.x, p.y);
      final color = getIsotopeColorForMass(
        atomicNumber: atomicNumber,
        massNumber: p.massNumber,
      );
      canvas.drawCircle(v, r, Paint()..color = color);
      canvas.drawCircle(v, r, stroke);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant IsotopeCanvasPainter oldDelegate) {
    return oldDelegate.particles != particles ||
        oldDelegate.atomicNumber != atomicNumber ||
        oldDelegate.chamberViewRect != chamberViewRect;
  }
}
