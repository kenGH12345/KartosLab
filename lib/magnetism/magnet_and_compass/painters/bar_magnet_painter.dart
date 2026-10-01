import 'package:flutter/material.dart';

/// Paints the horizontal bar magnet (with optional "see inside" domain
/// arrows) used in the default bar-magnet mode.
///
/// Class name unchanged.
///
/// Extracted from `simulations/magnet_and_compass.dart:618-694`.
class BarMagnetPainter extends CustomPainter {
  final bool seeInside;
  final bool flipped;
  const BarMagnetPainter({required this.seeInside, required this.flipped});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const r = 14.0;

    final sColor = flipped ? const Color(0xffe53935) : const Color(0xff3949ab);
    final nColor = flipped ? const Color(0xff3949ab) : const Color(0xffe53935);
    final sLabel = flipped ? 'N' : 'S';
    final nLabel = flipped ? 'S' : 'N';

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(2, 3, w - 2, h - 2), const Radius.circular(r)),
      Paint()..color = Colors.black45..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    canvas.drawRRect(
      RRect.fromLTRBAndCorners(0, 0, w / 2, h,
        topLeft: const Radius.circular(r), bottomLeft: const Radius.circular(r)),
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color.lerp(sColor, Colors.white, 0.28)!, sColor, Color.lerp(sColor, Colors.black, 0.22)!],
      ).createShader(Rect.fromLTWH(0, 0, w / 2, h)));

    canvas.drawRRect(
      RRect.fromLTRBAndCorners(w / 2, 0, w, h,
        topRight: const Radius.circular(r), bottomRight: const Radius.circular(r)),
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color.lerp(nColor, Colors.white, 0.28)!, nColor, Color.lerp(nColor, Colors.black, 0.22)!],
      ).createShader(Rect.fromLTWH(w / 2, 0, w / 2, h)));

    canvas.drawLine(Offset(w / 2, 5), Offset(w / 2, h - 5),
      Paint()..color = Colors.black38..strokeWidth = 1.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(r, 2, w - r * 2, 5), const Radius.circular(3)),
      Paint()..color = Colors.white.withValues(alpha: 0.20));

    if (seeInside) {
      final dp = Paint()..color = Colors.white.withValues(alpha: 0.18)..strokeWidth = 1.0;
      for (int i = 1; i < 10; i++) {
        canvas.drawLine(Offset(i * w / 10, 7), Offset(i * w / 10, h - 7), dp);
      }
      final ap = Paint()..color = Colors.white.withValues(alpha: 0.38)..strokeWidth = 1.4..strokeCap = StrokeCap.round;
      for (int i = 0; i < 8; i++) {
        final ax = (i + 0.5) * w / 8;
        final ay = h / 2;
        final dir = flipped ? -1.0 : 1.0;
        canvas.drawLine(Offset(ax - 8 * dir, ay), Offset(ax + 8 * dir, ay), ap);
        canvas.drawLine(Offset(ax + 8 * dir, ay), Offset(ax + 3 * dir, ay - 4), ap);
        canvas.drawLine(Offset(ax + 8 * dir, ay), Offset(ax + 3 * dir, ay + 4), ap);
      }
    }

    _label(canvas, sLabel, Offset(w * 0.24, h / 2), 22);
    _label(canvas, nLabel, Offset(w * 0.76, h / 2), 22);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(r)),
      Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  void _label(Canvas canvas, String t, Offset c, double fs) {
    final tp = TextPainter(
      text: TextSpan(text: t, style: TextStyle(color: Colors.white, fontSize: fs, fontWeight: FontWeight.w900, shadows: const [Shadow(color: Colors.black54, blurRadius: 3)])),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(BarMagnetPainter o) => o.seeInside != seeInside || o.flipped != flipped;
}
