import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/buoyancy/application/application_geometry.dart';
import 'package:kratos/buoyancy/domain/fluid/buoyancy_pool.dart';
import 'package:kratos/buoyancy/domain/force/force_visualization_contract.dart';
import 'package:kratos/buoyancy/domain/mass/buoyancy_mass.dart';
import 'package:kratos/buoyancy/domain/material/buoyancy_gravity.dart';
import 'package:kratos/buoyancy/domain/material/buoyancy_material.dart';
import 'package:kratos/buoyancy/domain/shape/shape_geometry.dart';
import 'package:kratos/buoyancy/domain/world/vec2.dart';
import 'package:kratos/buoyancy/physics/buoyancy_forces.dart';
import 'package:kratos/buoyancy/physics/buoyancy_physics_world.dart';
import 'package:kratos/buoyancy/physics/constants.dart';
import 'package:kratos/buoyancy/physics/drag_constraint.dart';
import 'package:kratos/buoyancy/physics/physics_clock.dart';
import 'package:kratos/buoyancy/physics/submerged_volume.dart';

BuoyancyMass woodBlock({
  String id = 'a',
  double massKg = 2,
  BVec2? position,
}) {
  final volume = massKg / BuoyancyMaterial.wood.density;
  return BuoyancyMass(
    id: id,
    material: BuoyancyMaterial.wood,
    geometry: ShapeGeometry.cubeFromVolume(volume),
    position: position ?? const BVec2(0, 0.2),
  );
}

