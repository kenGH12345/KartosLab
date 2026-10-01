import 'package:flutter/material.dart';

/// WireNode.ts — cubic bezier from sensor body to probe (SkaterPathSensorNode.ts).
class SensorWirePainter extends CustomPainter {
  SensorWirePainter({
    required this.bodyAnchor,
    required this.probeAnchor,
    this.bodyHeight = 200,
    this.lineWidth = 4,
  });

  /// Play-area view coordinate — body center bottom minus (0, 5).
  final Offset bodyAnchor;

  /// Play-area view coordinate — probe left center.
  final Offset probeAnchor;
  final double bodyHeight;
  final double lineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final delta = probeAnchor - bodyAnchor;
    final cp1 = bodyAnchor + Offset(delta.dx / 3, mathMax(delta.dy, bodyHeight * 2));
    const cp2Offset = Offset(-25, 0);
    final cp2 = probeAnchor + cp2Offset;

    final path = Path()
      ..moveTo(bodyAnchor.dx, bodyAnchor.dy)
      ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, probeAnchor.dx, probeAnchor.dy);

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  static double mathMax(double a, double b) => a > b ? a : b;

  /// Body anchor from play-area left edge (panel sits in adjacent column).
  static Offset defaultBodyAnchor(double playAreaHeight) {
    const panelBottomY = 210.0;
    return Offset(0, panelBottomY.clamp(80, playAreaHeight - 40));
  }

  /// Probe left attachment point (ProbeNode @ scale 0.5 → width ≈ 50 view px).
  static Offset probeLeft(Offset probeCenter, {double probeWidth = 50}) {
    return probeCenter - Offset(probeWidth / 2, 0);
  }

  @override
  bool shouldRepaint(covariant SensorWirePainter old) =>
      old.bodyAnchor != bodyAnchor ||
      old.probeAnchor != probeAnchor ||
      old.bodyHeight != bodyHeight;
}
