import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';

/// Flutter port of scenery-phet `TemperatureAndColorSensorNode` + `ThermometerNode`.
///
/// Evidence:
/// - `TemperatureAndColorSensorNode.ts` defaults (bulb 30, tube 18, ticks @ 25K)
/// - `ThermometerNode.ts` tick loop (major/minor alternating)
/// - tip (triangle leftmost) = model sensing position
class TemperatureAndColorSensorWidget extends StatelessWidget {
  const TemperatureAndColorSensorWidget({
    super.key,
    required this.temperatureKelvin,
    required this.sensedColor,
    this.active = true,
  });

  final double temperatureKelvin;
  final Color sensedColor;
  final bool active;

  static const double bulbDiameter = 30;
  static const double tubeWidth = 18;
  static const double horizontalSpace = 3;
  static const double bottomOffset = 5;
  static const double sideLength = 18;
  static const double lineWidth = 2;
  static const double tubeHeight = 100;

  /// `TemperatureAndColorSensorNode` thermometerNodeOptions
  static const double tickSpacingTemperature = 25;
  static const double majorTickLength = 10;
  static const double minorTickLength = 5;
  static const Color backgroundFill = Color.fromARGB(171, 255, 255, 255);

  static double get nominalWidth {
    final triW = math.cos(math.pi / 6) * sideLength;
    return triW + horizontalSpace + math.max(bulbDiameter, tubeWidth);
  }

  static double get nominalHeight =>
      tubeHeight + bulbDiameter / 2 + bottomOffset;

  /// Y of tip within the widget, from the top edge.
  static double get tipFromTop =>
      nominalHeight - bottomOffset - sideLength / 2;

  @override
  Widget build(BuildContext context) {
    final triW = math.cos(math.pi / 6) * sideLength;
    final totalW = triW + horizontalSpace + bulbDiameter;
    final totalH = tubeHeight + bulbDiameter / 2 + bottomOffset;

    final tMin = EfacConstants.waterFreezingPointTemperature;
    final tMax = EfacConstants.oliveOilBoilingPointTemperature;
    final frac =
        ((temperatureKelvin - tMin) / (tMax - tMin)).clamp(0.05, 0.95);

    return SizedBox(
      width: totalW,
      height: totalH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            bottom: bottomOffset,
            child: CustomPaint(
              size: Size(triW, sideLength),
              painter: _TrianglePainter(
                fill: active ? sensedColor : Colors.transparent,
              ),
            ),
          ),
          Positioned(
            left: triW + horizontalSpace,
            bottom: 0,
            child: CustomPaint(
              size: Size(bulbDiameter, tubeHeight + bulbDiameter * 0.6),
              painter: _ThermometerPainter(
                bulbDiameter: bulbDiameter,
                tubeWidth: tubeWidth,
                tubeHeight: tubeHeight,
                lineWidth: lineWidth,
                fraction: frac,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter({required this.fill});
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.fill != fill;
}

/// PhET `ThermometerNode` outline + fluid + ticks (no numeric labels on tube).
class _ThermometerPainter extends CustomPainter {
  _ThermometerPainter({
    required this.bulbDiameter,
    required this.tubeWidth,
    required this.tubeHeight,
    required this.lineWidth,
    required this.fraction,
  });

  final double bulbDiameter;
  final double tubeWidth;
  final double tubeHeight;
  final double lineWidth;
  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final bulbCy = size.height - bulbDiameter / 2;
    final tubeTopRadius = tubeWidth / 2;
    final straightTubeHeight = tubeHeight - tubeTopRadius;
    final straightTubeTop = bulbCy - (bulbDiameter / 2) - straightTubeHeight;
    final straightTubeLeft = cx - tubeWidth / 2;

    // Glass / background outline path (bulb + tube)
    final bulbStartAngle = -math.acos((tubeWidth / bulbDiameter).clamp(-1.0, 1.0));
    final bulbEndAngle = math.pi - bulbStartAngle;
    final outline = Path()
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, bulbCy), radius: bulbDiameter / 2),
        bulbStartAngle,
        bulbEndAngle - bulbStartAngle,
        false,
      )
      ..arcTo(
        Rect.fromCircle(
          center: Offset(cx, straightTubeTop),
          radius: tubeTopRadius,
        ),
        math.pi,
        -math.pi,
        false,
      )
      ..close();

    canvas.drawPath(
      outline,
      Paint()..color = TemperatureAndColorSensorWidget.backgroundFill,
    );

    // Fluid in bulb
    final fluidPaint = Paint()..color = const Color(0xFF850E0E);
    canvas.drawCircle(
      Offset(cx, bulbCy),
      (bulbDiameter - 4) / 2,
      fluidPaint,
    );

    // Fluid in tube
    final tubeFluidBottom = bulbCy - bulbDiameter / 2 + 4;
    final tubeFluidTop = straightTubeTop + tubeTopRadius;
    final fluidSpan = (tubeFluidBottom - tubeFluidTop).abs();
    final fluidH = fluidSpan * fraction;
    final fluidRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        cx - tubeWidth / 2 + 2,
        tubeFluidBottom - fluidH,
        cx + tubeWidth / 2 - 2,
        tubeFluidBottom,
      ),
      Radius.circular(tubeWidth / 2),
    );
    canvas.drawRRect(fluidRect, fluidPaint);

    // Outline stroke
    canvas.drawPath(
      outline,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth,
    );

    // Ticks — ThermometerNode.ts with tickSpacingTemperature
    final tMin = EfacConstants.waterFreezingPointTemperature;
    final tMax = EfacConstants.oliveOilBoilingPointTemperature;
    final scaleTempY = (tubeHeight + lineWidth) / (tMax - tMin);
    final offsetTemp = TemperatureAndColorSensorWidget.tickSpacingTemperature -
        (tMin % TemperatureAndColorSensorWidget.tickSpacingTemperature);
    var offset = offsetTemp * scaleTempY;
    final minorOffset =
        ((tMin + offsetTemp) %
                (TemperatureAndColorSensorWidget.tickSpacingTemperature * 2)) %
            2;
    final tickSpacing =
        TemperatureAndColorSensorWidget.tickSpacingTemperature * scaleTempY;

    // tubeFluidBottom in ThermometerNode local (Y-up from bulb); we use view Y-down.
    // PhET: y = tubeFluidBottom - i*spacing - offset (decreasing = up the tube)
    final tickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (var i = 0;
        i * tickSpacing + offset <= tubeHeight - (tubeTopRadius / 3);
        i++) {
      final y = tubeFluidBottom - (i * tickSpacing) - offset;
      if (y < straightTubeTop) break;
      final isMinor = (i % 2 == minorOffset.round());
      final len = isMinor
          ? TemperatureAndColorSensorWidget.minorTickLength
          : TemperatureAndColorSensorWidget.majorTickLength;
      canvas.drawLine(
        Offset(straightTubeLeft, y),
        Offset(straightTubeLeft + len, y),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ThermometerPainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}

/// Storage panel size matching EFACIntroScreenView math.
Size thermometerStorageSize(Size sensorSize) => Size(
      sensorSize.width * 2,
      sensorSize.height * 1.15,
    );
