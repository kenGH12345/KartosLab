import 'dart:ui';

import 'package:kratos/energy_forms_and_changes/common/model/energy_chunk.dart';
import 'package:kratos/energy_forms_and_changes/common/model/energy_container_category.dart';
import 'package:kratos/energy_forms_and_changes/common/model/model_rect.dart';
import 'package:kratos/energy_forms_and_changes/common/model/thermal_container.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';

enum BlockType { iron, brick }

/// PhET `Block.ts` implementing [ThermalContainer].
class ThermalBlock implements ThermalContainer {
  ThermalBlock({
    required this.id,
    required this.blockType,
    required this.position,
    this.zIndex = 0,
  }) {
    energy = mass * specificHeat * EfacConstants.roomTemperature;
    _updateTopSurface();
  }

  @override
  final String id;
  final BlockType blockType;
  int zIndex;

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
  @override
  final List<EnergyChunk> energyChunks = <EnergyChunk>[];

  double get surfaceWidth => EfacConstants.blockSurfaceWidth;
  double get density => blockType == BlockType.iron
      ? EfacConstants.ironDensity
      : EfacConstants.brickDensity;
  double get specificHeat => blockType == BlockType.iron
      ? EfacConstants.ironSpecificHeat
      : EfacConstants.brickSpecificHeat;
  double get mass {
    final w = surfaceWidth;
    return w * w * w * density;
  }

  @override
  EnergyContainerCategory get category => blockType == BlockType.iron
      ? EnergyContainerCategory.iron
      : EnergyContainerCategory.brick;

  @override
  ModelRect get bounds => ModelRect(
        position.dx - surfaceWidth / 2,
        position.dy,
        position.dx + surfaceWidth / 2,
        position.dy + surfaceWidth,
      );

  @override
  ModelRect get thermalContactArea => bounds;

  /// Perspective projection for hit-test (approximate front face).
  ModelRect get projectedShape => bounds;

  @override
  double get temperature => energy / (mass * specificHeat);

  @override
  double get energyAboveMinimum {
    final minE =
        EfacConstants.waterFreezingPointTemperature * mass * specificHeat;
    final above = energy - minE;
    return above > 0 ? above : 0;
  }

  @override
  double get energyBeyondMaxTemperature {
    const maxT = 620.0;
    final maxE = maxT * mass * specificHeat;
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
      contactLength:
          aabbContactLength(thermalContactArea, other.thermalContactArea),
    );
  }

  void _updateTopSurface() {
    _topSurface = HorizontalSurface(
      x: position.dx,
      y: position.dy + surfaceWidth,
      elementOnSurface: _topSurface?.elementOnSurface,
    );
  }

  @override
  void step(double dt) => _updateTopSurface();

  @override
  void reset({required Offset home}) {
    position = home;
    energy = mass * specificHeat * EfacConstants.roomTemperature;
    verticalVelocity = 0;
    userControlled = false;
    supportingSurface = null;
    energyChunks.clear();
    _updateTopSurface();
  }
}
