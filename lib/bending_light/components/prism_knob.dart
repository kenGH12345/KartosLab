import 'dart:math' as math;
import 'dart:ui';

/// `knob.png` is 34×31. `PrismNode` scales it to height 15.
const double prismKnobImageWidth = 34;
const double prismKnobImageHeight = 31;
const double prismKnobHeight = 15;

class PrismKnobPlacement {
  const PrismKnobPlacement({
    required this.topLeft,
    required this.width,
    required this.height,
    required this.angle,
  });

  final Offset topLeft;
  final double width;
  final double height;
  final double angle;
}

/// `PrismNode.updatePrismShape`. Circle shapes have no reference point.
PrismKnobPlacement placePrismKnob({
  required Offset reference,
  required Offset rotationCenter,
  double imageWidth = prismKnobImageWidth,
  double imageHeight = prismKnobImageHeight,
  double viewScale = 1,
}) {
  final scale = prismKnobHeight / imageHeight * viewScale;
  final width = imageWidth * scale;
  final height = prismKnobHeight * viewScale;
  final angle = math.atan2(
    rotationCenter.dy - reference.dy,
    rotationCenter.dx - reference.dx,
  );
  return PrismKnobPlacement(
    topLeft: reference + Offset(-width - 7 * viewScale, -height / 2 - 8 * viewScale),
    width: width,
    height: height,
    angle: angle,
  );
}
