
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/buoyancy/applications/composer/applications_composer.dart';
import 'package:kratos/buoyancy/applications/model/buoyancy_applications_model.dart';
import 'package:kratos/buoyancy/buoyancy_sim_host.dart';
import 'package:kratos/buoyancy/compare/composer/compare_composer.dart';
import 'package:kratos/buoyancy/compare/model/buoyancy_compare_model.dart';
import 'package:kratos/buoyancy/domain/material/buoyancy_gravity.dart';
import 'package:kratos/buoyancy/domain/material/buoyancy_material.dart';
import 'package:kratos/buoyancy/domain/shape/shape_geometry.dart';
import 'package:kratos/buoyancy/domain/world/vec2.dart';
import 'package:kratos/buoyancy/explore/composer/explore_composer.dart';
import 'package:kratos/buoyancy/explore/model/buoyancy_explore_model.dart';
import 'package:kratos/buoyancy/lab/model/buoyancy_lab_model.dart';
import 'package:kratos/buoyancy/layout/buoyancy_global_layout_spec.dart';
import 'package:kratos/buoyancy/physics/buoyancy_forces.dart';
import 'package:kratos/buoyancy/physics/constants.dart';
import 'package:kratos/buoyancy/rendering/camera/buoyancy_camera_config.dart';
import 'package:kratos/buoyancy/rendering/interaction/buoyancy_pointer_adapter.dart';
import 'package:kratos/buoyancy/rendering/mesh/duck_source_mesh.dart';
import 'package:kratos/buoyancy/rendering/mesh/procedural_meshes.dart';
import 'package:kratos/buoyancy/rendering/texture/buoyancy_texture_asset.dart';
import 'package:kratos/buoyancy/rendering/transform/bvec3.dart';
import 'package:kratos/buoyancy/rendering/transform/buoyancy_three_transform.dart';
import 'package:kratos/buoyancy/shapes/composer/shapes_composer.dart';
import 'package:kratos/buoyancy/shapes/model/buoyancy_shapes_model.dart';
import 'package:kratos/buoyancy/shared/application_mode.dart';
import 'package:kratos/buoyancy/shared/compare_block_set.dart';
import 'package:kratos/buoyancy/shared/two_block_mode.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

BuoyancyThreeTransform _mvt(BuoyancyCameraConfig cam, [Size vp = const Size(1024, 618)]) {
  return BuoyancyThreeTransform(
    camera: cam,
    frame: const BuoyancyGlobalLayoutSpec().designFrame(vp),
  );
}

