import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../gases_intro_constants.dart';

/// Faithful port of scenery-phet [GaugeNode] as used by [PressureGaugeNode].
///
/// Defaults match Gas Properties Ideal: radius=50, range 0..maxPressure (20000 kPa),
/// span = π + π/4, 21 ticks, red needle, white dial + left post gradient.
class PressureGaugePainter extends CustomPainter {
  PressureGaugePainter({
    required this.displayedKpa,
    this.radius = 50,
    this.numberOfTicks = 21,
    this.span = math.pi + math.pi / 4,
    this.rangeMin = 0,
    this.rangeMax = GasesIntroConstants.maxPressureKpa,
    this.label = 'Pressure',
    this.showValueText = true,
  });

  final double displayedKpa;
  final double radius;
  final int numberOfTicks;
  final double span;
  final double rangeMin;
  final double rangeMax;
  final String label;
  final bool showValueText;

  static const Color _postTop = Color.fromRGBO(120, 120, 120, 1);
  static const Color _postMid = Color.fromRGBO(220, 220, 220, 1);
  static const Color _postBot = Color.fromRGBO(100, 100, 100, 1);

  @override
  void paint(Canvas canvas, Size size) {
    final dialR = radius;
    final postH = 0.6 * dialR;
    final postW = dialR + 15;
    final cx = size.width - dialR;
    final cy = size.height / 2;
    final c = Offset(cx, cy);

    // Horizontal post sticking out left of dial (PressureGaugeNode.createPostGradient).
    final postRect = Rect.fromLTWH(cx - postW, cy - postH / 2, postW, postH);
    canvas.drawRect(
      postRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [_postTop, _postMid, _postMid, _postBot],
          stops: const [0.0, 0.3, 0.5, 1.0],
        ).createShader(postRect),
    );

    // White dial
    canvas.drawCircle(c, dialR, Paint()..color = Colors.white);
    canvas.drawCircle(
      c,
      dialR,
      Paint()
        ..color = const Color.fromRGBO(85, 85, 85, 1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final anglePerTick = span / numberOfTicks;
    final totalAngle = (numberOfTicks - 1) * anglePerTick;
    final startAngle = -math.pi / 2 - totalAngle / 2;

    const majorTickLength = 10.0;
    const minorTickLength = 5.0;
    final majorPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.butt;
    final minorPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.butt;

    for (var i = 0; i < numberOfTicks; i++) {
      final tickAngle = i * anglePerTick + startAngle;
      final tickLength = i.isEven ? majorTickLength : minorTickLength;
      final cos = math.cos(tickAngle);
      final sin = math.sin(tickAngle);
      final p1 = Offset(
        c.dx + (dialR - tickLength) * cos,
        c.dy + (dialR - tickLength) * sin,
      );
      final p2 = Offset(c.dx + dialR * cos, c.dy + dialR * sin);
      canvas.drawLine(p1, p2, i.isEven ? majorPaint : minorPaint);
    }

    // Label
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: const Color(0xFF334155),
          fontSize: dialR * 0.28,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: dialR * 1.3);
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - dialR / 3 - tp.height / 2));

    // Needle — GaugeNode linear mapping on displayedPressure (kPa).
    final clamped = displayedKpa.clamp(rangeMin, rangeMax);
    final t = rangeMax == rangeMin
        ? 0.0
        : (clamped - rangeMin) / (rangeMax - rangeMin);
    final needleAngle = startAngle + t * totalAngle;
    final needleLen = dialR - majorTickLength / 2;
    final tip = Offset(
      c.dx + needleLen * math.cos(needleAngle),
      c.dy + needleLen * math.sin(needleAngle),
    );
    canvas.drawLine(
      c,
      tip,
      Paint()
        ..color = Colors.red
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(c, 2, Paint()..color = Colors.black);

    // Atm readout under dial (PressureDisplay analogue, compact).
    if (showValueText) {
      final atm = displayedKpa * GasesIntroConstants.atmPerKpa;
      final valueTp = TextPainter(
        text: TextSpan(
          text: '${atm.toStringAsFixed(2)} atm',
          style: TextStyle(
            color: const Color(0xFF1E293B),
            fontSize: dialR * 0.22,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valueTp.paint(
        canvas,
        Offset(c.dx - valueTp.width / 2, c.dy + dialR * 0.42),
      );
    }
  }

  @override
  bool shouldRepaint(covariant PressureGaugePainter oldDelegate) =>
      oldDelegate.displayedKpa != displayedKpa ||
      oldDelegate.radius != radius ||
      oldDelegate.rangeMax != rangeMax ||
      oldDelegate.showValueText != showValueText;
}
