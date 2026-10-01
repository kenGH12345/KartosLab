import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';
import 'package:kratos/energy_skate_park/render/esp_render_data.dart';

class PieChartPainter extends CustomPainter {
  PieChartPainter({
    required this.data,
    this.center = const Offset(120, 280),
    this.radius = 48,
  });

  final EspRenderData data;
  final Offset center;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    if (!data.pieChartVisible) return;

    final values = [
      math.max(0, data.kineticEnergy),
      math.max(0, data.potentialEnergy),
      math.max(0, data.thermalEnergy),
    ];
    final colors = [
      EspColors.kineticEnergy,
      EspColors.potentialEnergy,
      EspColors.thermalEnergy,
    ];
    final sum = values.fold<double>(0, (a, b) => a + b);
    if (sum <= 1e-6) {
      canvas.drawCircle(center, radius, Paint()..color = Colors.black12);
      return;
    }

    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / sum) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        true,
        Paint()..color = colors[i],
      );
      start += sweep;
    }
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.black45
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant PieChartPainter old) =>
      old.data.kineticEnergy != data.kineticEnergy ||
      old.data.potentialEnergy != data.potentialEnergy ||
      old.data.thermalEnergy != data.thermalEnergy ||
      old.data.pieChartVisible != data.pieChartVisible;
}
