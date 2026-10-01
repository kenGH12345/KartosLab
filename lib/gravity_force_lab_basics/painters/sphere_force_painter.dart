import 'package:flutter/material.dart';

import '../gflb_colors.dart';
import '../render/gflb_render_data.dart';

/// Draws spheres, force arrows, dashed stems, and optional force labels.
class SphereForcePainter extends CustomPainter {
  SphereForcePainter({required this.render});

  final GflbRenderData render;

  @override
  void paint(Canvas canvas, Size size) {
    _paintMass(
      canvas,
      size,
      center: render.mass1Center,
      radius: render.mass1RadiusView,
      color: render.mass1Color,
      label: render.mass1Label,
      constantSize: render.constantSize,
      arrowTipDx: render.arrow1TipDx,
      arrowY: render.arrow1Y,
      arrowColor: GflbColors.forceArrow1,
    );
    _paintMass(
      canvas,
      size,
      center: render.mass2Center,
      radius: render.mass2RadiusView,
      color: render.mass2Color,
      label: render.mass2Label,
      constantSize: render.constantSize,
      arrowTipDx: render.arrow2TipDx,
      arrowY: render.arrow2Y,
      arrowColor: GflbColors.forceArrow2,
    );
  }

  void _paintMass(
    Canvas canvas,
    Size size, {
    required Offset center,
    required double radius,
    required Color color,
    required String label,
    required bool constantSize,
    required double arrowTipDx,
    required double arrowY,
    required Color arrowColor,
  }) {
    // Dashed stem from sphere to arrow height.
    final stemPaint = Paint()
      ..color = arrowColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    _drawDashedLine(
      canvas,
      Offset(center.dx, center.dy - 4),
      Offset(center.dx, arrowY),
      stemPaint,
    );

    // Sphere with radial highlight.
    final highlight = Color.lerp(color, Colors.white, 0.5)!;
    final gradient = RadialGradient(
      center: const Alignment(-0.6, -0.6),
      radius: 1,
      colors: [highlight, color],
    );
    final rect = Rect.fromCircle(center: center, radius: radius);
    final fill = Paint()..shader = gradient.createShader(rect);
    canvas.drawCircle(center, radius, fill);
    if (constantSize) {
      final stroke = Paint()
        ..color = Color.lerp(color, Colors.black, 0.15)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, radius, stroke);
    }

    // Center dot.
    canvas.drawCircle(center, 2, Paint()..color = Colors.black);

    // Label under sphere.
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 50);
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy + radius + 1),
    );

    // Force arrow at arrowY.
    _drawArrow(
      canvas,
      Offset(center.dx, arrowY),
      Offset(center.dx + arrowTipDx, arrowY),
      arrowColor,
    );

    if (render.showForceValues) {
      final ftp = TextPainter(
        text: TextSpan(
          text: render.forceLabel,
          style: const TextStyle(
            fontSize: 16,
            color: GflbColors.forceLabel,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 300);
      final labelCenter = Offset(center.dx, arrowY - 20);
      var left = labelCenter.dx - ftp.width / 2;
      left = left.clamp(10.0, size.width - ftp.width - 10).toDouble();
      final bgRect = Rect.fromLTWH(
        left - 2,
        labelCenter.dy - ftp.height / 2 - 1,
        ftp.width + 4,
        ftp.height + 2,
      );
      canvas.drawRect(
        bgRect,
        Paint()..color = GflbColors.forceLabelBackground,
      );
      ftp.paint(canvas, Offset(left, labelCenter.dy - ftp.height / 2));
    }
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);

    final dx = to.dx - from.dx;
    if (dx.abs() < 0.5) return;
    final dir = dx.sign;
    const headLen = 10.4;
    const headWidth = 10.4;
    final tip = to;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - dir * headLen, tip.dy - headWidth / 2)
      ..lineTo(tip.dx - dir * headLen, tip.dy + headWidth / 2)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 4.0;
    const gap = 4.0;
    final total = (b - a).distance;
    if (total < 1) return;
    final dir = (b - a) / total;
    var drawn = 0.0;
    while (drawn < total) {
      final start = a + dir * drawn;
      final end = a + dir * (drawn + dash).clamp(0, total);
      canvas.drawLine(start, end, paint);
      drawn += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant SphereForcePainter oldDelegate) =>
      oldDelegate.render != render;
}
