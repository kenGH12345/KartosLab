import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ColorWheelPainter extends CustomPainter {
  final double brightness;
  final Offset? selectedPoint;
  final Color? selectedColor;
  final double wheelCenterX;
  final double wheelCenterY;
  final double wheelRadius;

  ColorWheelPainter({
    this.brightness = 1.0,
    this.selectedPoint,
    this.selectedColor,
    this.wheelCenterX = 0,
    this.wheelCenterY = 0,
    this.wheelRadius = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = wheelCenterX > 0 ? wheelCenterX : size.width / 2;
    final cy = wheelCenterY > 0 ? wheelCenterY : size.height * 0.38;
    final r = wheelRadius > 0 ? wheelRadius : min(cx, cy) * 0.68;

    // 1 - Hue sweep
    final hueColors = List.generate(361, (i) {
      return HSVColor.fromAHSV(1.0, i.toDouble(), 1.0, brightness).toColor();
    });
    canvas.drawCircle(Offset(cx, cy), r,
      Paint()..shader = SweepGradient(colors: hueColors).createShader(
        Rect.fromCircle(center: Offset(cx, cy), radius: r)));

    // 2 - Saturation overlay
    canvas.drawCircle(Offset(cx, cy), r,
      Paint()..shader = RadialGradient(
        colors: [Colors.white, Colors.transparent],
        stops: [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)));

    // 3 - Rings
    canvas.drawCircle(Offset(cx, cy), r,
      Paint()..style = PaintingStyle.stroke..color = const Color(0xFF334155)..strokeWidth = 3);
    canvas.drawCircle(Offset(cx, cy), r + 4,
      Paint()..style = PaintingStyle.stroke..color = const Color(0xFF64748B)..strokeWidth = 1);

    // 4 - Selection
    if (selectedPoint != null && selectedColor != null) {
      canvas.drawCircle(selectedPoint!, 9,
        Paint()..style = PaintingStyle.stroke..color = Colors.white..strokeWidth = 3);
      canvas.drawCircle(selectedPoint!, 9,
        Paint()..style = PaintingStyle.stroke..color = Colors.black..strokeWidth = 1.5);
      canvas.drawCircle(selectedPoint!, 5,
        Paint()..color = selectedColor!);
    }

    // 5 - Info panel
    if (selectedColor != null) {
      final infoY = cy + r + 26;
      final sc = selectedColor!;
      final rv = (sc.r * 255).round();
      final gv = (sc.g * 255).round();
      final bv = (sc.b * 255).round();
      final hex = '#${rv.toRadixString(16).padLeft(2, '0')}${gv.toRadixString(16).padLeft(2, '0')}${bv.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
      final cname = _nameColor(sc);

      _t(canvas, '颜色名称：$cname', cx, infoY, 12, sc);
      _t(canvas, 'RGB 值：rgb($rv, $gv, $bv)', cx, infoY + 18, 10, const Color(0xFF64748B));
      _t(canvas, '十六进制：$hex', cx, infoY + 34, 10, const Color(0xFF64748B));

      final barY = infoY + 50;
      final barW = size.width * 0.48;
      const barH = 8.0;
      final comps = [
        ('R', rv, const Color(0xFFEF4444)),
        ('G', gv, const Color(0xFF22C55E)),
        ('B', bv, const Color(0xFF3B82F6)),
      ];
      for (int i = 0; i < 3; i++) {
        final by = barY + i * 18;
        _t(canvas, comps[i].$1, cx - barW / 2 - 16, by + barH / 2, 10, comps[i].$3);
        canvas.drawRRect(
          RRect.fromLTRBR(cx - barW / 2, by, cx - barW / 2 + barW, by + barH, const Radius.circular(4)),
          Paint()..color = const Color(0xFFE2E8F0));
        canvas.drawRRect(
          RRect.fromLTRBR(cx - barW / 2, by, cx - barW / 2 + barW * (comps[i].$2 / 255), by + barH, const Radius.circular(4)),
          Paint()..color = comps[i].$3);
        _t(canvas, '${comps[i].$2}', cx + barW / 2 + 20, by + barH / 2, 9, const Color(0xFF64748B));
      }
    }
  }

  String _nameColor(Color c) {
    final r = (c.r * 255).round();
    final g = (c.g * 255).round();
    final b = (c.b * 255).round();
    if (r > 200 && g < 50 && b < 50) return '红色';
    if (r < 50 && g > 200 && b < 50) return '绿色';
    if (r < 50 && g < 50 && b > 200) return '蓝色';
    if (r > 200 && g > 200 && b < 50) return '黄色';
    if (r > 200 && g < 50 && b > 200) return '品红';
    if (r < 50 && g > 200 && b > 200) return '青色';
    if (r > 200 && g > 200 && b > 200) return '白色';
    if (r < 30 && g < 30 && b < 30) return '黑色';
    if (r > 200 && g > 120 && g < 210 && b < 50) return '橙色';
    if (r > 120 && g < 80 && b > 120) return '紫色';
    return '混合色';
  }

  void _t(Canvas canvas, String text, double cx, double cy, double fs, Color c) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fs, fontWeight: FontWeight.w500, color: c)),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(ColorWheelPainter old) => true;
}