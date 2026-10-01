import 'package:flutter/material.dart';

import '../model/beers_law_model.dart';
import 'beers_law_mvt.dart';

/// PhET `BeamNode` — rectangular beam with LinearGradient across cuvette.
class BeersLawBeamNode extends StatelessWidget {
  const BeersLawBeamNode({
    super.key,
    required this.model,
    this.mvt = const BeersLawMvt(),
  });

  final BeersLawModel model;
  final BeersLawMvt mvt;

  @override
  Widget build(BuildContext context) {
    if (!model.beam.isVisible) return const SizedBox.shrink();

    final fill = model.beam.fill;
    if (fill == null) return const SizedBox.shrink();

    final origin = mvt.modelToView(model.beam.origin);
    final h = mvt.modelToViewDelta(model.beam.heightCm);
    final w = mvt.modelToViewDelta(model.beam.lengthCm);
    // overlap toward light housing (source xOverlap = 1 cm)
    final xOverlap = mvt.modelToViewDelta(1);
    final left = origin.dx - xOverlap;
    final top = origin.dy;
    final totalW = w + xOverlap;

    final cuvetteLeft = mvt.modelToViewDelta(fill.cuvetteLeftX) - left;
    final cuvetteW = mvt.modelToViewDelta(fill.cuvetteWidthCm);

    return Positioned(
      left: left,
      top: top,
      width: totalW,
      height: h,
      child: IgnorePointer(
        child: CustomPaint(
          size: Size(totalW, h),
          painter: _BeamPainter(
            base: fill.baseColor,
            leftAlpha: fill.leftAlpha,
            rightAlpha: fill.rightAlpha,
            gradientStartX: cuvetteLeft.clamp(0, totalW),
            gradientWidth: cuvetteW.clamp(1, totalW),
          ),
        ),
      ),
    );
  }
}

class _BeamPainter extends CustomPainter {
  _BeamPainter({
    required this.base,
    required this.leftAlpha,
    required this.rightAlpha,
    required this.gradientStartX,
    required this.gradientWidth,
  });

  final Color base;
  final double leftAlpha;
  final double rightAlpha;
  final double gradientStartX;
  final double gradientWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final leftColor = base.withValues(alpha: leftAlpha);
    final rightColor = base.withValues(alpha: rightAlpha);

    // Before cuvette: full intensity
    if (gradientStartX > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, gradientStartX, size.height),
        Paint()..color = leftColor,
      );
    }

    // Across cuvette: LinearGradient
    final gRect = Rect.fromLTWH(
      gradientStartX,
      0,
      gradientWidth,
      size.height,
    );
    canvas.drawRect(
      gRect,
      Paint()
        ..shader = LinearGradient(
          colors: [leftColor, rightColor],
        ).createShader(gRect),
    );

    // After cuvette: attenuated
    final afterX = gradientStartX + gradientWidth;
    if (afterX < size.width) {
      canvas.drawRect(
        Rect.fromLTWH(afterX, 0, size.width - afterX, size.height),
        Paint()..color = rightColor,
      );
    }

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.grey.withValues(alpha: 0.35)
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(covariant _BeamPainter oldDelegate) =>
      oldDelegate.base != base ||
      oldDelegate.leftAlpha != leftAlpha ||
      oldDelegate.rightAlpha != rightAlpha ||
      oldDelegate.gradientStartX != gradientStartX ||
      oldDelegate.gradientWidth != gradientWidth;
}
