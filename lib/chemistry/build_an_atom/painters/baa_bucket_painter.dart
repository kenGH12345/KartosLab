/// scenery-phet BucketHole / BucketFront for BAA particle buckets.
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

enum BaaBucketPaintLayer { hole, front }

class BaaBucketPainter extends CustomPainter {
  BaaBucketPainter({
    required this.layer,
    required this.width,
    required this.height,
    required this.baseColor,
    required this.label,
  });

  final BaaBucketPaintLayer layer;
  final double width;
  final double height;
  final Color baseColor;
  final String label;

  static const double holeEllipseHeightProportion = 0.25;

  @override
  void paint(Canvas canvas, Size size) {
    final holeRy = height * holeEllipseHeightProportion / 2;
    final holeCenter = Offset(size.width / 2, holeRy + 2);
    final rx = width / 2;

    if (layer == BaaBucketPaintLayer.hole) {
      final dark = Color.lerp(baseColor, Colors.black, 0.55)!;
      final mid = Color.lerp(baseColor, Colors.black, 0.35)!;
      canvas.drawOval(
        Rect.fromCenter(center: holeCenter, width: width, height: holeRy * 2),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(holeCenter.dx - rx, holeCenter.dy),
            Offset(holeCenter.dx + rx, holeCenter.dy),
            [mid, dark],
          ),
      );
      return;
    }

    final topY = holeCenter.dy;
    final bottomY = size.height - 4;
    final path = Path()
      ..moveTo(holeCenter.dx - rx * 0.92, topY)
      ..lineTo(holeCenter.dx - rx * 0.75, bottomY)
      ..lineTo(holeCenter.dx + rx * 0.75, bottomY)
      ..lineTo(holeCenter.dx + rx * 0.92, topY)
      ..close();

    final light = Color.lerp(baseColor, Colors.white, 0.25)!;
    final dark = Color.lerp(baseColor, Colors.black, 0.25)!;
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(holeCenter.dx - rx, topY),
          Offset(holeCenter.dx + rx, topY),
          [light, baseColor, dark],
          const [0.0, 0.45, 1.0],
        ),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: holeCenter,
        width: width * 0.95,
        height: holeRy * 2,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = dark,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
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
  bool shouldRepaint(covariant BaaBucketPainter oldDelegate) =>
      oldDelegate.layer != layer ||
      oldDelegate.baseColor != baseColor ||
      oldDelegate.label != label ||
      oldDelegate.width != width ||
      oldDelegate.height != height;
}
