import 'package:flutter/material.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';
import 'package:kratos/energy_skate_park/render/esp_mvt.dart';

class GridPainter extends CustomPainter {
  GridPainter({required this.mvt, required this.visible});

  final EspMvt mvt;
  final bool visible;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible) return;
    final paint = Paint()
      ..color = EspColors.gridLine
      ..strokeWidth = 1;

    // 1 m spacing in model.
    const span = 12.0;
    for (var x = -span; x <= span; x += 1) {
      final a = mvt.modelToViewXY(x, -1);
      final b = mvt.modelToViewXY(x, 10);
      canvas.drawLine(Offset(a.dx, 0), Offset(b.dx, size.height), paint);
    }
    for (var y = 0.0; y <= 10; y += 1) {
      final a = mvt.modelToViewXY(-span, y);
      final b = mvt.modelToViewXY(span, y);
      canvas.drawLine(Offset(0, a.dy), Offset(size.width, b.dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter old) =>
      old.visible != visible || old.mvt.viewOrigin != mvt.viewOrigin;
}
