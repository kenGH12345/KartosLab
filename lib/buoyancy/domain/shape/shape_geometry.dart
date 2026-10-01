import 'dart:math' as math;

/// Physics shape kinds from `MassShape.ts` plus Applications geometries.
///
/// Visual mesh may differ (Duck visual ≠ ellipsoid collider).
enum MassShapeKind {
  block,
  ellipsoid,
  verticalCylinder,
  horizontalCylinder,
  cone,
  invertedCone,
  duck,
  bottle,
  boat,
}

/// Geometry parameters in model meters. Center is mass position.
class ShapeGeometry {
  const ShapeGeometry._({
    required this.kind,
    this.width = 0,
    this.height = 0,
    this.depth = 0,
    this.radius = 0,
    this.length = 0,
    this.vertexUp = true,
    this.applicationAreas,
    this.applicationVolumes,
    this.applicationMaxVolume = 0,
    this.applicationMassVolume = 0,
  });

  final MassShapeKind kind;
  final double width;
  final double height;
  final double depth;
  final double radius;
  final double length;
  final bool vertexUp;

  /// Piecewise area/volume tables for boat/bottle (`ApplicationsMass`).
  final List<double>? applicationAreas;
  final List<double>? applicationVolumes;
  final double applicationMaxVolume;

  /// Hull / solid volume used for mass (boat hull ≠ outer displacement max).
  final double applicationMassVolume;

  factory ShapeGeometry.block({
    required double width,
    required double height,
    required double depth,
  }) =>
      ShapeGeometry._(
        kind: MassShapeKind.block,
        width: width,
        height: height,
        depth: depth,
      );

  factory ShapeGeometry.cubeFromVolume(double volume) {
    final side = math.pow(volume, 1 / 3).toDouble();
    return ShapeGeometry.block(width: side, height: side, depth: side);
  }

  factory ShapeGeometry.ellipsoid({
    required double width,
    required double height,
    required double depth,
  }) =>
      ShapeGeometry._(
        kind: MassShapeKind.ellipsoid,
        width: width,
        height: height,
        depth: depth,
      );

  factory ShapeGeometry.duck({
    required double width,
    required double height,
    required double depth,
  }) =>
      ShapeGeometry._(
        kind: MassShapeKind.duck,
        width: width,
        height: height,
        depth: depth,
      );

  factory ShapeGeometry.verticalCylinder({
    required double radius,
    required double height,
  }) =>
      ShapeGeometry._(
        kind: MassShapeKind.verticalCylinder,
        radius: radius,
        height: height,
      );

  factory ShapeGeometry.horizontalCylinder({
    required double radius,
    required double length,
  }) =>
      ShapeGeometry._(
        kind: MassShapeKind.horizontalCylinder,
        radius: radius,
        length: length,
        height: radius * 2,
      );

  factory ShapeGeometry.cone({
    required double radius,
    required double height,
    required bool vertexUp,
  }) =>
      ShapeGeometry._(
        kind: vertexUp ? MassShapeKind.cone : MassShapeKind.invertedCone,
        radius: radius,
        height: height,
        vertexUp: vertexUp,
      );

  /// Boat/bottle: precomputed piecewise tables. Not a cube approximation.
  factory ShapeGeometry.application({
    required MassShapeKind kind,
    required List<double> areas,
    required List<double> volumes,
    required double maxVolume,
    required double height,
    double? massVolume,
  }) {
    assert(kind == MassShapeKind.boat || kind == MassShapeKind.bottle);
    return ShapeGeometry._(
      kind: kind,
      height: height,
      applicationAreas: List<double>.unmodifiable(areas),
      applicationVolumes: List<double>.unmodifiable(volumes),
      applicationMaxVolume: maxVolume,
      applicationMassVolume: massVolume ?? maxVolume,
    );
  }

  double get halfHeight {
    switch (kind) {
      case MassShapeKind.block:
      case MassShapeKind.ellipsoid:
      case MassShapeKind.duck:
        return height / 2;
      case MassShapeKind.verticalCylinder:
      case MassShapeKind.cone:
      case MassShapeKind.invertedCone:
        return height / 2;
      case MassShapeKind.horizontalCylinder:
        return radius;
      case MassShapeKind.boat:
      case MassShapeKind.bottle:
        return height / 2;
    }
  }

  double get totalVolume {
    switch (kind) {
      case MassShapeKind.block:
        return width * height * depth;
      case MassShapeKind.ellipsoid:
      case MassShapeKind.duck:
        final a = width / 2;
        final b = height / 2;
        final c = depth / 2;
        return (4 / 3) * math.pi * a * b * c;
      case MassShapeKind.verticalCylinder:
        return math.pi * radius * radius * height;
      case MassShapeKind.horizontalCylinder:
        return math.pi * radius * radius * length;
      case MassShapeKind.cone:
      case MassShapeKind.invertedCone:
        return math.pi * radius * radius * height / 3;
      case MassShapeKind.boat:
      case MassShapeKind.bottle:
        return applicationMassVolume > 0
            ? applicationMassVolume
            : applicationMaxVolume;
    }
  }
}
