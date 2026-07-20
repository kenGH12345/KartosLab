import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 半圆形速度表：0-40 m/s
class Speedometer extends StatelessWidget {
  const Speedometer({super.key, required this.speed, this.maxSpeed = 40});
  final double speed;
  final double maxSpeed;

  @override Widget build(BuildContext context) => SizedBox(
    width: 120, height: 70,
    child: CustomPaint(painter: _SpeedometerPainter(speed: speed, maxSpeed: maxSpeed)),
  );
}

class _SpeedometerPainter extends CustomPainter {
  _SpeedometerPainter({required this.speed, required this.maxSpeed});
  final double speed;
  final double maxSpeed;

  @override void paint(Canvas c, Size sz) {
    final cx = sz.width / 2, cy = sz.height;
    final radius = sz.width * 0.38;
    final arcPaint = Paint()..color = const Color(0xFF64748B)..style = PaintingStyle.stroke..strokeWidth = 3;

    // 半圆刻度弧
    c.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: radius), math.pi, math.pi, false, arcPaint);

    // 刻度线
    final tickPaint = Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 2;
    for (var v = 0; v <= 40; v += 10) {
      final angle = math.pi + (v / maxSpeed) * math.pi;
      final x1 = cx + (radius - 6) * math.cos(angle);
      final y1 = cy + (radius - 6) * math.sin(angle);
      final x2 = cx + (radius + 4) * math.cos(angle);
      final y2 = cy + (radius + 4) * math.sin(angle);
      c.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
      final tp = TextPainter(text: TextSpan(text: '$v', style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))), textDirection: TextDirection.ltr)..layout();
      tp.paint(c, Offset(x2 + 2, y2 - tp.height / 2));
    }

    // 指针
    final ratio = (speed / maxSpeed).clamp(0.0, 1.0);
    final angle = math.pi + ratio * math.pi;
    final ptrLen = radius - 10;
    final px = cx + ptrLen * math.cos(angle);
    final py = cy + ptrLen * math.sin(angle);
    c.drawLine(Offset(cx, cy), Offset(px, py), Paint()..color = const Color(0xFFDC2626)..strokeWidth = 3..strokeCap = StrokeCap.round);

    // 数值
    final tp = TextPainter(text: TextSpan(text: speed.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))), textDirection: TextDirection.ltr)..layout();
    tp.paint(c, Offset(cx - tp.width / 2, cy - radius + 4));
  }

  @override bool shouldRepaint(_SpeedometerPainter o) => o.speed != speed;
}
