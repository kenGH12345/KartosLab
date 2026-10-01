import 'package:flutter/material.dart';

import '../fmw_colors.dart';
import '../render/fmw_render_data.dart';

/// Axes, grid, and border for a ChartRectangle (default 645×123).
class ChartFramePainter extends CustomPainter {
  ChartFramePainter({
    required this.chart,
    this.fillColor = FmwColors.chartBackground,
  });

  final FmwChartRenderData chart;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = fillColor);

    final gridPaint = Paint()
      ..color = FmwColors.chartGridLinesStroke
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final xSpan = chart.xMax - chart.xMin;
    final ySpan = chart.yMax - chart.yMin;
    if (xSpan > 0 && chart.gridXSpacing > 0) {
      var x = _firstGrid(chart.xMin, chart.gridXSpacing);
      while (x <= chart.xMax + 1e-9) {
        final nx = (x - chart.xMin) / xSpan;
        final dx = nx * size.width;
        canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), gridPaint);
        x += chart.gridXSpacing;
      }
    }
    if (ySpan > 0 && chart.gridYSpacing > 0) {
      var y = _firstGrid(chart.yMin, chart.gridYSpacing);
      while (y <= chart.yMax + 1e-9) {
        final ny = (y - chart.yMin) / ySpan;
        final dy = size.height - ny * size.height;
        canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
        y += chart.gridYSpacing;
      }
    }

    // Zero axes
    final axisPaint = Paint()
      ..color = FmwColors.axisStroke
      ..strokeWidth = 1.25
      ..style = PaintingStyle.stroke;
    if (chart.xMin < 0 && chart.xMax > 0 && xSpan > 0) {
      final dx = (-chart.xMin / xSpan) * size.width;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), axisPaint);
    }
    if (chart.yMin < 0 && chart.yMax > 0 && ySpan > 0) {
      final dy = size.height - (-chart.yMin / ySpan) * size.height;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), axisPaint);
    }

    canvas.drawRect(
      rect.deflate(0.5),
      Paint()
        ..color = FmwColors.panelStroke
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
  }

  static double _firstGrid(double min, double spacing) {
    if (spacing <= 0) return min;
    return (min / spacing).ceil() * spacing;
  }

  @override
  bool shouldRepaint(covariant ChartFramePainter oldDelegate) {
    return oldDelegate.chart != chart || oldDelegate.fillColor != fillColor;
  }
}
