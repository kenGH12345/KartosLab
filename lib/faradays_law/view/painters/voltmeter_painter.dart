import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../faradays_law_constants.dart';

/// Dial + needle — `VoltmeterGauge.js` / `VoltmeterNode.js` body portion.
class VoltmeterPainter extends CustomPainter {
  VoltmeterPainter({required this.needleAngle});

  final double needleAngle;

  static const double _bodyW = 170;
  static const double _bodyH = 107;
  static const double _readoutW = 132;
  static const double _arcRadius = 55;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);

    // Shaded body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: _bodyW, height: _bodyH),
      const Radius.circular(10),
    );
    canvas.drawRRect(
      bodyRect,
      Paint()..color = const Color(0xFF232674),
    );
    // Simple highlight edge
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final readout = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, -5), width: _readoutW, height: 72),
      const Radius.circular(5),
    );
    canvas.drawRRect(readout, Paint()..color = Colors.white);

    // Gauge arc
    final gaugeOrigin = const Offset(0, -5);
    canvas.save();
    canvas.translate(gaugeOrigin.dx, gaugeOrigin.dy + 20);

    final arcPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: _arcRadius),
      math.pi,
      math.pi,
      false,
      arcPaint,
    );
    // Vertical zero tick
    canvas.drawLine(Offset.zero, Offset(0, -_arcRadius), arcPaint);

    // + / −
    _drawPlus(canvas, Offset(_arcRadius / 2.3, -_arcRadius / 2.5));
    _drawMinus(canvas, Offset(-_arcRadius / 2.3, -_arcRadius / 2.5));

    // Needle
    final clamped = needleAngle.clamp(
      FaradaysLawConstants.needleMinAngle,
      FaradaysLawConstants.needleMaxAngle,
    );
    canvas.save();
    canvas.rotate(clamped);
    final needlePaint = Paint()
      ..color = const Color(0xFF3954A5)
      ..style = PaintingStyle.fill;
    final needle = Path()
      ..moveTo(-1, 0)
      ..lineTo(0, -53)
      ..lineTo(1, 0)
      ..close();
    // Wider head
    final head = Path()
      ..moveTo(0, -53)
      ..lineTo(-4, -41)
      ..lineTo(4, -41)
      ..close();
    canvas.drawPath(needle, needlePaint);
    canvas.drawPath(head, needlePaint);
    canvas.drawCircle(Offset.zero, 4, needlePaint);
    canvas.restore();

    canvas.restore();

    // Label
    final tp = TextPainter(
      text: const TextSpan(
        text: 'voltage',
        style: TextStyle(
          color: Color(0xFFFFFF00),
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: _readoutW);
    tp.paint(canvas, Offset(-tp.width / 2, _bodyH / 2 - 28));

    // Terminals
    _terminal(canvas, Offset(18, _bodyH / 2 + 9), isPlus: true);
    _terminal(canvas, Offset(-18, _bodyH / 2 + 9), isPlus: false);
  }

  void _drawPlus(Canvas canvas, Offset c) {
    final p = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c + const Offset(-6, 0), c + const Offset(6, 0), p);
    canvas.drawLine(c + const Offset(0, -6), c + const Offset(0, 6), p);
  }

  void _drawMinus(Canvas canvas, Offset c) {
    final p = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c + const Offset(-6, 0), c + const Offset(6, 0), p);
  }

  void _terminal(Canvas canvas, Offset c, {required bool isPlus}) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: 18, height: 18),
        const Radius.circular(3),
      ),
      Paint()
        ..color = const Color(0xFFC0C0C0)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: 18, height: 18),
        const Radius.circular(3),
      ),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    if (isPlus) {
      _drawPlus(canvas, c);
    } else {
      _drawMinus(canvas, c);
    }
  }

  @override
  bool shouldRepaint(covariant VoltmeterPainter oldDelegate) =>
      oldDelegate.needleAngle != needleAngle;
}