void main() {
  group('PHASE 5 camera projection', () {
    test('Compare lookAt / viewOffset differ from default', () {
      final c = BuoyancyCameraConfig.compare();
      final d = BuoyancyCameraConfig.buoyancyDefault();
      expect(c.lookAt.y, isNot(d.lookAt.y));
      expect(c.viewOffset, const Offset(-25, 0));
      expect(d.viewOffset, Offset.zero);
      expect(c.up.x, 0);
      expect(c.up.y, 0);
      expect(c.up.z, -1);
      expect(c.fovDegrees, 50);
    });

    test('known world points project deterministically (3×)', () {
      final t = _mvt(BuoyancyCameraConfig.compare());
      Offset once() => t.modelToView(const BVec3(0.1, -0.05, 0));
      final a = once();
      final b = once();
      final c = once();
      expect(a, b);
      expect(b, c);
      expect(a.dx.isFinite && a.dy.isFinite, isTrue);
    });

    test('Compare offset shifts lookAt left of design center', () {
      final t = _mvt(BuoyancyCameraConfig.compare());
      final p = t.modelToView(const BVec3(0, -0.1, 0));
      expect(p.dx, lessThan(buoyancyDesignWidth / 2));
    });

    test('Shapes/Applications camera uses buoyancy lookAt', () {
      expect(BuoyancyCameraConfig.buoyancyDefault().lookAt.y, -0.18);
    });
  });

  group('PHASE 5 inverse pointer transform', () {
    test('view→ray→z0≈model for points near lookAt', () {
      final t = _mvt(BuoyancyCameraConfig.buoyancyDefault());
      for (final w in const [
        BVec3(0, -0.1, 0),
        BVec3(-0.2, 0.05, 0),
        BVec3(0.15, -0.05, 0),
      ]) {
        final view = t.modelToView(w);
        final hit = t.intersectZPlane(t.rayFromViewport(view), 0)!;
        expect(hit.x, closeTo(w.x, 0.1));
        expect(hit.y, closeTo(w.y, 0.1));
      }
    });

    test('no axis inversion: +x world → larger screen x', () {
      final t = _mvt(BuoyancyCameraConfig.compare());
      final left = t.modelMetersToView(-0.3, 0);
      final right = t.modelMetersToView(0.3, 0);
      expect(right.dx, greaterThan(left.dx));
    });

    test('edge / far pointer still yields finite ray', () {
      final t = _mvt(BuoyancyCameraConfig.compare(), const Size(375, 667));
      for (final o in const [
        Offset(1, 1),
        Offset(374, 666),
        Offset(187, 333),
      ]) {
        final ray = t.rayFromViewport(o);
        expect(ray.direction.length, closeTo(1, 1e-9));
        expect(ray.origin.x.isFinite, isTrue);
      }
    });
  });

  group('PHASE 5 drag lifecycle', () {
    test('start/move/end does not teleport and clears userControlled', () {
      final model = BuoyancyExploreModel()..pause();
      final t = ExploreComposer().transform(
        const BuoyancyGlobalLayoutSpec().designFrame(const Size(1024, 618)),
      );
      final adapter = BuoyancyPointerAdapter(t);
      final before = model.blockA.position;
      final start = t.modelMetersToView(before.x, before.y);
      adapter.start(model, 'explore.blockA', start);
      expect(model.blockA.userControlled, isTrue);
      // Source startDrag lifts y by 0.0001 — not a teleport.
      expect(model.blockA.position.y, closeTo(before.y + 0.0001, 1e-9));
      expect(model.blockA.position.x, closeTo(before.x, 1e-9));

      final move = t.modelMetersToView(before.x + 0.05, before.y + 0.02);
      adapter.update(model, 'explore.blockA', move);
      expect(model.blockA.dragTarget, isNotNull);

      adapter.end(model, 'explore.blockA');
      expect(model.blockA.userControlled, isFalse);
      expect(model.blockA.dragTarget, isNull);
    });

    test('Compare drag A then B does not swap identities', () {
      final model = BuoyancyCompareModel()..pause();
      final t = CompareComposer().transform(
        const BuoyancyGlobalLayoutSpec().designFrame(const Size(1024, 618)),
      );
      final adapter = BuoyancyPointerAdapter(t);
      final a = model.blockA;
      final b = model.blockB;
      adapter.start(
        model,
        a.id,
        t.modelMetersToView(a.position.x, a.position.y),
      );
      adapter.end(model, a.id);
      adapter.start(
        model,
        b.id,
        t.modelMetersToView(b.position.x, b.position.y),
      );
      adapter.end(model, b.id);
      expect(model.blockA.id, a.id);
      expect(model.blockB.id, b.id);
      expect(model.blockA.mass, closeTo(4, 1e-9));
      expect(model.blockB.mass, closeTo(4, 1e-9));
    });
  });

  group('PHASE 5 physical sanity', () {
    test('F_g = (0,-mg) and F_b = (0, rho V_sub g)', () {
      final lab = BuoyancyLabModel()..pause();
      lab.block.position = const BVec2(0, -0.2);
      lab.world.pool.fluidY = 0;
      BuoyancyForces.applyPostStepForces(
        mass: lab.block,
        pool: lab.world.pool,
        gravity: lab.world.gravity,
        fixedDt: BuoyancyPhysicsConstants.fixedTimeStep,
      );
      expect(lab.block.gravityForce.x, 0);
      expect(
        lab.block.gravityForce.y,
        closeTo(-lab.block.mass * lab.world.gravity.value, 1e-9),
      );
      expect(lab.block.buoyancyForce.x, 0);
      expect(
        lab.block.buoyancyForce.y,
        closeTo(
          lab.world.pool.fluidDensity *
              lab.block.submergedVolume *
              lab.world.gravity.value,
          1e-9,
        ),
      );
    });

    test('higher gravity increases |F_g|', () {
      final lab = BuoyancyLabModel()..pause();
      BuoyancyForces.applyPostStepForces(
        mass: lab.block,
        pool: lab.world.pool,
        gravity: BuoyancyGravity.earth,
        fixedDt: 1 / 120,
      );
      final earthG = lab.block.gravityForce.y.abs();
      BuoyancyForces.applyPostStepForces(
        mass: lab.block,
        pool: lab.world.pool,
        gravity: BuoyancyGravity.jupiter,
        fixedDt: 1 / 120,
      );
      expect(lab.block.gravityForce.y.abs(), greaterThan(earthG));
    });

    test('higher fluid density raises buoyancy when submerged', () {
      final lab = BuoyancyLabModel()..pause();
      lab.block.position = const BVec2(0, -0.25);
      lab.world.pool.fluidY = 0;
      lab.setFluidPreset(BuoyancyMaterial.water);
      BuoyancyForces.applyPostStepForces(
        mass: lab.block,
        pool: lab.world.pool,
        gravity: lab.world.gravity,
        fixedDt: 1 / 120,
      );
      final waterB = lab.block.buoyancyForce.y;
      lab.setFluidPreset(BuoyancyMaterial.honey);
      BuoyancyForces.applyPostStepForces(
        mass: lab.block,
        pool: lab.world.pool,
        gravity: lab.world.gravity,
        fixedDt: 1 / 120,
      );
      expect(lab.block.buoyancyForce.y, greaterThan(waterB));
    });

    test('aluminum sinks relative to wood after equal steps', () {
      final wood = BuoyancyExploreModel();
      final al = BuoyancyExploreModel();
      al.setBlockMaterial('explore.blockA', BuoyancyMaterial.aluminum);
      wood.blockA.position = const BVec2(-0.2, 0.05);
      al.blockA.position = const BVec2(-0.2, 0.05);
      for (var i = 0; i < 180; i++) {
        wood.step(1 / 60);
        al.step(1 / 60);
      }
      expect(al.blockA.position.y, lessThan(wood.blockA.position.y));
    });
  });

  group('PHASE 5 duck visual/physics separation', () {
    test('duck physics kind is duck but mesh ≠ ellipsoid vertex count', () {
      final shapes = BuoyancyShapesModel()..pause();
      shapes.setObjectShape('A', MassShapeKind.duck);
      expect(shapes.objectA.mass.geometry.kind, MassShapeKind.duck);
      final duckMesh = ProceduralMeshes.forGeometry(shapes.objectA.mass.geometry);
      final ell = ProceduralMeshes.ellipsoid(
        shapes.objectA.mass.geometry.width,
        shapes.objectA.mass.geometry.height,
        shapes.objectA.mass.geometry.depth,
      );
      expect(duckMesh.vertexCount, DuckSourceMesh.vertexCount);
      expect(duckMesh.vertexCount, isNot(ell.vertexCount));
    });

    test('composer uses duck mesh for duck shape', () {
      final shapes = BuoyancyShapesModel()..pause();
      shapes.setObjectShape('A', MassShapeKind.duck);
      final scene = ShapesComposer().compose(shapes);
      expect(scene.meshes.single.mesh.vertexCount, DuckSourceMesh.vertexCount);
    });
  });

  group('PHASE 5 boat / bottle / waterline', () {
    test('boat mesh bounds match ONE_LITER source', () {
      final b = ProceduralMeshes.boatOneLiter().bounds();
      // BoatSourceMesh positions (LOCAL 0c835c64 primary geometry).
      expect(b.minX, closeTo(-0.151321, 1e-5));
      expect(b.maxY, closeTo(0.0359648, 1e-5));
    });

    test('bottle mesh is elongated along x (not cylinder stub)', () {
      final b = ProceduralMeshes.bottleTenLiter().bounds();
      expect(b.maxX - b.minX, greaterThan(b.maxZ - b.minZ));
    });

    test('Applications waterline tracks pool.fluidY', () {
      final apps = BuoyancyApplicationsModel()..pause();
      final before = ApplicationsComposer().compose(apps).fluidY;
      apps.world.pool.fluidVolume *= 0.5;
      apps.world.pool.computeFluidY(
        apps.world.masses.where((m) => m.visible).toList(),
      );
      final after = ApplicationsComposer().compose(apps).fluidY;
      expect(after, isNot(before));
      expect(after, apps.world.pool.fluidY);
    });

    test('cabin coupling is RESOLVED', () {
      expect(ApplicationsComposer.cabinBasinCoupling, 'RESOLVED');
      final apps = BuoyancyApplicationsModel()..pause();
      apps.setApplicationMode(ApplicationMode.boat);
      expect(
        ApplicationsComposer().compose(apps).cabinCouplingDeferred,
        isFalse,
      );
    });
  });

  group('PHASE 5 textures', () {
    test('source material maps resolve without substitution ids', () {
      expect(
        BuoyancyTextureAsset.pathForMaterial(BuoyancyMaterial.wood),
        'assets/buoyancy/images/wood_col.jpg',
      );
      expect(
        BuoyancyTextureAsset.pathForMaterial(BuoyancyMaterial.brick),
        'assets/buoyancy/images/brick_col.jpg',
      );
      expect(
        BuoyancyTextureAsset.pathForMaterial(BuoyancyMaterial.styrofoam),
        'assets/buoyancy/images/foam_col.jpg',
      );
      expect(
        BuoyancyTextureAsset.pathForMaterial(BuoyancyMaterial.ice),
        'assets/buoyancy/images/ice_col.jpg',
      );
      expect(
        BuoyancyTextureAsset.pathForMaterial(BuoyancyMaterial.aluminum),
        'assets/buoyancy/images/metal_col.jpg',
      );
    });
  });

  group('PHASE 5 reset lifecycle', () {
    test('Explore reset restores material/mode/visibility', () {
      final m = BuoyancyExploreModel();
      m.setMode(TwoBlockMode.twoBlocks);
      m.setBlockMaterial('explore.blockA', BuoyancyMaterial.brick);
      m.startDrag('explore.blockA', const BVec2(-0.1, 0.1));
      m.endDrag('explore.blockA');
      m.reset();
      expect(m.mode.name, 'oneBlock');
      expect(m.blockA.material.id, 'wood');
      expect(m.blockB.visible, isFalse);
      expect(m.blockA.userControlled, isFalse);
      expect(m.world.gravity.value, 9.8);
    });

    test('Lab reset restores gravity fluid force flags', () {
      final m = BuoyancyLabModel();
      m.setSelectedGravityPreset(BuoyancyGravity.moon);
      m.setFluidPreset(BuoyancyMaterial.honey);
      m.setForceDisplay(gravity: false, buoyancy: false, values: false);
      m.reset();
      expect(m.world.gravity.value, 9.8);
      expect(m.world.pool.fluidMaterial.id, 'water');
      expect(m.gravityForceVisible, isTrue);
      expect(m.buoyancyForceVisible, isTrue);
      expect(m.forceValuesVisible, isTrue);
    });

    test('Compare reset restores sameMass defaults', () {
      final m = BuoyancyCompareModel();
      m.setSameMass(9);
      m.setComparisonMode(CompareBlockSet.sameDensity);
      m.reset();
      expect(m.comparisonMode, CompareBlockSet.sameMass);
      expect(m.sameMassValue, 4);
      expect(m.blockA.mass, closeTo(4, 1e-6));
    });

    test('Shapes reset restores block wood ratios', () {
      final m = BuoyancyShapesModel();
      m.setObjectShape('A', MassShapeKind.duck);
      m.setMaterial(BuoyancyMaterial.aluminum);
      m.setMode(TwoBlockMode.twoBlocks);
      m.reset();
      expect(m.objectA.shape, MassShapeKind.block);
      expect(m.material.id, 'wood');
      expect(m.objectB.mass.visible, isFalse);
    });

    test('Applications reset restores bottle mode', () {
      final m = BuoyancyApplicationsModel();
      m.setApplicationMode(ApplicationMode.boat);
      m.setBottleInteriorVolume(0.008);
      m.reset();
      expect(m.applicationMode, ApplicationMode.bottle);
      expect(m.bottleInteriorVolume, 0.004);
      expect(m.boatBasinFluidVolume, 0);
    });
  });

  group('PHASE 5 determinism', () {
    test('same Lab steps → same snapshot ×3', () {
      BuoyancyLabModel run() {
        final m = BuoyancyLabModel();
        m.block.position = const BVec2(-0.15, 0.1);
        for (var i = 0; i < 90; i++) {
          m.step(1 / 60);
        }
        return m;
      }

      final a = run().snapshot();
      final b = run().snapshot();
      final c = run().snapshot();
      expect(a, b);
      expect(b, c);
    });

    test('same Explore drag sequence → same end position ×3', () {
      BVec2 run() {
        final m = BuoyancyExploreModel();
        m.startDrag('explore.blockA', const BVec2(-0.15, 0.15));
        m.updateDrag('explore.blockA', const BVec2(-0.1, 0.1));
        m.endDrag('explore.blockA');
        for (var i = 0; i < 60; i++) {
          m.step(1 / 60);
        }
        return m.blockA.position;
      }

      final a = run();
      final b = run();
      final c = run();
      expect(a.x, closeTo(b.x, 1e-12));
      expect(a.y, closeTo(b.y, 1e-12));
      expect(b.x, closeTo(c.x, 1e-12));
      expect(b.y, closeTo(c.y, 1e-12));
    });
  });

  group('PHASE 5 cross-screen host lifecycle', () {
    testWidgets('switching screens preserves models, no contamination',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: BuoyancySimHost()),
      );
      await tester.pump();

      // Mutate Compare via mode radio
      await tester.tap(find.text('sameVolume'));
      await tester.pump();

      await tester.tap(find.text('explore'));
      await tester.pump();
      expect(find.text('one'), findsOneWidget);

      await tester.tap(find.text('lab'));
      await tester.pump();
      expect(find.text('earth'), findsOneWidget);

      await tester.tap(find.text('compare'));
      await tester.pump();
      // Compare model was preserved: still on sameVolume
      final radio = tester.widget<RadioListTile<CompareBlockSet>>(
        find.byWidgetPredicate(
          (w) =>
              w is RadioListTile<CompareBlockSet> &&
              w.value == CompareBlockSet.sameVolume,
        ),
      );
      expect(radio.groupValue, CompareBlockSet.sameVolume);
      expect(find.byType(KratosResetAllButton), findsOneWidget);
    });

    testWidgets('host dispose does not throw', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BuoyancySimHost()),
      );
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  });
}
