import 'dart:math';
import 'package:flutter/material.dart';

/// Paints the compass face (72-tick dial) and a two-tone diamond needle
/// rotated by [needleAngle].
///
/// Class name unchanged.
///
/// Extracted from `simulations/magnet_and_compass.dart:793-867`.
class CompassPainter extends CustomPainter {
  final double needleAngle;
  const CompassPainter({required this.needleAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy) - 2.0;
    final c = Offset(cx, cy);

    canvas.drawCircle(c, r,
      Paint()..shader = RadialGradient(
        center: const Alignment(-0.2, -0.2),
        colors: const [Color(0xff4a4a4a), Color(0xff1a1a1a)],
      ).createShader(Rect.fromCircle(center: c, radius: r)));
    canvas.drawCircle(c, r,
      Paint()..color = const Color(0xff555555)..style = PaintingStyle.stroke..strokeWidth = 6.0);
    canvas.drawCircle(c, r - 5, Paint()..color = const Color(0xff1e1e1e));
    canvas.drawCircle(c, r - 5,
      Paint()..color = const Color(0xff444444)..style = PaintingStyle.stroke..strokeWidth = 2.0);

    for (int i = 0; i < 72; i++) {
      final a = i * pi / 36;
      final isMaj = i % 18 == 0;
      final isMed = i % 9 == 0;
      final inner = isMaj ? r - 22 : isMed ? r - 16 : r - 10;
      canvas.drawLine(
        Offset(cx + inner * cos(a), cy + inner * sin(a)),
        Offset(cx + (r - 7.0) * cos(a), cy + (r - 7.0) * sin(a)),
        Paint()
          ..color = isMaj ? Colors.white : isMed ? Colors.white60 : Colors.white30
          ..strokeWidth = isMaj ? 3.6 : 1.8
          ..strokeCap = StrokeCap.round);
    }

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(needleAngle);

    final nl = r - 12.0;
    final nhw = 11.0;

    final whiteNeedle = Path()..moveTo(0, nl)..lineTo(nhw, 0)..lineTo(-nhw, 0)..close();
    canvas.drawPath(whiteNeedle,
      Paint()..shader = LinearGradient(
        begin: const Alignment(-1, 0), end: const Alignment(1, 0),
        colors: const [Color(0xffaaaaaa), Color(0xffffffff), Color(0xffaaaaaa)],
      ).createShader(Rect.fromLTWH(-nhw, 0, nhw * 2, nl)));
    canvas.drawPath(whiteNeedle,
      Paint()..color = Colors.white38..style = PaintingStyle.stroke..strokeWidth = 0.7);

    final redNeedle = Path()..moveTo(0, -nl)..lineTo(nhw, 0)..lineTo(-nhw, 0)..close();
    canvas.drawPath(redNeedle,
      Paint()..shader = LinearGradient(
        begin: const Alignment(-1, 0), end: const Alignment(1, 0),
        colors: const [Color(0xff990000), Color(0xffee3333), Color(0xff990000)],
      ).createShader(Rect.fromLTWH(-nhw, -nl, nhw * 2, nl)));
    canvas.drawPath(redNeedle,
      Paint()..color = Colors.red.shade900..style = PaintingStyle.stroke..strokeWidth = 0.7);

    canvas.restore();

    canvas.drawCircle(c, 12,
      Paint()..shader = RadialGradient(
        colors: [Colors.grey.shade300, Colors.grey.shade700],
      ).createShader(Rect.fromCircle(center: c, radius: 12)));
    canvas.drawCircle(c, 12,
      Paint()..color = Colors.white30..style = PaintingStyle.stroke..strokeWidth = 1.5);
    canvas.drawCircle(c, 5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(CompassPainter o) => o.needleAngle != needleAngle;
}
