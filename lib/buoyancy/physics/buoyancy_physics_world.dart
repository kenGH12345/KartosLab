import '../domain/fluid/buoyancy_pool.dart';
import '../domain/mass/buoyancy_mass.dart';
import '../domain/material/buoyancy_gravity.dart';
import '../domain/world/vec2.dart';
import 'buoyancy_forces.dart';
import 'collision.dart';
import 'constants.dart';
import 'drag_constraint.dart';
import 'physics_clock.dart';

/// Shared physics world for all Buoyancy screens.
///
/// Does not know Compare/Explore/Lab/Shapes/Applications.
/// Does not import Flutter UI.
/// Does not reuse `lib/density/solver/buoyancy_world.dart`.
class BuoyancyPhysicsWorld {
  BuoyancyPhysicsWorld({
    BuoyancyPool? pool,
    BuoyancyGravity? gravity,
    PhysicsClock? clock,
    CollisionResolver? collision,
  })  : pool = pool ?? BuoyancyPool(),
        gravity = gravity ?? BuoyancyGravity.earth,
        clock = clock ?? PhysicsClock(),
        collision = collision ?? CollisionResolver();

  final BuoyancyPool pool;
  BuoyancyGravity gravity;
  final PhysicsClock clock;
  final CollisionResolver collision;
  final List<BuoyancyMass> masses = <BuoyancyMass>[];

  /// Optional Applications / multi-basin hook — runs before forces each fixed step.
  void Function()? beforeForcesHook;

  /// Optional per-mass basin fluid context (boat cabin). Null → main pool.
  ({
    double fluidY,
    double fluidVolume,
    double fluidDensity,
    double additionalVerticalAcceleration,
  })? Function(BuoyancyMass mass)? basinContextFor;

  void addMass(BuoyancyMass mass) {
    assert(masses.every((m) => m.id != mass.id), 'duplicate mass id');
    masses.add(mass);
  }

  void removeMass(String id) {
    masses.removeWhere((m) => m.id == id);
  }

  BuoyancyMass? massById(String id) {
    for (final m in masses) {
      if (m.id == id) {
        return m;
      }
    }
    return null;
  }

  /// Host frame dt → fixed substeps.
  void step(double externalDt) {
    final n = clock.planSubsteps(externalDt);
    for (var i = 0; i < n; i++) {
      _fixedStep(clock.fixedDt);
    }
    clock.advanceSimulationTime(n);
  }

  void _fixedStep(double dt) {
    final visible = masses.where((m) => m.visible).toList(growable: false);

    // updateFluid before forces (DensityBuoyancyModel postStep)
    beforeForcesHook?.call();
    pool.computeFluidY(visible);

    for (final mass in visible) {
      // Constraint force first (user drag continues during physics).
      mass.constraintForce = DragConstraint.computeForce(mass, dt);

      final basin = basinContextFor?.call(mass);
      BuoyancyForces.applyPostStepForces(
        mass: mass,
        pool: pool,
        gravity: gravity,
        fixedDt: dt,
        fluidYOverride: basin?.fluidY,
        fluidVolumeOverride: basin?.fluidVolume,
        fluidDensityOverride: basin?.fluidDensity,
        additionalVerticalAcceleration:
            basin?.additionalVerticalAcceleration ?? 0,
      );

      final net = BuoyancyForces.netNonContact(mass);
      assert(net.isFinite);

      final a = BVec2(net.x / mass.mass, net.y / mass.mass);
      var v = mass.velocity + a * dt;
      if (v.magnitude > BuoyancyPhysicsConstants.velocityCap) {
        v = v.withMagnitude(BuoyancyPhysicsConstants.velocityCap);
      }
      mass.velocity = v;
      mass.position = mass.position + mass.velocity * dt;

      collision.resolve(mass, pool);
      _assertFinite(mass);
    }

    collision.resolvePairs(visible);

    // Recompute fluid after motion (displacement changes).
    pool.computeFluidY(masses.where((m) => m.visible).toList());
  }

  void startDrag(String id, BVec2 modelPosition) {
    final mass = massById(id);
    if (mass == null || !mass.canMove) {
      return;
    }
    DragConstraint.startDrag(mass, modelPosition);
  }

  void updateDrag(String id, BVec2 modelPosition) {
    final mass = massById(id);
    if (mass == null) {
      return;
    }
    DragConstraint.updateDrag(mass, modelPosition);
  }

  void endDrag(String id) {
    final mass = massById(id);
    if (mass == null) {
      return;
    }
    DragConstraint.endDrag(mass);
  }

  void resetWorld({bool resetFluidMaterial = true}) {
    clock.reset();
    pool.reset(resetFluidMaterial: resetFluidMaterial);
    for (final m in masses) {
      m.reset();
    }
    pool.computeFluidY(masses.where((m) => m.visible).toList());
  }

  void resetMass(String id) {
    massById(id)?.reset();
  }

  BuoyancyWorldSnapshot snapshot() => BuoyancyWorldSnapshot(
        simulationTime: clock.simulationTime,
        fluidY: pool.fluidY,
        fluidVolume: pool.fluidVolume,
        fluidDensity: pool.fluidDensity,
        gravity: gravity.value,
        masses: masses.map((m) => m.snapshot()).toList(growable: false),
      );

  static void _assertFinite(BuoyancyMass mass) {
    assert(mass.position.isFinite);
    assert(mass.velocity.isFinite);
    assert(mass.mass.isFinite && mass.mass > 0);
    assert(mass.volume.isFinite && mass.volume > 0);
    assert(mass.density.isFinite && mass.density > 0);
    assert(mass.gravityForce.isFinite);
    assert(mass.buoyancyForce.isFinite);
  }
}

class BuoyancyWorldSnapshot {
  const BuoyancyWorldSnapshot({
    required this.simulationTime,
    required this.fluidY,
    required this.fluidVolume,
    required this.fluidDensity,
    required this.gravity,
    required this.masses,
  });

  final double simulationTime;
  final double fluidY;
  final double fluidVolume;
  final double fluidDensity;
  final double gravity;
  final List<BuoyancyMassSnapshot> masses;

  @override
  bool operator ==(Object other) {
    if (other is! BuoyancyWorldSnapshot) {
      return false;
    }
    if (simulationTime != other.simulationTime ||
        fluidY != other.fluidY ||
        fluidVolume != other.fluidVolume ||
        fluidDensity != other.fluidDensity ||
        gravity != other.gravity ||
        masses.length != other.masses.length) {
      return false;
    }
    for (var i = 0; i < masses.length; i++) {
      if (masses[i] != other.masses[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        simulationTime,
        fluidY,
        fluidVolume,
        fluidDensity,
        gravity,
        masses.length,
      );
}
