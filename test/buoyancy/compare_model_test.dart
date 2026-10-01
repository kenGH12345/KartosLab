import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/buoyancy/compare/model/buoyancy_compare_model.dart';
import 'package:kratos/buoyancy/domain/material/buoyancy_material.dart';
import 'package:kratos/buoyancy/domain/world/vec2.dart';
import 'package:kratos/buoyancy/physics/submerged_volume.dart';
import 'package:kratos/buoyancy/shared/compare_block_set.dart';

void main() {
  group('CompareModel', () {
    test('defaults: sameMass 4kg, initial mode SAME_MASS', () {
      final m = BuoyancyCompareModel();
      expect(m.comparisonMode, CompareBlockSet.sameMass);
      expect(m.sameMassValue, 4);
      expect(m.sameVolumeValue, 0.005);
      expect(m.sameDensityValue, 400);
      expect(m.blockA.mass, closeTo(4, 1e-6));
      expect(m.blockB.mass, closeTo(4, 1e-6));
      expect(m.blockA.volume, closeTo(0.002, 1e-9));
      expect(m.blockB.volume, closeTo(0.01, 1e-9));
      expect(m.blockA.visible, isTrue);
      expect(m.blockB.visible, isTrue);
    });

    test('same mass mode is not same density', () {
      final m = BuoyancyCompareModel();
      expect(m.blockA.density, closeTo(2000, 1e-6));
      expect(m.blockB.density, closeTo(400, 1e-6));
      expect(m.blockA.density, isNot(closeTo(m.blockB.density, 1e-6)));
    });

    test('same volume mode locks volume, different mass', () {
      final m = BuoyancyCompareModel()
        ..setComparisonMode(CompareBlockSet.sameVolume);
      expect(m.blockA.volume, closeTo(0.005, 1e-9));
      expect(m.blockB.volume, closeTo(0.005, 1e-9));
      expect(m.blockA.mass, closeTo(10, 1e-6));
      expect(m.blockB.mass, closeTo(2, 1e-6));
    });

    test('same density mode locks density, different volume', () {
      final m = BuoyancyCompareModel()
        ..setComparisonMode(CompareBlockSet.sameDensity);
      expect(m.blockA.density, closeTo(400, 1e-6));
      expect(m.blockB.density, closeTo(400, 1e-6));
      expect(m.blockA.volume, closeTo(0.005, 1e-9));
      expect(m.blockB.volume, closeTo(0.01, 1e-9));
    });

    test('modify sameMass shared control updates both densities', () {
      final m = BuoyancyCompareModel()..setSameMass(8);
      expect(m.sameMassValue, 8);
      expect(m.blockA.mass, closeTo(8, 1e-5));
      expect(m.blockB.mass, closeTo(8, 1e-5));
      expect(m.blockA.density, closeTo(8 / 0.002, 1e-5));
      expect(m.blockB.density, closeTo(8 / 0.01, 1e-5));
    });

    test('modify sameVolume shared control keeps cube masses', () {
      final m = BuoyancyCompareModel()
        ..setComparisonMode(CompareBlockSet.sameVolume)
        ..setSameVolume(0.008);
      expect(m.blockA.volume, closeTo(0.008, 1e-9));
      expect(m.blockB.volume, closeTo(0.008, 1e-9));
      expect(m.blockA.mass, closeTo(10, 1e-4));
      expect(m.blockB.mass, closeTo(2, 1e-4));
    });

    test('modify sameDensity shared control', () {
      final m = BuoyancyCompareModel()
        ..setComparisonMode(CompareBlockSet.sameDensity)
        ..setSameDensity(800);
      expect(m.blockA.density, closeTo(800, 1e-6));
      expect(m.blockB.density, closeTo(800, 1e-6));
    });

    test('mode switch hides inactive block sets', () {
      final m = BuoyancyCompareModel();
      final sameMassA = m.blockSetToMasses[CompareBlockSet.sameMass]![0];
      m.setComparisonMode(CompareBlockSet.sameVolume);
      expect(sameMassA.visible, isFalse);
      expect(m.blockA.visible, isTrue);
      expect(m.blockA.id.contains('sameVolume'), isTrue);
    });

    test('reset restores defaults without new Model()', () {
      final m = BuoyancyCompareModel()
        ..setSameMass(9)
        ..setComparisonMode(CompareBlockSet.sameDensity)
        ..setSameDensity(1200)
        ..setFluidMaterial(BuoyancyMaterial.honey);
      m.reset();
      expect(m.comparisonMode, CompareBlockSet.sameMass);
      expect(m.sameMassValue, 4);
      expect(m.sameDensityValue, 400);
      expect(m.world.pool.fluidMaterial.id, 'water');
      expect(m.blockA.mass, closeTo(4, 1e-5));
    });

    test('drag A and B via shared world', () {
      final m = BuoyancyCompareModel();
      m.startDrag(m.blockA.id, const BVec2(-0.6, 0.3));
      m.updateDrag(m.blockA.id, const BVec2(-0.55, 0.35));
      m.endDrag(m.blockA.id);
      m.startDrag(m.blockB.id, const BVec2(0.6, 0.3));
      m.endDrag(m.blockB.id);
      expect(m.blockA.userControlled, isFalse);
      expect(m.blockB.userControlled, isFalse);
    });

    test('both blocks share one physics world / fluid', () {
      final m = BuoyancyCompareModel();
      expect(identical(m.world.massById(m.blockA.id)!.id, m.blockA.id), isTrue);
      expect(m.world.masses.where((x) => x.visible).length, 2);
      m.step(1 / 60);
      expect(m.world.pool.fluidY.isFinite, isTrue);
    });

    test('determinism: same steps → same snapshot', () {
      CompareModelSnapshot run() {
        final m = BuoyancyCompareModel();
        for (var i = 0; i < 30; i++) {
          m.step(1 / 60);
        }
        return m.snapshot();
      }

      expect(run(), run());
    });
  });

  group('Compare reference cases', () {
    test('Case A: fully above → V_sub = 0', () {
      final m = BuoyancyCompareModel();
      m.blockA.position = const BVec2(-0.6, 2);
      final v = SubmergedVolume.displacedVolume(
        geometry: m.blockA.geometry,
        centerY: m.blockA.position.y,
        fluidY: m.world.pool.fluidY,
      );
      expect(v, 0);
    });
  });
}
