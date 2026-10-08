/// Oblique (near-3D) polarization angle indicator.
/// Mirrors `ObliquePolarizationAngleIndicator.ts` (V / H / Propagation axes).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../qm_photons_colors.dart';
import 'package:kratos/quantum_measurement/qm_strings.dart';

class AngleVisualization extends StatelessWidget {
  const AngleVisualization({
    super.key,
    required this.angleDegrees,
    this.radius = 48,
    this.showAxesLabels = true,
  });

  /// Null ⇒ unpolarized (no arrow).
  final double? angleDegrees;
  final double radius;
  final bool showAxesLabels;

  @override
  Widget build(BuildContext context) {
    final side = radius * 2.6;
    return SizedBox(
      width: side,
      height: side,
      child: CustomPaint(
        size: Size(side, side),
        painter: _ObliqueAnglePainter(
          angleDegrees: angleDegrees,
          radius: radius,
          showAxesLabels: showAxesLabels,
        ),
      ),
    );
  }
}

class _ObliqueAnglePainter extends CustomPainter {
  _ObliqueAnglePainter({
    required this.angleDegrees,
    required this.radius,
    required this.showAxesLabels,
  });

  final double? angleDegrees;
  final double radius;
  final bool showAxesLabels;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2 + 4);

    final vEnd = Offset(c.dx, c.dy - radius * 0.95);
    final hEnd = Offset(c.dx + radius * 0.85, c.dy + radius * 0.25);
    final propEnd = Offset(c.dx + radius * 0.55, c.dy - radius * 0.15);

    final axisPaint = Paint()
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    axisPaint.color = QmPhotonsColors.verticalPolarization;
    canvas.drawLine(c, vEnd, axisPaint);
    axisPaint.color = QmPhotonsColors.horizontalPolarization;
    canvas.drawLine(c, hEnd, axisPaint);

    final dash = Paint()
      ..color = Colors.black45
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    _dashedLine(canvas, c, propEnd, dash);

    canvas.drawOval(
      Rect.fromCenter(
        center: c,
        width: radius * 1.7,
        height: radius * 1.5,
      ),
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    if (showAxesLabels) {
      final tp = TextPainter(textDirection: TextDirection.ltr);
      void lab(String s, Offset o, Color color) {
        tp.text = TextSpan(
          text: s,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        );
        tp.layout();
        tp.paint(canvas, o);
      }

      lab(
        'V',
        Offset(vEnd.dx - 4, vEnd.dy - 14),
        QmPhotonsColors.verticalPolarization,
      );
      lab(
        'H',
        Offset(hEnd.dx + 4, hEnd.dy - 4),
        QmPhotonsColors.horizontalPolarization,
      );
      lab(QmStrings.propagation, Offset(propEnd.dx + 2, propEnd.dy - 12), Colors.black54);
    }

    if (angleDegrees == null) {
      final p = Paint()
        ..color = Colors.black45
        ..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(c.dx - 10, c.dy),
        Offset(c.dx + 10, c.dy),
        p,
      );
      canvas.drawLine(
        Offset(c.dx, c.dy - 10),
        Offset(c.dx, c.dy + 10),
        p,
      );
      return;
    }

    // 0° = H, 90° = V → blend into oblique V/H basis.
    final rad = angleDegrees! * math.pi / 180;
    const vUnitX = 0.0, vUnitY = -1.0;
    final hLen = math.sqrt(0.85 * 0.85 + 0.25 * 0.25);
    final hUnitX = 0.85 / hLen, hUnitY = 0.25 / hLen;
    final dirX = vUnitX * math.sin(rad) + hUnitX * math.cos(rad);
    final dirY = vUnitY * math.sin(rad) + hUnitY * math.cos(rad);
    final len = radius * 0.7;
    final a = Offset(c.dx - dirX * len, c.dy - dirY * len);
    final b = Offset(c.dx + dirX * len, c.dy + dirY * len);
    canvas.drawLine(
      a,
      b,
      Paint()
        ..color = QmPhotonsColors.photonStroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dashLen = 4.0;
    const gap = 3.0;
    final total = (b - a).distance;
    if (total <= 0) return;
    final dx = (b.dx - a.dx) / total;
    final dy = (b.dy - a.dy) / total;
    var d = 0.0;
    while (d < total) {
      final start = Offset(a.dx + dx * d, a.dy + dy * d);
      final endD = math.min(d + dashLen, total);
      final end = Offset(a.dx + dx * endD, a.dy + dy * endD);
      canvas.drawLine(start, end, paint);
      d += dashLen + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _ObliqueAnglePainter oldDelegate) =>
      oldDelegate.angleDegrees != angleDegrees ||
      oldDelegate.radius != radius ||
      oldDelegate.showAxesLabels != showAxesLabels;
}
