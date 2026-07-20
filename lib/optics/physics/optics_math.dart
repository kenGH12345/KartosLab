import 'dart:math' as math;
import 'dart:ui';

class LensImageGeometry {
  const LensImageGeometry({
    required this.objectDistance,
    required this.imageDistance,
    required this.magnification,
    required this.imagePoint,
    required this.isVirtual,
  });

  final double objectDistance;
  final double imageDistance;
  final double magnification;
  final Offset imagePoint;
  final bool isVirtual;
}

class OpticsMath {
  const OpticsMath._();

  static double imageDistance(double objectDistance, double focalLength) {
    final denominator = (1 / focalLength) - (1 / objectDistance);
    if (denominator.abs() < 0.002) {
      return denominator.isNegative ? -999 : 999;
    }
    return (1 / denominator).clamp(-999, 999);
  }

  static Offset extendFrom(Offset start, Offset direction, double length) {
    final d = math.sqrt(direction.dx * direction.dx + direction.dy * direction.dy);
    if (d == 0) return start;
    return Offset(
      start.dx + direction.dx / d * length,
      start.dy + direction.dy / d * length,
    );
  }

  static Offset directionTo(Offset from, Offset to) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final d = math.sqrt(dx * dx + dy * dy);
    if (d == 0) return const Offset(1, 0);
    return Offset(dx / d, dy / d);
  }

  static List<double> edgeSamples(double halfAperture) {
    return [-halfAperture, 0.0, halfAperture];
  }

  static LensImageGeometry lensImage({
    required double lensX,
    required double lensY,
    required Offset objectPoint,
    required double focalLength,
  }) {
    final objectDistance = lensX - objectPoint.dx;
    final imageDistance = OpticsMath.imageDistance(objectDistance, focalLength);
    final magnification = -imageDistance / objectDistance;
    final imagePoint = Offset(
      lensX + imageDistance,
      lensY + (objectPoint.dy - lensY) * magnification,
    );
    return LensImageGeometry(
      objectDistance: objectDistance,
      imageDistance: imageDistance,
      magnification: magnification,
      imagePoint: imagePoint,
      isVirtual: imageDistance < 0,
    );
  }
}
