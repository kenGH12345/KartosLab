import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../clb_constants.dart';
import '../render/circuit_render_data.dart';

/// Battery body geometry from `BatteryGraphicNode.js` (Canvas, not Icon).
///
/// Drawn in local coords with origin at body top-center (y=0 at main top ellipse),
/// then scaled by [CircuitRenderData.batteryGraphicScale] and centered at
/// [CircuitRenderData.batteryCenter] (BatteryNode.center = MVT(position)).
class BatteryPainter extends CustomPainter {
  BatteryPainter({required this.data});

  final CircuitRenderData data;

  // —— BatteryGraphicNode.js constants ——
  static const double _perspective = ClbConstants.batteryPerspectiveRatio;
  static const double _mainH = ClbConstants.batteryMainHeight;
  static const double _mainR = ClbConstants.batteryMainRadius;
  static const double _secR = _mainR * _perspective;
  static const double _posTermR = ClbConstants.batteryPositiveTerminalRadius;
  static const double _posTermH = ClbConstants.batteryPositiveTerminalHeight;
  static const double _posSideH = ClbConstants.batteryPositiveSideHeight;
  static const double _negTermR = ClbConstants.batteryNegativeTerminalRadius;

  static const Color _positiveColor = Color.fromRGBO(251, 176, 59, 1);
  static const Color _positiveHighlight = Colors.white;
  static const Color _negativeColor = Color.fromRGBO(53, 53, 53, 1);
  static const Color _negativeHighlight = Color.fromRGBO(142, 142, 142, 1);
  static const Color _terminalColor = Color.fromRGBO(190, 190, 190, 1);
  static const Color _terminalSide = Color.fromRGBO(168, 168, 168, 1);
  static const Color _terminalHighlight = Color.fromRGBO(227, 227, 227, 1);
  static const Color _strokeColor = Color.fromRGBO(33, 33, 33, 1);

  /// Unscaled axis-aligned bounds width (2 × main radius).
  static double get unscaledWidth => 2 * _mainR;

  /// Unscaled height spanning positive-up terminal tip to body bottom.
  static double get unscaledHeightPositiveUp => _mainH + _posTermH;

  /// Scaled width after BatteryNode scale 0.30.
  static double scaledWidth([double scale = ClbConstants.batteryGraphicScale]) =>
      unscaledWidth * scale;

  static double scaledHeightPositiveUp([
    double scale = ClbConstants.batteryGraphicScale,
  ]) =>
      unscaledHeightPositiveUp * scale;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = data.batteryGraphicScale;
    final isPositiveDown = !data.positiveTerminalUp;

    canvas.save();
    canvas.translate(data.batteryCenter.dx, data.batteryCenter.dy);
    canvas.scale(scale);

    // Local graphic: y from terminalTopY to _mainH; center of bounds → (0,0)
    final terminalTopY = isPositiveDown ? 0.0 : -_posTermH;
    final topY = terminalTopY;
    final bottomY = _mainH;
    final localCenterY = (topY + bottomY) / 2;
    canvas.translate(0, -localCenterY);

    final middleY =
        isPositiveDown ? (_mainH - _posSideH) : _posSideH;
    final terminalRadius = isPositiveDown ? _negTermR : _posTermR;

    final stroke = Paint()
      ..color = _strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = ClbConstants.batteryGraphicLineWidth;

    final bottomSide = _sideBand(middleY, _mainH);
    final topSide = _sideBand(middleY, 0);
    final topCap = _ellipse(0, _mainR, _secR);
    final terminalTop = _ellipse(terminalTopY, terminalRadius,
        terminalRadius * _perspective);

    // Fills
    final bottomGrad = isPositiveDown
        ? _cylinderGradient(_mainR, _positiveColor, _positiveHighlight, _positiveColor)
        : _cylinderGradient(_mainR, Colors.black, _negativeHighlight, _negativeColor);
    final topGrad = isPositiveDown
        ? _cylinderGradient(_mainR, Colors.black, _negativeHighlight, _negativeColor)
        : _cylinderGradient(_mainR, _positiveColor, _positiveHighlight, _positiveColor);

