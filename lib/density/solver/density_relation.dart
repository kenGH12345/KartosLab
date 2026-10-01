import 'dart:math' as math;

import '../density_constants.dart';
import '../model/density_block.dart';
import '../model/density_material.dart';

/// Clamp / range context matching Intro `MaterialMassVolumeControlNode`.
class DensityRelationLimits {
  const DensityRelationLimits({
    this.minVolume = DensityConstants.minVolume,
    this.maxVolume = DensityConstants.maxVolume,
    this.minMass = DensityConstants.minMass,
    this.maxMass = DensityConstants.maxMass,
    this.minCustomMass = DensityConstants.minCustomMass,
    this.maxCustomMass = DensityConstants.introMaxCustomMass,
  });

  final double minVolume;
  final double maxVolume;
  final double minMass;
  final double maxMass;
  final double minCustomMass;
  final double maxCustomMass;

  static const intro = DensityRelationLimits();

  /// `MaterialControlNode.ts`: minCustomMass / maxVolumeLiters * 1000.
  double get customDensityMin => minCustomMass / maxVolume;

  /// `MaterialControlNode.ts`: maxCustomMass / minCustomVolumeLiters * 1000.
  double get customDensityMax => maxCustomMass / minVolume;
}

/// Mass ↔ volume ↔ density. Does not mutate [DensityBlock].
///
/// Named material: density from catalog; mass or volume change keeps density.
/// Custom: mass and volume independent; density = m/V.
class DensityRelation {
  DensityRelation._();

  /// PhET `Utils.roundToInterval(value, interval)`.
  static double roundToInterval(double value, double interval) {
    if (interval <= 0) {
      throw ArgumentError.value(interval, 'interval', 'must be positive');
    }
    return (value / interval).round() * interval;
  }

  static double catalogDensity(DensityMaterialId id) {
    final material = DensityMaterials.byId(id);
    final density = material.density;
    if (density == null) {
      throw ArgumentError('Custom material has no catalog density');
    }
    return density;
  }

  /// Current density (kg/m³). Custom uses [DensityBlock.customDensity].
  static double densityOf(DensityBlock block) {
    if (block.isCustom) {
      final d = block.customDensity;
      if (d == null || d <= 0) {
        throw ArgumentError('Custom block requires positive customDensity');
      }
      return d;
    }
    return catalogDensity(block.materialId);
  }

  /// `Mass.ts`: mass = roundToInterval(density * volume, 1e-7).
  static double massOf(DensityBlock block) {
    _requireVolume(block.volume);
    return roundToInterval(
      densityOf(block) * block.volume,
      DensityConstants.tolerance,
    );
  }

  static double cubeSideLength(double volume) {
    _requireVolume(volume);
    return math.pow(volume, 1 / 3).toDouble();
  }

  static DensityBlock createWithVolume({
    required String id,
    required String tag,
    required DensityMaterialId materialId,
    required double volume,
    double? customDensity,
    int? colorArgb,
  }) {
    _requireVolume(volume);
    if (materialId == DensityMaterialId.custom) {
      final d = customDensity;
      if (d == null || d <= 0) {
        throw ArgumentError('createWithVolume(custom) needs positive density');
      }
    }
    return DensityBlock(
      id: id,
      tag: tag,
      materialId: materialId,
      volume: volume,
      customDensity:
          materialId == DensityMaterialId.custom ? customDensity : null,
      colorArgb: colorArgb,
    );
  }

  /// `Cube.createWithMass`: volume = mass / density.
  static DensityBlock createWithMass({
    required String id,
    required String tag,
    required DensityMaterialId materialId,
    required double mass,
    double? customDensity,
    int? colorArgb,
  }) {
    if (mass <= 0) {
      throw ArgumentError.value(mass, 'mass', 'must be positive');
    }
    final density = materialId == DensityMaterialId.custom
        ? customDensity
        : catalogDensity(materialId);
    if (density == null || density <= 0) {
      throw ArgumentError('createWithMass needs positive density');
    }
    return createWithVolume(
      id: id,
      tag: tag,
      materialId: materialId,
      volume: mass / density,
      customDensity: customDensity,
      colorArgb: colorArgb,
    );
  }

  /// User volume change (`MaterialMassVolumeControlNode` volume link).
  static DensityBlock setVolume(
    DensityBlock block,
    double cubicMeters, {
    DensityRelationLimits limits = DensityRelationLimits.intro,
  }) {
    if (cubicMeters <= 0) {
      throw ArgumentError.value(cubicMeters, 'volume', 'must be positive');
    }
    final volume = cubicMeters.clamp(limits.minVolume, limits.maxVolume);
    if (block.isCustom) {
      final mass = massOf(block);
      final density = (mass / volume).clamp(
        limits.customDensityMin,
        limits.customDensityMax,
      );
      return block.copyWith(volume: volume, customDensity: density);
    }
    return block.copyWith(volume: volume);
  }

  /// User mass change. Named → volume moves. Custom → density moves.
  static DensityBlock setMass(
    DensityBlock block,
    double mass, {
    DensityRelationLimits limits = DensityRelationLimits.intro,
  }) {
    if (mass <= 0) {
      throw ArgumentError.value(mass, 'mass', 'must be positive');
    }
    if (block.isCustom) {
      _requireVolume(block.volume);
      final density = (mass / block.volume).clamp(
        limits.customDensityMin,
        limits.customDensityMax,
      );
      return block.copyWith(customDensity: density);
    }
    final density = catalogDensity(block.materialId);
    final volume = (mass / density).clamp(limits.minVolume, limits.maxVolume);
    return block.copyWith(volume: volume);
  }

  /// Switch material. Volume kept; named mass recalculates.
  /// Custom inherits previous density, clamped (`MaterialControlNode.ts`).
  static DensityBlock setMaterial(
    DensityBlock block,
    DensityMaterialId next, {
    DensityRelationLimits limits = DensityRelationLimits.intro,
  }) {
    if (next == block.materialId &&
        (next != DensityMaterialId.custom || block.customDensity != null)) {
      return block;
    }
    if (next == DensityMaterialId.custom) {
      final prev = densityOf(block);
      final maxVolumeForClamp = math.max(block.volume, limits.minVolume);
      final minD = limits.minCustomMass / maxVolumeForClamp;
      final maxD = limits.maxCustomMass / limits.minVolume;
      return block.copyWith(
        materialId: DensityMaterialId.custom,
        customDensity: prev.clamp(minD, maxD),
      );
    }
    return block.copyWith(
      materialId: next,
      clearCustomDensity: true,
    );
  }

  static void _requireVolume(double volume) {
    if (volume <= 0) {
      throw ArgumentError.value(volume, 'volume', 'must be positive');
    }
  }
}
