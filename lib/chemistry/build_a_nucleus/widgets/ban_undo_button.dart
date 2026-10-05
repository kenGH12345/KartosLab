/// Decay 面板左侧 Undo。对标 scenery-phet `UndoButton`（黄圆 + 回弯箭头）。
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

class BanUndoButton extends StatelessWidget {
  const BanUndoButton({
    super.key,
    required this.onPressed,
    this.radius = 18,
  });

  final VoidCallback onPressed;
  final double radius;

  /// scenery-phet Undo 黄。
  static const Color baseColor = Color(0xFFFFD83A);

  @override
  Widget build(BuildContext context) {
    final d = radius * 2;
    return Tooltip(
      message: '撤销衰变',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const ValueKey('ban_undo_decay'),
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: CustomPaint(
            size: Size(d, d),
            painter: const _UndoDiscPainter(baseColor),
          ),
        ),
      ),
    );
  }
}

class _UndoDiscPainter extends CustomPainter {
  const _UndoDiscPainter(this.base);

  final Color base;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 1.05,
          colors: [
            Color.lerp(Colors.white, base, 0.15)!,
            base,
            Color.lerp(base, Colors.black, 0.25)!,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(
      c,
      r - 0.6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black.withValues(alpha: 0.35),
    );

    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.22
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(center: c.translate(0, r * 0.08), radius: r * 0.42);
    canvas.drawArc(rect, -0.2, -math.pi * 1.15, false, p);
    final tip = Offset(c.dx - r * 0.38, c.dy - r * 0.18);
    final head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx + r * 0.32, tip.dy - r * 0.08)
      ..lineTo(tip.dx + r * 0.18, tip.dy + r * 0.28)
      ..close();
    canvas.drawPath(head, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _UndoDiscPainter oldDelegate) =>
      oldDelegate.base != base;
}
