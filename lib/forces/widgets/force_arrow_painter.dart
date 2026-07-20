import 'package:flutter/material.dart';

/// 力箭头绘制器
class ForceArrowPainter extends CustomPainter {
  ForceArrowPainter({
    required this.magnitude,
    required this.direction, // true=right
    this.color = const Color(0xFFEF4444),
    this.label,
    this.maxForce = 500,
  });

  final double magnitude;
  final bool direction;
  final Color color;
  final String? label;
  final double maxForce;

  @override void paint(Canvas c, Size sz) {
    if (magnitude < 1) return;
    final ratio = (magnitude / maxForce).clamp(0.0, 1.0);
    final len = sz.width * 0.8 * ratio;
    final cy = sz.height / 2;
    final headSize = 10.0;
    final sign = direction ? 1.0 : -1.0;
    final bodyLen = len - headSize;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 箭杆
    c.drawLine(Offset(0, cy), Offset(sign * bodyLen, cy), paint);

    // 箭头
    if (bodyLen > 0) {
      final path = Path()
        ..moveTo(sign * len, cy)
        ..lineTo(sign * (bodyLen - headSize), cy - headSize)
        ..lineTo(sign * (bodyLen - headSize), cy + headSize)
        ..close();
      c.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
    }

    // 标签
    if (label != null) {
      final tp = TextPainter(text: TextSpan(text: label!, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)), textDirection: TextDirection.ltr)..layout();
      tp.paint(c, Offset(sign * len + 4, cy - tp.height / 2));
    }
  }

  @override bool shouldRepaint(ForceArrowPainter o) =>
      o.magnitude != magnitude || o.direction != direction || o.color != color || o.label != label;
}
