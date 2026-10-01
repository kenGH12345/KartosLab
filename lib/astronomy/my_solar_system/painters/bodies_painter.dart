/// Bodies only. No physics.
library;

import 'package:flutter/material.dart';

import '../my_solar_system_constants.dart';
import '../render/mss_render_data.dart';

class BodiesPainter extends CustomPainter {
  BodiesPainter(this.data);

  final MssRenderData data;

  @override
  void paint(Canvas canvas, Size size) {
    for (final body in data.bodies) {
      final c = data.mvt.toView(body.position);
      final r = data.mvt.toViewDelta(body.radiusAu).clamp(
            MySolarSystemConstants.bodyViewRadiusMin,
            MySolarSystemConstants.bodyViewRadiusMax,
          );
      canvas.drawCircle(
        c,
        r,
        Paint()..color = body.color,
      );
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(BodiesPainter oldDelegate) => oldDelegate.data != data;
}
