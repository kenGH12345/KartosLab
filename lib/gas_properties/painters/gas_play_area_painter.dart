import 'package:flutter/material.dart';

import '../gas_properties_colors.dart';
import '../render/gas_render_state.dart';
import '../transform/gas_coordinate_transform.dart';
import 'shaded_sphere.dart';

/// Container walls + particles + optional width / wall-velocity overlays.
class GasPlayAreaPainter extends CustomPainter {
  GasPlayAreaPainter({
    required this.state,
    required this.transform,
    this.dimParticles = false,
  });

  final GasRenderState state;
  final GasCoordinateTransform transform;
  final bool dimParticles;

  @override
  void paint(Canvas canvas, Size size) {
    final t = transform;
    final left = t.modelToViewX(state.containerLeft);
    final right = t.modelToViewX(state.containerRight);
    final top = t.modelToViewY(state.containerTop);
    final bottom = t.modelToViewY(state.containerBottom);
    final wall = t.modelToViewDelta(state.wallThickness).clamp(2.0, 6.0);

    canvas.drawRect(
      Rect.fromLTRB(left, top, right, bottom),
      Paint()..color = const Color(0xFF0B1220),
    );

    final wallPaint = Paint()
      ..color = const Color(GasPropertiesColors.containerStroke)
      ..style = PaintingStyle.stroke
      ..strokeWidth = wall
      ..strokeCap = StrokeCap.square;

    canvas.drawPath(
      Path()
        ..moveTo(left, top)
        ..lineTo(left, bottom)
        ..lineTo(right, bottom)
        ..lineTo(right, top),
      wallPaint,
    );

    if (state.lidIsOn) {
      final lidLeftModel = state.containerRight - state.lidWidth;
      final lidLeft = t.modelToViewX(lidLeftModel);
      canvas.drawLine(
        Offset(lidLeft, top),
        Offset(right, top),
        Paint()
          ..color = const Color(0xFFB0B0B0)
          ..strokeWidth = wall + 2,
      );
      // Handle on the LEFT edge of the lid — same as Gases Intro.
      _paintLidHandle(canvas, lidLeft + 18, top);
    }

    // Resize handle on left wall
    final midY = (top + bottom) / 2;
    _paintHandle(canvas, left, midY);

    final opacity = dimParticles ? 0.6 : 1.0;
    for (final p in state.particles) {
      paintShadedSphere(
        canvas,
        t.modelToView(p.x, p.y),
        t.modelToViewDelta(p.radius),
        mainColor: p.color.withValues(alpha: opacity),
        highlightColor: p.highlight.withValues(alpha: opacity),
      );
    }

    if (state.wallVelocityVisible && state.leftWallVelocityX.abs() > 1e-6) {
      final vx = state.leftWallVelocityX;
      final arrowLen = (vx * 0.05).clamp(-40.0, 40.0);
      final y = midY - 40;
      final paint = Paint()
        ..color = const Color(0xFF39B54A)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(left, y), Offset(left + arrowLen, y), paint);
      canvas.drawCircle(Offset(left + arrowLen, y), 4, paint);
    }

    // Hose marker
    canvas.drawCircle(
      Offset(right + 4, t.modelToViewY(state.containerBottom + 8750 / 5)),
      3,
      Paint()..color = const Color(0xFF94A3B8),
    );
  }

  void _paintLidHandle(Canvas canvas, double x, double lidY) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, lidY - 10), width: 28, height: 14),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(245, 245, 245, 1),
            Color.fromRGBO(160, 160, 160, 1),
          ],
        ).createShader(rect.outerRect),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    final indent = Paint()
      ..color = const Color(0x66000000)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final dx = rect.outerRect.left + 6 + i * 5.0;
      canvas.drawLine(
        Offset(dx, rect.outerRect.top + 3),
        Offset(dx, rect.outerRect.bottom - 3),
        indent,
      );
    }
  }

  void _paintHandle(Canvas canvas, double wallX, double midY) {
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(wallX - 14, midY), width: 18, height: 48),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      body,
      Paint()..color = const Color(GasPropertiesColors.resizeHandle),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant GasPlayAreaPainter oldDelegate) => true;
}
