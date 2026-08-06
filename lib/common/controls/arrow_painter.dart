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
    this.centered = false,
    this.labelAlign = LabelAlign.end,
  });

  final double magnitude;
  final bool direction;
  final Color color;
  final String? label;
  final double maxForce;
  /// true 时箭头相对 SizedBox 中心对称绘制（适用于合力等需要居中锤齐的场景）
  final bool centered;
  final LabelAlign labelAlign;

  @override
  void paint(Canvas canvas, Size size) {
    // 箭头画在上 1/3、标签留在下方（避免重叠）
    final arrowY = centered && label != null ? size.height * 0.28 : size.height / 2;
    if (magnitude < 1) {
      // 合力为零时仍需要显示“Σ0”标签（教学目的）：画中心小圆点 + 标签
      if (centered && label != null) {
        final cx = size.width / 2;
        canvas.drawCircle(Offset(cx, arrowY), 3, Paint()..color = color);
        final tp = TextPainter(
          text: TextSpan(text: label!, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          textDirection: TextDirection.ltr,
        )..layout();
        // 标签居中在 SizedBox 下方
        tp.paint(canvas, Offset(cx - tp.width / 2, arrowY + 8));
      }
      return;
    }
    final ratio = (magnitude / maxForce).clamp(0.0, 1.0);
    final len = size.width * 0.8 * ratio;
    final sign = direction ? 1.0 : -1.0;

    // centered=true 时以 SizedBox 中心为箭头中心对称展开；tail 与 tip 各处一半长度处
    final cx = size.width / 2;
    final tail = centered ? Offset(cx - sign * len / 2, arrowY) : Offset(0, arrowY);
    final tip = centered ? Offset(cx + sign * len / 2, arrowY) : Offset(sign * len, arrowY);

    // centered 模式：箭头画在上方，标签手动居中画在下方（不交给 ArrowPainter，避免重叠）
    if (centered && label != null) {
      final delegate = ArrowPainter(
        tail: tail,
        tip: tip,
        color: color,
        // 不传 label 给箭头绘制器
      );
      delegate.paint(canvas, size);
      final tp = TextPainter(
        text: TextSpan(text: label!, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, arrowY + 8));
      return;
    }

    final delegate = ArrowPainter(
      tail: tail,
      tip: tip,
      color: color,
      label: label,
      labelAlign: labelAlign,
    );
    delegate.paint(canvas, size);
  }

  @override
  bool shouldRepaint(ForceArrowPainter o) =>
      o.magnitude != magnitude || o.direction != direction || o.color != color || o.label != label
          || o.centered != centered || o.labelAlign != labelAlign;
}
