import 'package:flutter/material.dart';

import '../../data/measurement_plots_state.dart';
import '../../domain/wave_display_mode.dart';
import 'qwi_wave_plot_chart.dart';

/// PhET `TimePlotNode` — draggable probe + chart connected by a wire.
class QwiTimePlotOverlay extends StatelessWidget {
  const QwiTimePlotOverlay({
    super.key,
    required this.state,
    required this.waveRect,
    required this.mode,
    required this.onChanged,
  });

  final MeasurementPlotsState state;
  final Rect waveRect;
  final WaveDisplayMode mode;
  final VoidCallback onChanged;

  static const double _probeSize = 28;

  @override
  Widget build(BuildContext context) {
    final probe = state.probeCanvas(waveRect);
    final chartOrigin = state.timeChartCanvas(waveRect);
    final panelH = QwiPlotConstants.chartHeight +
        QwiPlotConstants.panelTopPad +
        QwiPlotConstants.panelBottomPad +
        16; // title row

    final range = state.timeSeries.getChartTimeRange();
    final chartPoints = state.timeSeries.points
        .map((p) => WavePlotPoint(x: p.time, value: p.value))
        .toList();

    final wireStart = Offset(chartOrigin.dx + 4, chartOrigin.dy + panelH - 20);
    final wireEnd = Offset(probe.dx, probe.dy + _probeSize * 0.35);

    return Stack(
      children: [
        CustomPaint(
          painter: _WirePainter(start: wireStart, end: wireEnd),
          size: Size.infinite,
        ),
        Positioned(
          left: chartOrigin.dx,
          top: chartOrigin.dy,
          child: GestureDetector(
            onPanUpdate: (d) {
              state.setTimeChartFromCanvas(
                waveRect,
                chartOrigin.dx + d.delta.dx,
                chartOrigin.dy + d.delta.dy,
              );
              onChanged();
            },
            child: Material(
              elevation: 2,
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  QwiPlotConstants.panelLeftPad,
                  QwiPlotConstants.panelTopPad,
                  QwiPlotConstants.panelRightPad,
                  QwiPlotConstants.panelBottomPad,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    QwiWavePlotChart(
                      key: const Key('qwi_time_plot_chart'),
                      width: QwiPlotConstants.timeChartWidth,
                      points: chartPoints,
                      xMin: range.minTime,
                      xMax: range.maxTime,
                      mode: mode,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: probe.dx - _probeSize / 2,
          top: probe.dy - _probeSize / 2,
          child: GestureDetector(
            onPanUpdate: (d) {
              state.setProbeFromCanvas(
                waveRect,
                probe.dx + d.delta.dx,
                probe.dy + d.delta.dy,
              );
              onChanged();
            },
            child: CustomPaint(
              key: const Key('qwi_time_plot_probe'),
              size: const Size(_probeSize, _probeSize),
              painter: _CrosshairProbePainter(),
            ),
          ),
        ),
      ],
    );
  }
}

class _CrosshairProbePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final stroke = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final fill = Paint()
      ..color = QwiPlotConstants.probeColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(c, size.width * 0.28, stroke);
    canvas.drawCircle(c, size.width * 0.28, fill);
    canvas.drawLine(Offset(c.dx, 2), Offset(c.dx, size.height - 2), stroke);
    canvas.drawLine(Offset(c.dx, 2), Offset(c.dx, size.height - 2), fill);
    canvas.drawLine(Offset(2, c.dy), Offset(size.width - 2, c.dy), stroke);
    canvas.drawLine(Offset(2, c.dy), Offset(size.width - 2, c.dy), fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WirePainter extends CustomPainter {
  _WirePainter({required this.start, required this.end});
  final Offset start;
  final Offset end;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2 + 18);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = QwiPlotConstants.wireColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _WirePainter old) => old.start != start || old.end != end;
}
