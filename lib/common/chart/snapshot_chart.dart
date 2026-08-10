import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

import '../widgets/experiment_logger.dart';

/// 实验记录快照关系图：把 [rows]（ExperimentLogger 的记录）按 x/y 两列画成散点图。
///
/// 纯展示组件 · 不依赖任何 sim model · 供所有 sim 的探究抽屉复用。
/// 默认选轴：x = 第一个 param 列，y = 第一个 reading 列（可由 [xKey]/[yKey] 覆盖）。
/// 仅绘制数值列；行中 x/y 任一非 num 时该行跳过（如"获胜方"文本列）。
/// 数据量 ≤ ExperimentLogger.maxRows（20），每次重建成本可忽略。
class SnapshotChart extends StatelessWidget {
  const SnapshotChart({
    super.key,
    required this.rows,
    required this.columns,
    this.xKey,
    this.yKey,
    this.height = 150,
    this.domainLabel,
    this.rangeLabel,
  });

  final List<Map<String, dynamic>> rows;
  final List<ColumnDef> columns;
  final String? xKey;
  final String? yKey;
  final double height;
  final String? domainLabel;
  final String? rangeLabel;

  @override
  Widget build(BuildContext context) {
    final xKey = this.xKey ?? _firstKey(columns, isParam: true);
    final yKey = this.yKey ?? _firstKey(columns, isParam: false);
    if (xKey == null || yKey == null) return const SizedBox.shrink();

    final points = <Offset>[];
    for (final row in rows) {
      final x = row[xKey];
      final y = row[yKey];
      if (x is num && y is num) points.add(Offset(x.toDouble(), y.toDouble()));
    }

    final xLabel = domainLabel ?? _labelOf(columns, xKey);
    final yLabel = rangeLabel ?? _labelOf(columns, yKey);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: const Color(0xFFF8FAFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.scatter_plot_outlined, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('关系图（$xLabel × $yLabel）',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (points.length < 2)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  // 区分"还没记录够"与"轴有效数值不足"（如 color_vision 的混合色文本列）
                  rows.length >= 2
                      ? '所选轴（$xLabel × $yLabel）有效数值数据不足 2 组，无法生成关系图。'
                      : '记录 ≥ 2 组数据后自动生成关系图，可直接观察规律。',
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                ),
              )
            else
              SizedBox(
                height: height,
                child: CustomPaint(
                  painter: _SnapshotChartPainter(
                    points: points,
                    xLabel: xLabel,
                    yLabel: yLabel,
                  ),
                  size: Size.infinite,
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String? _firstKey(List<ColumnDef> columns, {required bool isParam}) {
    for (final c in columns) {
      if (c.isParam == isParam) return c.key;
    }
    return null;
  }

  static String _labelOf(List<ColumnDef> columns, String key) {
    for (final c in columns) {
      if (c.key == key) return c.label;
    }
    return key;
  }
}

/// 散点关系图 painter：轴 + 刻度 + 数据点。域范围取数据 min/max ±10% padding。
class _SnapshotChartPainter extends CustomPainter {
  _SnapshotChartPainter({
    required this.points,
    required this.xLabel,
    required this.yLabel,
  });

  final List<Offset> points;
  final String xLabel;
  final String yLabel;

  static const _axisColor = Color(0xFF94A3B8);
  static const _gridColor = Color(0xFFE2E8F0);
  static const _dotColor = Color(0xFF2563EB);
  static const double _padLeft = 42;
  static const double _padRight = 16;
  static const double _padTop = 12;
  static const double _padBottom = 26;

  @override
  void paint(Canvas canvas, Size size) {
    final plotW = size.width - _padLeft - _padRight;
    final plotH = size.height - _padTop - _padBottom;
    if (plotW <= 0 || plotH <= 0 || points.length < 2) return;

    // 域范围：min/max ± 10% padding（单点退化时给默认跨度）
    final xs = points.map((p) => p.dx).toList()..sort();
    final ys = points.map((p) => p.dy).toList()..sort();
    final xMin = xs.first, xMax = xs.last;
    final yMin = ys.first, yMax = ys.last;
    final xSpan = (xMax - xMin).abs() < 1e-9 ? 1.0 : (xMax - xMin) * 0.1;
    final ySpan = (yMax - yMin).abs() < 1e-9 ? 1.0 : (yMax - yMin) * 0.1;
    final domMin = xMin - xSpan, domMax = xMax + xSpan;
    final ranMin = yMin - ySpan, ranMax = yMax + ySpan;

    final origin = Offset(_padLeft, _padTop + plotH);

    // 轴
    final axisPaint = Paint()..color = _axisColor..strokeWidth = 1;
    canvas.drawLine(origin, Offset(_padLeft + plotW, origin.dy), axisPaint);
    canvas.drawLine(origin, Offset(origin.dx, _padTop), axisPaint);

    // 零点线
    if (ranMin < 0 && ranMax > 0) {
      final zeroY = _toY(0, ranMin, ranMax, plotH, origin);
      canvas.drawLine(
        Offset(_padLeft, zeroY),
        Offset(_padLeft + plotW, zeroY),
        Paint()..color = _gridColor..strokeWidth = 1,
      );
    }

    // 数据点
    final dotPaint = Paint()..color = _dotColor..style = PaintingStyle.fill;
    for (final p in points) {
      final sx = _toX(p.dx, domMin, domMax, plotW, origin);
      final sy = _toY(p.dy, ranMin, ranMax, plotH, origin);
      canvas.drawCircle(Offset(sx, sy), 3, dotPaint);
    }

    // 刻度标签（min / max）
    final ts = const TextStyle(fontSize: 9, color: Color(0xFF64748B));
    _label(canvas, _fmt(yMin), Offset(origin.dx - 5, origin.dy), ts, TextAlign.right);
    _label(canvas, _fmt(yMax), Offset(origin.dx - 5, _padTop - 4), ts, TextAlign.right);
    _label(canvas, _fmt(xMin), Offset(origin.dx, origin.dy + 3), ts, TextAlign.center);
    _label(canvas, _fmt(xMax), Offset(_padLeft + plotW, origin.dy + 3), ts, TextAlign.center);

    // 轴标签
    _label(canvas, yLabel, Offset(8, _padTop), ts, TextAlign.left);
    _label(canvas, xLabel, Offset(origin.dx + plotW / 2, size.height - 12), ts, TextAlign.center);
  }

  double _toX(double v, double min, double max, double plotW, Offset origin) =>
      origin.dx + (v - min) / (max - min) * plotW;

  double _toY(double v, double min, double max, double plotH, Offset origin) =>
      origin.dy - (v - min) / (max - min) * plotH;

  String _fmt(double v) => v.abs() >= 100 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  void _label(Canvas canvas, String text, Offset pos, TextStyle style, TextAlign align) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textAlign: align, textDirection: TextDirection.ltr)
      ..layout();
    final dx = align == TextAlign.right
        ? pos.dx - tp.width
        : align == TextAlign.center
            ? pos.dx - tp.width / 2
            : pos.dx;
    tp.paint(canvas, Offset(dx, pos.dy));
  }

  @override
  bool shouldRepaint(covariant _SnapshotChartPainter old) =>
      !listEquals(old.points, points) || old.xLabel != xLabel || old.yLabel != yLabel;
}
