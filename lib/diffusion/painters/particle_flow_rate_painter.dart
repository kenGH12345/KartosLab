import 'package:flutter/material.dart';

import '../diffusion_constants.dart';
import '../model/particle_flow_rate.dart';

/// ParticleFlowRateNode — gas-properties @ 7a52c48.
///
/// Pair of color-coded arrows; length ∝ flow rate (particles/ps).
class ParticleFlowRatePainter extends CustomPainter {
  ParticleFlowRatePainter({
    required this.flowRate,
    required this.fillColor,
  });

  /// vector length per 1 particle/ps
  static const double vectorScale = 25;

  static const double xSpacing = 5;
  static const double headHeight = 15;
  static const double headWidth = 15;
  static const double tailWidth = 8;

  final ParticleFlowRate flowRate;
  final Color fillColor;

  double get _minTailLength => headHeight + 4;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height / 2);
    final fill = Paint()..color = fillColor;
    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final leftRate = flowRate.leftFlowRate;
    if (leftRate > 0) {
      final tipX = -(_minTailLength + leftRate * vectorScale);
      _drawArrow(
        canvas,
        origin + Offset(-xSpacing / 2, 0),
        tipX,
        fill,
        stroke,
      );
    }

    final rightRate = flowRate.rightFlowRate;
    if (rightRate > 0) {
      final tipX = _minTailLength + rightRate * vectorScale;
      _drawArrow(
        canvas,
        origin + Offset(xSpacing / 2, 0),
        tipX,
        fill,
        stroke,
      );
    }
  }

  void _drawArrow(
    Canvas canvas,
    Offset tailOrigin,
    double tipX,
    Paint fill,
    Paint stroke,
  ) {
    // ArrowNode from (0,0) to (tipX, 0) relative to tailOrigin.
    final tip = Offset(tailOrigin.dx + tipX, tailOrigin.dy);
    final pointingRight = tipX > 0;
    final sign = pointingRight ? 1.0 : -1.0;
    final length = tipX.abs();
    if (length < 1) return;

    final bodyEndX = tip.dx - sign * headHeight;
    final halfTail = tailWidth / 2;
    final halfHead = headWidth / 2;

    final path = Path()
      ..moveTo(tailOrigin.dx, tailOrigin.dy - halfTail)
      ..lineTo(bodyEndX, tip.dy - halfTail)
      ..lineTo(bodyEndX, tip.dy - halfHead)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(bodyEndX, tip.dy + halfHead)
      ..lineTo(bodyEndX, tip.dy + halfTail)
      ..lineTo(tailOrigin.dx, tip.dy + halfTail)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant ParticleFlowRatePainter oldDelegate) => true;
}

/// Stacked cyan + red flow-rate vector pair under the container.
class ParticleFlowRateVectors extends StatelessWidget {
  const ParticleFlowRateVectors({
    super.key,
    required this.flowRate1,
    required this.flowRate2,
  });

  final ParticleFlowRate flowRate1;
  final ParticleFlowRate flowRate2;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 28,
          width: double.infinity,
          child: CustomPaint(
            painter: ParticleFlowRatePainter(
              flowRate: flowRate1,
              fillColor: const Color(DiffusionConstants.particle1Color),
            ),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 28,
          width: double.infinity,
          child: CustomPaint(
            painter: ParticleFlowRatePainter(
              flowRate: flowRate2,
              fillColor: const Color(DiffusionConstants.particle2Color),
            ),
          ),
        ),
      ],
    );
  }
}
