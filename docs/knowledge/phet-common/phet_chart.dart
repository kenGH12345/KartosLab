import 'package:flutter/material.dart';
import 'chart_series.dart';
import 'chart_painter.dart';

/// PhET 通用时间序列图表 Widget。
///
/// 用法：
/// ```dart
/// PhetChart(
///   series: [posSeries, velSeries],
///   dataProviders: [posData, velData],
///   domainRange: const Range(0, 20),
///   rangeRange: const Range(-10, 10),
///   currentTime: state.time,
///   onTimeChanged: (t) => setState(() => ...),
/// )
/// ```
class PhetChart extends StatelessWidget {
  const PhetChart({
    super.key,
    required this.series,
    required this.dataProviders,
    required this.domainRange,
    required this.rangeRange,
    required this.currentTime,
    this.onTimeChanged,
    this.domainLabel,
    this.rangeLabel,
    this.showGrid = false,
    this.showSlider = true,
    this.showLegend = true,
    this.showZoomControls = false,
    this.zoomFraction = 1.1,
    this.height = 200,
  });

  final List<ChartSeries> series;
  final List<SeriesDataProvider> dataProviders;
  final Range domainRange;
  final Range rangeRange;
  final double currentTime;
  final ValueChanged<double>? onTimeChanged;
  final String? domainLabel;
  final String? rangeLabel;
  final bool showGrid;
  final bool showSlider;
  final bool showLegend;
  final bool showZoomControls;
  final double zoomFraction;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: GestureDetector(
        onHorizontalDragUpdate: showSlider && onTimeChanged != null
            ? (d) {
                // 用 RenderBox 获取画布宽，映射拖拽位移到时间
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                final w = box.size.width;
                const padLeft = 50.0, padRight = 20.0;
                final plotW = w - padLeft - padRight;
                if (plotW <= 0) return;
                final dx = d.localPosition.dx - padLeft;
                final t = domainRange.min + (dx / plotW) * (domainRange.max - domainRange.min);
                onTimeChanged?.call(t.clamp(domainRange.min, domainRange.max));
              }
            : null,
        child: CustomPaint(
          painter: ChartPainter(
            series: series,
            dataProviders: dataProviders,
            domainRange: domainRange,
            rangeRange: rangeRange,
            currentTime: currentTime,
            showGrid: showGrid,
            showSlider: showSlider,
            showLegend: showLegend,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}
