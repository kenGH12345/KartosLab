import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../model/color_vision_state.dart';
import '../solver/color_model.dart';

/// Paints the photon beam simulation on a canvas.
///
/// Renders:
/// - Individual photons as small colored circles
/// - Beam overlap zone as a semi-transparent mixed-color band
/// - Observer (Person) figure with perceived color label
class PhotonBeamPainter extends CustomPainter {
  final ColorVisionState state;

  PhotonBeamPainter(this.state);

  @override
  void paint(Canvas canvas, Size size) {
    final mixed = state.mixedColor;
    const overlapStart = 250.0;
    const overlapEnd = 320.0;

    // Draw each beam's photons — recolor if inside overlap zone
    for (final beam in state.beams) {
      final beamPaint = Paint()..style = PaintingStyle.fill;
      final mixedPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = mixed;

      for (final p in beam.alive) {
        final inOverlap = p.x >= overlapStart && p.x <= overlapEnd;
        if (inOverlap) {
          canvas.drawCircle(Offset(p.x, p.y), 3, mixedPaint);
        } else {
          beamPaint.color = beam.color;
          canvas.drawCircle(Offset(p.x, p.y), 3, beamPaint);
        }
      }
    }

    // Overlap zone visualization (semi-transparent mixed-color band)
    final zonePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = mixed.withAlpha(40);
    canvas.drawRect(
      const Rect.fromLTWH(overlapStart, 90, overlapEnd - overlapStart, 210),
      zonePaint,
    );

    // Person figure at the end
    final px = state.personPosition;
    _drawPerson(canvas, px, 190, mixed);
  }

  void _drawPerson(Canvas canvas, double x, double y, Color perceived) {
    // Head
    final headPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawCircle(Offset(x, y - 12), 10, headPaint);
    // Body
    canvas.drawRect(
      Rect.fromLTWH(x - 6, y, 12, 20),
      Paint()..color = const Color(0xFF475569),
    );
    // Perceived color indicator
    canvas.drawCircle(
      Offset(x + 18, y - 12),
      8,
      Paint()..color = perceived,
    );
    // Color label
    final tp = TextPainter(
      text: TextSpan(
        text: ColorModel.colorName(perceived),
        style: TextStyle(
          color: perceived.computeLuminance() > 0.5
              ? const Color(0xFF1E293B)
              : const Color(0xFFF8FAFC),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x + 30, y - 18));
  }

  @override
  bool shouldRepaint(PhotonBeamPainter oldDelegate) => true;
}
