import 'package:flutter/material.dart';

import '../fmw_colors.dart';
import '../render/fmw_render_data.dart';

/// Wave Packet Amplitudes chart: k-axis bars + optional continuous curve.
class WavePacketAmplitudesPainter extends CustomPainter {
  WavePacketAmplitudesPainter({
    required this.bars,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
    required this.continuous,
    this.widthIndicator,
  });

  final List<FmwAmplitudeBarData> bars;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;
  final List<Offset> continuous;
  final FmwWidthIndicatorData? widthIndicator;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = FmwColors.chartBackgroundCream);

    final xSpan = xMax - xMin;
    final ySpan = yMax - yMin;
    if (xSpan <= 0 || ySpan <= 0) return;

    double toX(double k) => ((k - xMin) / xSpan) * size.width;
    double toY(double a) => size.height - ((a - yMin) / ySpan) * size.height;

    // Zero / baseline
    final zeroY = toY(0);
    canvas.drawLine(
      Offset(0, zeroY),
      Offset(size.width, zeroY),
      Paint()
        ..color = FmwColors.axisStroke
        ..strokeWidth = 1,
    );

    // Continuous waveform under bars
    if (continuous.length >= 2) {
      final path = Path()..moveTo(continuous.first.dx, continuous.first.dy);
      for (var i = 1; i < continuous.length; i++) {
        path.lineTo(continuous[i].dx, continuous[i].dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = FmwColors.secondaryWaveformStroke
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }

    // Bars at waveNumber
    final barHalf = size.width / 80;
    for (final bar in bars) {
      final k = bar.waveNumber;
      if (k == null) continue;
      final cx = toX(k);
      final top = toY(bar.value);
      final r = Rect.fromLTRB(cx - barHalf, top, cx + barHalf, zeroY);
      canvas.drawRect(r, Paint()..color = bar.color);
    }

    if (widthIndicator != null) {
      final c = widthIndicator!.centerView;
      final half = widthIndicator!.halfWidthView;
      final paint = Paint()
        ..color = FmwColors.widthIndicatorsColor
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(c.dx - half, c.dy),
        Offset(c.dx + half, c.dy),
        paint,
      );
    }

    canvas.drawRect(
      rect.deflate(0.5),
      Paint()
        ..color = FmwColors.panelStroke
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant WavePacketAmplitudesPainter oldDelegate) {
    return oldDelegate.bars != bars ||
        oldDelegate.continuous != continuous ||
        oldDelegate.xMin != xMin ||
        oldDelegate.yMax != yMax ||
        oldDelegate.widthIndicator != widthIndicator;
  }
}

/// Chart panel that can host calipers / clock overlays with drag.
class HarmonicsChartWithTools extends StatelessWidget {
  const HarmonicsChartWithTools({
    super.key,
    required this.title,
    required this.chart,
    this.wavelengthCalipers,
    this.periodCalipers,
    this.periodClock,
    this.onDragWavelength,
    this.onDragPeriodCalipers,
    this.onDragPeriodClock,
  });

  final String title;
  final FmwChartRenderData chart;
  final FmwCalipersData? wavelengthCalipers;
  final FmwCalipersData? periodCalipers;
  final FmwPeriodClockData? periodClock;
  final ValueChanged<Offset>? onDragWavelength;
  final ValueChanged<Offset>? onDragPeriodCalipers;
  final ValueChanged<Offset>? onDragPeriodClock;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ),
        SizedBox(
          width: chart.width,
          height: chart.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _ChartBasePainter(chart: chart),
                  foregroundPainter: _ChartLinesPainter(chart: chart),
                ),
              ),
              if (wavelengthCalipers != null)
                _DraggableTool(
                  onDrag: onDragWavelength,
                  child: CustomPaint(
                    size: Size(chart.width, chart.height),
                    painter: _InlineCalipers(wavelengthCalipers!),
                  ),
                ),
              if (periodCalipers != null)
                _DraggableTool(
                  onDrag: onDragPeriodCalipers,
                  child: CustomPaint(
                    size: Size(chart.width, chart.height),
                    painter: _InlineCalipers(periodCalipers!),
                  ),
                ),
              if (periodClock != null)
                _DraggableTool(
                  onDrag: onDragPeriodClock,
                  child: CustomPaint(
                    size: Size(chart.width, chart.height),
                    painter: _InlineClock(periodClock!),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DraggableTool extends StatelessWidget {
  const _DraggableTool({required this.child, this.onDrag});

  final Widget child;
  final ValueChanged<Offset>? onDrag;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanUpdate: (d) {
        onDrag?.call(d.delta);
      },
      child: child,
    );
  }
}

