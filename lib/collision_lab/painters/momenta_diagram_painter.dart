import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../collision_lab_colors.dart';
import '../collision_lab_constants.dart';
import '../render/cl_render_data.dart';

/// Momenta diagram in model-space coordinates remapped to [size].
class MomentaDiagramPainter extends CustomPainter {
  MomentaDiagramPainter({required this.data});

  final ClRenderData data;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = data.momentaBounds;
    final w = bounds.width;
    final h = bounds.height;
    if (w <= 0 || h <= 0) return;

    Offset toView(Offset model) {
      final nx = (model.dx - bounds.left) / w;
      final ny = (bounds.top + h - model.dy) / h; // invert Y
      return Offset(nx * size.width, ny * size.height);
    }

    // Background + grid
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = CollisionLabColors.gridBackground,
    );
    final minor = Paint()
      ..color = CollisionLabColors.minorGridline
      ..strokeWidth = 0.7;
    final major = Paint()
      ..color = CollisionLabColors.majorGridline
      ..strokeWidth = 1.0;
    final spacing = CollisionLabConstants.minorGridlineSpacing /
        (data.momentaZoom / CollisionLabConstants.momentaZoomDefault);
    for (var x = _snap(bounds.left, spacing);
        x <= bounds.right + 1e-9;
        x += spacing) {
      final vx = toView(Offset(x, 0)).dx;
      final isMajor = _isMultiple(x, spacing * 5);
      canvas.drawLine(Offset(vx, 0), Offset(vx, size.height), isMajor ? major : minor);
    }
    for (var y = _snap(bounds.top, spacing);
        y <= bounds.bottom + 1e-9;
        y += spacing) {
      final vy = toView(Offset(0, y)).dy;
      final isMajor = _isMultiple(y, spacing * 5);
      canvas.drawLine(Offset(0, vy), Offset(size.width, vy), isMajor ? major : minor);
    }

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = CollisionLabColors.panelStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    for (final v in data.momentaVectors) {
      _arrow(canvas, toView(v.tail), toView(v.tip), v.color, v.label);
    }
    final total = data.totalMomenta;
    if (total != null) {
      _arrow(canvas, toView(total.tail), toView(total.tip), total.color, total.label);
    }
  }

  void _arrow(
    Canvas canvas,
    Offset tail,
    Offset tip,
    Color color,
    String? label,
  ) {
    final delta = tip - tail;
    if (delta.distance < 1.5) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(tail, tip, paint);
    final angle = math.atan2(delta.dy, delta.dx);
    const headLen = 8.0;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - headLen * math.cos(angle - 0.45),
          tip.dy - headLen * math.sin(angle - 0.45))
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - headLen * math.cos(angle + 0.45),
          tip.dy - headLen * math.sin(angle + 0.45));
    canvas.drawPath(path, paint);
    if (label != null) {
      final mid = Offset((tail.dx + tip.dx) / 2, (tail.dy + tip.dy) / 2 - 8);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(mid.dx - tp.width / 2, mid.dy));
    }
  }

  double _snap(double v, double step) {
    if (step == 0) return v;
    return (v / step).ceilToDouble() * step;
  }

  bool _isMultiple(double v, double step) {
    if (step == 0) return false;
    final q = v / step;
    return (q - q.roundToDouble()).abs() < 1e-5;
  }

  @override
  bool shouldRepaint(covariant MomentaDiagramPainter oldDelegate) => true;
}
