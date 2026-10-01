import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../transform/plinko_mvt.dart';

/// Hopper funnel — `Hopper.js`.
class HopperPainter extends CustomPainter {
  HopperPainter({
    required this.mvt,
    required this.numberOfRows,
  });

  final PlinkoMvt mvt;
  final int numberOfRows;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = mvt.layoutScale;
    final topWidth = 70 * scale;
    final hopperThickness = 28 * scale;
    final rimThickness = 3 * scale;
    final extraSpace = 12 * scale;
    final bottomWidth =
        45 * scale * 11 / (5 + math.min(6, numberOfRows));

    final cx = mvt.viewBoardLeft + mvt.viewBoardWidth / 2;
    final bottomY = mvt.viewBoardTop - 10 * scale;
    final topY = bottomY - hopperThickness;

    final hopperPath = Path()
      ..moveTo(cx, bottomY)
      ..lineTo(cx - bottomWidth / 2, bottomY)
      ..lineTo(cx - bottomWidth / 2 - extraSpace, topY)
      ..lineTo(cx + bottomWidth / 2 + extraSpace, topY)
      ..lineTo(cx + bottomWidth / 2, bottomY)
      ..close();

    final hopperPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Colors.black,
          Color.fromRGBO(136, 136, 136, 1),
          Colors.black,
        ],
        stops: [0, 0.47, 1],
      ).createShader(
        Rect.fromCenter(
          center: Offset(cx, (topY + bottomY) / 2),
          width: topWidth,
          height: hopperThickness,
        ),
      );

    canvas.drawPath(hopperPath, hopperPaint);

    final rimPath = Path()
      ..moveTo(cx - bottomWidth / 2, bottomY)
      ..lineTo(cx + bottomWidth / 2, bottomY)
      ..lineTo(cx + bottomWidth / 2, bottomY + rimThickness)
      ..lineTo(cx - bottomWidth / 2, bottomY + rimThickness)
      ..close();

    final rimPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Colors.red,
          Colors.white,
          Colors.red,
        ],
        stops: [0, 0.47, 1],
      ).createShader(
        Rect.fromLTWH(
          cx - bottomWidth / 2,
          bottomY,
          bottomWidth,
          rimThickness,
        ),
      );
    canvas.drawPath(rimPath, rimPaint);
  }

  @override
  bool shouldRepaint(covariant HopperPainter oldDelegate) =>
      oldDelegate.numberOfRows != numberOfRows ||
      oldDelegate.mvt.viewBoardWidth != mvt.viewBoardWidth;
}
