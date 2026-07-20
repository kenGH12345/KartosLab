import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 加速度计可视化组件
/// 半圆形表盘 + 指针，显示加速度方向和大小
class Accelerometer extends StatelessWidget {
  const Accelerometer({super.key, required this.acceleration, this.maxAccel = 10});
  final double acceleration;
  final double maxAccel;

  @override Widget build(BuildContext context) => SizedBox(
    width: 140, height: 90,
    child: CustomPaint(painter: _AccelerometerPainter(accel: acceleration, maxAccel: maxAccel)),
  );
}

class _AccelerometerPainter extends CustomPainter {
  _AccelerometerPainter({required this.accel, required this.maxAccel});
  final double accel, maxAccel;

  @override void paint(Canvas c, Size sz) {
    final cx = sz.width / 2, cy = sz.height * 0.45;
    final arcR = sz.width * 0.35;

    // 半圆弧
    c.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: arcR), math.pi, math.pi, false,
        Paint()..color = const Color(0xFFCBD5E1)..style = PaintingStyle.stroke..strokeWidth = 2);

    // 负/正方向标签
    _drawLabel(c, '← 负', Offset(cx - arcR - 20, cy), const TextStyle(fontSize: 9, color: Color(0xFF64748B)));
    _drawLabel(c, '正 →', Offset(cx + arcR - 10, cy), const TextStyle(fontSize: 9, color: Color(0xFF64748B)));

    // 刻度
    for (var v = -10; v <= 10; v += 1) {
      final ratio = (v + maxAccel) / (2 * maxAccel);
      final angle = math.pi * ratio;
      final isZero = v == 0;
      if (isZero) {
        final rOut = arcR + 10;
        c.drawLine(
            Offset(cx + (arcR - 8) * math.cos(angle), cy + (arcR - 8) * math.sin(angle)),
            Offset(cx + rOut * math.cos(angle), cy + rOut * math.sin(angle)),
            Paint()..color = const Color(0xFF1E293B)..strokeWidth = 2.5);
      } else if (v % 5 == 0) {
        c.drawLine(
            Offset(cx + (arcR - 8) * math.cos(angle), cy + (arcR - 8) * math.sin(angle)),
            Offset(cx + (arcR + 5) * math.cos(angle), cy + (arcR + 5) * math.sin(angle)),
            Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 2);
      } else {
        c.drawLine(
            Offset(cx + (arcR - 4) * math.cos(angle), cy + (arcR - 4) * math.sin(angle)),
            Offset(cx + (arcR + 5) * math.cos(angle), cy + (arcR + 5) * math.sin(angle)),
            Paint()..color = const Color(0xFFCBD5E1)..strokeWidth = 1);
      }
      // 数字标签（偶数值）
      if (v % 2 == 0 && v != 0) {
        final tp = TextPainter(text: TextSpan(text: '${v.abs()}',
            style: const TextStyle(fontSize: 8, color: Color(0xFF94A3B8))), textDirection: TextDirection.ltr)..layout();
        tp.paint(c, Offset(cx + (arcR + 6) * math.cos(angle) - tp.width / 2,
            cy + (arcR + 6) * math.sin(angle) - tp.height / 2));
      }
    }

    // 指针
    final clamped = accel.clamp(-maxAccel, maxAccel);
    final ratio = ((clamped + maxAccel) / (2 * maxAccel)).clamp(0.0, 1.0);
    final angle = math.pi * ratio;
    final ptrLen = arcR - 8;
    c.drawLine(Offset(cx, cy), Offset(cx + ptrLen * math.cos(angle), cy + ptrLen * math.sin(angle)),
        Paint()..color = const Color(0xFF7C3AED)..strokeWidth = 2.5..strokeCap = StrokeCap.round);
    c.drawCircle(Offset(cx, cy), 4, Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.fill);

    // 数值
    final valTp = TextPainter(text: TextSpan(
        text: 'a = ${accel.toStringAsFixed(2)} m/s²',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
        textDirection: TextDirection.ltr)..layout();
    valTp.paint(c, Offset(cx - valTp.width / 2, cy + arcR + 10));
  }

  void _drawLabel(Canvas c, String t, Offset p, TextStyle s) {
    final tp = TextPainter(text: TextSpan(text: t, style: s), textDirection: TextDirection.ltr)..layout();
    tp.paint(c, p);
  }

  @override bool shouldRepaint(_AccelerometerPainter o) => o.accel != accel;
}