void main() {
  group('A. Unit — buoyant force', () {
    test('F_b = rho * V_sub * g when fully submerged', () {
      final mass = woodBlock(massKg: 2);
      // Force full submersion by placing deep in water.
      mass.position = BVec2(0, -0.2);
      final pool = BuoyancyPool();
      pool.fluidY = 0;
      BuoyancyForces.applyPostStepForces(
        mass: mass,
        pool: pool,
        gravity: BuoyancyGravity.earth,
        fixedDt: BuoyancyPhysicsConstants.fixedTimeStep,
      );
      final expected = pool.fluidDensity * mass.volume * BuoyancyGravity.earth.value;
      expect(mass.buoyancyForce.y, closeTo(expected, 1e-6));
      expect(mass.buoyancyForce.x, 0);
    });

    test('F_b = 0 when above fluid', () {
      final mass = woodBlock();
      mass.position = const BVec2(0, 2);
      final pool = BuoyancyPool();
      pool.fluidY = 0;
      BuoyancyForces.applyPostStepForces(
        mass: mass,
        pool: pool,
        gravity: BuoyancyGravity.earth,
        fixedDt: BuoyancyPhysicsConstants.fixedTimeStep,
      );
      expect(mass.buoyancyForce.magnitude, 0);
      expect(mass.submergedVolume, 0);
    });

    test('scales with liquid density', () {
      final mass = woodBlock();
      mass.position = const BVec2(0, -0.2);
      final water = BuoyancyPool(fluidMaterial: BuoyancyMaterial.water)
        ..fluidY = 0;
      final mercury = BuoyancyPool(fluidMaterial: BuoyancyMaterial.mercury)
        ..fluidY = 0;
      BuoyancyForces.applyPostStepForces(
        mass: mass,
        pool: water,
        gravity: BuoyancyGravity.earth,
        fixedDt: BuoyancyPhysicsConstants.fixedTimeStep,
      );
      final fw = mass.buoyancyForce.y;
      BuoyancyForces.applyPostStepForces(
        mass: mass,
        pool: mercury,
        gravity: BuoyancyGravity.earth,
        fixedDt: BuoyancyPhysicsConstants.fixedTimeStep,
      );
      expect(mass.buoyancyForce.y / fw,
          closeTo(BuoyancyMaterial.mercury.density / BuoyancyMaterial.water.density, 1e-6));
    });
  });

  group('A. Unit — gravity', () {
    test('F_g = (0, -m*g)', () {
      final mass = woodBlock(massKg: 2);
      final pool = BuoyancyPool()..fluidY = -10;
      BuoyancyForces.applyPostStepForces(
        mass: mass,
        pool: pool,
        gravity: BuoyancyGravity.earth,
        fixedDt: BuoyancyPhysicsConstants.fixedTimeStep,
      );
      expect(mass.gravityForce.x, 0);
      expect(mass.gravityForce.y, closeTo(-2 * 9.8, 1e-9));
    });

    test('different g changes gravity and buoyancy together', () {
      final mass = woodBlock();
      mass.position = const BVec2(0, -0.2);
      final pool = BuoyancyPool()..fluidY = 0;
      BuoyancyForces.applyPostStepForces(
        mass: mass,
        pool: pool,
        gravity: BuoyancyGravity.moon,
        fixedDt: BuoyancyPhysicsConstants.fixedTimeStep,
      );
      expect(mass.gravityForce.y, closeTo(-mass.mass * 1.6, 1e-9));
      expect(
        mass.buoyancyForce.y,
        closeTo(pool.fluidDensity * mass.submergedVolume * 1.6, 1e-6),
      );
    });
  });

  group('A. Unit — mass/volume/density', () {
    test('mass = density * volume for named materials', () {
      final m = woodBlock(massKg: 2);
      expect(m.mass, closeTo(2, 1e-6));
      expect(m.density, 400);
      expect(m.volume, closeTo(2 / 400, 1e-9));
    });

    test('fixed density: setMassKeepingDensity resizes volume', () {
      final m = woodBlock(massKg: 2);
      m.setMassKeepingDensity(4);
      expect(m.density, 400);
      expect(m.mass, closeTo(4, 1e-6));
      expect(m.volume, closeTo(4 / 400, 1e-9));
    });

    test('custom density does not auto-change unless asked', () {
      final g = ShapeGeometry.cubeFromVolume(0.005);
      final m = BuoyancyMass(
        id: 'c',
        material: BuoyancyMaterial.customSolid(800),
        geometry: g,
        position: BVec2.zero,
      );
      final before = m.volume;
      m.setMaterial(BuoyancyMaterial.customSolid(1600));
      expect(m.volume, before);
      expect(m.mass, closeTo(1600 * before, 1e-6));
    });
  });

  group('A. Unit — submerged volume shapes', () {
    late ShapeGeometry block;
    late ShapeGeometry ellipsoid;
    late ShapeGeometry vCylinder;
    late ShapeGeometry hCylinder;
    late ShapeGeometry coneUp;
    late ShapeGeometry coneDown;

    setUp(() {
      block = ShapeGeometry.block(width: 0.2, height: 0.2, depth: 0.2);
      ellipsoid =
          ShapeGeometry.ellipsoid(width: 0.2, height: 0.2, depth: 0.2);
      vCylinder =
          ShapeGeometry.verticalCylinder(radius: 0.1, height: 0.2);
      hCylinder =
          ShapeGeometry.horizontalCylinder(radius: 0.1, length: 0.2);
      coneUp = ShapeGeometry.cone(radius: 0.1, height: 0.2, vertexUp: true);
      coneDown =
          ShapeGeometry.cone(radius: 0.1, height: 0.2, vertexUp: false);
    });

    void expectCases(ShapeGeometry g) {
      const cy = 0.0;
      final half = g.halfHeight;
      expect(
        SubmergedVolume.displacedVolume(
            geometry: g, centerY: cy, fluidY: cy - half - 0.01),
        0,
      );
      expect(
        SubmergedVolume.displacedVolume(
            geometry: g, centerY: cy, fluidY: cy + half + 0.01),
        closeTo(g.totalVolume, 1e-9),
      );
      final mid = SubmergedVolume.displacedVolume(
          geometry: g, centerY: cy, fluidY: cy);
      expect(mid, greaterThan(0));
      expect(mid, lessThan(g.totalVolume));
    }

    test('block', () => expectCases(block));
    test('ellipsoid / duck physics', () {
      expectCases(ellipsoid);
      final duck =
          ShapeGeometry.duck(width: 0.2, height: 0.2, depth: 0.2);
      expect(
        SubmergedVolume.displacedVolume(
            geometry: duck, centerY: 0, fluidY: 0),
        SubmergedVolume.displacedVolume(
            geometry: ellipsoid, centerY: 0, fluidY: 0),
      );
    });
    test('vertical cylinder', () => expectCases(vCylinder));
    test('horizontal cylinder', () => expectCases(hCylinder));
    test('cone vertex up', () => expectCases(coneUp));
    test('inverted cone', () => expectCases(coneDown));

    test('application piecewise volume', () {
      final areas = [0.0, 0.1, 0.2, 0.1, 0.0];
      final volumes = [0.0, 0.01, 0.03, 0.04, 0.05];
      final g = ShapeGeometry.application(
        kind: MassShapeKind.bottle,
        areas: areas,
        volumes: volumes,
        maxVolume: 0.05,
        height: 0.2,
      );
      expect(
        SubmergedVolume.displacedVolume(
            geometry: g, centerY: 0, fluidY: -0.2),
        0,
      );
      expect(
        SubmergedVolume.displacedVolume(
            geometry: g, centerY: 0, fluidY: 0.2),
        0.05,
      );
      expect(
        SubmergedVolume.displacedVolume(geometry: g, centerY: 0, fluidY: 0),
        closeTo(0.03, 1e-12),
      );
    });
  });

  group('B. Integration — physics step', () {
    test('fixed step is 1/120 and caps at 30', () {
      final clock = PhysicsClock();
      expect(clock.fixedDt, closeTo(1 / 120, 1e-15));
      expect(clock.maxSubSteps, 30);
      final n = clock.planSubsteps(1.0); // would need 120 steps
      expect(n, 30);
    });

    test('small dt runs proportionally', () {
      final clock = PhysicsClock();
      expect(clock.planSubsteps(1 / 120), 1);
      expect(clock.planSubsteps(2 / 120), 2);
    });

    test('pause freezes; resume continues', () {
      final world = BuoyancyPhysicsWorld();
      world.addMass(woodBlock());
      world.clock.pause();
      final before = world.snapshot();
      world.step(0.1);
      expect(world.snapshot(), before);
      world.clock.resume();
      world.step(0.1);
      expect(world.clock.simulationTime, greaterThan(0));
    });

    test('wood floats in water without teleport', () {
      final world = BuoyancyPhysicsWorld();
      final m = woodBlock(position: const BVec2(0, -0.05));
      world.addMass(m);
      for (var i = 0; i < 600; i++) {
        world.step(1 / 60);
      }
      expect(m.position.y.isFinite, isTrue);
      expect(m.velocity.magnitude, lessThan(1));
      // Wood density 400 < water 1000 → should not sit on pool floor.
      expect(m.bottomY, greaterThan(world.pool.minY + 0.01));
    });

    test('aluminum sinks without teleport', () {
      final world = BuoyancyPhysicsWorld();
      final volume = 0.005;
      final m = BuoyancyMass(
        id: 'al',
        material: BuoyancyMaterial.aluminum,
        geometry: ShapeGeometry.cubeFromVolume(volume),
        position: const BVec2(0, 0.1),
      );
      world.addMass(m);
      for (var i = 0; i < 800; i++) {
        world.step(1 / 60);
      }
      expect(m.bottomY, closeTo(world.pool.minY, 0.02));
    });

    test('neutral buoyancy net force near zero when fully submerged', () {
      final volume = 0.005;
      final m = BuoyancyMass(
        id: 'n',
        material: BuoyancyMaterial.customSolid(1000),
        geometry: ShapeGeometry.cubeFromVolume(volume),
        position: const BVec2(0, -0.2),
      );
      final pool = BuoyancyPool()..fluidY = 0;
      BuoyancyForces.applyPostStepForces(
        mass: m,
        pool: pool,
        gravity: BuoyancyGravity.earth,
        fixedDt: BuoyancyPhysicsConstants.fixedTimeStep,
      );
      final net = m.gravityForce.y + m.buoyancyForce.y;
      expect(net.abs(), lessThan(1e-6));
    });
  });

  group('C. Drag constraint', () {
    test('startDrag lifts by 0.0001 and sets userControlled', () {
      final m = woodBlock();
      final y0 = m.position.y;
      DragConstraint.startDrag(m, m.position);
      expect(m.userControlled, isTrue);
      expect(m.position.y, closeTo(y0 + 0.0001, 1e-12));
      expect(DragConstraint.maxForceFor(m), 2500);
    });

    test('update does not teleport; release keeps velocity', () {
      final world = BuoyancyPhysicsWorld();
      final m = woodBlock();
      world.addMass(m);
      world.startDrag('a', m.position);
      world.updateDrag('a', const BVec2(0.1, 0.3));
      world.step(1 / 60);
      expect(m.userControlled, isTrue);
      expect(m.position.x, isNot(0.1)); // force-limited, not teleport
      final vBefore = m.velocity;
      world.endDrag('a');
      expect(m.userControlled, isFalse);
      expect(m.velocity, vBefore);
    });

    test('physics continues while dragging', () {
      final world = BuoyancyPhysicsWorld();
      final m = woodBlock(position: const BVec2(0, 0.05));
      world.addMass(m);
      world.startDrag('a', m.position);
      final t0 = world.clock.simulationTime;
      world.step(0.1);
      expect(world.clock.simulationTime, greaterThan(t0));
      expect(m.gravityForce.magnitude, greaterThan(0));
    });
  });

  group('D. Determinism', () {
    BuoyancyWorldSnapshot runOnce() {
      final world = BuoyancyPhysicsWorld();
      world.addMass(woodBlock(position: const BVec2(0, -0.02)));
      for (var i = 0; i < 240; i++) {
        world.step(1 / 60);
      }
      return world.snapshot();
    }

    test('three identical runs match', () {
      final a = runOnce();
      final b = runOnce();
      final c = runOnce();
      expect(a, b);
      expect(b, c);
    });
  });

  group('E. Stability / isolation / reset', () {
    test('1000 steps stay finite', () {
      final world = BuoyancyPhysicsWorld();
      world.addMass(woodBlock());
      world.addMass(woodBlock(id: 'b', massKg: 4, position: const BVec2(0.2, 0.2)));
      for (var i = 0; i < 1000; i++) {
        world.step(1 / 60);
      }
      for (final m in world.masses) {
        expect(m.position.isFinite, isTrue);
        expect(m.velocity.isFinite, isTrue);
        expect(m.mass.isFinite, isTrue);
      }
      expect(world.pool.fluidY.isFinite, isTrue);
    });

    test('two worlds do not share state', () {
      final a = BuoyancyPhysicsWorld();
      final b = BuoyancyPhysicsWorld();
      a.addMass(woodBlock(id: 'a'));
      b.addMass(woodBlock(id: 'b', massKg: 8));
      a.gravity = BuoyancyGravity.moon;
      expect(b.gravity.value, 9.8);
      a.step(0.1);
      expect(b.clock.simulationTime, 0);
      expect(b.masses.single.mass, closeTo(8, 1e-6));
    });

    test('reset restores mass and clock', () {
      final world = BuoyancyPhysicsWorld();
      final m = woodBlock();
      world.addMass(m);
      world.step(0.5);
      world.startDrag('a', const BVec2(0.2, 0.4));
      world.resetWorld();
      expect(world.clock.simulationTime, 0);
      expect(m.userControlled, isFalse);
      expect(m.position, const BVec2(0, 0.2));
      expect(m.velocity, BVec2.zero);
    });

    test('application geometry boundary rejects cube stand-in API misuse', () {
      final geo = PiecewiseApplicationGeometry(
        kind: MassShapeKind.boat,
        areas: const [0, 1, 0],
        volumes: const [0, 0.5, 1],
        maxVolume: 1,
        height: 0.2,
      );
      expect(geo.toShapeGeometry().kind, MassShapeKind.boat);
      expect(geo.toShapeGeometry().kind, isNot(MassShapeKind.block));
    });

    test('force visualization contract uses source zoom mapping', () {
      expect(ForceVisualizationContract.zoomScaleForLevel(4), 1 / 16);
      expect(
        ForceVisualizationContract.arrowTipY(19.6, 4),
        closeTo(-19.6 * (1 / 16) * 20, 1e-9),
      );
    });

    test('fluid level rises with displacement', () {
      final world = BuoyancyPhysicsWorld();
      final y0 = world.pool.fluidY;
      final m = BuoyancyMass(
        id: 'sink',
        material: BuoyancyMaterial.aluminum,
        geometry: ShapeGeometry.cubeFromVolume(0.01),
        position: const BVec2(0, -0.1),
      );
      world.addMass(m);
      world.pool.computeFluidY(world.masses);
      expect(world.pool.fluidY, greaterThan(y0));
    });
  });

  group('Materials catalog', () {
    test('source densities present', () {
      expect(BuoyancyMaterial.wood.density, 400);
      expect(BuoyancyMaterial.water.density, 1000);
      expect(BuoyancyMaterial.materialR.density, 5010);
      expect(BuoyancyMaterial.buoyancyFluidMaterials.length, 6);
      expect(BuoyancyMaterial.simpleMassMaterials.length, 6);
    });
  });

  group('No Density spring reuse', () {
    test('drag maxForce is 2500 not spring-stiffness based', () {
      final m = woodBlock();
      expect(DragConstraint.maxForceFor(m), 2500);
      // Density BuoyancyWorld uses pointerStiffness=180 — we do not.
      expect(DragConstraint.startDragOffset, 0.0001);
    });
  });
}