    canvas.drawPath(topCap, Paint()
      ..shader = null
      ..color = isPositiveDown ? _negativeColor : _positiveColor
      ..style = PaintingStyle.fill);
    canvas.drawPath(topCap, stroke);

    canvas.drawPath(topSide, Paint()..shader = topGrad);
    canvas.drawPath(topSide, stroke);

    canvas.drawPath(bottomSide, Paint()..shader = bottomGrad);
    canvas.drawPath(bottomSide, stroke);

    canvas.drawPath(terminalTop, Paint()
      ..color = _terminalColor
      ..style = PaintingStyle.fill);
    canvas.drawPath(terminalTop, stroke);

    if (!isPositiveDown) {
      final termSide = _sideBand(terminalTopY, 0, radius: terminalRadius);
      final termGrad = _cylinderGradient(
        terminalRadius,
        _terminalSide,
        _terminalHighlight,
        _terminalSide,
      );
      canvas.drawPath(termSide, Paint()..shader = termGrad);
      canvas.drawPath(termSide, stroke);
    }

    canvas.restore();
  }

  Path _ellipse(double cy, double rx, double ry) {
    return Path()
      ..addOval(Rect.fromCenter(center: Offset(0, cy), width: rx * 2, height: ry * 2));
  }

  /// Vertical cylinder side: elliptical arcs at [y0] and [y1].
  Path _sideBand(double y0, double y1, {double radius = _mainR}) {
    final ry = radius * _perspective;
    final path = Path();
    // Front half at y0 (angles 0→π), then back along y1 (π→0)
    path.addArc(
      Rect.fromCenter(center: Offset(0, y0), width: radius * 2, height: ry * 2),
      0,
      math.pi,
    );
    path.arcTo(
      Rect.fromCenter(center: Offset(0, y1), width: radius * 2, height: ry * 2),
      math.pi,
      -math.pi,
      false,
    );
    path.close();
    return path;
  }

  /// `createGradient` from BatteryGraphicNode.js (quadratic blend stops).
  ui.Gradient _cylinderGradient(
    double radius,
    Color left,
    Color mid,
    Color right,
  ) {
    double blend(double highlight, double far, double position) {
      final d = ((far - position) / (highlight - far)).abs();
      return d * d;
    }

    Color lerp(Color a, Color b, double t) => Color.lerp(a, b, t.clamp(0.0, 1.0))!;

    final colors = <Color>[
      left,
      lerp(left, mid, blend(0.3, 0, 0.1)),
      lerp(left, mid, blend(0.3, 0, 0.15)),
      lerp(left, mid, blend(0.3, 0, 0.2)),
      lerp(left, mid, blend(0.3, 0, 0.25)),
      mid,
      lerp(right, mid, blend(0.3, 0.5, 0.325)),
      lerp(right, mid, blend(0.3, 0.5, 0.35)),
      lerp(right, mid, blend(0.3, 0.5, 0.375)),
      lerp(right, mid, blend(0.3, 0.5, 0.4)),
      lerp(right, mid, blend(0.3, 0.5, 0.425)),
      lerp(right, mid, blend(0.3, 0.5, 0.45)),
      lerp(right, mid, blend(0.3, 0.5, 0.475)),
      right,
    ];
    const stops = <double>[
      0.0,
      0.1,
      0.15,
      0.2,
      0.25,
      0.3,
      0.325,
      0.35,
      0.375,
      0.4,
      0.425,
      0.45,
      0.475,
      0.5,
    ];
    return ui.Gradient.linear(
      Offset(-radius, 0),
      Offset(radius, 0),
      colors,
      stops,
    );
  }

  @override
  bool shouldRepaint(covariant BatteryPainter oldDelegate) =>
      oldDelegate.data != data;
}
