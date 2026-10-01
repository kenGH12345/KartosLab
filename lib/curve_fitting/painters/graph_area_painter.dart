import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../curve_fitting_colors.dart';
import '../curve_fitting_constants.dart';
import '../curve_fitting_strings.dart';
import '../render/cf_render_data.dart';
import '../transform/math_coordinate_transform.dart';

/// White graph background, axes, ticks, labels, arrows — PhET `GraphAreaNode`.
class GraphAreaPainter extends CustomPainter {
  GraphAreaPainter({
    required this.render,
    required this.transform,
  });

  final CfRenderData render;
  final MathCoordinateTransform transform;

  static const double _minorTick = 0.3;
  static const double _majorTick = 0.75;
  static const List<double> _majorPositions = [-10, -5, 5, 10];
  static const double _tickLabelDistance = 0.5;
  static const double _axisLabelDistance = 0.2;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = render.graphBackgroundView;
    canvas.drawRect(
      bg,
      Paint()..color = CurveFittingColors.graphBackground,
    );
    canvas.drawRect(
      bg,
      Paint()
        ..color = CurveFittingColors.graphBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final axes = CurveFittingConstants.graphAxesBounds;
    final path = Path();

    // Axes
    final aLeft = transform.modelToView(Offset(axes.left, 0));
    final aRight = transform.modelToView(Offset(axes.right, 0));
    final aBottom = transform.modelToView(Offset(0, axes.top));
    final aTop = transform.modelToView(Offset(0, axes.bottom));
    path.moveTo(aLeft.dx, aLeft.dy);
    path.lineTo(aRight.dx, aRight.dy);
    path.moveTo(aBottom.dx, aBottom.dy);
    path.lineTo(aTop.dx, aTop.dy);

    // Ticks every 1 model unit on both axes
    const bgBounds = CurveFittingConstants.graphBackgroundModelBounds;
    for (var i = bgBounds.left; i <= bgBounds.right; i++) {
      final tickLen =
          _majorPositions.contains(i) ? _majorTick : _minorTick;
      final half = tickLen / 2;
      // Vertical tick on x-axis
      final t0 = transform.modelToView(Offset(i, -half));
      final t1 = transform.modelToView(Offset(i, half));
      path.moveTo(t0.dx, t0.dy);
      path.lineTo(t1.dx, t1.dy);
      // Horizontal tick on y-axis
      final u0 = transform.modelToView(Offset(-half, i));
      final u1 = transform.modelToView(Offset(half, i));
      path.moveTo(u0.dx, u0.dy);
      path.lineTo(u1.dx, u1.dy);
    }
    canvas.drawPath(path, axisPaint);

    // Major tick labels
    const labelStyle = TextStyle(color: Colors.black, fontSize: 14);
    for (final tick in _majorPositions) {
      final xPos = transform.modelToView(Offset(tick, -_tickLabelDistance));
      _drawCenteredText(canvas, '$tick', Offset(xPos.dx, xPos.dy), labelStyle,
          alignTop: true);
      final yPos = transform.modelToView(Offset(-_tickLabelDistance, tick));
      _drawCenteredText(canvas, '$tick', Offset(yPos.dx, yPos.dy), labelStyle,
          alignRight: true);
    }

    // Axis labels
    final xLabel = transform.modelToView(
      Offset(axes.right + _axisLabelDistance, 0),
    );
    final yLabel = transform.modelToView(
      Offset(0, axes.bottom + _axisLabelDistance),
    );
    _drawCenteredText(
      canvas,
      CurveFittingStrings.xSymbol,
      xLabel,
      const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontStyle: FontStyle.italic,
      ),
      alignLeft: true,
    );
    _drawCenteredText(
      canvas,
      CurveFittingStrings.ySymbol,
      yLabel,
      const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontStyle: FontStyle.italic,
      ),
      alignBottom: true,
    );

    // Double-headed arrows
    _drawDoubleArrow(canvas, aLeft, aRight);
    _drawDoubleArrow(canvas, aBottom, aTop);
  }

  void _drawCenteredText(
    Canvas canvas,
    String text,
    Offset anchor,
    TextStyle style, {
    bool alignTop = false,
    bool alignBottom = false,
    bool alignLeft = false,
    bool alignRight = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    var dx = anchor.dx - tp.width / 2;
    var dy = anchor.dy - tp.height / 2;
    if (alignTop) dy = anchor.dy;
    if (alignBottom) dy = anchor.dy - tp.height;
    if (alignLeft) dx = anchor.dx;
    if (alignRight) dx = anchor.dx - tp.width;
    tp.paint(canvas, Offset(dx, dy));
  }

  void _drawDoubleArrow(Canvas canvas, Offset a, Offset b) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;
    _drawArrowHead(canvas, paint, b, a);
    _drawArrowHead(canvas, paint, a, b);
  }

  void _drawArrowHead(Canvas canvas, Paint paint, Offset tip, Offset from) {
    final dx = tip.dx - from.dx;
    final dy = tip.dy - from.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 1e-6) return;
    final ux = dx / len;
    final uy = dy / len;
    const headHeight = 5.0;
    const headWidth = 5.0;
    final base = Offset(tip.dx - ux * headHeight, tip.dy - uy * headHeight);
    final px = -uy;
    final py = ux;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(base.dx + px * headWidth / 2, base.dy + py * headWidth / 2)
      ..lineTo(base.dx - px * headWidth / 2, base.dy - py * headWidth / 2)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant GraphAreaPainter oldDelegate) =>
      oldDelegate.render != render || oldDelegate.transform != transform;
}
