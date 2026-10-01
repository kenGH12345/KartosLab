import 'package:flutter/material.dart';

import '../../faradays_law_constants.dart';
import '../../model/magnet_orientation.dart';

/// Source-drawn bar magnet — `MagnetNode.js` (not a bitmap).
class MagnetPainter extends CustomPainter {
  MagnetPainter({required this.orientation});

  final MagnetOrientation orientation;

  static const Color _north = Color(FaradaysLawConstants.magnetNorthColorValue);
  static const Color _south = Color(FaradaysLawConstants.magnetSouthColorValue);

  @override
  void paint(Canvas canvas, Size size) {
    final w = FaradaysLawConstants.magnetWidth;
    final h = FaradaysLawConstants.magnetHeight;
    // Local origin at magnet center
    canvas.translate(size.width / 2, size.height / 2);

    final northLeft = orientation == MagnetOrientation.ns;
    _drawHalf(
      canvas,
      color: _north,
      label: 'N',
      left: northLeft ? -w / 2 : 0,
      width: w,
      height: h,
    );
    _drawHalf(
      canvas,
      color: _south,
      label: 'S',
      left: northLeft ? 0 : -w / 2,
      width: w,
      height: h,
    );
  }

  void _drawHalf(
    Canvas canvas, {
    required Color color,
    required String label,
    required double left,
    required double width,
    required double height,
  }) {
    final dx = width * FaradaysLawConstants.magnetOffsetDxRatio;
    final dy = height * FaradaysLawConstants.magnetOffsetDyRatio;
    final halfW = width / 2;

    // Local half centered at (left + halfW/2, 0) in magnet coords —
    // source draws half in local coords then places with left offset.
    canvas.save();
    canvas.translate(left + halfW / 2, 0);

    final darker = Color.lerp(color, Colors.black, FaradaysLawConstants.magnet3dShadowAmount)!;
    final topPath = Path()
      ..moveTo(-halfW / 2, -height / 2)
      ..lineTo(-halfW / 2 + dx, -height / 2 - dy)
      ..lineTo(halfW / 2 + dx, -height / 2 - dy)
      ..lineTo(halfW / 2 + dx, height / 2 - dy)
      ..lineTo(halfW / 2, height / 2)
      ..lineTo(-halfW / 2, -height / 2)
      ..close();
    canvas.drawPath(topPath, Paint()..color = darker);

    canvas.drawRect(
      Rect.fromLTWH(-halfW / 2, -height / 2, halfW, height),
      Paint()..color = color,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final scale = ((halfW * 0.9) / tp.width).clamp(0.0, 1.0);
    canvas.save();
    canvas.scale(scale);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MagnetPainter oldDelegate) =>
      oldDelegate.orientation != orientation;
}
