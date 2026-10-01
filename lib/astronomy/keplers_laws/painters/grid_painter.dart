import 'package:flutter/material.dart';

import '../keplers_laws_colors.dart';
import '../keplers_laws_constants.dart';
import '../render/keplers_mvt.dart';

/// [已确认] SolarSystemCommonGridNode spacing=1, 60 lines, bold origin
class GridPainter extends CustomPainter {
  GridPainter({required this.mvt, required this.visible});

  final KeplersMvt mvt;
  final bool visible;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible) return;
    final paint = Paint()
      ..color = const Color(0xFF808080)
      ..strokeWidth = 1;
    final bold = Paint()
      ..color = KeplersLawsColors.foreground
      ..strokeWidth = 2;
    const n = 30;
    for (var i = -n; i <= n; i++) {
      final x = mvt.toViewDelta(i * KeplersLawsConstants.gridSpacing);
      final y = mvt.toViewDelta(i * KeplersLawsConstants.gridSpacing);
      final p = i == 0 ? bold : paint;
      canvas.drawLine(
        Offset(mvt.center.dx + x, 0),
        Offset(mvt.center.dx + x, size.height),
        p,
      );
      canvas.drawLine(
        Offset(0, mvt.center.dy - y),
        Offset(size.width, mvt.center.dy - y),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter old) =>
      old.mvt != mvt || old.visible != visible;
}
