/// PhET Graph — a line graph for plotting data series.
///
/// Used for time→position, time→velocity, temperature→pressure, etc.
library;

import 'package:flutter/material.dart';
import 'graph_data.dart';

class PhetGraphPainter extends CustomPainter {
  final List<DataSeries> series;
  final String xLabel;
  final String yLabel;
  final double xMin;
  final double xMax;
  final double yMin;
  final yMax;

  const PhetGraphPainter({
    required this.series,
    this.xLabel = '',
    this.yLabel = '',
    this.xMin = 0,
    this.xMax = 1,
    this.yMin = 0,
    this.yMax = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pad = 30.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;

    // Background
    canvas.drawRect(Rect.fromLTWH(pad, pad, w, h),
        Paint()..color = const Color(0xff1a1a2e));

    // Border
    canvas.drawRect(Rect.fromLTWH(pad, pad, w, h),
        Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 1);

    // Grid
    for (int i = 1; i < 10; i++) {
      final gx = pad + w * i / 10;
      final gy = pad + h * i / 10;
      canvas.drawLine(Offset(gx, pad), Offset(gx, pad + h),
          Paint()..color = Colors.white12..strokeWidth = 0.5);
      canvas.drawLine(Offset(pad, gy), Offset(pad + w, gy),
          Paint()..color = Colors.white12..strokeWidth = 0.5);
    }

    // Axes labels
    _text(canvas, xLabel, Offset(pad + w / 2 - 20, pad + h + 5), 10, Colors.white70);
    _text(canvas, yLabel, Offset(5, pad + h / 2), 10, Colors.white70);

    // Plot series
    for (final s in series) {
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < s.points.length - 1; i++) {
        final p1 = _toScreen(s.points[i], pad, w, h);
        final p2 = _toScreen(s.points[i + 1], pad, w, h);
        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  Offset _toScreen(DataPoint dp, double pad, double w, double h) {
    final sx = pad + ((dp.x - xMin) / (xMax - xMin)).clamp(0, 1) * w;
    final sy = pad + h - ((dp.y - yMin) / (yMax - yMin)).clamp(0, 1) * h;
    return Offset(sx, sy);
  }

  void _text(Canvas c, String s, Offset pos, double fs, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(color: color, fontSize: fs)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, pos);
  }

  @override
  bool shouldRepaint(PhetGraphPainter old) => true;
}

/// A graph widget.
class PhetGraph extends StatelessWidget {
  final List<DataSeries> series;
  final String xLabel;
  final String yLabel;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;
  final double width;
  final double height;

  const PhetGraph({
    super.key,
    required this.series,
    this.xLabel = '',
    this.yLabel = '',
    this.xMin = 0,
    this.xMax = 1,
    this.yMin = 0,
    this.yMax = 1,
    this.width = 200,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: PhetGraphPainter(
          series: series,
          xLabel: xLabel,
          yLabel: yLabel,
          xMin: xMin,
          xMax: xMax,
          yMin: yMin,
          yMax: yMax,
        ),
      ),
    );
  }
}
