import 'package:flutter/material.dart';

import '../../clb_colors.dart';
import '../render/circuit_render_data.dart';

/// Circuit wires — `WireShapeCreator` (stroke 7 round) + `WireNode`
/// fill rgb(170,170,170) stroke rgb(143,143,143) lineWidth 1.
///
/// Segments are already in view coordinates (scale-only model→view).
class WirePainter extends CustomPainter {
  WirePainter({
    List<WireSegmentView>? segments,
    CircuitRenderData? data,
  }) : segments = segments ?? data?.wireSegments ?? const [];

  final List<WireSegmentView> segments;

  static const double strokeWidth = 7;

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;

    final path = Path();
    for (final seg in segments) {
      path.moveTo(seg.start.dx, seg.start.dy);
      path.lineTo(seg.end.dx, seg.end.dy);
    }

    final fillPaint = Paint()
      ..color = ClbColors.wireFill
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final outlinePaint = Paint()
      ..color = ClbColors.wireStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, outlinePaint);
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant WirePainter oldDelegate) =>
      !identical(oldDelegate.segments, segments) &&
      oldDelegate.segments != segments;
}
