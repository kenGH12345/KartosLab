/// Electron cloud — shred `IsotopeElectronCloudView`.
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ElectronCloudPainter extends CustomPainter {
  ElectronCloudPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    if (radius <= 1) return;
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..shader = ui.Gradient.radial(
          c,
          radius,
          const [
            Color.fromRGBO(0, 0, 255, 0),
            Color.fromRGBO(0, 0, 255, 0.4),
          ],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant ElectronCloudPainter oldDelegate) =>
      oldDelegate.radius != radius;
}

/// Covalent radii (pm) × empirical factors, MVT scale 1 → view px.
/// `MAP_ELECTRON_COUNT_TO_RADIUS` × `RADIUS_ADJUSTMENT_FACTORS`.
double electronCloudRadiusFor(int electronCount) {
  if (electronCount <= 0) return 0;
  const radii = <int, double>{
    1: 38,
    2: 32,
    3: 134,
    4: 90,
    5: 82,
    6: 77,
    7: 75,
    8: 73,
    9: 71,
    10: 69,
  };
  const adjust = <int, double>{
    1: 1.75,
    2: 1.85,
    4: 1.35,
    5: 1.4,
    6: 1.45,
    7: 1.45,
    8: 1.45,
    9: 1.45,
    10: 1.45,
  };
  final base = radii[electronCount] ?? radii[10]!;
  return base * (adjust[electronCount] ?? 1);
}
