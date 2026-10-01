import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';
import 'package:kratos/energy_skate_park/esp_strings.dart';
import 'package:kratos/energy_skate_park/render/esp_render_data.dart';

class EnergyBarPainter extends CustomPainter {
  EnergyBarPainter({required this.data, this.origin = const Offset(24, 24)});

  final EspRenderData data;
  final Offset origin;

  @override
  void paint(Canvas canvas, Size size) {
    if (!data.barGraphVisible) return;

    const barW = 28.0;
    const gap = 10.0;
    const maxH = 160.0;
    final energies = [
      data.kineticEnergy,
      data.potentialEnergy,
      data.thermalEnergy,
      data.totalEnergy,
    ];
    final colors = [
      EspColors.kineticEnergy,
      EspColors.potentialEnergy,
      EspColors.thermalEnergy,
      EspColors.totalEnergy,
    ];
    final labels = [
      EspStrings.kinetic,
      EspStrings.potential,
      EspStrings.thermal,
      EspStrings.total,
    ];

    final maxE = math.max(
      100.0,
      energies.map((e) => e.abs()).fold<double>(0, math.max),
    );

    final baseY = origin.dy + maxH;

    // Axis
    canvas.drawLine(
      Offset(origin.dx - 4, origin.dy),
      Offset(origin.dx - 4, baseY),
      Paint()
        ..color = Colors.black54
        ..strokeWidth = 1,
    );

    for (var i = 0; i < 4; i++) {
      final h = (energies[i].abs() / maxE) * maxH;
      final x = origin.dx + i * (barW + gap);
      final rect = Rect.fromLTWH(x, baseY - h, barW, h);
      canvas.drawRect(rect, Paint()..color = colors[i]);
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(fontSize: 10, color: Colors.black87),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: barW + 8);
      tp.paint(canvas, Offset(x + (barW - tp.width) / 2, baseY + 4));
    }
  }

  @override
  bool shouldRepaint(covariant EnergyBarPainter old) =>
      old.data.kineticEnergy != data.kineticEnergy ||
      old.data.potentialEnergy != data.potentialEnergy ||
      old.data.thermalEnergy != data.thermalEnergy ||
      old.data.totalEnergy != data.totalEnergy ||
      old.data.barGraphVisible != data.barGraphVisible;
}
