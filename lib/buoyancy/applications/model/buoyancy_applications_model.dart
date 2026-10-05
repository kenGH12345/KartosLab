import '../../application/application_geometry.dart';
import '../../domain/mass/buoyancy_mass.dart';
import '../../domain/material/buoyancy_gravity.dart';
import '../../domain/material/buoyancy_material.dart';
import '../../domain/shape/shape_geometry.dart';
import '../../domain/world/vec2.dart';
import '../../physics/buoyancy_physics_world.dart';
import '../../physics/constants.dart';
import '../../shared/application_mode.dart';
import '../../shared/buoyancy_scale_host.dart';
import '../../shared/buoyancy_screen_model.dart';
import 'boat_basin.dart';

/// Applications screen model — `BuoyancyApplicationsModel.ts`.
///
/// Bottle/Boat outer displacement uses source piecewise tables.
/// Boat cabin basin coupling follows source `updateFluid` / `getPoolFluidVolume`.
///
/// Source snapshot: LOCAL density-buoyancy-common HEAD `0c835c64`
/// (physics-equivalent to lockfile `0295f8f6`).
class BuoyancyApplicationsModel extends BuoyancyScreenModel
    with BuoyancyScaleHost {
  BuoyancyApplicationsModel({super.world}) {
    bottle = _createBottle();
    block = _createBrick();
    boat = _createBoat();
    world.addMass(bottle);
    world.addMass(block);
    world.addMass(boat);
    // Land scale −0.77 (`BuoyancyApplicationsModel.ts`).
    initScaleBodies(landX: -0.77);
    world.beforeForcesHook = _updateFluidCoupling;
    world.basinContextFor = _basinContextFor;
    _applyModeVisibility();
    world.pool.computeFluidY(
      world.masses.where((m) => m.visible).toList(),
    );
    lifecycle = ScreenModelLifecycle.idle;
  }

  static const double bottleVolume = 0.01;
  static const double bottleMassEmpty = 0.1;
  static const double bottleInteriorVolumeDefault = 0.004;
  static const double bottleHeight =
      2 * 0.85 * 0.08495233866810234; // FULL_RADIUS * scale * 2

  static const double defaultDisplacementVolume = 0.01; // 10 L equiv capacity
  static const double oneLiterHullVolume = 0.00011111354453554843;
  static const double oneLiterBoatHeight =
      BoatBasin.oneLiterBoundsMaxY - BoatBasin.oneLiterBoundsMinY;

  static const double fillEmptyMultiplier = 0.3;
  static const double boatReadyToSpillThreshold = 0.9;
  static const double boatFullThreshold = 0.01;

  late final BuoyancyMass bottle;
  late final BuoyancyMass block;
  late final BuoyancyMass boat;

  /// Source `Boat.basin` — independent cabin fluid compartment.
  final BoatBasin boatBasin = BoatBasin();

  ApplicationMode applicationMode = ApplicationMode.bottle;

  /// Bottle interior (materialInside*).
  BuoyancyMaterial bottleInteriorMaterial = BuoyancyMaterial.water;
  double bottleInteriorVolume = bottleInteriorVolumeDefault;

  bool spillingFluidOutOfBoat = false;
  bool boatFullySubmerged = false;
  double boatVerticalVelocity = 0;
  double boatVerticalAcceleration = 0;

  /// Back-compat accessor used by tests / snapshots.
  double get boatBasinFluidVolume => boatBasin.fluidVolume;
  set boatBasinFluidVolume(double v) => boatBasin.fluidVolume = v;

  static double get boatHullVolumeStatic =>
      oneLiterHullVolume *
      (defaultDisplacementVolume * BuoyancyPhysicsConstants.litersInCubicMeter);

  double get boatHullVolume => boatHullVolumeStatic;

  BuoyancyMass _createBottle() {
    final interiorMass =
        bottleInteriorMaterial.density * bottleInteriorVolumeDefault;
    final density = (bottleMassEmpty + interiorMass) / bottleVolume;
    final geom = PiecewiseApplicationGeometry.bottleTenLiter(
      height: bottleHeight,
    );
    return BuoyancyMass(
      id: 'applications.bottle',
      material: BuoyancyMaterial.customSolid(density),
      geometry: geom.toShapeGeometry(),
      position: BVec2.zero,
      containedMass: 0,
      visible: true,
    );
  }

  BuoyancyMass _createBrick() {
    return BuoyancyMass(
      id: 'applications.block',
      material: BuoyancyMaterial.brick,
      geometry: ShapeGeometry.cubeFromVolume(0.001),
      position: const BVec2(-0.5, 0.3),
      visible: false,
    );
  }

  BuoyancyMass _createBoat() {
    final geom = PiecewiseApplicationGeometry.boatScaled(
      displacementVolumeM3: defaultDisplacementVolume,
      oneLiterHeight: oneLiterBoatHeight,
      hullVolume: boatHullVolume,
    );
    return BuoyancyMass(
      id: 'applications.boat',
      material: BuoyancyMaterial.boatHull,
      geometry: geom.toShapeGeometry(),
      position: const BVec2(0.08, -0.1),
      containedMass: 0,
      visible: false,
    );
  }

  void _applyModeVisibility() {
    final bottleMode = applicationMode == ApplicationMode.bottle;
    bottle.visible = bottleMode;
    boat.visible = !bottleMode;
    block.visible = !bottleMode;
  }

  void setApplicationMode(ApplicationMode mode) {
    if (mode == applicationMode) {
      return;
    }
    final previous = applicationMode;
    applicationMode = mode;
    _applyModeVisibility();

    // When leaving boat scene, pour boat-basin fluid into pool.
    if (previous == ApplicationMode.boat && mode == ApplicationMode.bottle) {
      world.pool.fluidVolume += boatBasin.fluidVolume;
      boatBasin.reset();
      boat.containedMass = 0;
    }
    world.pool.computeFluidY(world.masses.where((m) => m.visible).toList());
  }

  void setBottleInteriorMaterial(BuoyancyMaterial material) {
    bottleInteriorMaterial = material;
    _syncBottleDensity();
  }

  void setBottleInteriorVolume(double volumeM3) {
    bottleInteriorVolume = volumeM3.clamp(0.0, 0.01).toDouble();
    _syncBottleDensity();
  }

  void _syncBottleDensity() {
    final interiorMass =
        bottleInteriorMaterial.density * bottleInteriorVolume;
    bottle.setCustomDensity(
      (bottleMassEmpty + interiorMass) / bottleVolume,
    );
  }

  void setBlockMaterial(BuoyancyMaterial material) {
    block.setMaterial(material);
    // ApplicationsScreenView: Material X → 0.006 m³, Y → 0.003 m³.
    if (material.id == BuoyancyMaterial.materialX.id) {
      setBlockVolume(0.006);
    } else if (material.id == BuoyancyMaterial.materialY.id) {
      setBlockVolume(0.003);
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
    block.setVolumeKeepingDensity(volumeM3);
  }

  /// Inject fluid into cabin (tests / scenario) — model-level only.
  void setBoatBasinFluidVolume(double volumeM3) {
    boatBasin.fluidVolume = volumeM3.clamp(0.0, double.infinity).toDouble();
    boatBasin.updateStepFromBoat(
      boat: boat,
      displacementVolumeM3: defaultDisplacementVolume,
    );
    boatBasin.computeY();
    boat.containedMass =
        world.pool.fluidMaterial.density * boatBasin.fluidVolume;
  }

  /// Re-float sunken boat — `resetBoatAndBlockPosition`.
  void resetBoatAndBlockPosition() {
    block.reset();
    boat.reset();
    boatBasin.reset();
    boat.containedMass = 0;
    spillingFluidOutOfBoat = false;
    boatFullySubmerged = false;
    boatVerticalVelocity = 0;
    boatVerticalAcceleration = 0;
    world.pool.reset(resetFluidMaterial: false);
    world.pool.computeFluidY(world.masses.where((m) => m.visible).toList());
  }

  /// Source `BuoyancyApplicationsModel.updateFluid` + `getPoolFluidVolume`.
  void _updateFluidCoupling() {
    if (applicationMode != ApplicationMode.boat || !boat.visible) {
      return;
    }

    boatBasin.updateStepFromBoat(
      boat: boat,
      displacementVolumeM3: defaultDisplacementVolume,
    );
    final boatStepTop = boatBasin.boatStepTop(boat, defaultDisplacementVolume);

    var poolFluidVolume = world.pool.fluidVolume;
    var boatFluidVolume = boatBasin.fluidVolume;
    final boatBasinMaximumVolume = boatBasin.getMaximumVolume(boatBasin.stepTop);

    final poolEmptyVolumeToBoatTop = world.pool.emptyVolumeAt(
      boatStepTop.clamp(world.pool.minY, world.pool.maxY),
      world.masses.where((m) => m.visible).toList(),
    );
    final boatEmptyVolumeToBoatTop = boatBasin.getEmptyVolume(boatStepTop);

    var poolExcess = poolFluidVolume - poolEmptyVolumeToBoatTop;
    var boatExcess = boatFluidVolume - boatEmptyVolumeToBoatTop;

    final boatHeight = boat.geometry.height;

    if (boatFluidVolume > 0) {
      if (boatStepTop >
          world.pool.fluidY + boatHeight * boatReadyToSpillThreshold) {
        spillingFluidOutOfBoat = true;
      }
    } else {
      spillingFluidOutOfBoat = false;
    }

    if (spillingFluidOutOfBoat) {
      boatExcess =
          (fillEmptyMultiplier * boat.volume).clamp(0.0, boatFluidVolume);
    } else if (boatFluidVolume > 0 &&
        (boatBasin.fluidY - boatBasin.stepTop).abs() >= boatFullThreshold) {
      // Filling animation toward full (source getPoolFluidVolume).
      final excess = _min(
        fillEmptyMultiplier * boat.volume,
        boatBasinMaximumVolume - boatFluidVolume,
      );
      poolExcess = excess;
      boatExcess = -excess;
    }

    if (poolExcess > 0 && boatExcess < 0) {
      final transfer = _min(poolExcess, -boatExcess);
      poolFluidVolume -= transfer;
      boatFluidVolume += transfer;
    } else if (boatExcess > 0) {
      poolFluidVolume += boatExcess;
      boatFluidVolume -= boatExcess;
    }

    world.pool.fluidVolume = poolFluidVolume;
    boatBasin.fluidVolume = boatFluidVolume;
    boatBasin.computeY();
    boat.containedMass =
        world.pool.fluidMaterial.density * boatBasin.fluidVolume;

    boatFullySubmerged =
        boatStepTop < world.pool.fluidY - BuoyancyPhysicsConstants.tolerance;
  }

  ({
    double fluidY,
    double fluidVolume,
    double fluidDensity,
    double additionalVerticalAcceleration,
  })? _basinContextFor(BuoyancyMass mass) {
    if (applicationMode != ApplicationMode.boat || !boat.visible) {
      return null;
    }
    if (boatBasin.isMassInside(mass, boat) && !boatFullySubmerged) {
      return (
        fluidY: boatBasin.fluidY,
        fluidVolume: boatBasin.fluidVolume,
        fluidDensity: world.pool.fluidDensity,
        additionalVerticalAcceleration: boatVerticalAcceleration,
      );
    }
    return null;
  }

  @override
  void step(double externalDt) {
    if (isDisposed || isPaused) {
      return;
    }
    syncScaleBodies();
    lifecycle = ScreenModelLifecycle.physicsRunning;
    final prevVy = boat.velocity.y;
    world.step(externalDt);
    if (applicationMode == ApplicationMode.boat && boat.visible) {
      final dt = externalDt <= 0 ? 1 / 60 : externalDt;
      boatVerticalAcceleration = (boat.velocity.y - prevVy) / dt;
      boatVerticalVelocity = boat.velocity.y;
      final boatStepTop =
          boatBasin.boatStepTop(boat, defaultDisplacementVolume);
      boatFullySubmerged =
          boatStepTop < world.pool.fluidY - BuoyancyPhysicsConstants.tolerance;
    }
    if (!landScale.userControlled) {
      landScaleX = landScale.position.x.clamp(-1.2, world.pool.minX - 0.08);
      landScale.position = BVec2(landScaleX, landScale.position.y);
    }
    lifecycle = ScreenModelLifecycle.idle;
  }

  @override
  void reset() {
    applicationMode = ApplicationMode.bottle;
    bottleInteriorMaterial = BuoyancyMaterial.water;
    bottleInteriorVolume = bottleInteriorVolumeDefault;
    boatBasin.reset();
    spillingFluidOutOfBoat = false;
    boatFullySubmerged = false;
    boatVerticalVelocity = 0;
    boatVerticalAcceleration = 0;
    world.gravity = BuoyancyGravity.earth;
    world.resetWorld();
    resetScaleBodies(landX: -0.77);
    _syncBottleDensity();
    _applyModeVisibility();
    world.pool.computeFluidY(world.masses.where((m) => m.visible).toList());
    lifecycle = ScreenModelLifecycle.idle;
  }

  ApplicationsModelSnapshot snapshot() => ApplicationsModelSnapshot(
        applicationMode: applicationMode,
        bottleInteriorVolume: bottleInteriorVolume,
        bottleInteriorMaterialId: bottleInteriorMaterial.id,
        boatBasinFluidVolume: boatBasin.fluidVolume,
        world: world.snapshot(),
      );

  static double _min(double a, double b) => a < b ? a : b;
}

class ApplicationsModelSnapshot {
  const ApplicationsModelSnapshot({
    required this.applicationMode,
    required this.bottleInteriorVolume,
    required this.bottleInteriorMaterialId,
    required this.boatBasinFluidVolume,
    required this.world,
  });

  final ApplicationMode applicationMode;
  final double bottleInteriorVolume;
  final String bottleInteriorMaterialId;
  final double boatBasinFluidVolume;
  final BuoyancyWorldSnapshot world;

  @override
  bool operator ==(Object other) =>
      other is ApplicationsModelSnapshot &&
      applicationMode == other.applicationMode &&
      bottleInteriorVolume == other.bottleInteriorVolume &&
      bottleInteriorMaterialId == other.bottleInteriorMaterialId &&
      boatBasinFluidVolume == other.boatBasinFluidVolume &&
      world == other.world;

  @override
  int get hashCode => Object.hash(
        applicationMode,
        bottleInteriorVolume,
        bottleInteriorMaterialId,
        boatBasinFluidVolume,
        world,
      );
}
