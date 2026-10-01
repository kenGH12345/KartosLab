/// World-space grid from scene spacing / center via MVT.
library;

import 'package:flutter/material.dart';

import '../model/gao_vec.dart';
import '../render/gao_mvt.dart';

class GaoGridPainter extends CustomPainter {
  GaoGridPainter({
    required this.mvt,
    required this.gridSpacing,
    required this.gridCenter,
    required this.visible,
  });

  final GaoMvt mvt;
  final double gridSpacing;
  final GaoVec gridCenter;
  final bool visible;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible || gridSpacing <= 0) return;
    final thin = Paint()
      ..color = const Color(0xFF808080)
      ..strokeWidth = 1;
    final bold = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    final topLeft = mvt.viewToModel(Offset.zero);
    final bottomRight = mvt.viewToModel(Offset(size.width, size.height));
    final minX = topLeft.x < bottomRight.x ? topLeft.x : bottomRight.x;
    final maxX = topLeft.x > bottomRight.x ? topLeft.x : bottomRight.x;
    final minY = topLeft.y < bottomRight.y ? topLeft.y : bottomRight.y;
    final maxY = topLeft.y > bottomRight.y ? topLeft.y : bottomRight.y;

    final startIx = ((minX - gridCenter.x) / gridSpacing).floor() - 1;
    final endIx = ((maxX - gridCenter.x) / gridSpacing).ceil() + 1;
    final startIy = ((minY - gridCenter.y) / gridSpacing).floor() - 1;
    final endIy = ((maxY - gridCenter.y) / gridSpacing).ceil() + 1;

    for (var ix = startIx; ix <= endIx; ix++) {
      final x = gridCenter.x + ix * gridSpacing;
      final a = mvt.modelToView(GaoVec(x, minY));
      final b = mvt.modelToView(GaoVec(x, maxY));
      canvas.drawLine(a, b, ix == 0 ? bold : thin);
    }
    for (var iy = startIy; iy <= endIy; iy++) {
      final y = gridCenter.y + iy * gridSpacing;
      final a = mvt.modelToView(GaoVec(minX, y));
      final b = mvt.modelToView(GaoVec(maxX, y));
      canvas.drawLine(a, b, iy == 0 ? bold : thin);
    }
  }

  @override
  bool shouldRepaint(covariant GaoGridPainter old) =>
      old.mvt != mvt ||
      old.gridSpacing != gridSpacing ||
      old.gridCenter != gridCenter ||
      old.visible != visible;
}
