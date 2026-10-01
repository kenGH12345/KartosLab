import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';
import 'package:kratos/energy_skate_park/render/esp_render_data.dart';

class TrackPainter extends CustomPainter {
  TrackPainter({required this.data});

  final EspRenderData data;

  @override
  void paint(Canvas canvas, Size size) {
    for (final poly in data.trackPolylines) {
      if (poly.points.length < 2) continue;
      final path = Path()..moveTo(poly.points.first.dx, poly.points.first.dy);
      for (var i = 1; i < poly.points.length; i++) {
        path.lineTo(poly.points[i].dx, poly.points[i].dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = EspColors.roadFill
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = EspColors.roadLine
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }

    for (final dot in data.pathDots) {
      canvas.drawCircle(
        dot,
        3,
        Paint()..color = EspColors.pathFill,
      );
    }

    for (final cp in data.controlPointViews) {
      canvas.drawCircle(cp, 6, Paint()..color = Colors.white);
      canvas.drawCircle(
        cp,
        6,
        Paint()
          ..color = EspColors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TrackPainter old) => old.data != data;
}
