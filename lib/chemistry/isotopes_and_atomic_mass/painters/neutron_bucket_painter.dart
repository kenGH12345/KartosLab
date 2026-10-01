/// Neutron SphereBucket hole + front (scenery-phet BucketHole / BucketFront).
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

enum BucketPaintLayer { hole, front }

class NeutronBucketPainter extends CustomPainter {
  NeutronBucketPainter({
    required this.layer,
    required this.width,
    required this.height,
    this.label = 'neutrons',
  });

  final BucketPaintLayer layer;
  final double width;
  final double height;
  final String label;

  static const double holeEllipseHeightProportion = 0.25;

  @override
  void paint(Canvas canvas, Size size) {
    final holeRy = height * holeEllipseHeightProportion / 2;
    final holeCenter = Offset(size.width / 2, holeRy + 2);
    final rx = width / 2;

    if (layer == BucketPaintLayer.hole) {
      final holePaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(holeCenter.dx - rx, holeCenter.dy),
          Offset(holeCenter.dx + rx, holeCenter.dy),
          [const Color(0xFF555555), const Color(0xFF222222)],
        );
      canvas.drawOval(
        Rect.fromCenter(
          center: holeCenter,
          width: width,
          height: holeRy * 2,
        ),
        holePaint,
      );
      return;
    }

    // Front: trapezoid body + top ellipse rim
    final topY = holeCenter.dy;
    final bottomY = size.height - 4;
    final path = Path()
      ..moveTo(holeCenter.dx - rx * 0.92, topY)
      ..lineTo(holeCenter.dx - rx * 0.75, bottomY)
      ..lineTo(holeCenter.dx + rx * 0.75, bottomY)
      ..lineTo(holeCenter.dx + rx * 0.92, topY)
      ..close();

    final bodyPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(holeCenter.dx - rx, topY),
        Offset(holeCenter.dx + rx, topY),
        [
          const Color(0xFF9E9E9E),
          const Color(0xFF616161),
          const Color(0xFF424242),
        ],
        [0.0, 0.45, 1.0],
      );
    canvas.drawPath(path, bodyPaint);

    canvas.drawOval(
      Rect.fromCenter(
        center: holeCenter,
        width: width * 0.95,
        height: holeRy * 2,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF757575),
    );

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width * 0.85);
    tp.paint(
      canvas,
      Offset(
        holeCenter.dx - tp.width / 2,
        (topY + bottomY) / 2 - tp.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant NeutronBucketPainter oldDelegate) {
    return oldDelegate.layer != layer ||
        oldDelegate.width != width ||
        oldDelegate.height != height ||
        oldDelegate.label != label;
  }
}
