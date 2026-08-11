import 'package:flutter/material.dart';

/// 浓度条 painter：竖直渐变条（0→max）+ 指针箭头 + 饱和灰段 + 数值/定性双视图。
class ConcentrationBarPainter extends CustomPainter {
  const ConcentrationBarPainter({
    required this.concentration,
    required this.maxConcentration,
    required this.color,
    this.showValue = false,
    this.isSaturated = false,
  });

  final double concentration;
  final double maxConcentration;
  final Color color;

  /// 显示数值（quantitative）还是定性 HIGH/LOW（qualitative）。
  final bool showValue;
  final bool isSaturated;

  @override
  void paint(Canvas canvas, Size size) {
    const padLeft = 18.0;
    const padBottom = 18.0;
    final barW = size.width - padLeft - 8;
    final barTop = 8.0;
    final barH = size.height - barTop - padBottom;
    if (barW <= 0 || barH <= 0) return;

    // 渐变条背景（透明→溶质浓色 → 示意浓度升高颜色变深）
    final rect = Rect.fromLTWH(padLeft, barTop, barW, barH);
    final grad = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [color.withValues(alpha: 0.25), color],
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..shader = grad.createShader(rect),
    );

    // 刻度（0 / max/2 / max）
    final ts = TextStyle(fontSize: 9, color: const Color(0xFF64748B), height: 1.2);
    for (final frac in [0.0, 0.5, 1.0]) {
      final y = barTop + barH * (1 - frac);
      canvas.drawLine(
        Offset(padLeft + barW, y),
        Offset(padLeft + barW + 4, y),
        Paint()
          ..color = const Color(0xFF94A3B8)
          ..strokeWidth = 1,
      );
      _text(canvas, (maxConcentration * frac).toStringAsFixed(1),
          Offset(padLeft - 4, y - 6), ts, TextAlign.right);
    }

    // 指针：指向当前浓度位置
    final f = maxConcentration <= 0
        ? 0.0
        : (concentration / maxConcentration).clamp(0.0, 1.0);
    final pointerY = barTop + barH * (1 - f);
    final pointer = Path()
      ..moveTo(size.width - 6, pointerY - 5)
      ..lineTo(size.width - 6, pointerY + 5)
      ..lineTo(size.width - 2, pointerY)
      ..close();
    canvas.drawPath(pointer, Paint()..color = const Color(0xFF1E293B));

    // 饱和灰段（max 之上）· 超饱和时不显示（指针封顶）
    if (isSaturated) {
      canvas.drawRect(
        Rect.fromLTWH(padLeft, barTop, barW, barH * 0.06),
        Paint()
          ..color = const Color(0xFFB0BEC5).withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke,
      );
    }

    // 数值 / 定性标签
    final labelStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: isSaturated ? const Color(0xFFB45309) : const Color(0xFF334155),
    );
    _text(
      canvas,
      showValue
          ? '${concentration.toStringAsFixed(2)} M'
          : (isSaturated ? 'HIGH' : (f < 0.5 ? 'LOW' : 'HIGH')),
      Offset(size.width - 6, size.height - 14),
      labelStyle,
      TextAlign.right,
    );
  }

  void _text(Canvas canvas, String text, Offset pos, TextStyle style, TextAlign align) {
    final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textAlign: align,
        textDirection: TextDirection.ltr)
      ..layout();
    final dx = align == TextAlign.right ? pos.dx - tp.width : pos.dx;
    tp.paint(canvas, Offset(dx, pos.dy));
  }

  @override
  bool shouldRepaint(covariant ConcentrationBarPainter old) =>
      old.concentration != concentration ||
      old.maxConcentration != maxConcentration ||
      old.color != color ||
      old.showValue != showValue ||
      old.isSaturated != isSaturated;
}