// Local painters to avoid circular imports with measurement_painters in overlay.
class _InlineCalipers extends CustomPainter {
  _InlineCalipers(this.data);
  final FmwCalipersData data;

  @override
  void paint(Canvas canvas, Size size) {
    final left = data.origin;
    final right = Offset(left.dx + data.measuredWidthView, left.dy);
    final paint = Paint()
      ..color = data.color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(left, right, paint);
    const jaw = 14.0;
    canvas.drawLine(
      Offset(left.dx, left.dy - jaw),
      Offset(left.dx, left.dy + jaw),
      paint,
    );
    canvas.drawLine(
      Offset(right.dx, right.dy - jaw),
      Offset(right.dx, right.dy + jaw),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _InlineCalipers oldDelegate) =>
      oldDelegate.data != data;
}

class _InlineClock extends CustomPainter {
  _InlineClock(this.data);
  final FmwPeriodClockData data;

  @override
  void paint(Canvas canvas, Size size) {
    final c = data.center;
    final r = data.radius;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = data.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final sweep = data.percentTime * 2 * 3.141592653589793;
    if (sweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -3.141592653589793 / 2,
        sweep,
        true,
        Paint()..color = data.color.withValues(alpha: 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _InlineClock oldDelegate) =>
      oldDelegate.data != data;
}

class _ChartBasePainter extends CustomPainter {
  _ChartBasePainter({required this.chart});
  final FmwChartRenderData chart;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = FmwColors.chartBackground,
    );
    final xSpan = chart.xMax - chart.xMin;
    final ySpan = chart.yMax - chart.yMin;
    if (xSpan <= 0 || ySpan <= 0) return;
    final grid = Paint()
      ..color = FmwColors.chartGridLinesStroke
      ..strokeWidth = 1;
    if (chart.gridXSpacing > 0) {
      for (var x = chart.xMin; x <= chart.xMax + 1e-9; x += chart.gridXSpacing) {
        final nx = (x - chart.xMin) / xSpan;
        canvas.drawLine(
          Offset(nx * size.width, 0),
          Offset(nx * size.width, size.height),
          grid,
        );
      }
    }
    if (chart.gridYSpacing > 0) {
      for (var y = chart.yMin; y <= chart.yMax + 1e-9; y += chart.gridYSpacing) {
        final ny = (y - chart.yMin) / ySpan;
        final dy = size.height - ny * size.height;
        canvas.drawLine(Offset(0, dy), Offset(size.width, dy), grid);
      }
    }
    canvas.drawRect(
      (Offset.zero & size).deflate(0.5),
      Paint()
        ..color = FmwColors.panelStroke
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _ChartBasePainter oldDelegate) =>
      oldDelegate.chart != chart;
}

class _ChartLinesPainter extends CustomPainter {
  _ChartLinesPainter({required this.chart});
  final FmwChartRenderData chart;

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in chart.polylines) {
      if (line.points.length < 2) continue;
      final path = Path()..moveTo(line.points.first.dx, line.points.first.dy);
      for (var i = 1; i < line.points.length; i++) {
        path.lineTo(line.points[i].dx, line.points[i].dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = line.color
          ..strokeWidth = line.strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round,
      );
    }
    final ind = chart.widthIndicator;
    if (ind != null) {
      final c = ind.centerView;
      final half = ind.halfWidthView;
      final paint = Paint()
        ..color = FmwColors.widthIndicatorsColor
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(c.dx - half, c.dy),
        Offset(c.dx + half, c.dy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ChartLinesPainter oldDelegate) =>
      oldDelegate.chart != chart;
}
