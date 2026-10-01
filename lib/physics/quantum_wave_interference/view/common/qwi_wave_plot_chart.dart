import 'package:flutter/material.dart';

import '../../data/measurement_plots_state.dart';
import '../../domain/wave_display_mode.dart';

/// Shared white chart with 4×4 grid + polyline (PhET `WavePlotChartNode`).
class QwiWavePlotChart extends StatelessWidget {
  const QwiWavePlotChart({
    super.key,
    required this.width,
    required this.points,
    required this.xMin,
    required this.xMax,
    required this.mode,
    this.amplitudeScale = 1.0,
  });

  final double width;
  final List<WavePlotPoint> points;
  final double xMin;
  final double xMax;
  final WaveDisplayMode mode;
  final double amplitudeScale;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, QwiPlotConstants.chartHeight),
      painter: _WavePlotChartPainter(
        points: points,
        xMin: xMin,
        xMax: xMax,
        unipolar: mode == WaveDisplayMode.amplitude,
        amplitudeScale: amplitudeScale,
      ),
    );
  }
}

class _WavePlotChartPainter extends CustomPainter {
  _WavePlotChartPainter({
    required this.points,
    required this.xMin,
    required this.xMax,
    required this.unipolar,
    required this.amplitudeScale,
  });

  final List<WavePlotPoint> points;
  final double xMin;
  final double xMax;
  final bool unipolar;
  final double amplitudeScale;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(4)),
      bg,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(4)),
      Paint()
        ..color = const Color(0xFFAAAAAA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final grid = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      final y = size.height * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final baselineY = unipolar ? size.height : size.height / 2;
    final halfH = unipolar ? size.height : size.height / 2;
    final scale = amplitudeScale <= 0 ? 1.0 : amplitudeScale;

    canvas.drawLine(
      Offset(0, baselineY),
      Offset(size.width, baselineY),
      Paint()
        ..color = const Color(0xFF888888)
        ..strokeWidth = 1,
    );

    if (points.length < 2) return;
    final span = (xMax - xMin).abs() < 1e-12 ? 1.0 : (xMax - xMin);
    final path = Path();
    var started = false;
    for (final p in points) {
      final px = ((p.x - xMin) / span) * size.width;
      final py = baselineY - (p.value / scale) * halfH;
      if (!started) {
        path.moveTo(px, py);
        started = true;
      } else {
        path.lineTo(px, py);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF1A6FB5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _WavePlotChartPainter old) =>
      old.points != points ||
      old.xMin != xMin ||
      old.xMax != xMax ||
      old.unipolar != unipolar ||
      old.amplitudeScale != amplitudeScale;
}
