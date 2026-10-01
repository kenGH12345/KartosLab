import 'package:flutter/material.dart';

/// Paints the small vertical bar magnet that sits on top of the Earth visual
/// in earth-field mode.
///
/// Renamed from `_VerticalMagnetPainter` → `VerticalMagnetPainter`
/// (private → public).
///
/// Extracted from `simulations/magnet_and_compass.dart:555-613`.
class VerticalMagnetPainter extends CustomPainter {
  final bool flipped;
  const VerticalMagnetPainter({required this.flipped});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const r = 7.0;

    final topColor = flipped ? const Color(0xffe53935) : const Color(0xff3949ab);
    final botColor = flipped ? const Color(0xff3949ab) : const Color(0xffe53935);
    final topLabel = flipped ? 'N' : 'S';
    final botLabel = flipped ? 'S' : 'N';

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(3, 4, w - 2, h - 2), const Radius.circular(r)),
      Paint()..color = Colors.black54..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    canvas.drawRRect(
      RRect.fromLTRBAndCorners(0, 0, w, h / 2,
        topLeft: const Radius.circular(r), topRight: const Radius.circular(r)),
      Paint()..shader = LinearGradient(
        begin: Alignment.centerLeft, end: Alignment.centerRight,
        colors: [Color.lerp(topColor, Colors.black, 0.25)!, Color.lerp(topColor, Colors.white, 0.28)!, Color.lerp(topColor, Colors.black, 0.25)!],
      ).createShader(Rect.fromLTWH(0, 0, w, h / 2)));

    canvas.drawRRect(
      RRect.fromLTRBAndCorners(0, h / 2, w, h,
        bottomLeft: const Radius.circular(r), bottomRight: const Radius.circular(r)),
      Paint()..shader = LinearGradient(
        begin: Alignment.centerLeft, end: Alignment.centerRight,
        colors: [Color.lerp(botColor, Colors.black, 0.25)!, Color.lerp(botColor, Colors.white, 0.28)!, Color.lerp(botColor, Colors.black, 0.25)!],
      ).createShader(Rect.fromLTWH(0, h / 2, w, h / 2)));

    canvas.drawLine(Offset(2, h / 2), Offset(w - 2, h / 2),
      Paint()..color = Colors.black45..strokeWidth = 1.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(2, 2, w - 4, 4), const Radius.circular(3)),
      Paint()..color = Colors.white.withValues(alpha: 0.22));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(r)),
      Paint()..color = Colors.white30..style = PaintingStyle.stroke..strokeWidth = 1.2);

    _label(canvas, topLabel, Offset(w / 2, h * 0.25), 11);
    _label(canvas, botLabel, Offset(w / 2, h * 0.75), 11);
  }

  void _label(Canvas canvas, String t, Offset c, double fs) {
    final tp = TextPainter(
      text: TextSpan(text: t, style: TextStyle(color: Colors.white, fontSize: fs, fontWeight: FontWeight.w900, shadows: const [Shadow(color: Colors.black54, blurRadius: 3)])),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(VerticalMagnetPainter o) => o.flipped != flipped;
}
