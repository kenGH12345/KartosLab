/// FlatPolarizationAngleIndicator — polarization in V–H plane, propagation into page.
/// Source: `js/photons/view/FlatPolarizationAngleIndicator.ts`
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../qm_photons_colors.dart';

class FlatPolarizationAngleIndicator extends StatelessWidget {
  const FlatPolarizationAngleIndicator({
    super.key,
    required this.angleDegrees,
    this.scale = 1.2,
  });

  /// Null ⇒ unpolarized (filled circle, no arrow).
  final double? angleDegrees;
  final double scale;

  @override
  Widget build(BuildContext context) {
    const axisLength = 50.0;
    final side = (axisLength * 2 + 36) * scale;
    return SizedBox(
      width: side,
      height: side + 18,
      child: CustomPaint(
        size: Size(side, side + 18),
        painter: _FlatPainter(
          angleDegrees: angleDegrees,
          scale: scale,
        ),
      ),
    );
  }
}

class _FlatPainter extends CustomPainter {
  _FlatPainter({required this.angleDegrees, required this.scale});

  final double? angleDegrees;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2 - 6);
    final axisLen = 50.0 * scale;
    final unit = axisLen * 0.75;

    final axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    // Double-headed V (vertical) and H (horizontal) axes
    _doubleArrow(canvas, Offset(c.dx, c.dy + axisLen), Offset(c.dx, c.dy - axisLen), axisPaint);
    _doubleArrow(canvas, Offset(c.dx - axisLen, c.dy), Offset(c.dx + axisLen, c.dy), axisPaint);

    final tp = TextPainter(textDirection: TextDirection.ltr);
    void lab(String s, Offset o, Color color) {
      tp.text = TextSpan(
        text: s,
        style: TextStyle(
          fontSize: 13 * scale.clamp(0.8, 1.4),
          fontWeight: FontWeight.bold,
          color: color,
        ),
      );
      tp.layout();
      tp.paint(canvas, o);
    }

    lab('V', Offset(c.dx - 6, c.dy - axisLen - 16), QmPhotonsColors.verticalPolarization);
    lab('H', Offset(c.dx + axisLen + 2, c.dy - 7), QmPhotonsColors.horizontalPolarization);

    final circleFill = angleDegrees == null
        ? QmPhotonsColors.photonStroke.withValues(alpha: 0.35)
        : const Color(0xFFDDDDDD).withValues(alpha: 0.35);
    canvas.drawCircle(c, unit, Paint()..color = circleFill);
    canvas.drawCircle(
      c,
      unit,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Propagation-into-page symbol (circle with X) at center
    canvas.drawCircle(
      c,
      unit * 0.175,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    final xR = unit * 0.1;
    final xPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.2;
    canvas.drawLine(c + Offset(-xR, -xR), c + Offset(xR, xR), xPaint);
    canvas.drawLine(c + Offset(-xR, xR), c + Offset(xR, -xR), xPaint);

    if (angleDegrees != null) {
      // 0° = H (right), 90° = V (up). Screen Y down ⇒ use -sin for up.
      final rad = angleDegrees! * math.pi / 180;
      final dx = math.cos(rad) * unit;
      final dy = -math.sin(rad) * unit;
      final arrow = Paint()
        ..color = QmPhotonsColors.photonStroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      _doubleArrow(canvas, c - Offset(dx, dy), c + Offset(dx, dy), arrow, head: 7);

      final theta = 'θ = ${angleDegrees!.round()}°';
      tp.text = TextSpan(
        text: theta,
        style: TextStyle(fontSize: 12 * scale.clamp(0.8, 1.3), color: Colors.black87),
      );
      tp.layout();
      // Place near the tip in the first quadrant-ish
      final tip = c + Offset(dx * 0.55, dy * 0.55);
      tp.paint(canvas, tip + const Offset(6, -14));
    }
  }

  void _doubleArrow(
    Canvas canvas,
    Offset a,
    Offset b,
    Paint paint, {
    double head = 4,
  }) {
    canvas.drawLine(a, b, paint);
    _arrowHead(canvas, b, a, paint, head);
    _arrowHead(canvas, a, b, paint, head);
  }

  void _arrowHead(Canvas canvas, Offset tip, Offset from, Paint paint, double head) {
    final ang = math.atan2(tip.dy - from.dy, tip.dx - from.dx);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx - head * math.cos(ang - 0.4),
        tip.dy - head * math.sin(ang - 0.4),
      )
      ..lineTo(
        tip.dx - head * math.cos(ang + 0.4),
        tip.dy - head * math.sin(ang + 0.4),
      )
      ..close();
    canvas.drawPath(path, Paint()..color = paint.color);
  }

  @override
  bool shouldRepaint(covariant _FlatPainter oldDelegate) =>
      oldDelegate.angleDegrees != angleDegrees || oldDelegate.scale != scale;
}
