import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'chart_series.dart';

/// 绘制时间序列折线图。遵循 Flutter phet CustomPainter 规范：
/// - 构造注入不可变数据
/// - paint(Canvas, Size) 命令式绘制
/// - shouldRepaint 引用比较
class ChartPainter extends CustomPainter {
  ChartPainter({
    required this.series,
    required this.dataProviders,
    required this.domainRange,
    required this.rangeRange,
    required this.currentTime,
    this.showGrid = false,
    this.showSlider = true,
    this.showLegend = true,
    this.textStyle,
  });

  final List<ChartSeries> series;
  final List<SeriesDataProvider> dataProviders;
  final Range domainRange; // x 轴范围（时间）
  final Range rangeRange; // y 轴范围（值）
  final double currentTime;
  final bool showGrid;
  final bool showSlider;
  final bool showLegend;
  final TextStyle? textStyle;

  static const _axisColor = Color(0xFF94A3B8);
  static const _gridColor = Color(0xFFE2E8F0);
  static const _sliderColor = Color(0xFFEF4444);
  static const double _padLeft = 50;
  static const double _padRight = 20;
  static const double _padTop = 10;
  static const double _padBottom = 30;

  @override
  void paint(Canvas canvas, Size size) {
    final plotW = size.width - _padLeft - _padRight;
    final plotH = size.height - _padTop - _padBottom;
    if (plotW <= 0 || plotH <= 0) return;

    final origin = Offset(_padLeft, _padTop + plotH);

    // ── 轴 ──
    final axisPaint = Paint()..color = _axisColor..strokeWidth = 1;
    canvas.drawLine(origin, Offset(_padLeft + plotW, origin.dy), axisPaint); // x 轴
    canvas.drawLine(origin, Offset(origin.dx, _padTop), axisPaint); // y 轴

    // ── 零点线 ──
    if (rangeRange.min < 0 && rangeRange.max > 0) {
      final zeroY = _toScreenY(0, plotH, origin);
      canvas.drawLine(
        Offset(_padLeft, zeroY),
        Offset(_padLeft + plotW, zeroY),
        Paint()..color = _gridColor..strokeWidth = 1,
      );
    }

    // ── 网格 ──
    if (showGrid) _drawGrid(canvas, plotW, plotH, origin);

    // ── 数据线 ──
    for (var i = 0; i < series.length && i < dataProviders.length; i++) {
      if (!series[i].visible) continue;
      _drawSeries(canvas, i, plotW, plotH, origin);
    }

    // ── 时间竖线 ──
    if (showSlider && series.isNotEmpty && dataProviders.isNotEmpty &&
        dataProviders.first.getAllPoints().isNotEmpty) {
      final tX = _toScreenX(currentTime, plotW, origin);
      final sliderPaint = Paint()
        ..color = _sliderColor
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      final dashPath = Path()
        ..moveTo(tX, _padTop)
        ..lineTo(tX, _padTop + plotH);
      canvas.drawPath(_dashPath(dashPath, 4, 4), sliderPaint);
    }

    // ── 刻度标签 ──
    _drawTickLabels(canvas, plotW, plotH, origin);

    // ── 图例 ──
    if (showLegend) _drawLegend(canvas, size);
  }

  double _toScreenX(double val, double plotW, Offset origin) {
    final r = domainRange;
    if (r.max == r.min) return origin.dx;
    return origin.dx + (val - r.min) / (r.max - r.min) * plotW;
  }

  double _toScreenY(double val, double plotH, Offset origin) {
    final r = rangeRange;
    if (r.max == r.min) return origin.dy;
    return origin.dy - (val - r.min) / (r.max - r.min) * plotH;
  }

  void _drawSeries(Canvas canvas, int idx, double plotW, double plotH, Offset origin) {
    final points = dataProviders[idx].getAllPoints();
    if (points.length < 2) return;

    final paint = Paint()
      ..color = series[idx].color
      ..strokeWidth = series[idx].strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    bool first = true;
    for (final p in points) {
      final sx = _toScreenX(p.time, plotW, origin);
      final sy = _toScreenY(p.value, plotH, origin);
      if (first) {
        path.moveTo(sx, sy);
        first = false;
      } else {
        path.lineTo(sx, sy);
      }
    }
    canvas.drawPath(path, paint);
  }

  void _drawGrid(Canvas canvas, double plotW, double plotH, Offset origin) {
    final gridPaint = Paint()..color = _gridColor..strokeWidth = 0.5;
    // 水平网格（5 条）
    for (var i = 1; i < 5; i++) {
      final y = origin.dy - plotH * i / 5;
      canvas.drawLine(Offset(origin.dx, y), Offset(origin.dx + plotW, y), gridPaint);
    }
  }

  void _drawTickLabels(Canvas canvas, double plotW, double plotH, Offset origin) {
    final ts = textStyle ?? const TextStyle(fontSize: 10, color: Color(0xFF64748B));
    // y 轴标签（min / max）
    _drawLabel(canvas, rangeRange.min.toStringAsFixed(1), Offset(origin.dx - 5, origin.dy), ts, TextAlign.right);
    _drawLabel(canvas, rangeRange.max.toStringAsFixed(1), Offset(origin.dx - 5, _padTop), ts, TextAlign.right);
    // x 轴标签
    _drawLabel(canvas, domainRange.min.toStringAsFixed(0), Offset(origin.dx, origin.dy + 2), ts, TextAlign.center);
    if (domainRange.max > 0) {
      _drawLabel(canvas, domainRange.max.toStringAsFixed(0),
          Offset(origin.dx + plotW, origin.dy + 2), ts, TextAlign.center);
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset pos, TextStyle style, TextAlign align) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textAlign: align, textDirection: TextDirection.ltr)..layout();
    final dx = align == TextAlign.right ? pos.dx - tp.width : align == TextAlign.center ? pos.dx - tp.width / 2 : pos.dx;
    tp.paint(canvas, Offset(dx, pos.dy));
  }

  void _drawLegend(Canvas canvas, Size size) {
    final ts = textStyle ?? const TextStyle(fontSize: 10, color: Color(0xFF334155));
    double x = size.width - _padRight - 60;
    double y = _padTop;
    for (var i = 0; i < series.length; i++) {
      final s = series[i];
      if (!s.visible) continue;
      final label = s.abbr.isNotEmpty ? '${s.abbr} ${s.unit}' : '${s.title} ${s.unit}';
      final tp = TextPainter(text: TextSpan(text: label, style: ts), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(x + 14, y));
      // 颜色块
      canvas.drawRect(Rect.fromLTWH(x, y + 3, 10, 10), Paint()..color = s.color);
      y += tp.height + 4;
    }
  }

  Path _dashPath(Path source, double dash, double gap) {
    final result = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dash : gap;
        final end = (distance + len).clamp(0.0, metric.length);
        if (draw) result.addPath(metric.extractPath(distance, end), Offset.zero);
        distance += len;
        draw = !draw;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant ChartPainter old) =>
      series != old.series ||
      dataProviders != old.dataProviders ||
      domainRange != old.domainRange ||
      rangeRange != old.rangeRange ||
      currentTime != old.currentTime ||
      showGrid != old.showGrid ||
      showSlider != old.showSlider ||
      showLegend != old.showLegend;
}

/// 简单的数值范围封装。
class Range {
  final double min;
  final double max;
  const Range(this.min, this.max);
  double get span => max - min;
}
