import 'dart:math';
import 'package:flutter/material.dart';

/// 通用矢量箭头绘制器——泛化自 forces 模块的 ForceArrowPainter。
///
/// 支持：
/// - 任意尾→头坐标（不仅限于水平从左侧边出发）
/// - 单箭头 / 双箭头
/// - 可配置箭头头大小、杆宽
/// - 标签（自动跟随方向、可选位置）
class ArrowPainter extends CustomPainter {
  ArrowPainter({
    required this.tail,
    required this.tip,
    this.color = const Color(0xFFEF4444),
    this.headHeight = 10.0,
    this.headWidth = 10.0,
    this.tailWidth = 4.0,
    this.doubleHead = false,
    this.label,
    this.labelAlign = LabelAlign.end,
    this.labelOffset = 4.0,
  });

  /// 尾部坐标（相对于 Canvas 原点）
  final Offset tail;

  /// 头部坐标（相对于 Canvas 原点）
  final Offset tip;

  final Color color;
  final double headHeight;
  final double headWidth;
  final double tailWidth;
  final bool doubleHead;
  final String? label;
  final LabelAlign labelAlign;
  final double labelOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final dx = tip.dx - tail.dx;
    final dy = tip.dy - tail.dy;
    final length = sqrt(dx * dx + dy * dy);
    if (length < 2) return;

    final dir = Offset(dx / length, dy / length);
    final perp = Offset(-dy / length, dx / length);

    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round;

    // ── 箭杆 ──
    final bodyStart = tail + dir * (doubleHead ? headHeight : 0);
    final bodyEnd = tip - dir * headHeight;
    if ((bodyEnd - bodyStart).distance > 2) {
      paint.strokeWidth = tailWidth;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(bodyStart, bodyEnd, paint);
    }

    // ── 箭头（尖）──
    _drawHead(canvas, tip, -dir, perp, headHeight, headWidth);

    // ── 双箭头尾部 ──
    if (doubleHead) {
      _drawHead(canvas, tail, dir, perp, headHeight, headWidth);
    }

    // ── 标签 ──
    if (label != null && length > 4) {
      final tp = TextPainter(
        text: TextSpan(
          text: label!,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      Offset labelPos;
      switch (labelAlign) {
        case LabelAlign.end:
          labelPos = tip + dir * labelOffset;
          break;
        case LabelAlign.start:
          labelPos = tail - dir * (tp.width + labelOffset);
          break;
        case LabelAlign.center:
          final mid = Offset((tail.dx + tip.dx) / 2, (tail.dy + tip.dy) / 2);
          labelPos = mid - Offset(tp.width / 2, tp.height / 2);
          break;
      }
      tp.paint(canvas, labelPos);
    }
  }

  void _drawHead(Canvas canvas, Offset pivot, Offset dir, Offset perp, double hh, double hw) {
    final path = Path()
      ..moveTo(pivot.dx, pivot.dy)
      ..lineTo(pivot.dx + dir.dx * hh + perp.dx * hw / 2, pivot.dy + dir.dy * hh + perp.dy * hw / 2)
      ..lineTo(pivot.dx + dir.dx * hh - perp.dx * hw / 2, pivot.dy + dir.dy * hh - perp.dy * hw / 2)
      ..close();
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant ArrowPainter old) =>
      tail != old.tail ||
      tip != old.tip ||
      color != old.color ||
      headHeight != old.headHeight ||
      headWidth != old.headWidth ||
      tailWidth != old.tailWidth ||
      doubleHead != old.doubleHead ||
      label != old.label;
}

enum LabelAlign { start, end, center }

/// 力箭头绘制器（兼容旧接口，内部委托给 ArrowPainter）。
class ForceArrowPainter extends CustomPainter {
  ForceArrowPainter({
    required this.magnitude,
    required this.direction,
    this.color = const Color(0xFFEF4444),
    this.label,
    this.maxForce = 500,
  });

  final double magnitude;
  final bool direction;
  final Color color;
  final String? label;
  final double maxForce;

  @override
  void paint(Canvas canvas, Size size) {
    if (magnitude < 1) return;
    final ratio = (magnitude / maxForce).clamp(0.0, 1.0);
    final len = size.width * 0.8 * ratio;
    final cy = size.height / 2;
    final sign = direction ? 1.0 : -1.0;

    final delegate = ArrowPainter(
      tail: Offset(0, cy),
      tip: Offset(sign * len, cy),
      color: color,
      label: label,
    );
    delegate.paint(canvas, size);
  }

  @override
  bool shouldRepaint(ForceArrowPainter o) =>
      o.magnitude != magnitude || o.direction != direction || o.color != color || o.label != label;
}
