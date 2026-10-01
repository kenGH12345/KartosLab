import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';
import 'package:kratos/energy_skate_park/render/esp_mvt.dart';

/// Horizontal line at skater.referenceHeight (ReferenceHeightLine.ts subset).
class ReferenceHeightPainter extends CustomPainter {
  ReferenceHeightPainter({
    required this.mvt,
    required this.referenceHeight,
    required this.visible,
  });

  final EspMvt mvt;
  final double referenceHeight;
  final bool visible;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible) return;
    final y = mvt.modelToViewXY(0, referenceHeight).dy;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..color = EspColors.referenceLineFill
        ..strokeWidth = 2,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: 'h₀=${referenceHeight.toStringAsFixed(1)} m',
        style: const TextStyle(
          fontSize: 11,
          color: EspColors.referenceLineFill,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(8, y - 16));
  }

  @override
  bool shouldRepaint(covariant ReferenceHeightPainter old) =>
      old.referenceHeight != referenceHeight ||
      old.visible != visible ||
      old.mvt.viewOrigin != mvt.viewOrigin;
}
