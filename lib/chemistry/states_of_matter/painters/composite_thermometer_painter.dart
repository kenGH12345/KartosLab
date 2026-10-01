import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../gas_properties/painters/shaded_sphere.dart';

/// Liquid thermometer only — PhET `ThermometerNode` geometry from
/// `CompositeThermometerNode.ts`. Readout lives in [CompositeThermometer] widget.
class CompositeThermometerPainter extends CustomPainter {
  CompositeThermometerPainter({
    required this.temperatureKelvin,
    this.minKelvin = 0,
    this.maxMercuryKelvin = 1000,
    this.bulbDiameter = 23,
    this.tubeWidth = 13,
    this.tubeHeight = 65,
    this.glassThickness = 2.5,
    this.tickSpacing = 8,
    this.majorTickLength = 8,
    this.minorTickLength = 4,
  });

  final double? temperatureKelvin;
  final double minKelvin;
  final double maxMercuryKelvin;
  final double bulbDiameter;
  final double tubeWidth;
  final double tubeHeight;
  final double glassThickness;
  final double tickSpacing;
  final double majorTickLength;
  final double minorTickLength;

  static const Color fluidMain = Color(0xFF850E0E);
  static const Color fluidHighlight = Color(0xFFFF7575);

  /// Intrinsic size used by the composite widget for layout.
  Size get intrinsicSize {
    final w = math.max(bulbDiameter, tubeWidth) + majorTickLength + 4;
    final h = tubeHeight + bulbDiameter;
    return Size(w, h);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final intrinsic = intrinsicSize;
    final s = math.min(size.width / intrinsic.width, size.height / intrinsic.height);

    canvas.save();
    canvas.translate(
      (size.width - intrinsic.width * s) / 2,
      (size.height - intrinsic.height * s) / 2,
    );
    canvas.scale(s);

    final bulbR = bulbDiameter / 2;
    final ox = intrinsic.width / 2;
    final oy = tubeHeight + bulbR;
    canvas.translate(ox, oy);

    final tubeTopRadius = tubeWidth / 2;
    final straightTubeHeight = tubeHeight - tubeTopRadius;
    final straightTubeTop = -bulbR - straightTubeHeight;
    final inset = glassThickness;

    // Glass outline background
    final outline = Path()
      ..addArc(
        Rect.fromCircle(center: Offset.zero, radius: bulbR),
        -math.acos((tubeWidth / bulbDiameter).clamp(-1.0, 1.0)),
        math.pi +
            2 * math.acos((tubeWidth / bulbDiameter).clamp(-1.0, 1.0)),
      )
      ..lineTo(tubeWidth / 2, straightTubeTop)
      ..arcToPoint(
        Offset(-tubeWidth / 2, straightTubeTop),
        radius: Radius.circular(tubeTopRadius),
        clockwise: false,
      )
      ..close();

    canvas.drawPath(outline, Paint()..color = Colors.white);
    canvas.drawPath(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.black,
    );

    final t = temperatureKelvin;
    final fillFrac = t == null
        ? 0.0
        : ((t - minKelvin) / (maxMercuryKelvin - minKelvin)).clamp(0.0, 1.0);

    // Fluid in bulb
    paintShadedSphere(
      canvas,
      Offset.zero,
      bulbR - inset,
      mainColor: fluidMain,
      highlightColor: fluidHighlight,
    );

    // Fluid in tube
    if (fillFrac > 0) {
      final fluidTop =
          straightTubeTop + (1 - fillFrac) * (straightTubeHeight + bulbR * 0.4);
      final fluidRect = RRect.fromRectAndRadius(
        Rect.fromLTRB(
          -tubeWidth / 2 + inset,
          fluidTop,
          tubeWidth / 2 - inset,
          -bulbR + inset,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(fluidRect, Paint()..color = fluidMain);
    }

    // Tick marks (spacing ≈ 8 along tube)
    final tickPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1;
    final tickCount = (straightTubeHeight / tickSpacing).floor();
    for (var i = 0; i <= tickCount; i++) {
      final y = straightTubeTop + i * tickSpacing;
      if (y > -bulbR) break;
      final major = i % 2 == 0;
      final len = major ? majorTickLength : minorTickLength;
      canvas.drawLine(
        Offset(tubeWidth / 2 + 1, y),
        Offset(tubeWidth / 2 + 1 + len, y),
        tickPaint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CompositeThermometerPainter oldDelegate) {
    return oldDelegate.temperatureKelvin != temperatureKelvin;
  }
}
