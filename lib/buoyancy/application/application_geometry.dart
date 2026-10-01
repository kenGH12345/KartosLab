import 'dart:math' as math;

import '../applications/model/application_displacement_tables.dart';
import '../domain/shape/shape_geometry.dart';

/// Boundary for Applications boat/bottle precomputed displacement tables.
///
/// Source: `ApplicationsMass.ts`, `Boat.ts`, `Bottle.ts`, `BoatDesign.ts`.
/// Tables extracted from LOCAL common HEAD `0c835c64`.
abstract class ApplicationGeometry {
  ShapeGeometry toShapeGeometry();
}

/// Piecewise-linear displacement geometry (source `evaluatePiecewiseLinear`).
class PiecewiseApplicationGeometry implements ApplicationGeometry {
  PiecewiseApplicationGeometry({
    required this.kind,
    required this.areas,
    required this.volumes,
    required this.maxVolume,
    required this.height,
    this.massVolume,
  }) : assert(kind == MassShapeKind.boat || kind == MassShapeKind.bottle);

  final MassShapeKind kind;
  final List<double> areas;
  final List<double> volumes;
  final double maxVolume;
  final double height;
  final double? massVolume;

  /// Bottle `TEN_LITER_DISPLACED_*` (already 10 L scaled).
  factory PiecewiseApplicationGeometry.bottleTenLiter({
    required double height,
  }) {
    final vols = ApplicationDisplacementTables.bottleVolumes;
    return PiecewiseApplicationGeometry(
      kind: MassShapeKind.bottle,
      areas: ApplicationDisplacementTables.bottleAreas,
      volumes: vols,
      maxVolume: vols.last,
      height: height,
      massVolume: vols.last,
    );
  }

  /// BoatDesign tables scaled by `stepMultiplier = (V/0.001)^(1/3)`.
  ///
  /// Source `Boat.ts` updateStepInformation — NOT `toLiters` for table scale.
  factory PiecewiseApplicationGeometry.boatScaled({
    required double displacementVolumeM3,
    required double oneLiterHeight,
    required double hullVolume,
  }) {
    final m = math.pow(displacementVolumeM3 / 0.001, 1 / 3).toDouble();
    final areas = ApplicationDisplacementTables.boatOneLiterAreas
        .map((a) => a * m * m)
        .toList(growable: false);
    final volumes = ApplicationDisplacementTables.boatOneLiterVolumes
        .map((v) => v * m * m * m)
        .toList(growable: false);
    return PiecewiseApplicationGeometry(
      kind: MassShapeKind.boat,
      areas: areas,
      volumes: volumes,
      maxVolume: volumes.last,
      height: m * oneLiterHeight,
      massVolume: hullVolume,
    );
  }

  @override
  ShapeGeometry toShapeGeometry() => ShapeGeometry.application(
        kind: kind,
        areas: areas,
        volumes: volumes,
        maxVolume: maxVolume,
        height: height,
        massVolume: massVolume,
      );
}
