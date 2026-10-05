import '../../domain/mass/buoyancy_mass.dart';
import '../../domain/material/buoyancy_gravity.dart';
import '../../domain/material/buoyancy_material.dart';
import '../../domain/shape/shape_geometry.dart';
import '../../domain/world/vec2.dart';
import '../../physics/buoyancy_physics_world.dart';
import '../../physics/constants.dart';
import '../../shared/buoyancy_scale_host.dart';
import '../../shared/buoyancy_screen_model.dart';
import '../../shared/compare_block_set.dart';

/// Compare screen model — `BuoyancyCompareModel` / `CompareBlockSetModel`.
///
/// Source snapshot: LOCAL density-buoyancy-common HEAD `0c835c64`.
class BuoyancyCompareModel extends BuoyancyScreenModel with BuoyancyScaleHost {
  BuoyancyCompareModel({super.world}) {
    _buildAllBlockSets();
    _applyVisibility();
    world.pool.computeFluidY(world.masses.where((m) => m.visible).toList());
    lifecycle = ScreenModelLifecycle.idle;
  }

  static const double sameMassDefault = 4;
  static const double sameMassMin = 1;
  static const double sameMassMax = 10;
  static const double sameVolumeDefault = 0.005;
  static const double sameVolumeMin = 0.001;
  static const double sameVolumeMax = 0.01;
  static const double sameDensityDefault = 400; // Material.WOOD
  static const double sameDensityMin = 100;
  static const double sameDensityMax = 3000;

  /// CubesData[0] / [1] from BuoyancyCompareModel.ts
  static const double blockASameMassVolume = 0.002;
  static const double blockBSameMassVolume = 0.01;
  static const double blockASameVolumeMass = 10;
  static const double blockBSameVolumeMass = 2;
  static const double blockASameDensityVolume = 0.005;
  static const double blockBSameDensityVolume = 0.01;

  static const double blockSpacing = 0.01;

  CompareBlockSet comparisonMode = CompareBlockSet.sameMass;
  double sameMassValue = sameMassDefault;
  double sameVolumeValue = sameVolumeDefault;
  double sameDensityValue = sameDensityDefault;

  /// Compat aliases for existing call sites.
  static const double scaleHeight = BuoyancyScaleHost.scaleHeight;
  static const double poolScaleX = BuoyancyScaleHost.poolScaleX;

  late final Map<CompareBlockSet, List<BuoyancyMass>> blockSetToMasses;

  BuoyancyMass get blockA => blockSetToMasses[comparisonMode]![0];
  BuoyancyMass get blockB => blockSetToMasses[comparisonMode]![1];

  void _buildAllBlockSets() {
    blockSetToMasses = {
      CompareBlockSet.sameMass: [
        _cube(
          id: 'compare.sameMass.A',
          mass: sameMassDefault,
          volume: blockASameMassVolume,
          // density = 4/0.002 = 2000 → brick
          material: BuoyancyMaterial.brick,
        ),
        _cube(
          id: 'compare.sameMass.B',
          mass: sameMassDefault,
          volume: blockBSameMassVolume,
          // density = 4/0.01 = 400 → wood
          material: BuoyancyMaterial.wood,
        ),
      ],
      CompareBlockSet.sameVolume: [
        _cube(
          id: 'compare.sameVolume.A',
          mass: blockASameVolumeMass,
          volume: sameVolumeDefault,
          material: BuoyancyMaterial.brick,
        ),
        _cube(
          id: 'compare.sameVolume.B',
          mass: blockBSameVolumeMass,
          volume: sameVolumeDefault,
          material: BuoyancyMaterial.wood,
        ),
      ],
      CompareBlockSet.sameDensity: [
        _cube(
          id: 'compare.sameDensity.A',
          mass: sameDensityDefault * blockASameDensityVolume,
          volume: blockASameDensityVolume,
          material: BuoyancyMaterial.wood,
        ),
        _cube(
          id: 'compare.sameDensity.B',
          mass: sameDensityDefault * blockBSameDensityVolume,
          volume: blockBSameDensityVolume,
          material: BuoyancyMaterial.wood,
        ),
      ],
    };

    for (final entry in blockSetToMasses.entries) {
      _positionPair(entry.value);
      for (final m in entry.value) {
        world.addMass(m);
      }
    }

    // Land scale initial X ≈ −0.78 (Compare); pool scale from Pool default.
    initScaleBodies(landX: -0.78);
  }

  BuoyancyMass _cube({
    required String id,
    required double mass,
    required double volume,
    required BuoyancyMaterial material,
  }) {
    final density = mass / volume;
    final mat = (material.density - density).abs() < 1e-6
        ? material
        : BuoyancyMaterial.customSolid(density);
    return BuoyancyMass(
      id: id,
      material: mat,
      geometry: ShapeGeometry.cubeFromVolume(volume),
      position: BVec2.zero,
      visible: false,
    );
  }

