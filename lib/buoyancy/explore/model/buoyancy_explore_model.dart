import '../../domain/mass/buoyancy_mass.dart';
import '../../domain/material/buoyancy_gravity.dart';
import '../../domain/material/buoyancy_material.dart';
import '../../domain/shape/shape_geometry.dart';
import '../../domain/world/vec2.dart';
import '../../physics/buoyancy_physics_world.dart';
import '../../shared/buoyancy_scale_host.dart';
import '../../shared/buoyancy_screen_model.dart';
import '../../shared/two_block_mode.dart';

/// Explore screen model — `BuoyancyExploreModel.ts`.
///
/// Source snapshot: LOCAL density-buoyancy-common HEAD `0c835c64`.
class BuoyancyExploreModel extends BuoyancyScreenModel with BuoyancyScaleHost {
  BuoyancyExploreModel({super.world}) {
    blockA = BuoyancyMass(
      id: 'explore.blockA',
      material: BuoyancyMaterial.wood,
      geometry: ShapeGeometry.cubeFromVolume(2 / BuoyancyMaterial.wood.density),
      position: const BVec2(-0.2, 0.2),
    );
    blockB = BuoyancyMass(
      id: 'explore.blockB',
      material: BuoyancyMaterial.aluminum,
      geometry:
          ShapeGeometry.cubeFromVolume(13.5 / BuoyancyMaterial.aluminum.density),
      position: const BVec2(0.05, 0.35),
      visible: false,
    );
    this.world.addMass(blockA);
    this.world.addMass(blockB);
    // Land scale at −0.65 (`BuoyancyExploreModel.ts`); pool scale from Pool default.
    initScaleBodies(landX: -0.65);
    this.world.pool.computeFluidY([blockA]);
    lifecycle = ScreenModelLifecycle.idle;
  }

  /// SIMPLE + CUSTOM + Material R/S (`availableMassMaterials`).
  static final List<BuoyancyMaterial> availableMaterials = [
    ...BuoyancyMaterial.simpleMassMaterials,
    BuoyancyMaterial.customSolid(1000),
    BuoyancyMaterial.materialR,
    BuoyancyMaterial.materialS,
  ];

  late final BuoyancyMass blockA;
  late final BuoyancyMass blockB;
  TwoBlockMode mode = TwoBlockMode.oneBlock;

  void setMode(TwoBlockMode next) {
    mode = next;
    blockB.visible = next == TwoBlockMode.twoBlocks;
    world.pool.computeFluidY(world.masses.where((m) => m.visible).toList());
  }

  void setBlockMaterial(String id, BuoyancyMaterial material) {
    final m = world.massById(id);
    if (m == null) {
      return;
    }
    m.setMaterial(material);
    // ExploreScreenView: Material R → 0.003 m³, Material S → 0.001 m³.
    if (material.id == BuoyancyMaterial.materialR.id) {
      setBlockVolume(id, 0.003);
    } else if (material.id == BuoyancyMaterial.materialS.id) {
      setBlockVolume(id, 0.001);
    }
  }

  void setBlockMass(String id, double massKg) {
    final m = world.massById(id);
    if (m == null || massKg <= 0 || !massKg.isFinite) {
      return;
    }
    if (m.material.custom) {
      m.setCustomDensity(massKg / m.volume);
    } else {
      m.setMassKeepingDensity(massKg);
    }
  }

  void setBlockVolume(String id, double volumeM3) {
    final m = world.massById(id);
    if (m == null || volumeM3 <= 0 || !volumeM3.isFinite) {
      return;
    }
    if (m.material.custom) {
      final mass = m.mass;
      m.setVolumeKeepingDensity(volumeM3);
      m.setCustomDensity(mass / volumeM3);
    } else {
      m.setVolumeKeepingDensity(volumeM3);
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
    mode = TwoBlockMode.oneBlock;
    world.gravity = BuoyancyGravity.earth;
    world.resetWorld();
    blockB.visible = false;
    resetScaleBodies(landX: -0.65);
    world.pool.computeFluidY([blockA]);
    lifecycle = ScreenModelLifecycle.idle;
  }

  ExploreModelSnapshot snapshot() => ExploreModelSnapshot(
        mode: mode,
        world: world.snapshot(),
      );
}

class ExploreModelSnapshot {
  const ExploreModelSnapshot({required this.mode, required this.world});

  final TwoBlockMode mode;
  final BuoyancyWorldSnapshot world;

  @override
  bool operator ==(Object other) =>
      other is ExploreModelSnapshot && mode == other.mode && world == other.world;

  @override
  int get hashCode => Object.hash(mode, world);
}
