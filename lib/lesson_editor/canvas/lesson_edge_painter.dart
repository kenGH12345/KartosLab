import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/editable_lesson_model.dart';
import 'lesson_node_card.dart';

/// 拖拽中的临时边（T5 · 源节点 id + 当前指针位置，画布局部坐标）。
@immutable
class TempLessonEdge {
  const TempLessonEdge({required this.fromId, required this.pointer});

  final String fromId;
  final Offset pointer;
}

/// 节点连线绘制（T5/T6 · T1 核心）。
///
/// 遵循项目 CustomPainter 范式（ui-framework.md §四）：构造注入不可变数据
/// （edges + layout）+ [shouldRepaint] 引用比较（layout/edges 变化才重绘）。
///
/// 三型视觉（T6 · AC-6/AC-7）：
/// - next → 蓝色实线
/// - onCompleted → 蓝色实线 + "完成后" 标签
/// - routes → 橙色实线 + 条件名标签；兜底路由（isFallback）→ 灰色虚线 + "否则"
/// - routes 同源多路由 → 按路由序号做分叉偏移（源端 y 向错开）
class LessonEdgePainter extends CustomPainter {
  const LessonEdgePainter({
    required this.edges,
    required this.layout,
    this.conflictEdgeKeys = const {},
    this.tempEdge,
  });

  final List<LessonEdge> edges;

  /// 节点 id → 画布坐标。
  final Map<String, Offset> layout;

  /// 冲突边集合（"fromId:toId" 键 · T21 · F14 冲突边 → 黄虚线）。
  final Set<String> conflictEdgeKeys;

  /// 拖拽中的临时边（源节点 id + 当前指针位置 · 画布局部坐标）。
  final TempLessonEdge? tempEdge;

  static const double _nodeH = 36; // 与 LessonNodeCard 实际高度对齐（padding 8+8 + 行高）
  static const Color _nextColor = Color(0xFF3B82F6);
  static const Color _routesColor = Color(0xFFF59E0B);
  static const Color _fallbackColor = Color(0xFF94A3B8);

  @override
  void paint(Canvas canvas, Size size) {
    // 分叉偏移：统计每个源节点的 routes 路由序号
    final routeIndex = <String, int>{};
    for (final edge in edges) {
      if (edge.type != 'routes') continue;
      final idx = routeIndex[edge.fromId] ?? 0;
      routeIndex[edge.fromId] = idx + 1;
      _drawRouteEdge(canvas, edge, idx);
    }
    for (final edge in edges) {
      if (edge.type == 'routes') continue;
      _drawLinearEdge(canvas, edge);
    }
    final temp = tempEdge;
    if (temp != null) {
      final from = layout[temp.fromId];
      if (from != null) {
        _drawTempEdge(canvas, from, temp.pointer);
      }
    }
  }

  // ---------- 线性边（next / onCompleted） ----------

  void _drawLinearEdge(Canvas canvas, LessonEdge edge) {
    final from = layout[edge.fromId];
    final to = layout[edge.toId];
    if (from == null || to == null) return;
    final p0 = Offset(from.dx + LessonNodeCard.width, from.dy + _nodeH / 2);
    final p1 = Offset(to.dx, to.dy + _nodeH / 2);
    if (conflictEdgeKeys.contains('${edge.fromId}:${edge.toId}')) {
      // T21 · 冲突边 → 黄色虚线（教学语义冲突警告 · 不阻止）
      final paint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      _drawDashedLine(canvas, p0, p1, paint);
      _drawLabel(canvas, _mid(p0, p1), '⚠ 冲突', const Color(0xFFB45309));
      return;
    }
    final paint = Paint()
      ..color = _nextColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    _drawArrowLine(canvas, p0, p1, paint);
    if (edge.label != null) {
      _drawLabel(canvas, _mid(p0, p1), edge.label!, paint.color);
    }
  }

  // ---------- routes 边（分叉 · T6） ----------

  void _drawRouteEdge(Canvas canvas, LessonEdge edge, int index) {
    final from = layout[edge.fromId];
    final to = layout[edge.toId];
    if (from == null || to == null) return;
    final p0 = Offset(from.dx + LessonNodeCard.width, from.dy + _nodeH / 2);
    final p1 = Offset(to.dx, to.dy + _nodeH / 2);
    // 分叉：源端 y 向错开（每路 +12px），视觉区分多路由
    final fan = p0 + Offset(0, (index + 1) * 12);
    final color =
        edge.isFallback ? _fallbackColor : _routesColor;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    if (edge.isFallback) {
      // 兜底路由：虚线
      paint
        ..color = color.withValues(alpha: 0.7)
        ..strokeWidth = 1.5;
      _drawDashedLine(canvas, p0, p1, paint);
    } else {
      canvas.drawLine(p0, fan, paint);
      _drawArrowLine(canvas, fan, p1, paint);
    }
    if (edge.label != null) {
      _drawLabel(canvas, _mid(fan, p1), edge.label!, color);
    }
  }

  // ---------- 临时边（拖拽中） ----------

  void _drawTempEdge(Canvas canvas, Offset from, Offset pointer) {
    final paint = Paint()
      ..color = const Color(0xFF1177AA).withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final p0 = Offset(from.dx + LessonNodeCard.width, from.dy + _nodeH / 2);
    _drawArrowLine(canvas, p0, pointer, paint);
  }

  // ---------- 图元 ----------

  static Offset _mid(Offset a, Offset b) => Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);

  void _drawArrowLine(Canvas canvas, Offset p0, Offset p1, Paint paint) {
    canvas.drawLine(p0, p1, paint);
    const arrowLen = 8.0;
    final angle = math.atan2(p1.dy - p0.dy, p1.dx - p0.dx);
    final arrowPaint = Paint()..color = paint.color;
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(
        p1.dx - arrowLen * math.cos(angle - 0.4),
        p1.dy - arrowLen * math.sin(angle - 0.4),
      )
      ..lineTo(
        p1.dx - arrowLen * math.cos(angle + 0.4),
        p1.dy - arrowLen * math.sin(angle + 0.4),
      )
      ..close();
    canvas.drawPath(path, arrowPaint);
  }

  void _drawDashedLine(Canvas canvas, Offset p0, Offset p1, Paint paint) {
    const dash = 6.0;
    const gap = 4.0;
    final total = (p1 - p0).distance;
    final dir = (p1 - p0) / total;
    var dist = 0.0;
    while (dist < total) {
      final a = p0 + dir * dist;
      final b = p0 + dir * math.min(dist + dash, total);
      canvas.drawLine(a, b, paint);
      dist += dash + gap;
    }
  }

  void _drawLabel(Canvas canvas, Offset pos, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos + const Offset(4, -14));
  }

  @override
  bool shouldRepaint(covariant LessonEdgePainter old) =>
      old.edges != edges ||
      old.layout != layout ||
      old.conflictEdgeKeys != conflictEdgeKeys ||
      old.tempEdge != tempEdge;
}
