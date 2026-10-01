import 'dart:math' as math;

import '../domain/shape/shape_geometry.dart';

/// Ratio → geometry helpers from Cuboid / Ellipsoid / Cylinder / Cone / Duck.
class ShapeRatios {
  ShapeRatios._();

  static const double minDimension = 0.1;
  static final double maxDimension = math.pow(0.01, 1 / 3).toDouble();

  static double lerpDimension(double ratio) =>
      minDimension + ratio * (maxDimension - minDimension);

  static ShapeGeometry fromRatios(MassShapeKind kind, double widthRatio, double heightRatio) {
    switch (kind) {
      case MassShapeKind.block:
        final halfW = lerpDimension(widthRatio) / 2;
        final halfH = lerpDimension(heightRatio) / 2;
        return ShapeGeometry.block(
          width: halfW * 2,
          height: halfH * 2,
          depth: halfW * 2,
        );
      case MassShapeKind.ellipsoid:
      case MassShapeKind.duck:
        final halfW = lerpDimension(widthRatio) / 2;
        final halfH = lerpDimension(heightRatio) / 2;
        final factory = kind == MassShapeKind.duck
            ? ShapeGeometry.duck
            : ShapeGeometry.ellipsoid;
        return factory(
          width: halfW * 2,
          height: halfH * 2,
          depth: halfW * 2,
        );
      case MassShapeKind.verticalCylinder:
        return ShapeGeometry.verticalCylinder(
          radius: lerpDimension(widthRatio) / 2,
          height: lerpDimension(heightRatio),
        );
      case MassShapeKind.horizontalCylinder:
        return ShapeGeometry.horizontalCylinder(
          radius: lerpDimension(heightRatio) / 2,
          length: lerpDimension(widthRatio),
        );
      case MassShapeKind.cone:
        return ShapeGeometry.cone(
          radius: lerpDimension(widthRatio) / 2,
          height: lerpDimension(heightRatio),
          vertexUp: true,
        );
      case MassShapeKind.invertedCone:
        return ShapeGeometry.cone(
          radius: lerpDimension(widthRatio) / 2,
          height: lerpDimension(heightRatio),
          vertexUp: false,
        );
      case MassShapeKind.bottle:
      case MassShapeKind.boat:
        throw ArgumentError('Use ApplicationGeometry for boat/bottle');
    }
  }
}
