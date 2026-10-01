import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../masb_constants.dart';
import '../model/masb_model.dart';
import '../model/mass.dart';
import '../model/spring.dart';
import '../transform/masb_coordinate_transform.dart';

/// Bounce workspace painter: shelves, springs, masses, reference lines.
class SpringMassPainter extends CustomPainter {
  SpringMassPainter({
    required this.model,
    required this.transform,
  });

  final MasbModel model;
  final MasbCoordinateTransform transform;

  // PhET PhetColorScheme.VELOCITY / ACCELERATION (approx).
  static const _velocityColor = Color(0xFF00B400);
  static const _accelColor = Color(0xFFE87600);

  @override
  void paint(Canvas canvas, Size size) {
    _paintCeiling(canvas, size);
    _paintShelves(canvas);
    _paintReferenceLines(canvas, size);
    for (final s in model.springs) {
      _paintSpring(canvas, s);
      _paintPeriodTrace(canvas, s);
    }
    for (final m in model.masses) {
      _paintOneMass(canvas, m);
      if (m.spring != null) {
        _paintVectors(canvas, m);
      }
    }
  }

  void _paintPeriodTrace(Canvas canvas, MasbSpring spring) {
    final trace = spring.periodTrace;
    if (trace == null || !spring.periodTraceVisible) return;
    final mass = spring.massAttached;
    if (mass == null || mass.userControlled || mass.verticalVelocity == 0) {
      return;
    }
    final state = trace.state;
    if (state == 0) return;

    final massEq = spring.massEquilibriumYPosition;
    final eqY = transform.modelToViewY(massEq);
    final firstPeakY = transform.modelToViewY(massEq + trace.firstPeakY);
    final secondPeakY = transform.modelToViewY(massEq + trace.secondPeakY);
    final disp = spring.massEquilibriumDisplacement ?? 0;
    final currentY = transform.modelToViewY(massEq + disp);

    // PeriodTraceNode: originalX = modelToViewX(spring.x - 0.2) + xOffset
    final originalX =
        transform.modelToViewX(spring.positionX - 0.2) + trace.xOffset;
    const xStep = 10.0;
    final middleX = originalX + xStep;
    final lastX = originalX + 2 * xStep;

    final path = Path()..moveTo(originalX, eqY);
    path.lineTo(originalX, state == 1 ? currentY : firstPeakY);
    if (state > 1) {
      path.lineTo(middleX, state == 1 ? currentY : firstPeakY);
      path.lineTo(middleX, state == 2 ? currentY : secondPeakY);
      if (state > 2) {
        path.lineTo(lastX, state == 2 ? currentY : secondPeakY);
        path.lineTo(lastX, state == 3 ? currentY : eqY);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: trace.alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = trace.lineWidth
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
  }

  void _paintVectors(Canvas canvas, MasbMass mass) {
    if (!model.velocityVectorVisible && !model.accelerationVectorVisible) {
      return;
    }
    final com = transform.modelToView(mass.positionX, mass.centerOfMassY);
    // Offset left of mass so arrows clear the spring (Lab layout).
    final anchor = Offset(com.dx - 18, com.dy);
    const vScale = 28.0;
    const aScale = 3.5;
    if (model.velocityVectorVisible) {
      final dy = -mass.verticalVelocity * vScale;
      _arrow(canvas, anchor, Offset(anchor.dx, anchor.dy + dy), _velocityColor);
    }
    if (model.accelerationVectorVisible) {
      final dy = -mass.acceleration * aScale;
      final aAnchor = Offset(anchor.dx - 10, anchor.dy);
      _arrow(
        canvas,
        aAnchor,
        Offset(aAnchor.dx, aAnchor.dy + dy),
        _accelColor,
      );
    }
  }

  /// Filled arrow + black stroke (PhET VectorArrow / ArrowNode look).
  void _arrow(Canvas canvas, Offset from, Offset to, Color color) {
    final dir = to - from;
    final len = dir.distance;
    if (len < 3) return;
    final n = dir / len;
    final left = Offset(-n.dy, n.dx);

    const tailW = 3.5;
    const headW = 7.0;
    const headL = 10.0;
    final bodyLen = math.max(0.0, len - headL);
    final neck = from + n * bodyLen;
    final tip = to;

    final path = Path()
      ..moveTo(from.dx + left.dx * tailW, from.dy + left.dy * tailW)
      ..lineTo(neck.dx + left.dx * tailW, neck.dy + left.dy * tailW)
      ..lineTo(neck.dx + left.dx * headW, neck.dy + left.dy * headW)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(neck.dx - left.dx * headW, neck.dy - left.dy * headW)
      ..lineTo(neck.dx - left.dx * tailW, neck.dy - left.dy * tailW)
      ..lineTo(from.dx - left.dx * tailW, from.dy - left.dy * tailW)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _paintShelves(Canvas canvas) {
    final y = transform.modelToViewY(MasbConstants.floorY) -
        transform.modelToViewDeltaY(-MasbConstants.shelfHeight).abs();
    final h = 7.0;
    final left1 = transform.modelToViewX(0.05);
    final right1 = transform.modelToViewX(
      model.scene == MasbScene.lab ? 0.65 : 0.50,
    );
    final paint = Paint()..color = const Color(0xFF9CA3AF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(left1, y, right1, y + h),
        const Radius.circular(2),
      ),
      paint,
    );
    if (model.scene != MasbScene.lab) {
      final left2 = transform.modelToViewX(0.55);
      final right2 = transform.modelToViewX(0.82);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(left2, y, right2, y + h),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  void _paintReferenceLines(Canvas canvas, Size size) {
    void dashAt(double modelY, Color color, {double stroke = 2}) {
      final y = transform.modelToViewY(modelY);
      final paint = Paint()
        ..color = color
        ..strokeWidth = stroke;
      const dash = 6.0;
      const gap = 2.5;
      var x = 0.0;
      while (x < size.width) {
        canvas.drawLine(
          Offset(x, y),
          Offset((x + dash).clamp(0, size.width), y),
          paint,
        );
        x += dash + gap;
      }
    }

    for (final spring in model.springs) {
      if (model.naturalLengthVisible) {
        dashAt(
          spring.positionY - spring.naturalRestingLength,
          const Color(0xFF4142E8),
        );
      }
      if (model.equilibriumPositionVisible && spring.massAttached != null) {
        dashAt(spring.equilibriumYPosition, const Color(0xFF00B400));
      }
      if (model.scene == MasbScene.lab &&
          spring.massAttached != null &&
          (spring.periodTraceVisible ||
              model.velocityVectorVisible ||
              model.accelerationVectorVisible)) {
        dashAt(spring.equilibriumYPosition, Colors.black, stroke: 1.5);
      }
    }
    if (model.movableLineVisible) {
      dashAt(model.movableLineY, const Color(0xFFFF0000));
    }
  }

  void _paintCeiling(Canvas canvas, Size size) {
    final y = transform.modelToViewY(MasbConstants.ceilingY);
    // Thin support line; numbered hanger bar is drawn by SpringSystemControlsOverlay.
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..color = const Color(0xFF9CA3AF)
        ..strokeWidth = 2,
    );
  }

  void _paintSpring(Canvas canvas, MasbSpring spring) {
    final top = transform.modelToView(spring.positionX, spring.positionY);
    final bottom = transform.modelToView(spring.positionX, spring.bottom);
    final lengthPx = (bottom.dy - top.dy).abs();
    if (lengthPx < 1) return;

    final loops = _loopCount(spring.naturalRestingLength);
    const radiusX = 12.0;
    const radiusY = 5.5;
    final path = Path();
    final coilTop = top.dy + 10;
    final coilBottom = bottom.dy - 10;
    final coilLen = math.max(1.0, coilBottom - coilTop);
    const pointsPerLoop = 20;
    final totalPoints = loops * pointsPerLoop;
    for (var i = 0; i <= totalPoints; i++) {
      final t = i / totalPoints;
      final y = coilTop + coilLen * t;
      final angle = t * loops * 2 * math.pi;
      final x = top.dx + radiusX * math.sin(angle);
      final yWobble = radiusY * math.cos(angle) * 0.15;
      if (i == 0) {
        path.moveTo(x, y + yWobble);
      } else {
        path.lineTo(x, y + yWobble);
      }
    }
    path.moveTo(top.dx, coilBottom);
    path.lineTo(bottom.dx, bottom.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF1F2937)
        ..style = PaintingStyle.stroke
        ..strokeWidth = spring.thickness.clamp(1.0, 6.0)
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
  }

  void _paintOneMass(Canvas canvas, MasbMass mass) {
    final top = transform.modelToView(mass.positionX, mass.positionY);
    final radiusPx = transform.modelToViewDeltaX(mass.radius).abs();
    final cylH = transform.modelToViewDeltaY(-mass.cylinderHeight).abs();
    final hookH = transform.modelToViewDeltaY(-MasbConstants.hookHeight).abs();

    canvas.drawLine(
      top,
      Offset(top.dx, top.dy + hookH),
      Paint()
        ..color = const Color(0xFF374151)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final bodyTop = top.dy + hookH;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(top.dx, bodyTop + cylH / 2),
        width: radiusPx * 2,
        height: cylH,
      ),
      const Radius.circular(4),
    );
    final fill = Color(mass.colorArgb);
    canvas.drawRRect(rect, Paint()..color = fill);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Color.lerp(fill, Colors.black, 0.35)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final labelText =
        mass.mysteryLabel ? '?' : '${(mass.massKg * 1000).round()}';
    final label = TextPainter(
      text: TextSpan(
        text: labelText,
        style: TextStyle(
          color: Colors.white,
          fontSize: mass.mysteryLabel ? 14 : 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    label.paint(
      canvas,
      Offset(top.dx - label.width / 2, bodyTop + cylH / 2 - label.height / 2),
    );
  }

  int _loopCount(double springLength) {
    final t = ((springLength - 0.1) / 0.4).clamp(0.0, 1.0);
    return (2 + t * 10).round().clamp(2, 12);
  }

  @override
  bool shouldRepaint(covariant SpringMassPainter oldDelegate) => true;
}
