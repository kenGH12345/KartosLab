import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../som_strings.dart';

/// Pressure dial gauge — PhET `DialGaugeNode` (dial + collar + L elbow connector).
class DialGaugePainter extends CustomPainter {
  DialGaugePainter({
    required this.pressureAtm,
    this.maxPressure = 200,
    this.elbowHeight = 30,
  });

  final double pressureAtm;
  final double maxPressure;

  /// PhET `DialGaugeNode.setElbowHeight` — vertical pipe below the elbow bend.
  final double elbowHeight;

  /// Dial face diameter (PhET GaugeNode radius 80 × scale 0.5 → Ø80).
  static const double dialDiameter = 80;

  @override
  void paint(Canvas canvas, Size size) {
    final dialR = dialDiameter / 2;
    final cx = dialR + 4;
    final cy = dialR + 4;

    // --- Collar + L connector (right of dial) ---
    const collarW = 30.0;
    const collarH = 25.0;
    final collarLeft = cx + dialR - 10;
    final collarTop = cy - collarH / 2;
    final collarRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(collarLeft, collarTop, collarW, collarH),
      const Radius.circular(2),
    );
    canvas.drawRRect(
      collarRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF787878),
            Color(0xFFDCDCDC),
            Color(0xFFDCDCDC),
            Color(0xFF646464),
          ],
          stops: [0, 0.3, 0.5, 1],
        ).createShader(collarRect.outerRect),
    );

    // Horizontal pipe + elbow bend + vertical extension (fill #ddd)
    const elbowW = 6.0; // CONNECTOR_WIDTH_PROPORTION * 30
    const elbowLen = 60.0; // CONNECTOR_LENGTH_PROPORTION * 60
    const halfStroke = 5.0;
    final pipeLeft = collarLeft + collarW;
    final pipeTop = cy - elbowW / 2 - halfStroke;
    final pipeFill = Paint()..color = const Color(0xFFDDDDDD);

    final horiz = Path()
      ..moveTo(pipeLeft, pipeTop)
      ..lineTo(pipeLeft + elbowLen + elbowW / 2, pipeTop)
      ..quadraticBezierTo(
        pipeLeft + elbowLen + elbowW + halfStroke,
        pipeTop,
        pipeLeft + elbowLen + elbowW + halfStroke,
        pipeTop + elbowW / 2 + halfStroke,
      )
      ..lineTo(pipeLeft + elbowLen - halfStroke, pipeTop + elbowW + halfStroke * 2)
      ..lineTo(pipeLeft, pipeTop + elbowW + halfStroke * 2)
      ..close();
    canvas.drawPath(horiz, pipeFill);

    final vertLeft = pipeLeft + elbowLen - halfStroke;
    final vertTop = pipeTop + elbowW / 2 + halfStroke;
    final vertH = elbowHeight.clamp(0.0, 400.0);
    canvas.drawRect(
      Rect.fromLTWH(vertLeft, vertTop, elbowW + 2 * halfStroke, vertH),
      pipeFill,
    );

    // --- Bezel + face ---
    final radius = dialR * 0.95;
    canvas.drawCircle(
      Offset(cx, cy),
      radius + 4,
      Paint()..color = const Color(0xFF888888),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()..color = const Color(0xFFF5F5F5),
    );

    // Ticks
    final tickPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    const startAngle = math.pi * 0.75;
    const sweep = math.pi * 1.5;
    for (var i = 0; i <= 10; i++) {
      final t = i / 10;
      final a = startAngle + sweep * t;
      final outer =
          Offset(cx + radius * 0.92 * math.cos(a), cy + radius * 0.92 * math.sin(a));
      final inner =
          Offset(cx + radius * 0.78 * math.cos(a), cy + radius * 0.78 * math.sin(a));
      canvas.drawLine(inner, outer, tickPaint);
    }

    // Label
    final tp = TextPainter(
      text: TextSpan(
        text: SomStrings.pressure,
        style: TextStyle(
          color: Colors.black87,
          fontSize: radius * 0.22,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - radius * 0.35));

    // Needle
    final clamped = pressureAtm.clamp(0.0, maxPressure);
    final frac = clamped / maxPressure;
    final needleAngle = startAngle + sweep * frac;
    final needleLen = radius * 0.72;
    final needlePaint = Paint()
      ..color = const Color(0xFFE50000)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(
        cx + needleLen * math.cos(needleAngle),
        cy + needleLen * math.sin(needleAngle),
      ),
      needlePaint,
    );
    canvas.drawCircle(Offset(cx, cy), 3.5, Paint()..color = Colors.black87);

    // Readout
    final readout = Rect.fromCenter(
      center: Offset(cx, cy + radius * 0.72),
      width: radius * 1.4,
      height: radius * 0.36,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(readout, const Radius.circular(3)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(readout, const Radius.circular(3)),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final valueTp = TextPainter(
      text: TextSpan(
        text: '${clamped.toStringAsFixed(1)} ${SomStrings.pressureUnitsAtm}',
        style: TextStyle(
          color: Colors.black87,
          fontSize: radius * 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: readout.width * 0.95);
    valueTp.paint(
      canvas,
      Offset(
        readout.center.dx - valueTp.width / 2,
        readout.center.dy - valueTp.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant DialGaugePainter oldDelegate) =>
      oldDelegate.pressureAtm != pressureAtm ||
      oldDelegate.maxPressure != maxPressure ||
      oldDelegate.elbowHeight != elbowHeight;
}
