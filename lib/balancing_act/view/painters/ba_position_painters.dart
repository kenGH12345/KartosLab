import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:kratos/balancing_act/ba_colors.dart';
import 'package:kratos/balancing_act/ba_mvt.dart';
import 'package:kratos/balancing_act/ba_shared_constants.dart';
import 'package:kratos/balancing_act/ba_strings.dart';
import 'package:kratos/balancing_act/model/plank.dart';
/// Source: `RotatingRulerNode.ts` — full ruler (not a single line).
class BaRotatingRulerPainter extends CustomPainter {
  BaRotatingRulerPainter({required this.mvt, required this.plank});

  final BaModelViewTransform mvt;
  final Plank plank;

  /// Empirically determined in source.
  static const double rulerHeightPx = 50;

  @override
  void paint(Canvas canvas, Size size) {
    // Take 1/2 meter off end so ruler doesn't exceed plank length.
    const rulerLengthInModel = BaGeometry.plankLength - 0.5; // 4.0 m
    final numTickMarks = (rulerLengthInModel * 4).round() + 1; // every 1/4 m
    final rulerLengthPx = mvt.modelToViewDeltaX(rulerLengthInModel);
    final majorTickWidth = rulerLengthPx / (numTickMarks - 1);

    final pivot = mvt.modelToView(plank.pivotPoint);
    final topCenter = mvt.modelToView(plank.bottomCenterPosition);

    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(-plank.tiltAngle);
    // After canvas.rotate(-tilt), map world offset into rotated frame.
    final cos = math.cos(plank.tiltAngle);
    final sin = math.sin(plank.tiltAngle);
    final dx = topCenter.dx - pivot.dx;
    final dy = topCenter.dy - pivot.dy;
    final localX = dx * cos - dy * sin;
    final localY = dx * sin + dy * cos;

    final left = localX - rulerLengthPx / 2;
    final top = localY; // top of ruler sits on plank bottom

    final rect = Rect.fromLTWH(left, top, rulerLengthPx, rulerHeightPx);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      Paint()..color = BaColors.rulerFill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Tick marks + numeric labels (skip 0 at center).
    final tp = TextPainter(textDirection: ui.TextDirection.ltr);
    for (var i = 0; i < numTickMarks; i++) {
      final x = left + i * majorTickWidth;
      final isMajor = i % 2 == 0;
      final tickH = isMajor ? 18.0 : 10.0;
      canvas.drawLine(
        Offset(x, top),
        Offset(x, top + tickH),
        Paint()
          ..color = Colors.black
          ..strokeWidth = isMajor ? 1.5 : 1,
      );

      final labelValue = ((i - (numTickMarks - 1) / 2) / 4).abs();
      if (labelValue != 0) {
        final text = labelValue == labelValue.roundToDouble()
            ? labelValue.toInt().toString()
            : labelValue.toString();
        tp.text = TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontFamily: 'Arial',
            height: 1,
          ),
        );
        tp.layout();
        tp.paint(canvas, Offset(x - tp.width / 2, top + tickH + 1));
      }
    }

    // Center divider — looks like two separate rulers.
    canvas.drawLine(
      Offset(localX, top),
      Offset(localX, top + rulerHeightPx),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 1,
    );

    // Units labels
    void paintUnits(double centerX) {
      tp.text = TextSpan(
        text: BaStrings.meters,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontFamily: 'Arial',
          height: 1,
        ),
      );
      tp.layout(maxWidth: rulerLengthPx / 2.1);
      tp.paint(
        canvas,
        Offset(centerX - tp.width / 2, top + rulerHeightPx - tp.height - 2),
      );
    }

    paintUnits(left + rulerLengthPx * 0.25);
    paintUnits(left + rulerLengthPx * 0.75);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BaRotatingRulerPainter oldDelegate) =>
      oldDelegate.plank.tiltAngle != plank.tiltAngle ||
      oldDelegate.plank.bottomCenterPosition != plank.bottomCenterPosition;
}

/// Source: `PositionMarkerSetNode.ts` + `PositionMarkerNode.ts`.
class BaPositionMarksPainter extends CustomPainter {
  BaPositionMarksPainter({required this.mvt, required this.plank});

  final BaModelViewTransform mvt;
  final Plank plank;

  static const double lineLength = 14;
  static const double circleRadius = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final numTickMarks =
        (BaGeometry.plankLength / BaGeometry.interSnapToMarkerDistance)
                .round() -
            1; // 17
    final interMarkerDistance =
        mvt.modelToViewDeltaX(BaGeometry.interSnapToMarkerDistance);
    final pivot = mvt.modelToView(plank.pivotPoint);
    final topCenter = mvt.modelToView(plank.bottomCenterPosition);

    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(-plank.tiltAngle);

    final cos = math.cos(plank.tiltAngle);
    final sin = math.sin(plank.tiltAngle);
    final dx = topCenter.dx - pivot.dx;
    final dy = topCenter.dy - pivot.dy;
    final localX = dx * cos - dy * sin;
    final localY = dx * sin + dy * cos;

    // Markers spanned with center at plank bottom-center; skip label 0.
    final totalWidth = (numTickMarks - 1) * interMarkerDistance;
    final startX = localX - totalWidth / 2;
    final paint = Paint()
      ..color = BaColors.positionMark
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final fill = Paint()..color = BaColors.positionMark;
    final tp = TextPainter(textDirection: ui.TextDirection.ltr);

    for (var i = 0; i < numTickMarks; i++) {
      final label = (i - (numTickMarks ~/ 2)).abs();
      if (label == 0) continue;
      final x = startX + i * interMarkerDistance;
      // Dashed vertical line
      const dash = 2.0;
      var y = localY;
      while (y < localY + lineLength) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, math.min(y + dash, localY + lineLength)),
          paint,
        );
        y += dash * 2;
      }
      canvas.drawCircle(
        Offset(x, localY + lineLength),
        circleRadius,
        fill,
      );
      tp.text = TextSpan(
        text: '$label',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
          height: 1,
        ),
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(x - tp.width / 2, localY + lineLength + circleRadius + 1),
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BaPositionMarksPainter oldDelegate) =>
      oldDelegate.plank.tiltAngle != plank.tiltAngle ||
      oldDelegate.plank.bottomCenterPosition != plank.bottomCenterPosition;
}
