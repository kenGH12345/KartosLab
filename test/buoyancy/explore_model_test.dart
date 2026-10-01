import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/buoyancy/domain/material/buoyancy_material.dart';
import 'package:kratos/buoyancy/domain/world/vec2.dart';
import 'package:kratos/buoyancy/explore/model/buoyancy_explore_model.dart';
import 'package:kratos/buoyancy/shared/two_block_mode.dart';

void main() {
  group('ExploreModel', () {
    test('defaults: A wood 2kg visible, B aluminum 13.5kg hidden', () {
      final m = BuoyancyExploreModel();
      expect(m.mode, TwoBlockMode.oneBlock);
      expect(m.blockA.material.id, 'wood');
      expect(m.blockA.mass, closeTo(2, 1e-5));
      expect(m.blockA.visible, isTrue);
      expect(m.blockB.material.id, 'aluminum');
      expect(m.blockB.mass, closeTo(13.5, 1e-5));
      expect(m.blockB.visible, isFalse);
      expect(m.blockA.position, const BVec2(-0.2, 0.2));
      expect(m.blockB.position, const BVec2(0.05, 0.35));
    });

    test('show B adds to world visibility / fluid', () {
      final m = BuoyancyExploreModel()..setMode(TwoBlockMode.twoBlocks);
      expect(m.blockB.visible, isTrue);
      // 2 blocks + land/pool scales
      expect(
        m.world.masses
            .where((x) => x.visible && !x.id.startsWith('scale.'))
            .length,
        2,
      );
    });

    test('hide B removes from fluid computation', () {
      final m = BuoyancyExploreModel()
        ..setMode(TwoBlockMode.twoBlocks)
        ..setMode(TwoBlockMode.oneBlock);
      expect(m.blockB.visible, isFalse);
      expect(
        m.world.masses
            .where((x) => x.visible && !x.id.startsWith('scale.'))
            .length,
        1,
      );
    });

    test('material change keeps volume, updates mass', () {
      final m = BuoyancyExploreModel();
      final vol = m.blockA.volume;
      m.setBlockMaterial('explore.blockA', BuoyancyMaterial.aluminum);
      expect(m.blockA.volume, closeTo(vol, 1e-12));
      expect(m.blockA.mass, closeTo(vol * BuoyancyMaterial.aluminum.density, 1e-5));
    });

    test('set mass on named material resizes volume', () {
      final m = BuoyancyExploreModel()..setBlockMass('explore.blockA', 4);
      expect(m.blockA.mass, closeTo(4, 1e-5));
      expect(m.blockA.density, closeTo(BuoyancyMaterial.wood.density, 1e-6));
    });

    test('set volume on named material updates mass', () {
      final m = BuoyancyExploreModel()..setBlockVolume('explore.blockA', 0.01);
      expect(m.blockA.volume, closeTo(0.01, 1e-12));
      expect(m.blockA.mass, closeTo(0.01 * 400, 1e-5));
    });

    test('drag A', () {
      final m = BuoyancyExploreModel();
      m.startDrag('explore.blockA', const BVec2(-0.2, 0.3));
      m.updateDrag('explore.blockA', const BVec2(-0.1, 0.4));
      m.endDrag('explore.blockA');
      expect(m.blockA.userControlled, isFalse);
    });

    test('two objects share pool', () {
      final m = BuoyancyExploreModel()..setMode(TwoBlockMode.twoBlocks);
      m.step(1 / 60);
      expect(m.world.pool.fluidY.isFinite, isTrue);
      // A + B + land scale + pool scale
      expect(m.world.masses.length, 4);
      expect(m.landScale.visible, isTrue);
      expect(m.poolScale.visible, isTrue);
    });

    test('reset restores show/hide material mass volume position', () {
      final m = BuoyancyExploreModel()
        ..setMode(TwoBlockMode.twoBlocks)
        ..setBlockMaterial('explore.blockA', BuoyancyMaterial.brick)
        ..setBlockMass('explore.blockA', 5)
        ..setFluidMaterial(BuoyancyMaterial.honey);
      m.blockA.position = const BVec2(0, 1);
      m.reset();
      expect(m.mode, TwoBlockMode.oneBlock);
      expect(m.blockB.visible, isFalse);
      expect(m.blockA.material.id, 'wood');
      expect(m.blockA.mass, closeTo(2, 1e-5));
      expect(m.blockA.position, const BVec2(-0.2, 0.2));
      expect(m.world.pool.fluidMaterial.id, 'water');
    });

    test('pause stops physics advance', () {
      final m = BuoyancyExploreModel();
      final t0 = m.world.clock.simulationTime;
      m.pause();
      m.step(1);
      expect(m.world.clock.simulationTime, t0);
      m.resume();
      m.step(1 / 60);
      expect(m.world.clock.simulationTime, greaterThan(t0));
    });

    test('dispose stops stepping', () {
      final m = BuoyancyExploreModel()..dispose();
      final t0 = m.world.clock.simulationTime;
      m.step(1);
      expect(m.world.clock.simulationTime, t0);
    });

    test('determinism', () {
      ExploreModelSnapshot run() {
        final m = BuoyancyExploreModel()..setMode(TwoBlockMode.twoBlocks);
        for (var i = 0; i < 20; i++) {
          m.step(1 / 60);
        }
        return m.snapshot();
      }

      expect(run(), run());
    });
  });
}
