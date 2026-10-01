import 'package:flutter/material.dart';

import '../model/water_side_geometry.dart';
import '../waves_intro_constants.dart';
import '../model/lattice.dart';

/// Water side view — filled surface from center-line lattice values.
/// [已确认] WaterSideViewNode + WaveInterferenceUtils @ 31ebfd7
class WaterSideViewPainter extends CustomPainter {
  WaterSideViewPainter({required this.lattice});

  final Lattice lattice;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final values = <double>[];
    lattice.getCenterLineValues(values);
    final pointSourceIndex = WavesIntroConstants.pointSourceHorizontal -
        WavesIntroConstants.latticePadding;
    final pts = WaterSideGeometry.sidePathPoints(
      centerLine: values,
      waveAreaBounds: bounds,
      pointSourceIndex: pointSourceIndex,
    );
    if (pts.isEmpty) return;

    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    path
      ..lineTo(pts.last.dx, bounds.bottom)
      ..lineTo(pts.first.dx, bounds.bottom)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = WaterSideGeometry.waterSideColor
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant WaterSideViewPainter oldDelegate) => true;
}
