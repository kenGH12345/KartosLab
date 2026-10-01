import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/buoyancy/domain/material/buoyancy_gravity.dart';
import 'package:kratos/buoyancy/domain/material/buoyancy_material.dart';
import 'package:kratos/buoyancy/domain/world/vec2.dart';
import 'package:kratos/buoyancy/lab/model/buoyancy_lab_model.dart';

void main() {
  group('LabModel', () {
    test('defaults: wood 2kg, earth gravity, water', () {
      final m = BuoyancyLabModel();
      expect(m.block.material.id, 'wood');
      expect(m.block.mass, closeTo(2, 1e-5));
      expect(m.block.position, const BVec2(-0.2, 0.2));
      expect(m.world.gravity.value, 9.8);
      expect(m.world.pool.fluidMaterial.id, 'water');
    });

    test('gravity presets include moon earth jupiter planetX', () {
      expect(
        BuoyancyLabModel.gravityPresets.map((g) => g.value).toList(),
        [1.6, 9.8, 24.8, 19.6],
      );
    });

    test('setSelectedGravityPreset changes shared gravity', () {
      final m = BuoyancyLabModel()
        ..setSelectedGravityPreset(BuoyancyGravity.moon);
      expect(m.world.gravity.value, 1.6);
      m.setSelectedGravityPreset(BuoyancyGravity.jupiter);
      expect(m.world.gravity.value, 24.8);
    });

    test('custom gravity via BuoyancyGravity.customValue', () {
      final m = BuoyancyLabModel()
        ..setSelectedGravityPreset(BuoyancyGravity.customValue(12));
      expect(m.world.gravity.value, 12);
    });

    test('fluid preset changes density', () {
      final m = BuoyancyLabModel()
        ..setFluidPreset(BuoyancyMaterial.honey);
      expect(m.world.pool.fluidDensity, BuoyancyMaterial.honey.density);
    });

    test('fluid density slider clamps', () {
      final m = BuoyancyLabModel()..setFluidDensity(100);
      expect(m.world.pool.fluidDensity, 500);
      m.setFluidDensity(20000);
      expect(m.world.pool.fluidDensity, 15000);
    });

    test('force values available on mass; visibility flags in model', () {
      final m = BuoyancyLabModel();
      m.block.position = const BVec2(-0.2, -0.2);
      m.step(1 / 60);
      expect(m.block.gravityForce.y, isNot(0));
      expect(m.gravityForceVisible, isTrue);
      m.setForceDisplay(gravity: false, buoyancy: false, values: false);
      expect(m.gravityForceVisible, isFalse);
      expect(m.buoyancyForceVisible, isFalse);
    });

    test('fluidDisplacedVolumeLiters derives from submerged fraction', () {
      final m = BuoyancyLabModel();
      m.block.percentSubmerged = 50;
      expect(
        m.fluidDisplacedVolumeLiters,
        closeTo(0.5 * m.block.volume * 1000, 1e-6),
      );
    });

    test('block material / mass / volume controls', () {
      final m = BuoyancyLabModel()
        ..setBlockMaterial(BuoyancyMaterial.aluminum)
        ..setBlockMass(5);
      expect(m.block.material.id, 'aluminum');
      expect(m.block.mass, closeTo(5, 1e-4));
    });

    test('reset restores gravity fluid object force display', () {
      final m = BuoyancyLabModel()
        ..setSelectedGravityPreset(BuoyancyGravity.moon)
        ..setFluidPreset(BuoyancyMaterial.mercury)
        ..setForceDisplay(gravity: false)
        ..setBlockMass(8);
      m.reset();
      expect(m.world.gravity.value, 9.8);
      expect(m.world.pool.fluidMaterial.id, 'water');
      expect(m.gravityForceVisible, isTrue);
      expect(m.block.mass, closeTo(2, 1e-5));
    });

    test('determinism', () {
      LabModelSnapshot run() {
        final m = BuoyancyLabModel()
          ..setSelectedGravityPreset(BuoyancyGravity.moon);
        for (var i = 0; i < 25; i++) {
          m.step(1 / 60);
        }
        return m.snapshot();
      }

      expect(run(), run());
    });
  });
}
