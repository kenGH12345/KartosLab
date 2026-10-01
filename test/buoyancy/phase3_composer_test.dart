import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/buoyancy/applications/composer/applications_composer.dart';
import 'package:kratos/buoyancy/applications/model/buoyancy_applications_model.dart';
import 'package:kratos/buoyancy/compare/composer/compare_composer.dart';
import 'package:kratos/buoyancy/compare/model/buoyancy_compare_model.dart';
import 'package:kratos/buoyancy/domain/material/buoyancy_material.dart';
import 'package:kratos/buoyancy/explore/composer/explore_composer.dart';
import 'package:kratos/buoyancy/explore/model/buoyancy_explore_model.dart';
import 'package:kratos/buoyancy/lab/composer/lab_composer.dart';
import 'package:kratos/buoyancy/lab/model/buoyancy_lab_model.dart';
import 'package:kratos/buoyancy/layout/buoyancy_global_layout_spec.dart';
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
import 'package:kratos/buoyancy/shared/two_block_mode.dart';

BuoyancyThreeTransform mvtOf(BuoyancyCameraConfig cam, Size vp) {
  const g = BuoyancyGlobalLayoutSpec();
  return BuoyancyThreeTransform(camera: cam, frame: g.designFrame(vp));
}

void main() {
  const viewports = [
    Size(375, 667),
    Size(1024, 768),
    Size(1920, 1080),
  ];

  group('PHASE 3 camera / MVT', () {
    test('Compare lookAt and viewOffset are not default buoyancy', () {
      final c = BuoyancyCameraConfig.compare();
      final d = BuoyancyCameraConfig.buoyancyDefault();
      expect(c.lookAt.y, -0.1);
      expect(c.viewOffset, const Offset(-25, 0));
      expect(d.lookAt.y, -0.18);
      expect(d.viewOffset, Offset.zero);
      expect(c.up.z, -1);
      expect(c.zoom, buoyancyDefaultCameraZoom);
    });

    test('lookAt projects finite with Compare offset', () {
      final t = mvtOf(BuoyancyCameraConfig.compare(), const Size(1024, 618));
      final p = t.modelToView(const BVec3(0, -0.1, 0));
      expect(p.dx.isFinite, isTrue);
      expect(p.dy.isFinite, isTrue);
      expect(p.dx, lessThan(512));
      expect(p.dx, greaterThan(200));
    });

    test('projection is deterministic', () {
      final t = mvtOf(BuoyancyCameraConfig.compare(), const Size(1024, 618));
      final a = t.modelToView(const BVec3(0.1, 0, 0));
      final b = t.modelToView(const BVec3(0.1, 0, 0));
      expect(a, b);
    });

    test('ray-plane conversion is not a 2D scale multiply', () {
      final t =
          mvtOf(BuoyancyCameraConfig.buoyancyDefault(), const Size(1024, 618));
      final world = const BVec3(0.05, 0.1, 0);
      final view = t.modelToView(world);
      final ray = t.rayFromViewport(view);
      final hit = t.intersectZPlane(ray, 0)!;
      expect(hit.x, closeTo(world.x, 0.08));
      expect(hit.y, closeTo(world.y, 0.08));
    });
  });

  group('PHASE 3 meshes / textures', () {
    test('Duck mesh has source vertices', () {
      expect(DuckSourceMesh.vertexCount, greaterThan(100));
      expect(DuckSourceMesh.triangleCount, greaterThan(100));
    });

    test('Boat one-liter bounds match BoatDesign.ONE_LITER_BOUNDS', () {
      final m = ProceduralMeshes.boatOneLiter();
      final b = m.bounds();
      expect(b.minX, closeTo(-0.15132071936070812, 1e-6));
      expect(b.maxY, closeTo(0.03596482386676778, 1e-6));
      expect(m.vertexCount, greaterThan(100));
    });

    test('Bottle mesh is not a unit cylinder', () {
      final m = ProceduralMeshes.bottleTenLiter();
      final b = m.bounds();
      expect(m.vertexCount, greaterThan(50));
      expect(b.maxX - b.minX, greaterThan(b.maxZ - b.minZ));
    });

    test('material textures map to extracted assets', () {
      expect(BuoyancyTextureAsset.pathForMaterial(BuoyancyMaterial.wood),
          endsWith('wood_col.jpg'));
      expect(BuoyancyTextureAsset.pathForMaterial(BuoyancyMaterial.brick),
          endsWith('brick_col.jpg'));
      expect(BuoyancyTextureAsset.pathForMaterial(BuoyancyMaterial.styrofoam),
          endsWith('foam_col.jpg'));
      expect(BuoyancyTextureAsset.pathForMaterial(BuoyancyMaterial.ice),
          endsWith('ice_col.jpg'));
      expect(BuoyancyTextureAsset.pathForMaterial(BuoyancyMaterial.aluminum),
          endsWith('metal_col.jpg'));
    });
  });

  group('PHASE 3 composers', () {
    for (final vp in viewports) {
      test('Compare two visible cubes at $vp', () {
        final model = BuoyancyCompareModel();
        final composer = CompareComposer();
        final frame = composer.global.designFrame(vp);
        final scene = composer.compose(model);
        expect(scene.meshes.length, 2);
        expect(frame.contentBounds.width, greaterThan(0));
        final t = composer.transform(frame);
        final a = t.modelMetersToView(
          model.blockA.position.x,
          model.blockA.position.y,
        );
        final b = t.modelMetersToView(
          model.blockB.position.x,
          model.blockB.position.y,
        );
        expect(a.dx, lessThan(b.dx));
      });
    }

    test('Explore hides B instead of opacity 0', () {
      final model = BuoyancyExploreModel();
      final scene = ExploreComposer().compose(model);
      expect(scene.meshes.any((m) => m.id == 'explore.blockB'), isFalse);
      model.setMode(TwoBlockMode.twoBlocks);
      final two = ExploreComposer().compose(model);
      expect(two.meshes.any((m) => m.id == 'explore.blockB'), isTrue);
    });

    test('Lab force arrows hide |F|<0.05 N', () {
      final model = BuoyancyLabModel();
      model.block.gravityForce = model.block.gravityForce;
      final scene = LabComposer().compose(model);
      expect(scene.forceArrows, isNotNull);
    });

    test('Shapes catalog seven kinds project', () {
      final model = BuoyancyShapesModel();
      final composer = ShapesComposer();
      for (final kind in kShapesCatalog) {
        model.setObjectShape('A', kind);
        final scene = composer.compose(model);
        expect(scene.meshes, isNotEmpty);
        expect(model.objectA.shape, kind);
      }
    });

    test('Applications bottle vs boat meshes', () {
      final model = BuoyancyApplicationsModel();
      final composer = ApplicationsComposer();
      var scene = composer.compose(model);
      expect(scene.meshes.any((m) => m.id == 'applications.bottle'), isTrue);
      expect(scene.meshes.any((m) => m.id == 'applications.boat'), isFalse);
      model.setApplicationMode(ApplicationMode.boat);
      scene = composer.compose(model);
      expect(scene.meshes.any((m) => m.id == 'applications.boat'), isTrue);
      expect(scene.cabinCouplingDeferred, isFalse);
      expect(ApplicationsComposer.cabinBasinCoupling, 'RESOLVED');
    });

    test('pointer adapter drives Model.startDrag not view teleport', () {
      final model = BuoyancyExploreModel();
      final composer = ExploreComposer();
      final frame = composer.global.designFrame(const Size(1024, 618));
      final t = composer.transform(frame);
      final adapter = BuoyancyPointerAdapter(t);
      final before = model.blockA.position;
      final view = t.modelMetersToView(before.x, before.y);
      adapter.start(model, 'explore.blockA', view);
      expect(model.blockA.userControlled, isTrue);
      adapter.end(model, 'explore.blockA');
      expect(model.blockA.userControlled, isFalse);
    });
  });
}
