import 'package:flutter/material.dart';

import '../render/fmw_render_data.dart';

/// Draws one or more polylines already mapped into chart-local coordinates.
class WaveformLinePainter extends CustomPainter {
  WaveformLinePainter({required this.polylines});

  final List<FmwPolylineData> polylines;

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in polylines) {
      if (line.points.length < 2) continue;
      final path = Path()..moveTo(line.points.first.dx, line.points.first.dy);
      for (var i = 1; i < line.points.length; i++) {
        path.lineTo(line.points[i].dx, line.points[i].dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = line.color
          ..strokeWidth = line.strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..isAntiAlias = true,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformLinePainter oldDelegate) {
    return oldDelegate.polylines != polylines;
  }
}
