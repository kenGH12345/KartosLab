import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../pl_colors.dart';

/// Orange Reset All — scenery-phet ResetAllButton / ResetShape.
class PlResetAllButton extends StatelessWidget {
  const PlResetAllButton({super.key, required this.onPressed, this.radius = 20.5});

  final VoidCallback onPressed;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final d = radius * 2;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: CustomPaint(
        size: Size(d, d),
        painter: _ResetAllPainter(radius: radius),
      ),
    );
  }
}

class _ResetAllPainter extends CustomPainter {
  _ResetAllPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final disc = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.4),
        radius: 1.05,
        colors: const [
          Color.fromRGBO(255, 190, 90, 1),
          PlColors.resetAll,
          Color.fromRGBO(210, 120, 20, 1),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: radius));
    canvas.drawCircle(c, radius, disc);
    canvas.drawCircle(
      c,
      radius - 0.5,
      Paint()
        ..color = const Color.fromRGBO(160, 90, 15, 1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.save();
    canvas.translate(c.dx, c.dy - 0.0125 * radius);
    final arrow = _resetShapePath(radius);
    canvas.drawPath(arrow, Paint()..color = Colors.white);
    canvas.restore();
  }

  static Path _resetShapePath(double radius) {
    const adj = 0.8;
    final innerR = radius * 0.4 - adj;
    final outerR = radius * 0.625 + adj;
    final headWidth = 2.0 * (outerR - innerR);
    const startAngle = -math.pi * 0.35;
    const endToNeck = -2 * math.pi * 0.85;
    const arrowHeadSpan = -math.pi * 0.18;
    final neckAngle = startAngle + endToNeck;
    final path = Path()
      ..moveTo(innerR * math.cos(startAngle), innerR * math.sin(startAngle))
      ..lineTo(outerR * math.cos(startAngle), outerR * math.sin(startAngle));
    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: outerR),
      startAngle,
      endToNeck,
      false,
    );
    final extrusion = (headWidth - (outerR - innerR)) / 2;
    path
      ..lineTo(
        (outerR + extrusion) * math.cos(neckAngle),
        (outerR + extrusion) * math.sin(neckAngle),
      )
      ..lineTo(
        ((outerR + innerR) * 0.55) * math.cos(neckAngle + arrowHeadSpan),
        ((outerR + innerR) * 0.55) * math.sin(neckAngle + arrowHeadSpan),
      )
      ..lineTo(
        (innerR - extrusion) * math.cos(neckAngle),
        (innerR - extrusion) * math.sin(neckAngle),
      )
      ..lineTo(innerR * math.cos(neckAngle), innerR * math.sin(neckAngle));
    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: innerR),
      neckAngle,
      -endToNeck,
      false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _ResetAllPainter oldDelegate) =>
      oldDelegate.radius != radius;
}
