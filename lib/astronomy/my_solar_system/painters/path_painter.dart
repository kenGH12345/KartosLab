/// Trails. [MSS] PathsCanvasNode strokeWidth 3；裁剪在 Controller，不在 paint 里 shift。
library;

import 'package:flutter/material.dart';

import '../my_solar_system_constants.dart';
import '../render/mss_render_data.dart';

class PathPainter extends CustomPainter {
  PathPainter(this.data);

  final MssRenderData data;

  @override
  void paint(Canvas canvas, Size size) {
    for (final body in data.bodies) {
      if (body.path.length < 2) continue;
      final path = Path();
      final first = data.mvt.toView(body.path.first);
      path.moveTo(first.dx, first.dy);
      for (var i = 1; i < body.path.length; i++) {
        final p = data.mvt.toView(body.path[i]);
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = body.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = MySolarSystemConstants.pathStrokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(PathPainter oldDelegate) => oldDelegate.data != data;
}
