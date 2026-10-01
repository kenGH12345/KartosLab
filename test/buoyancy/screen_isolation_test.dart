import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/buoyancy/applications/model/buoyancy_applications_model.dart';
import 'package:kratos/buoyancy/compare/model/buoyancy_compare_model.dart';
import 'package:kratos/buoyancy/domain/material/buoyancy_gravity.dart';
import 'package:kratos/buoyancy/domain/material/buoyancy_material.dart';
import 'package:kratos/buoyancy/domain/shape/shape_geometry.dart';
import 'package:kratos/buoyancy/domain/world/vec2.dart';
import 'package:kratos/buoyancy/explore/model/buoyancy_explore_model.dart';
import 'package:kratos/buoyancy/lab/model/buoyancy_lab_model.dart';
import 'package:kratos/buoyancy/physics/submerged_volume.dart';
import 'package:kratos/buoyancy/shapes/model/buoyancy_shapes_model.dart';
import 'package:kratos/buoyancy/shared/application_mode.dart';
import 'package:kratos/buoyancy/shared/compare_block_set.dart';
import 'package:kratos/buoyancy/shared/two_block_mode.dart';

void main() {
  group('Cross-screen isolation', () {
    test('mutating each screen does not contaminate others', () {
      final compare = BuoyancyCompareModel();
      final explore = BuoyancyExploreModel();
      final lab = BuoyancyLabModel();
      final shapes = BuoyancyShapesModel();
      final apps = BuoyancyApplicationsModel();

      // Worlds are distinct instances
      expect(identical(compare.world, explore.world), isFalse);
      expect(identical(lab.world, shapes.world), isFalse);
      expect(identical(apps.world, compare.world), isFalse);

      compare.setSameMass(9);
      compare.setComparisonMode(CompareBlockSet.sameDensity);
      explore.setMode(TwoBlockMode.twoBlocks);
      explore.setBlockMaterial('explore.blockA', BuoyancyMaterial.brick);
      lab.setSelectedGravityPreset(BuoyancyGravity.moon);
      lab.setFluidPreset(BuoyancyMaterial.honey);
      shapes.setObjectShape('A', MassShapeKind.duck);
      shapes.setMaterial(BuoyancyMaterial.aluminum);
      apps.setApplicationMode(ApplicationMode.boat);

      // Compare mutations must not touch Explore fluid / gravity
      expect(explore.world.pool.fluidMaterial.id, 'water');
      expect(explore.world.gravity.value, 9.8);
      expect(explore.mode, TwoBlockMode.twoBlocks);
      expect(explore.blockA.material.id, 'brick');

      // Explore must not change Lab gravity (lab set moon itself)
      expect(lab.world.gravity.value, 1.6);
      expect(compare.world.gravity.value, 9.8);

      // Lab honey must not change Explore / Compare / Shapes fluid
      expect(compare.world.pool.fluidMaterial.id, 'water');
      expect(shapes.world.pool.fluidMaterial.id, 'water');
      expect(lab.world.pool.fluidMaterial.id, 'honey');

      // Shapes duck must not change Compare blocks mode
      expect(compare.comparisonMode, CompareBlockSet.sameDensity);
      expect(shapes.objectA.shape, MassShapeKind.duck);
      expect(shapes.material.id, 'aluminum');

      // Apps boat must not change other screen modes
      expect(apps.applicationMode, ApplicationMode.boat);
      expect(explore.mode, TwoBlockMode.twoBlocks);
      expect(shapes.mode, TwoBlockMode.oneBlock);
    });
  });

  group('Numerical reference cases (shared)', () {
    test('Case A above → V_sub=0 F_b path', () {
      final lab = BuoyancyLabModel();
      lab.block.position = lab.block.position.copyWithY(3);
      final v = SubmergedVolume.displacedVolume(
        geometry: lab.block.geometry,
        centerY: lab.block.position.y,
        fluidY: lab.world.pool.fluidY,
      );
      expect(v, 0);
    });

    test('Case B fully submerged', () {
      final lab = BuoyancyLabModel();
      lab.block.position = lab.block.position.copyWithY(-1);
      lab.world.pool.fluidY = 0;
      final v = SubmergedVolume.displacedVolume(
        geometry: lab.block.geometry,
        centerY: lab.block.position.y,
        fluidY: 0,
      );
      expect(v, closeTo(lab.block.volume, 1e-12));
    });

    test('Case C partial', () {
      final lab = BuoyancyLabModel();
      lab.world.pool.fluidY = 0;
      lab.block.position = lab.block.position.copyWithY(0);
      final v = SubmergedVolume.displacedVolume(
        geometry: lab.block.geometry,
        centerY: 0,
        fluidY: 0,
      );
      expect(v, greaterThan(0));
      expect(v, lessThan(lab.block.volume));
    });

    test('Case D neutral buoyancy wood in water at equilibrium region', () {
      // wood density 400 < water 1000 → floats (not neutral). Neutral uses custom.
      final lab = BuoyancyLabModel()
        ..setBlockMaterial(BuoyancyMaterial.customSolid(1000));
      expect(lab.block.density, closeTo(lab.world.pool.fluidDensity, 1e-9));
    });

    test('Case E heavy settles — aluminum sinks after steps', () {
      final explore = BuoyancyExploreModel();
      explore.setBlockMaterial('explore.blockA', BuoyancyMaterial.aluminum);
      explore.blockA.position = const BVec2(-0.2, 0.05);
      for (var i = 0; i < 120; i++) {
        explore.step(1 / 60);
      }
      expect(explore.blockA.position.y, lessThan(0.05));
    });
  });
}

extension on BVec2 {
  BVec2 copyWithY(double y) => BVec2(x, y);
}
