import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../faradays_law_constants.dart';

/// Coil↔bulb wires — `CoilsWiresNode.js`.
class CoilsWiresPainter extends CustomPainter {
  CoilsWiresPainter({required this.topCoilVisible});

  final bool topCoilVisible;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(FaradaysLawConstants.wireColorValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = FaradaysLawConstants.wireWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bulb = FaradaysLawConstants.bulbPosition;
    final leftStart = Offset(bulb.dx - 15, bulb.dy);
    final rightStart = Offset(bulb.dx + 10, bulb.dy);

    final bottom = FaradaysLawConstants.bottomCoilPosition;
    final bottomTopEnd = bottom + FaradaysLawConstants.fourCoilTopEnd;
    final bottomBottomEnd = bottom + FaradaysLawConstants.fourCoilBottomEnd;

    const r = FaradaysLawConstants.wireArcRadius;

    // Bottom coil left-bottom wire
    _polyline(canvas, paint, [
      leftStart,
      Offset(leftStart.dx, bottomBottomEnd.dy - r),
    ]);
    _quadTo(canvas, paint, Offset(leftStart.dx, bottomBottomEnd.dy - r),
        Offset(leftStart.dx, bottomBottomEnd.dy),
        Offset(leftStart.dx + r, bottomBottomEnd.dy));
    _polyline(canvas, paint, [
      Offset(leftStart.dx + r, bottomBottomEnd.dy),
      bottomBottomEnd,
    ]);

    // Bottom coil right-top wire
    _polyline(canvas, paint, [
      rightStart,
      Offset(rightStart.dx, bottomTopEnd.dy - r),
    ]);
    _quadTo(canvas, paint, Offset(rightStart.dx, bottomTopEnd.dy - r),
        Offset(rightStart.dx, bottomTopEnd.dy),
        Offset(rightStart.dx + r, bottomTopEnd.dy));
    _polyline(canvas, paint, [
      Offset(rightStart.dx + r, bottomTopEnd.dy),
      bottomTopEnd,
    ]);

    if (!topCoilVisible) return;

    final top = FaradaysLawConstants.topCoilPosition;
    final topTopEnd = top + FaradaysLawConstants.twoCoilTopEnd;
    final topBottomEnd = top + FaradaysLawConstants.twoCoilBottomEnd;

    // Top coil top wire
    const lengthRatio = 0.5;
    const yMargin = 18.0;
    final horizontalLength = topTopEnd.dx - rightStart.dx;
    final arcA = rightStart + Offset(horizontalLength * lengthRatio, yMargin);
    final arcB = Offset(rightStart.dx + horizontalLength * lengthRatio, topTopEnd.dy);

    _polyline(canvas, paint, [
      rightStart + const Offset(0, yMargin),
      Offset(arcA.dx - r, arcA.dy),
    ]);
    _quadTo(canvas, paint, Offset(arcA.dx - r, arcA.dy), arcA,
        Offset(arcA.dx, arcA.dy - r));
    _polyline(canvas, paint, [
      Offset(arcA.dx, arcA.dy - r),
      Offset(arcB.dx, arcB.dy + r),
    ]);
    _quadTo(canvas, paint, Offset(arcB.dx, arcB.dy + r), arcB,
        Offset(arcB.dx + r, arcB.dy));
    _polyline(canvas, paint, [
      Offset(arcB.dx + r, arcB.dy),
      topTopEnd,
    ]);

    // Top coil bottom wire (simplified continuous path)
    const lengthRatio2 = 0.55;
    const yMargin2 = 35.0;
    final horizontalLength2 = topBottomEnd.dx - leftStart.dx;
    final arcX = Offset(rightStart.dx, leftStart.dy + yMargin2);
    final arcY = leftStart + Offset(horizontalLength2 * lengthRatio2, yMargin2);
    final arcZ =
        Offset(leftStart.dx + horizontalLength2 * lengthRatio2, topBottomEnd.dy);

    _polyline(canvas, paint, [
      leftStart + const Offset(0, yMargin2),
      Offset(arcX.dx - r, arcX.dy),
    ]);
    // Arc across
    final arcPath = Path()
      ..moveTo(arcX.dx - r, arcX.dy)
      ..arcTo(
        Rect.fromCircle(center: arcX, radius: r),
        math.pi,
        -math.pi,
        false,
      );
    canvas.drawPath(arcPath, paint);
    _polyline(canvas, paint, [
      Offset(arcX.dx + r, arcX.dy),
      Offset(arcY.dx - r, arcY.dy),
    ]);
    _quadTo(canvas, paint, Offset(arcY.dx - r, arcY.dy), arcY,
        Offset(arcY.dx, arcY.dy - r));
    _polyline(canvas, paint, [
      Offset(arcY.dx, arcY.dy - r),
      Offset(arcZ.dx, arcZ.dy + r),
    ]);
    _quadTo(canvas, paint, Offset(arcZ.dx, arcZ.dy + r), arcZ,
        Offset(arcZ.dx + r, arcZ.dy));
    _polyline(canvas, paint, [
      Offset(arcZ.dx + r, arcZ.dy),
      topBottomEnd,
    ]);
  }

  void _polyline(Canvas canvas, Paint paint, List<Offset> pts) {
    if (pts.length < 2) return;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  void _quadTo(
    Canvas canvas,
    Paint paint,
    Offset from,
    Offset control,
    Offset to,
  ) {
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(control.dx, control.dy, to.dx, to.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CoilsWiresPainter oldDelegate) =>
      oldDelegate.topCoilVisible != topCoilVisible;
}
