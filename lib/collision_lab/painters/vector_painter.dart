import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../collision_lab_constants.dart';
import '../render/cl_render_data.dart';

class VectorPainter extends CustomPainter {
  VectorPainter({required this.data, this.showVelocityTips = false});

  final ClRenderData data;
  final bool showVelocityTips;

  @override
  void paint(Canvas canvas, Size size) {
    for (final v in data.velocityVectors) {
      _drawArrow(canvas, v.tail, v.tip, v.color, solid: true);
      if (showVelocityTips) {
        _drawTipCircle(canvas, v.tip);
      }
    }
    for (final v in data.momentumVectors) {
      _drawArrow(canvas, v.tail, v.tip, v.color, solid: true);
    }
    if (data.changeInMomentumOpacity > 0.01) {
      canvas.saveLayer(
        Offset.zero & size,
        Paint()..color = Color.fromRGBO(0, 0, 0, data.changeInMomentumOpacity),
      );
      for (final v in data.changeInMomentumVectors) {
        _drawArrow(canvas, v.tail, v.tip, v.color, solid: false, dashed: true);
      }
      canvas.restore();
    }
  }

  void _drawTipCircle(Canvas canvas, Offset tip) {
    final r = CollisionLabConstants.velocityTipCircleRadius;
    canvas.drawCircle(
      tip,
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      tip,
      r,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: 'v',
        style: TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(tip.dx - tp.width / 2, tip.dy - tp.height / 2));
  }

  void _drawArrow(
    Canvas canvas,
    Offset tail,
    Offset tip,
    Color color, {
    required bool solid,
    bool dashed = false,
  }) {
    final delta = tip - tail;
    final len = delta.distance;
    if (len < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (dashed) {
      _dashedLine(canvas, tail, tip, paint);
    } else {
      canvas.drawLine(tail, tip, paint);
    }

    final angle = math.atan2(delta.dy, delta.dx);
    const headLen = 10.0;
    const headAngle = 0.45;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx - headLen * math.cos(angle - headAngle),
        tip.dy - headLen * math.sin(angle - headAngle),
      )
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx - headLen * math.cos(angle + headAngle),
        tip.dy - headLen * math.sin(angle + headAngle),
      );
    canvas.drawPath(path, paint);
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    final delta = b - a;
    final dist = delta.distance;
    if (dist == 0) return;
    final dir = delta / dist;
    const dash = 5.0;
    const gap = 4.0;
    var t = 0.0;
    while (t < dist) {
      final start = a + dir * t;
      final end = a + dir * math.min(t + dash, dist);
      canvas.drawLine(start, end, paint);
      t += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant VectorPainter oldDelegate) => true;
}
