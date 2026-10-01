import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Angle arc geometry — mirrors PhET `CurvedArrowNode` + `VectorAngleNode`.
///
/// Source behavior (not comment):
/// - Model angle from `atan2(y,x)` (CCW from +x in model / Y-up).
/// - View Y is down; Flutter `drawArc` positive sweep is clockwise.
/// - Therefore Flutter `sweepAngle = -modelAngleRadians`.
/// - `isAnticlockwise = modelAngle >= 0` in CurvedArrowNode maps to the same
///   visual via the negated end angle passed to scenery.
class VaAngleArcGeometry {
  const VaAngleArcGeometry();

  static const double maxCurvedArrowRadius = 25;
  static const double maxRadiusScale = 0.79;
  static const double maxBaselineWidth = 55;
  static const double maxBaselineScale = 0.60;
  static const double textOffset = 3.5;
  static const double angleUnderBaselineThreshold = 35;
  static const double arrowheadWidth = 8;
  static const double arrowheadHeight = 6;
  static const double arcStrokeWidth = 1.2;

  /// Flutter canvas sweep for a model angle in radians.
  static double flutterSweep(double modelAngleRadians) => -modelAngleRadians;

  static double radiusForViewMagnitude(double viewMagnitude) {
    if (viewMagnitude <= 0) return maxCurvedArrowRadius;
    return math.min(maxRadiusScale * viewMagnitude, maxCurvedArrowRadius);
  }

  static double baselineLength(double radius) =>
      math.min(radius / maxBaselineScale, maxBaselineWidth);

  /// Paint baseline + arc (+ optional arrowhead) + degree label at [tailView].
  void paint(
    Canvas canvas, {
    required Offset tailView,
    required double modelAngleRadians,
    required double angleDegrees,
    required double viewMagnitude,
    required bool signedConvention,
    int decimalPlaces = 1,
  }) {
    if (viewMagnitude <= 0 && modelAngleRadians.abs() < 1e-12) return;

    final radius = radiusForViewMagnitude(viewMagnitude);
    final baseline = baselineLength(radius);

    // Baseline along +x in view
    final basePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;
    canvas.drawLine(
      tailView,
      tailView + Offset(baseline, 0),
      basePaint,
    );

    final isAnticlockwise = modelAngleRadians >= 0;
    final subtended = math.asin(
      (arrowheadHeight / radius).clamp(0.0, 1.0),
    );
    final showHead = modelAngleRadians.abs() > subtended;
    final corrected = isAnticlockwise
        ? modelAngleRadians - subtended
        : modelAngleRadians + subtended;
    final drawAngle = showHead ? corrected : modelAngleRadians;
    final drawSweep = flutterSweep(drawAngle);

    final arcPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = arcStrokeWidth;
    canvas.drawArc(
      Rect.fromCircle(center: tailView, radius: radius),
      0,
      drawSweep,
      false,
      arcPaint,
    );

    if (showHead) {
      _paintArrowhead(canvas, tailView, radius, modelAngleRadians, isAnticlockwise);
    }

    _paintLabel(
      canvas,
      tailView: tailView,
      radius: radius,
      modelAngleRadians: modelAngleRadians,
      angleDegrees: angleDegrees,
      signedConvention: signedConvention,
      decimalPlaces: decimalPlaces,
    );
  }

  void _paintArrowhead(
    Canvas canvas,
    Offset center,
    double radius,
    double modelAngle,
    bool isAnticlockwise,
  ) {
    final subtended = math.asin((arrowheadHeight / radius).clamp(0.0, 1.0));
    final corrected =
        isAnticlockwise ? modelAngle - subtended : modelAngle + subtended;
    // Tip of arc in view: (cos(θ)·r, -sin(θ)·r) — matches CurvedArrowNode translation.
    final tip = Offset(
      center.dx + math.cos(corrected) * radius,
      center.dy - math.sin(corrected) * radius,
    );
    final rot = isAnticlockwise ? -modelAngle : -modelAngle + math.pi;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(-arrowheadWidth / 2, 0)
      ..lineTo(0, -arrowheadHeight)
      ..lineTo(arrowheadWidth / 2, 0)
      ..close();
    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(rot);
    canvas.drawPath(path, Paint()..color = Colors.black);
    canvas.restore();
  }

  void _paintLabel(
    Canvas canvas, {
    required Offset tailView,
    required double radius,
    required double modelAngleRadians,
    required double angleDegrees,
    required bool signedConvention,
    required int decimalPlaces,
  }) {
    final text =
        '${angleDegrees.toStringAsFixed(decimalPlaces)}°';
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.black, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    Offset local;
    if (signedConvention) {
      if (angleDegrees > angleUnderBaselineThreshold) {
        local = Offset(
          (radius + textOffset) * math.cos(modelAngleRadians / 2),
          -(radius + textOffset) * math.sin(modelAngleRadians / 2),
        );
      } else if (angleDegrees >= 0) {
        local = Offset(radius / 2, radius / 2);
      } else if (angleDegrees > -angleUnderBaselineThreshold) {
        local = Offset(radius / 2, -radius / 2 + tp.height / 2);
      } else {
        local = Offset(
          (radius + textOffset) * math.cos(modelAngleRadians / 2),
          -(radius + textOffset) * math.sin(modelAngleRadians / 2) +
              tp.height / 2,
        );
      }
    } else {
      if (angleDegrees < angleUnderBaselineThreshold) {
        local = Offset(radius / 2, radius / 2);
      } else {
        final angle = math.min(modelAngleRadians, math.pi);
        local = Offset(
          (radius + textOffset) * math.cos(angle / 2),
          -(radius + textOffset) * math.sin(angle / 2),
        );
      }
    }

    tp.paint(canvas, tailView + local);
  }
}
