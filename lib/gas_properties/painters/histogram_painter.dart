import 'package:flutter/material.dart';

import '../gas_properties_colors.dart';
import '../render/gas_render_state.dart';
import 'package:kratos/gas_properties/gas_properties_strings.dart';

/// Speed or KE histogram — 19 bins from EnergySamplingState.
class HistogramPainter extends CustomPainter {
  HistogramPainter({
    required this.heavyBins,
    required this.lightBins,
    required this.yMax,
    required this.title,
    this.heavyColor = const Color(GasPropertiesColors.heavyParticle),
    this.lightColor = const Color(GasPropertiesColors.lightParticle),
  });

  final List<double> heavyBins;
  final List<double> lightBins;
  final double yMax;
  final String title;
  final Color heavyColor;
  final Color lightColor;

  @override
  void paint(Canvas canvas, Size size) {
    final padL = 28.0;
    final padR = 8.0;
    final padT = 22.0;
    final padB = 20.0;
    final plot = Rect.fromLTRB(padL, padT, size.width - padR, size.height - padB);

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(GasPropertiesColors.panelFill),
    );

    final titleTp = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    titleTp.paint(canvas, const Offset(8, 4));

    // Axes
    final axis = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(plot.left, plot.bottom),
      Offset(plot.right, plot.bottom),
      axis,
    );
    canvas.drawLine(
      Offset(plot.left, plot.top),
      Offset(plot.left, plot.bottom),
      axis,
    );

    final n = heavyBins.length;
    if (n == 0 || yMax <= 0) return;
    final barW = plot.width / n;

    for (var i = 0; i < n; i++) {
      final h = (heavyBins[i] / yMax).clamp(0.0, 1.0) * plot.height;
      final l = (lightBins[i] / yMax).clamp(0.0, 1.0) * plot.height;
      final x = plot.left + i * barW;
      // Stack light then heavy (or side-by-side)
      final half = barW * 0.42;
      canvas.drawRect(
        Rect.fromLTWH(x + 1, plot.bottom - h, half, h),
        Paint()..color = heavyColor,
      );
      canvas.drawRect(
        Rect.fromLTWH(x + half + 1, plot.bottom - l, half, l),
        Paint()..color = lightColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant HistogramPainter oldDelegate) => true;
}

class AverageSpeedPanel extends StatelessWidget {
  const AverageSpeedPanel({super.key, required this.energy});

  final EnergyRenderDatum? energy;

  @override
  Widget build(BuildContext context) {
    String fmt(double? v) =>
        v == null ? '—' : '${v.toStringAsFixed(0)} pm/ps';
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(GasPropertiesColors.panelFill),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(GasPropertiesColors.panelStroke)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            GasPropertiesStrings.averageSpeed,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${GasPropertiesStrings.heavy}: ${fmt(energy?.heavyAverageSpeed)}',
            style: const TextStyle(
              color: Color(GasPropertiesColors.heavyParticle),
              fontSize: 12,
            ),
          ),
          Text(
            '${GasPropertiesStrings.light}: ${fmt(energy?.lightAverageSpeed)}',
            style: const TextStyle(
              color: Color(GasPropertiesColors.lightParticle),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
