import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/intro_ball.dart';
import '../plinko_colors.dart';
import '../plinko_constants.dart';
import '../transform/plinko_mvt.dart';

/// Shared cylinder metrics — one x/y/w/h relationship for top → body → bottom.
class CylinderGeometry {
  CylinderGeometry({
    required this.cx,
    required this.topY,
    required this.ellipseW,
    required this.ellipseH,
    required this.cylinderH,
  });

  final double cx;
  final double topY;
  final double ellipseW;
  final double ellipseH;
  final double cylinderH;

  double get hw => ellipseW / 2;
  double get topCenterY => topY + ellipseH / 2;
  double get bottomCenterY => topCenterY + cylinderH;

  Rect get topOval => Rect.fromCenter(
        center: Offset(cx, topCenterY),
        width: ellipseW,
        height: math.max(ellipseH, 2),
      );

  Rect get bottomOval => Rect.fromCenter(
        center: Offset(cx, bottomCenterY),
        width: ellipseW,
        height: math.max(ellipseH, 2),
      );

  /// Front side path — `CylindersFrontNode.js` sideShape.
  Path get sidePath {
    final eh = math.max(ellipseH, 2.0);
    return Path()
      ..moveTo(cx - hw, topCenterY)
      ..lineTo(cx - hw, bottomCenterY)
      // bottom ellipticalArc: from π → 0, anticlockwise (lower half)
      ..arcTo(
        Rect.fromCenter(
          center: Offset(cx, bottomCenterY),
          width: ellipseW,
          height: eh,
        ),
        math.pi,
        -math.pi,
        false,
      )
      ..lineTo(cx + hw, topCenterY)
      // top ellipticalArc: from 0 → π (upper half of opening)
      ..arcTo(
        Rect.fromCenter(
          center: Offset(cx, topCenterY),
          width: ellipseW,
          height: eh,
        ),
        0,
        math.pi,
        false,
      )
      ..close();
  }
}

/// Intro cylinders — `CylindersBackNode.js` + `CylindersFrontNode.js`.
class CylindersPainter extends CustomPainter {
  CylindersPainter({
    required this.cylinderInfo,
    required this.mvt,
    required this.numberOfRows,
    this.frontOnly = false,
    this.backOnly = false,
  });

  final CylinderInfo cylinderInfo;
  final PlinkoMvt mvt;
  final int numberOfRows;
  final bool frontOnly;
  final bool backOnly;

  @override
  void paint(Canvas canvas, Size size) {
    final nBins = numberOfRows + 1;
    const boundsWidth =
        PlinkoConstants.histogramMaxX - PlinkoConstants.histogramMinX;
    final ellipseW = mvt.modelToViewDeltaX(cylinderInfo.cylinderWidth);
    final ellipseH =
        mvt.modelToViewDeltaY(cylinderInfo.ellipseHeight).abs();
    final cylinderH =
        mvt.modelToViewDeltaY(cylinderInfo.cylinderHeight).abs();
    final verticalOffset =
        -mvt.modelToViewDeltaY(cylinderInfo.verticalOffset);

    final base = PlinkoColors.cylinderBase;
    int ch(double unit) => (unit * 255.0).round().clamp(0, 255);
    final darker = Color.fromRGBO(
      ch(base.r * 0.3),
      ch(base.g * 0.3),
      ch(base.b * 0.3),
      base.a,
    );
    final brighter = Color.fromRGBO(
      ch(base.r + 0.5 * (1.0 - base.r)),
      ch(base.g + 0.5 * (1.0 - base.g)),
      ch(base.b + 0.5 * (1.0 - base.b)),
      base.a,
    );

    for (var i = 0; i < nBins; i++) {
      final binCenterX =
          ((i + 0.5) / nBins) * boundsWidth + PlinkoConstants.histogramMinX;
      final x = mvt.modelToView(Offset(binCenterX, 0)).dx;
      final yTop = mvt.modelToView(Offset(binCenterX, cylinderInfo.top)).dy;
      final geo = CylinderGeometry(
        cx: x,
        topY: yTop + verticalOffset,
        ellipseW: ellipseW,
        ellipseH: ellipseH,
        cylinderH: cylinderH,
      );

      // Back layer — top ellipse only (`CylindersBackNode`)
      if (!frontOnly) {
        canvas.drawOval(
          geo.topOval,
          Paint()..color = PlinkoColors.topCylinderFill,
        );
        canvas.drawOval(
          geo.topOval,
          Paint()
            ..color = PlinkoColors.topCylinderStroke
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }

      // Front layer — side body (`CylindersFrontNode`)
      if (!backOnly) {
        final side = geo.sidePath;
        canvas.drawPath(
          side,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              // CylindersFrontNode: darker(0.7) → base → brighter(0.5)
              colors: [darker, base, brighter],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(
              Rect.fromCenter(
                center: Offset(geo.cx, geo.topCenterY + geo.cylinderH / 2),
                width: geo.ellipseW,
                height: geo.cylinderH + geo.ellipseH,
              ),
            ),
        );
        canvas.drawPath(
          side,
          Paint()
            ..color = PlinkoColors.sideCylinderStroke
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
        // Bottom ellipse rim (visible opening edge)
        canvas.drawArc(
          geo.bottomOval,
          0,
          math.pi,
          false,
          Paint()
            ..color = PlinkoColors.sideCylinderStroke
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CylindersPainter oldDelegate) =>
      oldDelegate.numberOfRows != numberOfRows ||
      oldDelegate.mvt.viewBoardWidth != mvt.viewBoardWidth;
}
