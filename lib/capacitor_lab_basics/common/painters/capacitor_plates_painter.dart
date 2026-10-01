import 'package:flutter/material.dart';

import '../render/circuit_render_data.dart';
import '../transform/box_shape_creator.dart';

/// Capacitor plates — `PlateNode` / `BoxNode` three visible faces.
///
/// Use [paintBottom] / [paintTop] so E-field can sit between plates
/// (`CapacitorNode`: bottom → eField → top).
class CapacitorPlatesPainter extends CustomPainter {
  CapacitorPlatesPainter({
    required this.data,
    this.paintBottom = true,
    this.paintTop = true,
  });

  final CircuitRenderData data;
  final bool paintBottom;
  final bool paintTop;

  static const _stroke = Color.fromRGBO(0, 0, 0, 1);

  @override
  void paint(Canvas canvas, Size size) {
    if (paintBottom) _paintPlate(canvas, data.bottomPlate);
    if (paintTop) _paintPlate(canvas, data.topPlate);
  }

  void _paintPlate(Canvas canvas, PlateRenderData plate) {
    _fillFace(canvas, plate.top, data.plateColor);
    _fillFace(canvas, plate.front, data.plateFrontColor);
    _fillFace(canvas, plate.right, data.plateRightColor);
  }

  void _fillFace(Canvas canvas, BoxFacePoints face, Color fill) {
    final path = face.toPath();
    canvas.drawPath(
      path,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = _stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CapacitorPlatesPainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.paintBottom != paintBottom ||
      oldDelegate.paintTop != paintTop;
}
