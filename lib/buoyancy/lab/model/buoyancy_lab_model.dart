import '../../domain/mass/buoyancy_mass.dart';
import '../../domain/material/buoyancy_gravity.dart';
import '../../domain/material/buoyancy_material.dart';
import '../../domain/shape/shape_geometry.dart';
import '../../domain/world/vec2.dart';
import '../../physics/buoyancy_physics_world.dart';
import '../../physics/constants.dart';
import '../../shared/buoyancy_scale_host.dart';
import '../../shared/buoyancy_screen_model.dart';

/// Lab screen model — `BuoyancyLabModel.ts`.
///
/// Source snapshot: LOCAL density-buoyancy-common HEAD `0c835c64`.
class BuoyancyLabModel extends BuoyancyScreenModel with BuoyancyScaleHost {
  BuoyancyLabModel({super.world}) {
    block = BuoyancyMass(
      id: 'lab.block',
      material: BuoyancyMaterial.wood,
      geometry: ShapeGeometry.cubeFromVolume(2 / BuoyancyMaterial.wood.density),
      position: const BVec2(-0.2, 0.2),
    );
    this.world.addMass(block);
    // Land scale −0.65, canMove:false (`BuoyancyLabModel.ts`).
    initScaleBodies(landX: -0.65, landCanMove: false);
    this.world.pool.computeFluidY([block]);
    lifecycle = ScreenModelLifecycle.idle;
  }

  static final List<BuoyancyMaterial> availableMassMaterials = [
    ...BuoyancyMaterial.simpleMassMaterials,
    BuoyancyMaterial.customSolid(1000),
    BuoyancyMaterial.materialT,
    BuoyancyMaterial.materialU,
  ];

  static const List<BuoyancyGravity> gravityPresets = [
    BuoyancyGravity.moon,
    BuoyancyGravity.earth,
    BuoyancyGravity.jupiter,
    BuoyancyGravity.planetX,
  ];

  late final BuoyancyMass block;

  /// Kept for model tests; View uses [BuoyancyDisplayProperties].
  bool gravityForceVisible = true;
  bool buoyancyForceVisible = true;
  bool forceValuesVisible = true;

  /// liters — DerivedProperty in source from percentSubmerged × volume.
  double get fluidDisplacedVolumeLiters =>
      (block.percentSubmerged / 100) *
      block.volume *
      BuoyancyPhysicsConstants.litersInCubicMeter;

  void setForceDisplay({
    bool? gravity,
    bool? buoyancy,
    bool? values,
  }) {
    if (gravity != null) gravityForceVisible = gravity;
    if (buoyancy != null) buoyancyForceVisible = buoyancy;
    if (values != null) forceValuesVisible = values;
  }

  void setSelectedGravityPreset(BuoyancyGravity g) {
    world.gravity = g;
  }

  void setFluidDensity(double density) {
    final clamped = density
        .clamp(
          BuoyancyPhysicsConstants.fluidDensityMinKgPerM3,
          BuoyancyPhysicsConstants.fluidDensityMaxKgPerM3,
        )
        .toDouble();
    setFluidMaterial(BuoyancyMaterial.customFluid(clamped));
  }

  void setFluidPreset(BuoyancyMaterial fluid) {
    assert(fluid.isFluid);
    setFluidMaterial(fluid);
  }

  void setBlockMaterial(BuoyancyMaterial material) {
    block.setMaterial(material);
    // LabScreenView: Material T/U → 0.005 m³.
    if (material.id == BuoyancyMaterial.materialT.id ||
        material.id == BuoyancyMaterial.materialU.id) {
      setBlockVolume(0.005);
    }
  }

  void setBlockMass(double massKg) {
    if (massKg <= 0 || !massKg.isFinite) {
      return;
    }
    if (block.material.custom) {
      block.setCustomDensity(massKg / block.volume);
    } else {
      block.setMassKeepingDensity(massKg);
    }
  }

  void setBlockVolume(double volumeM3) {
    if (volumeM3 <= 0 || !volumeM3.isFinite) {
      return;
    }
    if (block.material.custom) {
      final mass = block.mass;
      block.setVolumeKeepingDensity(volumeM3);
      block.setCustomDensity(mass / volumeM3);
    } else {
      block.setVolumeKeepingDensity(volumeM3);
    }
  }

  @override
  void step(double externalDt) {
    syncScaleBodies();
    super.step(externalDt);
  }

  @override
  void reset() {
    gravityForceVisible = true;
    buoyancyForceVisible = true;
    forceValuesVisible = true;
    world.gravity = BuoyancyGravity.earth;
    world.resetWorld();
    resetScaleBodies(landX: -0.65);
    world.pool.computeFluidY([block]);
    lifecycle = ScreenModelLifecycle.idle;
  }

  LabModelSnapshot snapshot() => LabModelSnapshot(
        gravityForceVisible: gravityForceVisible,
        buoyancyForceVisible: buoyancyForceVisible,
        forceValuesVisible: forceValuesVisible,
        gravity: world.gravity.value,
        fluidDensity: world.pool.fluidDensity,
        world: world.snapshot(),
      );
}

class LabModelSnapshot {
  const LabModelSnapshot({
    required this.gravityForceVisible,
    required this.buoyancyForceVisible,
    required this.forceValuesVisible,
    required this.gravity,
    required this.fluidDensity,
    required this.world,
  });

  final bool gravityForceVisible;
  final bool buoyancyForceVisible;
  final bool forceValuesVisible;
  final double gravity;
  final double fluidDensity;
  final BuoyancyWorldSnapshot world;

  @override
  bool operator ==(Object other) =>
      other is LabModelSnapshot &&
      gravityForceVisible == other.gravityForceVisible &&
      buoyancyForceVisible == other.buoyancyForceVisible &&
      forceValuesVisible == other.forceValuesVisible &&
      gravity == other.gravity &&
      fluidDensity == other.fluidDensity &&
      world == other.world;

  @override
  int get hashCode => Object.hash(
        gravityForceVisible,
        buoyancyForceVisible,
        forceValuesVisible,
        gravity,
        fluidDensity,
        world,
      );
}
