import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../friction_constants.dart';

/// Port of scenery-phet `ThermometerNode` with FrictionScreenView options.
class FrictionThermometerPainter extends CustomPainter {
  FrictionThermometerPainter({required this.temperature});

  /// Mapped from vibrationAmplitude (same range as PhET ThermometerNode).
  final double temperature;

  static const double bulbDiameter = FrictionConstants.thermometerBulbDiameter;
  static const double tubeWidth = FrictionConstants.thermometerTubeWidth;
  static const double tubeHeight = FrictionConstants.thermometerTubeHeight;
  static const double glassThickness = FrictionConstants.thermometerGlassThickness;
  static const double lineWidth = FrictionConstants.thermometerLineWidth;
  static const double tickSpacing = FrictionConstants.thermometerTickSpacing;
  static const double majorTickLength = FrictionConstants.thermometerMajorTickLength;

  static Size get intrinsicSize {
    final w = math.max(bulbDiameter, tubeWidth) + lineWidth + majorTickLength + 4;
    final h = tubeHeight + bulbDiameter + lineWidth;
    return Size(w, h);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bulbR = bulbDiameter / 2;
    final ox = size.width / 2;
    final oy = tubeHeight + bulbR;

    canvas.save();
    canvas.translate(ox, oy);

    final bulbStartAngle = -math.acos((tubeWidth / bulbDiameter).clamp(-1.0, 1.0));
    final bulbEndAngle = math.pi - bulbStartAngle;
    final tubeTopRadius = tubeWidth / 2;
    final straightTubeHeight = tubeHeight - tubeTopRadius;
    final straightTubeTop = -bulbR - straightTubeHeight;

    // Glass outline fill (white)
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
    canvas.drawPath(outline, Paint()..color = Colors.white);
    canvas.drawPath(
      outline,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth,
    );

    // Fluid
    final minT = FrictionConstants.thermometerMinTemp;
    final maxT = FrictionConstants.thermometerMaxTemp;
    final frac = ((temperature - minT) / (maxT - minT)).clamp(0.0, 1.0);

    final bulbFluidDiameter = bulbDiameter - glassThickness - lineWidth / 2;
    final tubeFluidWidth = tubeWidth - glassThickness - lineWidth / 2;
    final tubeFluidRadius = tubeFluidWidth / 2;
    final clipBulbRadius = bulbFluidDiameter / 2;
    final clipStart =
        -math.acos((tubeFluidRadius / clipBulbRadius).clamp(-1.0, 1.0));
    final clipEnd = math.pi - clipStart;
    final tubeFluidBottom = clipBulbRadius * math.sin(clipEnd);
    final maxFluidHeight = (straightTubeTop.abs() + tubeFluidBottom).clamp(1.0, 400.0);
    final fluidHeight = maxFluidHeight * frac;

    canvas.save();
    final clipPath = Path()
      ..addArc(
        Rect.fromCircle(center: Offset.zero, radius: clipBulbRadius),
        clipStart,
        clipEnd - clipStart,
      )
      ..arcTo(
        Rect.fromCircle(
          center: Offset(0, straightTubeTop + glassThickness / 2),
          radius: tubeFluidRadius,
        ),
        math.pi,
        -math.pi,
        false,
      )
      ..close();
    canvas.clipPath(clipPath);

    final fluidTop = tubeFluidBottom - fluidHeight;
    final fluidRect = Rect.fromLTRB(
      -tubeFluidRadius,
      fluidTop,
      tubeFluidRadius,
      tubeFluidBottom + clipBulbRadius,
    );
    canvas.drawRect(
      fluidRect,
      Paint()..color = FrictionConstants.thermometerFluidMain,
    );
    // Highlight strip
    canvas.drawRect(
      Rect.fromLTRB(
        -tubeFluidRadius * 0.55,
        fluidTop,
        -tubeFluidRadius * 0.15,
        tubeFluidBottom + clipBulbRadius * 0.3,
      ),
      Paint()..color = FrictionConstants.thermometerFluidHighlight,
    );
    canvas.restore();

    // Tick marks on the right of the tube
    final tickX = tubeWidth / 2;
    var y = -bulbR - tickSpacing;
    var i = 0;
    while (y > straightTubeTop + 4) {
      final len = majorTickLength.toDouble();
      canvas.drawLine(
        Offset(tickX, y),
        Offset(tickX + len, y),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 1,
      );
      y -= tickSpacing;
      i++;
      if (i > 40) break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FrictionThermometerPainter oldDelegate) =>
      oldDelegate.temperature != temperature;
}

class FrictionThermometer extends StatelessWidget {
  const FrictionThermometer({super.key, required this.temperature});

  final double temperature;

  @override
  Widget build(BuildContext context) {
    final size = FrictionThermometerPainter.intrinsicSize;
    return CustomPaint(
      size: size,
      painter: FrictionThermometerPainter(temperature: temperature),
    );
  }
}
