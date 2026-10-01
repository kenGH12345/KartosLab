/// Electron cloud for Make isotopes (IsotopeElectronCloudView subset).
library;

import 'package:flutter/material.dart';

import '../iaam_constants.dart';

class ElectronCloudPainter extends CustomPainter {
  ElectronCloudPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..color = IaamConstants.electronCloud.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..color = IaamConstants.electronCloud.withValues(alpha: 0.18),
    );
  }

  @override
  bool shouldRepaint(covariant ElectronCloudPainter oldDelegate) =>
      oldDelegate.radius != radius;
}

/// Empirical cloud radii (view px) by electron count for Z=1..10.
/// Tuned so labels fit; full IsotopeElectronCloudView radii deferred to P1.
double electronCloudRadiusFor(int electronCount) {
  const radii = <double>[
    0, 40, 50, 60, 70, 75, 80, 85, 90, 95, 100,
  ];
  if (electronCount <= 0) return 40;
  if (electronCount >= radii.length) return radii.last;
  return radii[electronCount];
}
