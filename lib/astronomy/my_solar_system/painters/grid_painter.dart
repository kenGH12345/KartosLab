/// World-space grid. Spacing from [SimulationConfig]; lines follow MVT.
///
/// [KEPLER-SECONDARY] SolarSystemCommonGridNode spacing=1 AU.
library;

import 'package:flutter/material.dart';

import '../config/simulation_config.dart';
import '../my_solar_system_colors.dart';
import '../render/mss_mvt.dart';

class GridPainter extends CustomPainter {
  GridPainter({
    required this.mvt,
    required this.visible,
    this.config = SimulationConfig.instance,
  });

  final MssMvt mvt;
  final bool visible;
  final SimulationConfig config;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible) return;
    final paint = Paint()
      ..color = const Color(0xFF808080)
      ..strokeWidth = 1;
    final bold = Paint()
      ..color = MySolarSystemColors.foreground
      ..strokeWidth = 2;
    final n = config.gridHalfCount;
    final spacing = config.gridSpacing;
    for (var i = -n; i <= n; i++) {
      final x = mvt.toViewDelta(i * spacing);
      final y = mvt.toViewDelta(i * spacing);
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
