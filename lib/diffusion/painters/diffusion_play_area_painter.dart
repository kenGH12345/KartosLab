import 'package:flutter/material.dart';

import '../diffusion_constants.dart';
import '../model/diffusion_model.dart';
import '../model/particle.dart';

/// Container + particles + optional COM markers.
class DiffusionPlayAreaPainter extends CustomPainter {
  DiffusionPlayAreaPainter({required this.model});

  final DiffusionModel model;

  @override
  void paint(Canvas canvas, Size size) {
    final c = model.container;
    final sx = size.width / c.width;
    final sy = size.height / c.height;

    // Interior
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF1A1A1A),
    );

    // Walls
    final wall = Paint()
      ..color = const Color(0xFFBDBDBD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (c.wallThickness * sx).clamp(2.0, 6.0);
    canvas.drawRect(Offset.zero & size, wall);

    // Divider
    if (c.hasDivider) {
      final dx = c.dividerX * sx;
      final tw = (c.dividerThickness * sx).clamp(2.0, 8.0);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(dx, size.height / 2),
          width: tw,
          height: size.height,
        ),
        Paint()..color = const Color(0xFFE0E0E0),
      );
    }

    void drawParticle(DiffusionParticle p) {
      final cx = p.x * sx;
      // model y up → view y down
      final cy = size.height - p.y * sy;
      final r = (p.radius * sx).clamp(2.0, 40.0);
      final paint = Paint()..color = Color(p.colorArgb);
      canvas.drawCircle(Offset(cx, cy), r, paint);
      canvas.drawCircle(
        Offset(cx - r * 0.3, cy - r * 0.3),
        r * 0.35,
        Paint()..color = Color(p.highlightArgb),
      );
    }

    for (final p in model.particles1) {
      drawParticle(p);
    }
    for (final p in model.particles2) {
      drawParticle(p);
    }

    if (model.centerOfMassVisible) {
      void drawCom(double? x, int color) {
        if (x == null) return;
        final vx = x * sx;
        canvas.drawLine(
          Offset(vx, 0),
          Offset(vx, size.height),
          Paint()
            ..color = Color(color).withValues(alpha: 0.85)
            ..strokeWidth = 2,
        );
      }

      drawCom(model.centerOfMass1, DiffusionConstants.particle1Color);
      drawCom(model.centerOfMass2, DiffusionConstants.particle2Color);
    }

    if (model.scaleVisible) {
      final tp = TextPainter(
        text: const TextSpan(
          text: '16 nm',
          style: TextStyle(color: Colors.white70, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width / 2 - tp.width / 2, size.height - 18));
    }
  }

  @override
  bool shouldRepaint(covariant DiffusionPlayAreaPainter oldDelegate) => true;
}
