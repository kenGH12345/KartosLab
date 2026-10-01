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
      final lidRight = right;
      final lidTop = top - 5;
      final lidH = wall + 6;

      // Thick gray lid bar (PhET LidNode base) — anchored to container right.
      final lidRect = RRect.fromRectAndRadius(
        Rect.fromLTRB(lidLeft, lidTop, lidRight, lidTop + lidH),
        const Radius.circular(1),
      );
      canvas.drawRRect(
        lidRect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD4D4D4), Color(0xFF9A9A9A), Color(0xFF7A7A7A)],
          ).createShader(lidRect.outerRect),
      );

      // Handle at RIGHT end of lid (PhET LidNode: handle.right = base.right − inset).
      _paintLidHandle(canvas, Offset(lidRight - 10, lidTop));
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

    if (state.widthVisible) {
      final tp = TextPainter(
        text: TextSpan(
          text: '${(state.widthPm / 1000).toStringAsFixed(1)} nm',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset((left + right) / 2 - tp.width / 2, bottom + 6));
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

  void _paintLidHandle(Canvas canvas, Offset anchor) {
    // L-bracket attachment under the grip (PhET HandleNode, right attachment).
    final bracket = Path()
      ..moveTo(anchor.dx - 2, anchor.dy + 2)
      ..lineTo(anchor.dx - 2, anchor.dy - 10)
      ..lineTo(anchor.dx + 6, anchor.dy - 10);
    canvas.drawPath(
      bracket,
      Paint()
        ..color = const Color(0xFF8A8A8A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // Horizontal ribbed grip above the lid (scale ~0.4 of HandleNode).
    final grip = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(anchor.dx + 2, anchor.dy - 18),
        width: 36,
        height: 16,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      grip,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8E8E8), Color(0xFFA0A0A0), Color(0xFF707070)],
        ).createShader(grip.outerRect),
    );
    canvas.drawRRect(
      grip,
      Paint()
        ..color = const Color(0xFF555555)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // Finger indents
    final indent = Paint()
      ..color = const Color(0xFF5A5A5A)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (final dx in [-10.0, -3.0, 4.0, 11.0]) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(anchor.dx + 2 + dx, anchor.dy - 18),
          width: 6,
          height: 10,
        ),
        -2.4,
        1.6,
        false,
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
