import 'dart:math' as math;

import '../domain/shape/shape_geometry.dart';

/// Submerged / displaced volume from source shape formulas.
///
/// Sources: `Cuboid.ts`, `Ellipsoid.ts`, `VerticalCylinder.ts`,
/// `HorizontalCylinder.ts`, `Cone.ts`, `Duck.ts` (extends Ellipsoid),
/// `ApplicationsMass.ts` (piecewise).
class SubmergedVolume {
  SubmergedVolume._();

  /// Displaced volume of [geometry] whose center is at [centerY], up to [fluidY].
  static double displacedVolume({
    required ShapeGeometry geometry,
    required double centerY,
    required double fluidY,
  }) {
    final bottom = centerY - geometry.halfHeight;
    final top = centerY + geometry.halfHeight;
    if (fluidY <= bottom) {
      return 0;
    }
    if (fluidY >= top) {
      if (geometry.kind == MassShapeKind.boat ||
          geometry.kind == MassShapeKind.bottle) {
        return geometry.applicationMaxVolume > 0
            ? geometry.applicationMaxVolume
            : geometry.totalVolume;
      }
      return geometry.totalVolume;
    }

    switch (geometry.kind) {
      case MassShapeKind.block:
      case MassShapeKind.verticalCylinder:
        return geometry.totalVolume * (fluidY - bottom) / (top - bottom);
      case MassShapeKind.ellipsoid:
      case MassShapeKind.duck:
        final t = (fluidY - bottom) / (top - bottom);
        return geometry.totalVolume * t * t * (3 - 2 * t);
      case MassShapeKind.horizontalCylinder:
        return _horizontalCylinderVolume(geometry, bottom, top, fluidY);
      case MassShapeKind.cone:
      case MassShapeKind.invertedCone:
        return _coneVolume(geometry, bottom, top, fluidY);
      case MassShapeKind.boat:
      case MassShapeKind.bottle:
        return _applicationVolume(geometry, bottom, top, fluidY);
    }
  }

  /// Cross-section area at [fluidY] (used by basin root finder).
  static double displacedArea({
    required ShapeGeometry geometry,
    required double centerY,
    required double fluidY,
  }) {
    final bottom = centerY - geometry.halfHeight;
    final top = centerY + geometry.halfHeight;
    if (fluidY < bottom || fluidY > top) {
      return 0;
    }
    switch (geometry.kind) {
      case MassShapeKind.block:
        return geometry.width * geometry.depth;
      case MassShapeKind.verticalCylinder:
        return math.pi * geometry.radius * geometry.radius;
      case MassShapeKind.ellipsoid:
      case MassShapeKind.duck:
        final t = (fluidY - bottom) / (top - bottom);
        final a = geometry.width / 2;
        final c = geometry.depth / 2;
        final maxArea = 4 * math.pi * a * c;
        return maxArea * (t - t * t);
      case MassShapeKind.horizontalCylinder:
        final t = (fluidY - bottom) / (top - bottom);
        final maxArea = 2 * geometry.radius * geometry.length;
        return maxArea * 2 * math.sqrt(t - t * t);
      case MassShapeKind.cone:
      case MassShapeKind.invertedCone:
        var t = (fluidY - bottom) / (top - bottom);
        if (geometry.vertexUp) {
          t = 1 - t;
        }
        final r = geometry.radius * t;
        return math.pi * r * r;
      case MassShapeKind.boat:
      case MassShapeKind.bottle:
        final t = (fluidY - bottom) / (top - bottom);
        return _piecewise(geometry.applicationAreas!, t);
    }
  }

  static double _horizontalCylinderVolume(
    ShapeGeometry g,
    double bottom,
    double top,
    double fluidY,
  ) {
    final t = (fluidY - bottom) / (top - bottom);
    final f = 2 * t - 1;
    return g.totalVolume *
        (2 * math.sqrt(t - t * t) * f + math.acos(-f)) /
        math.pi;
  }

  static double _coneVolume(
    ShapeGeometry g,
    double bottom,
    double top,
    double fluidY,
  ) {
    final ratio = (fluidY - bottom) / (top - bottom);
    final area = math.pi * g.radius * g.radius;
    if (g.vertexUp) {
      // Cone.ts isVertexUp branch
      return area * g.height * (ratio * (3 + ratio * (ratio - 3))) / 3;
    }
    return area * g.height * ratio * ratio * ratio / 3;
  }

  static double _applicationVolume(
    ShapeGeometry g,
    double bottom,
    double top,
    double fluidY,
  ) {
    final t = (fluidY - bottom) / (top - bottom);
    return _piecewise(g.applicationVolumes!, t);
  }

  /// `ApplicationsMass.evaluatePiecewiseLinear`
  static double _piecewise(List<double> values, double ratio) {
    if (values.isEmpty) {
      return 0;
    }
    final logicalIndex = ratio * (values.length - 1);
    if (logicalIndex % 1 == 0) {
      return values[logicalIndex.round()];
    }
    final lo = logicalIndex.floor();
    final hi = logicalIndex.ceil();
    final a = values[lo];
    final b = values[hi];
    final t = (logicalIndex - lo) / (hi - lo);
    return a + (b - a) * t;
  }
}
