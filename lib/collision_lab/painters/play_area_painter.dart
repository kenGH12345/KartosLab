import 'package:flutter/material.dart';

import '../collision_lab_colors.dart';
import '../collision_lab_constants.dart';
import '../model/cl_vec.dart';
import '../render/cl_mvt.dart';
import '../render/cl_render_data.dart';

class PlayAreaPainter extends CustomPainter {
  PlayAreaPainter({required this.data, required this.mvt});

  final ClRenderData data;
  final ClMvt mvt;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = data.playAreaRect;
    canvas.drawRect(rect, Paint()..color = CollisionLabColors.gridBackground);

    if (data.gridVisible) {
      _drawGrid(canvas, rect);
    } else if (data.is1d) {
      _drawTopTicks(canvas, rect);
    }

    // Border is painted in a separate overlay layer so it stays above clipped balls
    // (PhET: border Rectangle dilated by lineWidth/2 around playAreaViewBounds).
  }

  void _drawGrid(Canvas canvas, Rect rect) {
    final minor = Paint()
      ..color = CollisionLabColors.minorGridline
      ..strokeWidth = 0.8;
    final major = Paint()
      ..color = CollisionLabColors.majorGridline
      ..strokeWidth = 1.2;

    final topLeft = mvt.viewToModel(Offset(rect.left, rect.top));
    final bottomRight = mvt.viewToModel(Offset(rect.right, rect.bottom));
    final minX = topLeft.x < bottomRight.x ? topLeft.x : bottomRight.x;
    final maxX = topLeft.x > bottomRight.x ? topLeft.x : bottomRight.x;
    final minY = topLeft.y < bottomRight.y ? topLeft.y : bottomRight.y;
    final maxY = topLeft.y > bottomRight.y ? topLeft.y : bottomRight.y;

    for (var x = _snapUp(minX, CollisionLabConstants.minorGridlineSpacing);
        x <= maxX + 1e-9;
        x += CollisionLabConstants.minorGridlineSpacing) {
      final vx = mvt.modelToView(ClVec(x, 0)).dx;
      canvas.drawLine(
        Offset(vx, rect.top),
        Offset(vx, rect.bottom),
        _isMultiple(x, CollisionLabConstants.majorGridlineSpacing)
            ? major
            : minor,
      );
    }
    for (var y = _snapUp(minY, CollisionLabConstants.minorGridlineSpacing);
        y <= maxY + 1e-9;
        y += CollisionLabConstants.minorGridlineSpacing) {
      final vy = mvt.modelToView(ClVec(0, y)).dy;
      canvas.drawLine(
        Offset(rect.left, vy),
        Offset(rect.right, vy),
        _isMultiple(y, CollisionLabConstants.majorGridlineSpacing)
            ? major
            : minor,
      );
    }
  }

  void _drawTopTicks(Canvas canvas, Rect rect) {
    final minor = Paint()
      ..color = CollisionLabColors.tickLine
      ..strokeWidth = 1;
    final major = Paint()
      ..color = CollisionLabColors.majorGridline
      ..strokeWidth = 1.4;
    for (var x = -2.0;
        x <= 2.0 + 1e-9;
        x += CollisionLabConstants.minorGridlineSpacing) {
      final vx = mvt.modelToView(ClVec(x, 0)).dx;
      final isMajor =
          _isMultiple(x, CollisionLabConstants.majorGridlineSpacing);
      final h = isMajor ? 8.0 : 4.0;
      canvas.drawLine(
        Offset(vx, rect.top),
        Offset(vx, rect.top + h),
        isMajor ? major : minor,
      );
    }
  }

  double _snapUp(double v, double step) {
    final q = (v / step).ceilToDouble();
    return q * step;
  }

  bool _isMultiple(double v, double step) {
    final q = v / step;
    return (q - q.roundToDouble()).abs() < 1e-6;
  }

  @override
  bool shouldRepaint(covariant PlayAreaPainter oldDelegate) => true;
}
