import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/controller/esp_controller.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';
import 'package:kratos/energy_skate_park/esp_strings.dart';
import 'package:kratos/energy_skate_park/render/esp_render_builder.dart';

/// Left-side Energy bar accordion (EnergyBarGraphAccordionBox.ts layout).
class EnergyBarPanel extends StatelessWidget {
  const EnergyBarPanel({super.key, required this.controller});

  final EspController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.view.barGraphVisible) {
      return const SizedBox.shrink();
    }
    final data = EspRenderBuilder.build(controller);
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

    return Material(
      elevation: 2,
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 168,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        decoration: BoxDecoration(
          border: Border.all(color: EspColors.panelStroke),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  icon: const Icon(Icons.remove, size: 16, color: Colors.red),
                  onPressed: () =>
                      controller.setBarGraphVisible(false),
                ),
                const Expanded(
                  child: Text(
                    'Energy',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: _BarChartPainter(
                  energies: energies,
                  colors: colors,
                  labels: labels,
                  maxE: maxE,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.zoom_out, size: 18),
                  onPressed: () {},
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.zoom_in, size: 18),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.energies,
    required this.colors,
    required this.labels,
    required this.maxE,
  });

  final List<double> energies;
  final List<Color> colors;
  final List<String> labels;
  final double maxE;

  @override
  void paint(Canvas canvas, Size size) {
    const barW = 26.0;
    const gap = 8.0;
    const top = 8.0;
    final maxH = size.height - 36;
    final baseY = top + maxH;

    canvas.drawLine(
      Offset(12, top),
      Offset(12, baseY),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 1.5,
    );
    // Arrow head
    final path = Path()
      ..moveTo(12, top)
      ..lineTo(9, top + 8)
      ..lineTo(15, top + 8)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.black87);

    for (var i = 0; i < 4; i++) {
      final h = (energies[i].abs() / maxE) * maxH;
      final x = 24 + i * (barW + gap);
      final rect = Rect.fromLTWH(x, baseY - h, barW, h);
      canvas.drawRect(rect, Paint()..color = colors[i]);
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.black45
          ..style = PaintingStyle.stroke,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(fontSize: 9, color: Colors.black87),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: barW + 10);
      tp.paint(canvas, Offset(x + (barW - tp.width) / 2, baseY + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) => true;
}
