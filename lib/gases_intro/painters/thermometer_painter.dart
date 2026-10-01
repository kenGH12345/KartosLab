import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'shaded_sphere.dart';

/// Faithful port of scenery-phet [ThermometerNode] with Gas Properties Ideal options:
/// bulbDiameter=30, tubeHeight=100, tubeWidth=20, glassThickness=3, lineWidth=1.
/// Fluid colors #850e0e / #ff7575. Null T → 0 fill. Range typically 0..1000 K.
class ThermometerPainter extends CustomPainter {
  ThermometerPainter({
    required this.temperatureK,
    this.minTemperature = 0,
    this.maxTemperature = 1000,
    this.bulbDiameter = 30,
    this.tubeWidth = 20,
    this.tubeHeight = 100,
    this.glassThickness = 3,
    this.lineWidth = 1,
    this.tickSpacing = 6,
    this.majorTickLength = 10,
    this.minorTickLength = 6,
  });

  final double? temperatureK;
  final double minTemperature;
  final double maxTemperature;
  final double bulbDiameter;
  final double tubeWidth;
  final double tubeHeight;
  final double glassThickness;
  final double lineWidth;
  final double tickSpacing;
  final double majorTickLength;
  final double minorTickLength;

  static const Color fluidMain = Color(0xFF850E0E);
  static const Color fluidHighlight = Color(0xFFFF7575);

  static const double _fluidOverlap = 1;

  @override
  void paint(Canvas canvas, Size size) {
    // Intrinsic geometry (~ tubeHeight + bulbDiameter + lineWidth).
    final intrinsicH = tubeHeight + bulbDiameter + lineWidth;
    final intrinsicW = math.max(bulbDiameter, tubeWidth) + lineWidth + 4;
    final sx = size.width / intrinsicW;
    final sy = size.height / intrinsicH;
    final s = math.min(sx, sy);

    canvas.save();
    canvas.translate(
      (size.width - intrinsicW * s) / 2,
      (size.height - intrinsicH * s) / 2,
    );
    canvas.scale(s);

    // Bulb center at (0,0) in source; shift so content is in positive coords.
    final bulbR = bulbDiameter / 2;
    final ox = intrinsicW / 2;
    final oy = tubeHeight + bulbR + lineWidth / 2;

    canvas.translate(ox, oy);

    final bulbStartAngle = -math.acos((tubeWidth / bulbDiameter).clamp(-1.0, 1.0));
    final bulbEndAngle = math.pi - bulbStartAngle;
    final tubeTopRadius = tubeWidth / 2;
    final straightTubeHeight = tubeHeight - tubeTopRadius;
    final straightTubeTop = -(bulbR) - straightTubeHeight;
    final straightTubeLeft = -tubeWidth / 2;

    // Background fill (white)
    final outlinePath = Path()
      ..addArc(
        Rect.fromCircle(center: Offset.zero, radius: bulbR),
        bulbStartAngle,
        bulbEndAngle - bulbStartAngle,
      )
      ..arcTo(
        Rect.fromCircle(center: Offset(0, straightTubeTop), radius: tubeTopRadius),
        math.pi,
        -math.pi,
        false,
      )
      ..close();
    canvas.drawPath(outlinePath, Paint()..color = Colors.white);

    // Fluid geometry
    final bulbFluidDiameter = bulbDiameter - glassThickness - lineWidth / 2;
    final tubeFluidWidth = tubeWidth - glassThickness - lineWidth / 2;
    final tubeFluidRadius = tubeFluidWidth / 2;
    final clipBulbRadius = bulbFluidDiameter / 2;
    final clipStartAngle =
        -math.acos((tubeFluidRadius / clipBulbRadius).clamp(-1.0, 1.0));
    final clipEndAngle = math.pi - clipStartAngle;
    final tubeFluidBottom = clipBulbRadius * math.sin(clipEndAngle);
    final tubeFluidLeft = -tubeFluidRadius;

    final maxFluidHeight = (straightTubeTop.abs() + tubeFluidBottom).clamp(1.0, 400.0);
    final temp = temperatureK ?? minTemperature;
    final clamped = temp.clamp(minTemperature, maxTemperature);
    final frac = maxTemperature == minTemperature
        ? 0.0
        : (clamped - minTemperature) / (maxTemperature - minTemperature);
    // null → 0 fill (GasPropertiesThermometerNode maps null to 0).
    final fluidHeight = temperatureK == null ? 0.0 : frac * maxFluidHeight;

    // Bulb fluid (ShadedSphereNode with Thermometer offsets)
    paintShadedSphere(
      canvas,
      Offset.zero,
      bulbFluidDiameter / 2,
      mainColor: fluidMain,
      highlightColor: fluidHighlight,
      highlightXOffset: -0.2,
      highlightYOffset: 0.2,
    );

    // Tube fluid
    if (fluidHeight > 0) {
      final tubeRect = Rect.fromLTRB(
        tubeFluidLeft,
        tubeFluidBottom - fluidHeight,
        tubeFluidLeft + tubeFluidWidth,
        tubeFluidBottom + _fluidOverlap,
      );
      canvas.save();
      canvas.clipPath(
        Path()
          ..moveTo(tubeFluidLeft, tubeFluidBottom + _fluidOverlap)
          ..arcTo(
            Rect.fromCircle(
              center: Offset(0, straightTubeTop),
              radius: tubeFluidRadius,
            ),
            math.pi,
            -math.pi,
            false,
          )
          ..lineTo(-tubeFluidLeft, tubeFluidBottom + _fluidOverlap)
          ..close(),
      );
      canvas.drawRect(
        tubeRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [
              fluidMain,
              fluidHighlight,
              fluidHighlight,
              fluidMain,
            ],
            stops: const [0.0, 0.4, 0.5, 1.0],
          ).createShader(tubeRect),
      );
      canvas.restore();
    }

    // Outline + ticks
    final outline = Path()
      ..addArc(
        Rect.fromCircle(center: Offset.zero, radius: bulbR),
        bulbStartAngle,
        bulbEndAngle - bulbStartAngle,
      )
      ..arcTo(
        Rect.fromCircle(center: Offset(0, straightTubeTop), radius: tubeTopRadius),
        math.pi,
        -math.pi,
        false,
      )
      ..close();

    // Tick marks on left of tube
    final tickPath = Path();
    for (var i = 0;
        i * tickSpacing <= tubeHeight - (tubeTopRadius / 3);
        i++) {
      final y = tubeFluidBottom - (i * tickSpacing) - tickSpacing;
      if (y < straightTubeTop + tubeTopRadius) break;
      final len = i.isEven ? majorTickLength : minorTickLength;
      tickPath
        ..moveTo(straightTubeLeft, y)
        ..lineTo(straightTubeLeft + len, y);
    }
    outline.addPath(tickPath, Offset.zero);

    canvas.drawPath(
      outline,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth,
    );
    canvas.drawPath(
      tickPath,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ThermometerPainter oldDelegate) =>
      oldDelegate.temperatureK != temperatureK ||
      oldDelegate.maxTemperature != maxTemperature;
}
