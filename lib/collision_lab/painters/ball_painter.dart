import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../render/cl_render_data.dart';

/// Balls + COM. Clipped to play-area like PhET `BallNode` clipArea.
/// Vectors are painted separately and are NOT clipped.
class BallPainter extends CustomPainter {
  BallPainter({required this.data});

  final ClRenderData data;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(data.playAreaRect);

    for (final trail in data.pathTrails) {
      if (trail.points.length < 2) continue;
      final path = Path()..moveTo(trail.points.first.dx, trail.points.first.dy);
      for (var i = 1; i < trail.points.length; i++) {
        path.lineTo(trail.points[i].dx, trail.points[i].dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = trail.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    for (final ball in data.balls) {
      _paintBall(canvas, ball);
    }

    final com = data.comPosition;
    if (data.comVisible && com != null) {
      final paint = Paint()
        ..color = const Color.fromRGBO(70, 70, 70, 1)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      const s = 7.0;
      canvas.drawLine(
          Offset(com.dx - s, com.dy - s), Offset(com.dx + s, com.dy + s), paint);
      canvas.drawLine(
          Offset(com.dx - s, com.dy + s), Offset(com.dx + s, com.dy - s), paint);
    }

    canvas.restore();
  }

  void _paintBall(Canvas canvas, ClBallRender ball) {
    final r = ball.radius;
    final c = ball.center;
    final gradient = RadialGradient(
      center: const Alignment(-0.35, -0.4),
      radius: 1.05,
      colors: [
        Color.lerp(ball.color, Colors.white, 0.55)!,
        ball.color,
        Color.lerp(ball.color, Colors.black, 0.25)!,
      ],
      stops: const [0.0, 0.55, 1.0],
    );
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()..shader = gradient.createShader(rect),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    if (ball.rotation.abs() > 1e-6) {
      final mark = Offset(
        c.dx + math.cos(ball.rotation) * r * 0.65,
        c.dy + math.sin(ball.rotation) * r * 0.65,
      );
      canvas.drawLine(
        c,
        mark,
        Paint()
          ..color = Colors.black54
          ..strokeWidth = 1.5,
      );
    }

    final luminance = ball.color.computeLuminance();
    final labelColor = luminance > 0.55 ? Colors.black : Colors.white;
    final tp = TextPainter(
      text: TextSpan(
        text: ball.label,
        style: TextStyle(
          color: labelColor,
          fontSize: math.max(11, r * 0.7),
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));

    if (ball.valueLabel != null) {
      final vp = TextPainter(
        text: TextSpan(
          text: ball.valueLabel,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      vp.paint(canvas, Offset(c.dx + r + 4, c.dy - vp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant BallPainter oldDelegate) => true;
}
