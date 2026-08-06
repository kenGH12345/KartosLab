import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ChallengePainter extends CustomPainter {
  final Color targetColor;
  final Color currentColor;
  final double accuracy;
  final int score;
  final int streak;
  final int level;
  final int timeLeft;
  final bool showTarget;
  final double redIntensity;
  final double greenIntensity;
  final double blueIntensity;

  ChallengePainter({
    required this.targetColor,
    required this.currentColor,
    required this.accuracy,
    this.score = 0,
    this.streak = 0,
    this.level = 1,
    this.timeLeft = 30,
    this.showTarget = true,
    this.redIntensity = 0,
    this.greenIntensity = 0,
    this.blueIntensity = 0,
  });

  static const double bottleW = 52, bottleH = 140, bottleMargin = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // 1 — Status bar
    const topY = 4.0, barH = 26.0;
    final barX = cx - 160;
    canvas.drawRRect(
      RRect.fromLTRBR(barX, topY, barX + 320, topY + barH, const Radius.circular(13)),
      Paint()..color = const Color(0xB01E293B));
    final items = [('得分', '$score'), ('连胜', '$streak'), ('剩余', '${timeLeft}s')];
    for (int i = 0; i < 3; i++) {
      final ix = barX + 24 + i * 100.0;
      _t(canvas, items[i].$1, ix + 16, topY + 13, 9, const Color(0xFF94A3B8));
      _t(canvas, items[i].$2, ix + 40, topY + 13, 11, Colors.white);
    }

    // 2 — Three bottles (缩小以腾出空间)
    final bottlesY = topY + barH + 4;
    final bx0 = cx - (bottleW * 1.5 + bottleMargin);
    final bottleData = [
      (const Color(0xFFFF0000), 'R', redIntensity),
      (const Color(0xFF00CC00), 'G', greenIntensity),
      (const Color(0xFF0088FF), 'B', blueIntensity),
    ];
    for (int i = 0; i < 3; i++) {
      _drawBottle(canvas, bx0 + i * (bottleW + bottleMargin), bottlesY, bottleData[i]);
    }

    // 3 — 匹配度条 (放在瓶子下方,圆的上方,避免与圆 label 重叠)
    final barY = bottlesY + bottleH + 20;
    final barW = min(size.width * 0.7, 260.0);
    final barX2 = cx - barW / 2;
    const bh = 12.0;
    canvas.drawRRect(RRect.fromLTRBR(barX2, barY, barX2 + barW, barY + bh, const Radius.circular(6)),
      Paint()..color = const Color(0xFFE2E8F0));
    final accColor = accuracy >= 90 ? const Color(0xFF22C55E)
        : accuracy >= 70 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444);
    canvas.drawRRect(RRect.fromLTRBR(barX2, barY, barX2 + barW * (accuracy / 100).clamp(0.0, 1.0), barY + bh, const Radius.circular(6)),
      Paint()..color = accColor);
    _t(canvas, '匹配度 ${accuracy.round()}%', cx, barY + bh / 2 + 1, 9,
      accuracy > 50 ? Colors.white : const Color(0xFF334155));

    // 4 — 双色对比圆 (在匹配度条下方,label 和 rgb 值都在圆下有空间)
    final circleR = min(size.width * 0.13, 45.0);
    final compY = barY + bh + 16 + circleR;
    final gap = circleR * 0.4;

    _drawCircle(canvas, cx - circleR - gap / 2, compY, circleR, targetColor, '🎯 目标', showTarget);
    if (!showTarget) {
      canvas.drawCircle(Offset(cx - circleR - gap / 2, compY), circleR, Paint()..color = const Color(0x99475569));
      _t(canvas, '?', cx - circleR - gap / 2, compY, 26, Colors.white70);
    }
    _drawCircle(canvas, cx + circleR + gap / 2, compY, circleR, currentColor, '🧪 你调制的', true);

    // 中间箭头
    final arrowPaint = Paint()..color = const Color(0xFF64748B)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawPath(Path()..moveTo(cx - gap/2 + 4, compY)..lineTo(cx + gap/2 - 4, compY), arrowPaint);
    canvas.drawPath(Path()..moveTo(cx + gap/2-4, compY)..lineTo(cx + gap/2-10, compY-4)..lineTo(cx + gap/2-10, compY+4)..close(), Paint()..color = const Color(0xFF64748B));

    // 5 — result message (在圆下 label/rgb 之下,避免遮挡)
    if (accuracy >= 90) {
      _t(canvas, '✨ 完美！通过！ ✨', cx, compY + circleR + 40, 12, const Color(0xFF22C55E));
    }
  }

  void _drawBottle(Canvas canvas, double x, double y, (Color, String, double) d) {
    final (color, label, intensity) = d;
    const neckW = 18.0, bodyTop = 20.0;
    final bodyH = bottleH - 20.0;

    final bodyRect = RRect.fromLTRBR(x, y + bodyTop, x + bottleW, y + bottleH, const Radius.circular(8));
    canvas.drawRRect(bodyRect, Paint()..style = PaintingStyle.stroke..color = const Color(0xFF94A3B8)..strokeWidth = 2);
    final neckX = x + (bottleW - neckW) / 2;
    canvas.drawRRect(RRect.fromLTRBR(neckX, y, neckX + neckW, y + bodyTop + 6, const Radius.circular(4)),
      Paint()..style = PaintingStyle.stroke..color = const Color(0xFF94A3B8)..strokeWidth = 2);

    final fillH = (bodyH - 8) * (intensity / 100);
    if (fillH > 0) {
      canvas.drawRRect(RRect.fromLTRBR(x + 3, y + bodyTop + bodyH - 8 - fillH, x + bottleW - 3, y + bodyTop + bodyH - 8, const Radius.circular(6)),
        Paint()..style = PaintingStyle.fill..color = color.withAlpha(200));
    }
    canvas.drawRect(Rect.fromLTWH(x + 5, y + bodyTop + 4, 4, 30), Paint()..color = const Color(0x30FFFFFF));

    _ts(canvas, label, x + bottleW / 2, y + bodyTop + bodyH / 2 - 8, 15,
      TextStyle(fontWeight: FontWeight.w800, color: color));
    _t(canvas, '${intensity.round()}', x + bottleW / 2, y + bottleH + 4, 10, const Color(0xFF64748B));
  }

  void _drawCircle(Canvas canvas, double cx, double cy, double r, Color color, String label, bool show) {
    canvas.drawCircle(Offset(cx + 1, cy + 1), r + 1, Paint()..color = const Color(0x15000000));
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = show ? color : const Color(0xFF475569));
    canvas.drawCircle(Offset(cx - r*0.28, cy - r*0.3), r*0.2, Paint()..color = const Color(0x1FFFFFFF));
    canvas.drawCircle(Offset(cx, cy), r, Paint()..style = PaintingStyle.stroke..color = const Color(0xFF64748B)..strokeWidth = 2);
    _t(canvas, label, cx, cy + r + 12, 9, const Color(0xFF64748B));
    if (show) {
      final rv = (color.r * 255).round(), gv = (color.g * 255).round(), bv = (color.b * 255).round();
      _t(canvas, 'rgb($rv,$gv,$bv)', cx, cy + r + 23, 7, const Color(0xFF94A3B8));
    }
  }

  void _t(Canvas canvas, String text, double cx, double cy, double fs, Color c) {
    final tp = TextPainter(text: TextSpan(text: text, style: TextStyle(fontSize: fs, fontWeight: FontWeight.w600, color: c)),
      textDirection: ui.TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  void _ts(Canvas canvas, String text, double cx, double cy, double fs, TextStyle style) {
    final tp = TextPainter(text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(ChallengePainter old) => true;
}