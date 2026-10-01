import 'dart:math' as math;
import 'dart:ui';

import 'package:kratos/energy_forms_and_changes/common/model/energy_chunk.dart';
import 'package:kratos/energy_forms_and_changes/common/model/energy_container_category.dart';
import 'package:kratos/energy_forms_and_changes/common/model/model_rect.dart';
import 'package:kratos/energy_forms_and_changes/common/model/thermal_container.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';

enum BeakerType { water, oliveOil }

/// PhET `Beaker` / Intro `BeakerContainer`.
class Beaker implements ThermalContainer {
  Beaker({
    required this.id,
    required this.beakerType,
    required this.position,
    this.width = EfacIntroBeaker.beakerWidth,
    this.height = EfacIntroBeaker.beakerHeight,
  }) {
    energy = mass * specificHeat * EfacConstants.roomTemperature;
    fluidProportion = EfacConstants.initialFluidProportion;
    _updateTopSurface();
  }

  @override
  final String id;
  final BeakerType beakerType;
  final double width;
  final double height;

  @override
  Offset position;
  @override
  bool userControlled = false;
  @override
  double verticalVelocity = 0;
  @override
  HorizontalSurface? supportingSurface;
  HorizontalSurface? _topSurface;

  @override
  HorizontalSurface? get topSurface => _topSurface;

  @override
  double energy = 0;
  double fluidProportion = EfacConstants.initialFluidProportion;
  double steamingProportion = 0;
  @override
  final List<EnergyChunk> energyChunks = <EnergyChunk>[];

  double get density => beakerType == BeakerType.water
      ? EfacConstants.waterDensity
      : EfacConstants.oliveOilDensity;
  double get specificHeat => beakerType == BeakerType.water
      ? EfacConstants.waterSpecificHeat
      : EfacConstants.oliveOilSpecificHeat;
  double get fluidBoilingPoint => beakerType == BeakerType.water
      ? EfacConstants.waterBoilingPointTemperature
      : EfacConstants.oliveOilBoilingPointTemperature;
  double get mass =>
      math.pi *
      math.pow(width / 2, 2) *
      height *
      EfacConstants.initialFluidProportion *
      density;

  double get majorTickMarkDistance => height * 0.95 / 3; // EFACIntroModel.ts:45

  @override
  EnergyContainerCategory get category => beakerType == BeakerType.water
      ? EnergyContainerCategory.water
      : EnergyContainerCategory.oliveOil;

  @override
  ModelRect get bounds => ModelRect(
    position.dx - width / 2,
    position.dy,
    position.dx + width / 2,
    position.dy + height,
  );

  @override
  ModelRect get thermalContactArea => ModelRect(
    position.dx - width / 2,
    position.dy,
    position.dx + width / 2,
    position.dy + height * fluidProportion,
  );

  ModelRect get steamArea {
    final fluidTop = position.dy + height * fluidProportion;
    return ModelRect(
      position.dx - width / 2,
      fluidTop,
      position.dx + width / 2,
      fluidTop + height * 2 * steamingProportion,
    );
  }

  @override
  double get temperature {
    final t = energy / (mass * specificHeat);
    return t < fluidBoilingPoint ? t : fluidBoilingPoint;
  }

  double get rawTemperature => energy / (mass * specificHeat);

  @override
  double get energyAboveMinimum {
    final minE =
        EfacConstants.waterFreezingPointTemperature * mass * specificHeat;
    final above = energy - minE;
    return above > 0 ? above : 0;
  }

  @override
  double get energyBeyondMaxTemperature {
    final maxE = fluidBoilingPoint * mass * specificHeat;
    final beyond = energy - maxE;
    return beyond > 0 ? beyond : 0;
  }

  @override
  int get energyChunkBalance {
    final expected = EfacConstants.energyToNumChunksMapper(energy);
    return energyChunks.length - expected;
  }

  @override
  void changeEnergy(double delta) {
    energy += delta;
    final minE =
        EfacConstants.waterFreezingPointTemperature * mass * specificHeat;
    if (energy < minE) energy = minE;
  }

  @override
  double exchangeEnergyWith(ThermalContainer other, double dt) {
    return exchangeThermalEnergy(
      this,
      other,
      dt,
      contactLength: aabbContactLength(
        thermalContactArea,
        other.thermalContactArea,
      ),
    );
  }

  /// BeakerContainer.ts — raise fluid when blocks intersect.
  void updateFluidDisplacement(List<ModelRect> blockBounds) {
    var displacement = 0.0;
    for (final b in blockBounds) {
      if (!bounds.intersects(b)) continue;
      final overlapX =
          math.min(bounds.maxX, b.maxX) - math.max(bounds.minX, b.minX);
      final overlapY =
          math.min(bounds.maxY, b.maxY) - math.max(bounds.minY, b.minY);
      if (overlapX > 0 && overlapY > 0) {
        // PhET uses intersection area × 120 empirically.
        displacement += overlapX * overlapY * 120;
      }
    }
    final raised = EfacConstants.initialFluidProportion + displacement;
    fluidProportion = raised.clamp(0.5, 1.0);
    _updateTopSurface();
  }

  @override
  void step(double dt) {
    final temp = rawTemperature;
    if (temp > fluidBoilingPoint - EfacIntroBeaker.steamingRange) {
      steamingProportion =
          (1 - (fluidBoilingPoint - temp) / EfacIntroBeaker.steamingRange)
              .clamp(0.0, 1.0);
    } else {
      steamingProportion = 0;
    }
    _updateTopSurface();
  }

  void _updateTopSurface() {
    // PhET Beaker.ts: topSurface = bounds.minY + MATERIAL_THICKNESS
    // (inner floor). Blocks fall onto this and sink into the fluid — NOT the rim.
    _topSurface = HorizontalSurface(
      x: position.dx,
      y: position.dy + EfacIntroBeaker.materialThickness,
      elementOnSurface: _topSurface?.elementOnSurface,
    );
  }

  @override
  void reset({required Offset home}) {
    position = home;
    energy = mass * specificHeat * EfacConstants.roomTemperature;
    fluidProportion = EfacConstants.initialFluidProportion;
    steamingProportion = 0;
    verticalVelocity = 0;
    userControlled = false;
    supportingSurface = null;
    energyChunks.clear();
    _updateTopSurface();
  }
}

class EfacIntroBeaker {
  static const double beakerWidth = 0.085;
  static const double beakerHeight = beakerWidth * 1.1;
  static const double steamingRange = 10;

  /// PhET `Beaker.ts` MATERIAL_THICKNESS — inner floor where immersed blocks rest.
  static const double materialThickness = 0.001;
}
