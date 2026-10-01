import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Orange Reset All — scenery-phet `ResetAllButton` / `ResetButton` / `ResetShape`.
///
/// Drawn programmatically (no Material Icons, no PNG). Icon is the filled
/// curved arrow from `ResetShape.ts` with `adjustShapeForStroke: true`.
class ClbResetAllButton extends StatelessWidget {
  const ClbResetAllButton({
    super.key,
    required this.onPressed,
    this.radius = 25,
  });

  final VoidCallback onPressed;

  /// CapacitanceScreenView / CLBLightBulbScreenView: `radius: 25`.
  final double radius;

  /// `PhetColorScheme.RESET_ALL_BUTTON_BASE_COLOR`
  static const Color baseColor = Color.fromRGBO(247, 151, 34, 1);

  @override
  Widget build(BuildContext context) {
    final d = radius * 2;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: CustomPaint(
        size: Size(d, d),
        painter: _ResetAllPainter(radius: radius),
      ),
    );
  }
}

class _ResetAllPainter extends CustomPainter {
  _ResetAllPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);

    // Round orange disc (ResetAllButton baseColor).
    final disc = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.4),
        radius: 1.05,
        colors: const [
          Color.fromRGBO(255, 190, 90, 1),
          ClbResetAllButton.baseColor,
          Color.fromRGBO(210, 120, 20, 1),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: radius));
    canvas.drawCircle(c, radius, disc);
    canvas.drawCircle(
      c,
      radius - 0.5,
      Paint()
        ..color = const Color.fromRGBO(160, 90, 15, 1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Icon offset — ResetButton.ts yContentOffset (adjustShapeForStroke → x=0).
    canvas.save();
    canvas.translate(c.dx, c.dy - 0.0125 * radius);

    final arrow = _resetShapePath(radius, adjustShapeForStroke: true);
    canvas.drawPath(arrow, Paint()..color = Colors.white);
    canvas.drawPath(
      arrow,
      Paint()
        ..color = const Color.fromRGBO(80, 80, 80, 1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  /// `scenery-phet/js/ResetShape.ts` — origin at circle center.
  static Path _resetShapePath(
    double radius, {
    required bool adjustShapeForStroke,
  }) {
    const radiusAdjustment = 0.8;
    final headWidthScale = adjustShapeForStroke ? 2.0 : 2.25;
    final adj = adjustShapeForStroke ? radiusAdjustment : 0.0;

    final innerR = radius * 0.4 - adj;
    final outerR = radius * 0.625 + adj;
    final headWidth = headWidthScale * (outerR - innerR);

    const startAngle = -math.pi * 0.35;
    const endToNeck = -2 * math.pi * 0.85;
    const arrowHeadSpan = -math.pi * 0.18;
    final neckAngle = startAngle + endToNeck;

    double cosA(double a) => math.cos(a);
    double sinA(double a) => math.sin(a);

    final path = Path()
      ..moveTo(innerR * cosA(startAngle), innerR * sinA(startAngle))
      ..lineTo(outerR * cosA(startAngle), outerR * sinA(startAngle));

    // Outer curve — kite `arc(..., anticlockwise: true)` ≈ Flutter negative sweep.
    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: outerR),
      startAngle,
      endToNeck,
      false,
    );

    final extrusion = (headWidth - (outerR - innerR)) / 2;
    path.lineTo(
      (outerR + extrusion) * cosA(neckAngle),
      (outerR + extrusion) * sinA(neckAngle),
    );

    final pointRadius = (outerR + innerR) * 0.55;
    path.lineTo(
      pointRadius * cosA(neckAngle + arrowHeadSpan),
      pointRadius * sinA(neckAngle + arrowHeadSpan),
    );
    path.lineTo(
      (innerR - extrusion) * cosA(neckAngle),
      (innerR - extrusion) * sinA(neckAngle),
    );
    path.lineTo(
      innerR * cosA(neckAngle),
      innerR * sinA(neckAngle),
    );

    // Inner curve — kite `arc(..., anticlockwise: false)` from neck → start.
    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: innerR),
      neckAngle,
      -endToNeck,
      false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _ResetAllPainter oldDelegate) =>
      oldDelegate.radius != radius;
}
