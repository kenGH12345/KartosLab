import 'dart:math' as math;

import 'package:flutter/material.dart';

/// scenery-phet `FaceNode` — smile / frown feedback face.
class PhetFaceNode extends StatelessWidget {
  const PhetFaceNode({
    super.key,
    required this.headDiameter,
    this.smiling = true,
    this.headFill = const Color(0xFFFFFF00),
    this.headStroke = const Color(0xFF666666),
    this.opacity = 1.0,
  });

  final double headDiameter;
  final bool smiling;
  final Color headFill;
  final Color headStroke;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(
        size: Size(headDiameter, headDiameter),
        painter: _FacePainter(
          smiling: smiling,
          headFill: headFill,
          headStroke: headStroke,
        ),
      ),
    );
  }
}

class _FacePainter extends CustomPainter {
  _FacePainter({
    required this.smiling,
    required this.headFill,
    required this.headStroke,
  });

  final bool smiling;
  final Color headFill;
  final Color headStroke;

  @override
  void paint(Canvas canvas, Size size) {
    final d = size.width;
    final c = Offset(d / 2, d / 2);
    final r = d / 2;

    canvas.drawCircle(c, r, Paint()..color = headFill);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = headStroke,
    );

    final eyeR = d * 0.075;
    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(c.dx - d * 0.2, c.dy - d * 0.1), eyeR, eyePaint);
    canvas.drawCircle(Offset(c.dx + d * 0.2, c.dy - d * 0.1), eyeR, eyePaint);

    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = d * 0.05
      ..strokeCap = StrokeCap.round;

    if (smiling) {
      // arc(0, d*0.05, d*0.25, PI*0.2, PI*0.8) in FaceNode local (origin=center)
      final mouthC = Offset(c.dx, c.dy + d * 0.05);
      final mouthR = d * 0.25;
      canvas.drawArc(
        Rect.fromCircle(center: mouthC, radius: mouthR),
        math.pi * 0.2,
        math.pi * 0.6,
        false,
        mouthPaint,
      );
    } else {
      // frown: arc(0, d*0.4, d*0.20, -PI*0.75, -PI*0.25)
      final mouthC = Offset(c.dx, c.dy + d * 0.4);
      final mouthR = d * 0.20;
      canvas.drawArc(
        Rect.fromCircle(center: mouthC, radius: mouthR),
        -math.pi * 0.75,
        math.pi * 0.5,
        false,
        mouthPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FacePainter oldDelegate) =>
      oldDelegate.smiling != smiling ||
      oldDelegate.headFill != headFill ||
      oldDelegate.headStroke != headStroke;
}
