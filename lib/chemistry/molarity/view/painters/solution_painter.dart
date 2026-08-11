import 'package:flutter/material.dart';

/// 溶液液面 painter：按体积比例填充烧杯内部。
///
/// 颜色由 model 的 `Solution.solutionColor`（ColorRange 插值）提供 · 高度 = volume/maxVolume。
class SolutionPainter extends CustomPainter {
  const SolutionPainter({
    required this.color,
    required this.fillFraction,
  });

  final Color color;
  final double fillFraction;

  @override
  void paint(Canvas canvas, Size size) {
    final f = fillFraction.clamp(0.0, 1.0);
    if (f <= 0) return;

    final paint = Paint()..color = color;
    // 液面以下填充（含底部圆角）
    final top = size.height - 8 - f * (size.height - 30);
    final body = Rect.fromLTWH(6, top, size.width - 12, size.height - 6 - top);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(6)),
      paint,
    );

    // 液面高光线
    canvas.drawLine(
      Offset(8, top),
      Offset(size.width - 8, top),
      Paint()
        ..color = color.withValues(alpha: 0.6)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant SolutionPainter old) =>
      old.color != color || old.fillFraction != fillFraction;
}
