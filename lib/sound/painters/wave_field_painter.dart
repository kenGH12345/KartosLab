import 'dart:math';
import 'package:flutter/material.dart';
import '../model/sound_state.dart';

/// Paints the spherical sound wave as concentric arcs around the speaker.
///
/// Each element in [SoundState.amplitudes] maps to one arc at distance
/// baseRadius + index * pixelStep from the speaker.
///
/// Color mapping (matches Java WaveMediumGraphic):
/// - Amplitude = 0 to mid-gray (128)
/// - Positive amplitude to lighter (toward white)
/// - Negative amplitude to darker (toward black)
class WaveFieldPainter extends CustomPainter {
  final SoundState state;
  final double angularSpan;

  WaveFieldPainter(this.state, {this.angularSpan = 60});

  static const double _pixelStep = 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = state.speakerX;
    final cy = state.speakerY;
    final baseR = state.baseRadius;
    final amps = state.amplitudes;
    final halfSpan = angularSpan / 2;

    for (int i = 0; i < amps.length; i++) {
      final double a = amps[i];
      final double r = baseR + i * _pixelStep;

      if (cx + r > size.width + 100) break;

      final color = _amplitudeToColor(a);
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final rect = Rect.fromLTWH(cx - r, cy - r, r * 2, r * 2);
      canvas.drawArc(
        rect,
        -pi / 2 - (halfSpan * pi / 180),
        angularSpan * pi / 180,
        false,
        paint,
      );
    }

    _drawSpeaker(canvas, cx, cy);
  }

  Color _amplitudeToColor(double amp) {
    final int gray = (128 + amp * 127).clamp(0, 255).round();
    return Color.fromARGB(255, gray, gray, gray);
  }

  void _drawSpeaker(Canvas canvas, double x, double y) {
    final fill = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), 12, fill);

    final border = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(x, y), 12, border);

    final line = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(x - 6, y - 4), Offset(x + 4, y), line);
    canvas.drawLine(Offset(x - 6, y + 4), Offset(x + 4, y), line);
  }

  @override
  bool shouldRepaint(covariant WaveFieldPainter oldDelegate) => true;
}