  void _positionPair(List<BuoyancyMass> masses) {
    assert(masses.length == 2);
    final poolMinX = -BuoyancyPhysicsConstants.poolWidth / 2;
    final poolMaxX = BuoyancyPhysicsConstants.poolWidth / 2;

    final a = masses[0];
    final b = masses[1];
    final aW = a.geometry.width;
    final bW = b.geometry.width;

    a.position = BVec2(
      poolMinX - blockSpacing - aW / 2,
      a.geometry.halfHeight,
    );
    b.position = BVec2(
      poolMaxX + blockSpacing + bW / 2,
      b.geometry.halfHeight,
    );
  }

  void _applyVisibility() {
    for (final entry in blockSetToMasses.entries) {
      final visible = entry.key == comparisonMode;
      for (final m in entry.value) {
        m.visible = visible;
      }
    }
  }

  void setComparisonMode(CompareBlockSet mode) {
    comparisonMode = mode;
    _applyVisibility();
    world.pool.computeFluidY(world.masses.where((m) => m.visible).toList());
  }

  /// SAME_MASS: shared mass control; density = mass / each cube volume.
  void setSameMass(double mass) {
    final clamped = mass.clamp(sameMassMin, sameMassMax).toDouble();
    sameMassValue = clamped;
    for (final m in blockSetToMasses[CompareBlockSet.sameMass]!) {
      final density = clamped / m.volume;
      m.setCustomDensity(density);
    }
  }

  /// SAME_VOLUME: shared volume; each cube keeps its fixed mass from cubesData.
  void setSameVolume(double volume) {
    final clamped = volume.clamp(sameVolumeMin, sameVolumeMax).toDouble();
    sameVolumeValue = clamped;
    final masses = blockSetToMasses[CompareBlockSet.sameVolume]!;
    final fixedMasses = [blockASameVolumeMass, blockBSameVolumeMass];
    for (var i = 0; i < masses.length; i++) {
      final m = masses[i];
      final bottom = m.bottomY;
      m.geometry = ShapeGeometry.cubeFromVolume(clamped);
      m.position = BVec2(m.position.x, bottom + m.geometry.halfHeight);
      m.setCustomDensity(fixedMasses[i] / clamped);
    }
  }

  /// SAME_DENSITY: shared density; volumes stay; mass updates.
  void setSameDensity(double density) {
    final clamped = density.clamp(sameDensityMin, sameDensityMax).toDouble();
    sameDensityValue = clamped;
    for (final m in blockSetToMasses[CompareBlockSet.sameDensity]!) {
      m.setCustomDensity(clamped);
    }
  }

  @override
  void step(double externalDt) {
    syncScaleBodies();
    super.step(externalDt);
    if (!landScale.userControlled) {
      landScaleX = landScale.position.x.clamp(-1.2, world.pool.minX - 0.08);
      landScale.position = BVec2(landScaleX, landScale.position.y);
    }
  }

  @override
  void setGravity(BuoyancyGravity g) => world.gravity = g;

  @override
  void reset() {
    lifecycle = ScreenModelLifecycle.idle;
    comparisonMode = CompareBlockSet.sameMass;
    sameMassValue = sameMassDefault;
    sameVolumeValue = sameVolumeDefault;
    sameDensityValue = sameDensityDefault;
    world.gravity = BuoyancyGravity.earth;
    world.resetWorld();
    // Re-position after mass reset (geometry/position restored from ctor).
    for (final entry in blockSetToMasses.entries) {
      _positionPair(entry.value);
    }
    resetScaleBodies(landX: -0.78);
    _applyVisibility();
    world.pool.computeFluidY(world.masses.where((m) => m.visible).toList());
  }

  CompareModelSnapshot snapshot() => CompareModelSnapshot(
        comparisonMode: comparisonMode,
        sameMassValue: sameMassValue,
        sameVolumeValue: sameVolumeValue,
        sameDensityValue: sameDensityValue,
        world: world.snapshot(),
      );
}

class CompareModelSnapshot {
  const CompareModelSnapshot({
    required this.comparisonMode,
    required this.sameMassValue,
    required this.sameVolumeValue,
    required this.sameDensityValue,
    required this.world,
  });

  final CompareBlockSet comparisonMode;
  final double sameMassValue;
  final double sameVolumeValue;
  final double sameDensityValue;
  final BuoyancyWorldSnapshot world;

  @override
  bool operator ==(Object other) =>
      other is CompareModelSnapshot &&
      comparisonMode == other.comparisonMode &&
      sameMassValue == other.sameMassValue &&
      sameVolumeValue == other.sameVolumeValue &&
      sameDensityValue == other.sameDensityValue &&
      world == other.world;

  @override
  int get hashCode => Object.hash(
        comparisonMode,
        sameMassValue,
        sameVolumeValue,
        sameDensityValue,
        world,
      );
}
