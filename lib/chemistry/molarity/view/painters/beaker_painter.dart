import 'package:flutter/material.dart';

/// 烧杯外壁 painter：玻璃容器 + 液面刻度（½L / 1L）+ 底部弧线。
///
/// 纯几何绘制 · 不依赖 model。烧杯内液体/沉淀由上层叠加其他 painter。
class BeakerPainter extends CustomPainter {
  const BeakerPainter({
    required this.volumeFraction,
    this.wallColor = const Color(0xFFB0BEC5),
    this.scaleLabels = const ['½ L', '1 L'],
  });

  /// 当前液面高度占满杯比例（volume / maxVolume）· 决定刻度指示。
  final double volumeFraction;
  final Color wallColor;
  final List<String> scaleLabels;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final r = RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(6));
    final wallPaint = Paint()
      ..color = wallColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 外壁（圆角矩形）
    canvas.drawRRect(r, wallPaint);

    // 玻璃高光（左侧半透明竖条）
    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 6, 12, size.height - 24),
        const Radius.circular(6),
      ),
      highlight,
    );

    // 底部弧线（容器内底）
    final bottomPaint = Paint()
      ..color = wallColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final bottomArc = Rect.fromLTWH(4, size.height - 16, size.width - 8, 20);
    canvas.drawArc(bottomArc, 0, 3.1416, false, bottomPaint);

    // 刻度线（½L 与 1L）
    final tickPaint = Paint()
      ..color = const Color(0xFF78909C)
      ..strokeWidth = 1;
    final textStyle = TextStyle(
        fontSize: 9, color: const Color(0xFF546E7A), height: 1.2);
    for (var i = 0; i < scaleLabels.length; i++) {
      final frac = scaleLabels.length == 1 ? 1.0 : (i + 1) / scaleLabels.length;
      final y = size.height - 8 - frac * (size.height - 30);
      canvas.drawLine(Offset(size.width - 26, y), Offset(size.width - 12, y), tickPaint);
      _text(canvas, scaleLabels[i], Offset(size.width - 30, y - 7), textStyle,
          TextAlign.right);
    }

    // 液面位置刻度指针（当前液面高度）
    final levelY = size.height - 8 - volumeFraction.clamp(0.0, 1.0) * (size.height - 30);
    final levelPaint = Paint()
      ..color = const Color(0xFF37474F).withValues(alpha: 0.6)
      ..strokeWidth = 1.5;
    canvas.drawLine(
        Offset(size.width - 30, levelY), Offset(size.width - 10, levelY), levelPaint);
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
  bool shouldRepaint(covariant BeakerPainter old) =>
      old.volumeFraction != volumeFraction || old.scaleLabels != scaleLabels;
}
