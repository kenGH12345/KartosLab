import 'package:flutter/material.dart';

import '../../faradays_law_constants.dart';

/// Four directional drag-hint arrows — `MagnetMovementArrowsNode.js`.
class MagnetArrowsPainter extends CustomPainter {
  MagnetArrowsPainter({required this.magnetSize});

  final Size magnetSize;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = const Color(FaradaysLawConstants.magnetArrowFillValue)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final halfW = magnetSize.width / 2;
    final halfH = magnetSize.height / 2;
    const d = FaradaysLawConstants.magnetArrowDistance;

    _arrow(canvas, fill, stroke, Offset(cx + halfW + d + 15, cy), 0);
    _arrow(canvas, fill, stroke, Offset(cx - halfW - d - 15, cy), mathPi);
    _arrow(canvas, fill, stroke, Offset(cx, cy - halfH - d - 15), -mathPi / 2);
    _arrow(canvas, fill, stroke, Offset(cx, cy + halfH + d + 15), mathPi / 2);
  }

  static const double mathPi = 3.141592653589793;

  void _arrow(Canvas canvas, Paint fill, Paint stroke, Offset tip, double rotation) {
    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(rotation);
    // Arrow pointing +X, tip at origin-ish — source: 0,0 → 30,0
    final path = Path()
      ..moveTo(-30, 0)
      ..lineTo(-12, -5)
      ..lineTo(-12, -11)
      ..lineTo(0, 0)
      ..lineTo(-12, 11)
      ..lineTo(-12, 5)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MagnetArrowsPainter oldDelegate) =>
      oldDelegate.magnetSize != magnetSize;
}
