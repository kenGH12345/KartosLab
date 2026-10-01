import 'package:flutter/material.dart';
import 'package:kratos/color_vision/color_vision_constants.dart';

/// PhET `SolidBeamNode` geometry — leftHalf / rightHalf / wholeBeam, α=0.8.
///
/// [bounds] uses Flutter Rect: left=minX, top=source maxY (upper),
/// right=maxX, bottom=source minY (lower). Matches Bounds2 quirk in source.
class SolidBeamPainter extends CustomPainter {
  SolidBeamPainter({
    required this.bounds,
    required this.cutoffX,
    required this.filterVisible,
    required this.leftColor,
    required this.rightColor,
    required this.wholeColor,
  });

  final Rect bounds;
  final double cutoffX;
  final bool filterVisible;
  final Color leftColor;
  final Color rightColor;
  final Color wholeColor;

  static const double triangleHeight = 30;
  static const double alpha = ColorVisionConstants.defaultBeamAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final minX = bounds.left;
    final maxX = bounds.right;
    final minY = bounds.bottom; // source Bounds2.minY
    final maxY = bounds.top; // source Bounds2.maxY
    final width = maxX - minX;
    if (width <= 0) return;

    final smallTriangleWidth = cutoffX - minX;
    final smallTriangleHeight = smallTriangleWidth * triangleHeight / width;

    final leftHalf = Path()
      ..moveTo(minX, minY)
      ..lineTo(minX, maxY)
      ..lineTo(cutoffX, maxY + smallTriangleHeight)
      ..lineTo(cutoffX, minY - smallTriangleHeight)
      ..close();

    final rightHalf = Path()
      ..moveTo(cutoffX, minY - smallTriangleHeight)
      ..lineTo(cutoffX, maxY + smallTriangleHeight)
      ..lineTo(maxX, maxY + triangleHeight)
      ..lineTo(maxX, minY - triangleHeight)
      ..close();

    final wholeBeam = Path()
      ..moveTo(minX, minY)
      ..lineTo(minX, maxY)
      ..lineTo(maxX, maxY + triangleHeight)
      ..lineTo(maxX, minY - triangleHeight)
      ..close();

    Color withBeamAlpha(Color c) => c.withValues(alpha: alpha * c.a);

    if (filterVisible) {
      canvas.drawPath(leftHalf, Paint()..color = withBeamAlpha(leftColor));
      canvas.drawPath(rightHalf, Paint()..color = withBeamAlpha(rightColor));
    } else {
      canvas.drawPath(wholeBeam, Paint()..color = withBeamAlpha(wholeColor));
    }
  }

  @override
  bool shouldRepaint(covariant SolidBeamPainter oldDelegate) =>
      oldDelegate.bounds != bounds ||
      oldDelegate.cutoffX != cutoffX ||
      oldDelegate.filterVisible != filterVisible ||
      oldDelegate.leftColor != leftColor ||
      oldDelegate.rightColor != rightColor ||
      oldDelegate.wholeColor != wholeColor;
}
