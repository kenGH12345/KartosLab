import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../model/color_vision_state.dart';
import '../solver/color_model.dart';

class PotionCauldronPainter extends CustomPainter {
  final ColorVisionState state;
  final double bubblePhase;
  final bool showLabels;
  final bool bottlesOnly;

  PotionCauldronPainter(this.state, {this.bubblePhase = 0, this.showLabels = true, this.bottlesOnly = false});

  static const double bottleW = 52, bottleH = 140, bottleMargin = 16;
  static const double cauldronW = 210, cauldronH = 150;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    // 固定紧凑布局：瓶子在顶部,大锅紧接在瓶子下方,留出底部标签空间
    const bottlesY = 6.0;
    const gap = 12.0;
    final cauldronY = bottlesY + bottleH + gap;
    // 若空间不够,锅体上移贴顶
    final maxCauldronBottom = size.height - 44; // 预留标签空间
    final adjustedCauldronY = (cauldronY + cauldronH > maxCauldronBottom)
        ? (maxCauldronBottom - cauldronH).clamp(bottlesY + 20, cauldronY)
        : cauldronY;

    final r = [
      _BottleData(const Color(0xFFFF0000), 'R', state.redIntensity, _rRgb(state.redIntensity)),
      _BottleData(const Color(0xFF00CC00), 'G', state.greenIntensity, _rRgb(state.greenIntensity)),
      _BottleData(const Color(0xFF0088FF), 'B', state.blueIntensity, _rRgb(state.blueIntensity)),
    ];
    final bx0 = cx - (bottleW * 1.5 + bottleMargin);
    for (int i = 0; i < 3; i++) {
      _drawBottle(canvas, bx0 + i * (bottleW + bottleMargin), bottlesY, r[i]);
    }

    if (bottlesOnly) return; // 复合布局模式: 混合色由 Widget 层渲染,跳过锅体
    _drawCauldron(canvas, cx - cauldronW / 2, adjustedCauldronY, state.mixedColor);
  }

  void _drawBottle(Canvas canvas, double x, double y, _BottleData d) {
    const neckW = 18.0, neckH = 20.0;
    const bodyTop = 20.0;
    final bodyH = bottleH - neckH;

    final bodyRect = RRect.fromLTRBR(x, y + bodyTop, x + bottleW, y + bottleH, const Radius.circular(8));
    canvas.drawRRect(bodyRect, Paint()..style = PaintingStyle.stroke..color = const Color(0xFF94A3B8)..strokeWidth = 2);
    final neckX = x + (bottleW - neckW) / 2;
    canvas.drawRRect(
      RRect.fromLTRBR(neckX, y, neckX + neckW, y + bodyTop + 6, const Radius.circular(4)),
      Paint()..style = PaintingStyle.stroke..color = const Color(0xFF94A3B8)..strokeWidth = 2);

    final fillH = (bodyH - 8) * (d.intensity / 100);
    if (fillH > 0) {
      final liquidRect = RRect.fromLTRBR(
        x + 3, y + bodyTop + bodyH - 8 - fillH, x + bottleW - 3, y + bodyTop + bodyH - 8,
        const Radius.circular(6));
      canvas.drawRRect(liquidRect, Paint()..style = PaintingStyle.fill..color = d.color.withAlpha(200));
    }

    canvas.drawRect(Rect.fromLTWH(x + 5, y + bodyTop + 4, 4, 30), Paint()..color = const Color(0x30FFFFFF));

    final labelTp = TextPainter(
      text: TextSpan(text: d.label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: d.color)),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    labelTp.paint(canvas, Offset(x + (bottleW - labelTp.width) / 2, y + bodyTop + bodyH / 2 - 10));

    final valTp = TextPainter(
      text: TextSpan(text: '${d.intensity.round()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    valTp.paint(canvas, Offset(x + (bottleW - valTp.width) / 2, y + bottleH + 4));
  }

  void _drawCauldron(Canvas canvas, double x, double y, Color mixed) {
    final cx = x + cauldronW / 2;
    final cy = y + cauldronH / 2;

    // Glow aura
    canvas.drawCircle(Offset(cx, cy), cauldronW * 0.6,
      Paint()..shader = ui.Gradient.radial(Offset(cx, cy), cauldronW * 0.6,
        [mixed.withAlpha(40), mixed.withAlpha(8), Colors.transparent]));

    // Simple visible bowl — dark border + colored fill
    final bowlRect = RRect.fromLTRBR(x, y, x + cauldronW, y + cauldronH, const Radius.circular(24));
    canvas.drawRRect(bowlRect, Paint()..color = const Color(0xFF334155));
    canvas.drawRRect(bowlRect, Paint()..style = PaintingStyle.stroke..color = const Color(0xFF1E293B)..strokeWidth = 3);

    // Mixed color fill
    final innerRect = RRect.fromLTRBR(x + 12, y + 18, x + cauldronW - 12, y + cauldronH - 18, const Radius.circular(16));
    canvas.drawRRect(innerRect, Paint()..color = mixed);
    // Highlight
    canvas.drawRRect(RRect.fromLTRBR(x + 18, y + 24, x + cauldronW * 0.45, y + 38, const Radius.circular(12)),
      Paint()..color = const Color(0x22FFFFFF));

    // Bubbles
    final rng = Random(42);
    for (int i = 0; i < 10; i++) {
      final bx = x + 24 + rng.nextDouble() * (cauldronW - 48);
      final by = y + cauldronH - 20 - ((bubblePhase + i * 0.65) % (2 * pi)) / (2 * pi) * (cauldronH - 36);
      canvas.drawCircle(Offset(bx, by), 2.5 + rng.nextDouble() * 3.5,
        Paint()..color = Colors.white.withAlpha(70));
    }

    // Title + labels
    final titleTp = TextPainter(text: const TextSpan(text: '魔法大锅',
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFF1F5F9))),
      textDirection: ui.TextDirection.ltr)..layout();
    titleTp.paint(canvas, Offset(x + (cauldronW - titleTp.width) / 2, y + cauldronH * 0.38));

    if (showLabels) {
      final rv = (mixed.r * 255).round(), gv = (mixed.g * 255).round(), bv = (mixed.b * 255).round();
      final colorName = ColorModel.colorName(mixed);
      final nameTp = TextPainter(text: TextSpan(text: colorName,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: mixed)),
        textDirection: ui.TextDirection.ltr)..layout();
      nameTp.paint(canvas, Offset(x + (cauldronW - nameTp.width) / 2, y + cauldronH + 4));
      final rgbTp = TextPainter(text: TextSpan(text: 'rgb($rv, $gv, $bv)',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
        textDirection: ui.TextDirection.ltr)..layout();
      rgbTp.paint(canvas, Offset(x + (cauldronW - rgbTp.width) / 2, y + cauldronH + 22));
    }
  }

  int _rRgb(double intensity) => (intensity / 100 * 255).clamp(0, 255).round();

  @override
  bool shouldRepaint(PotionCauldronPainter old) => true;
}

class _BottleData {
  final Color color;
  final String label;
  final double intensity;
  final int rgbValue;
  const _BottleData(this.color, this.label, this.intensity, this.rgbValue);
}