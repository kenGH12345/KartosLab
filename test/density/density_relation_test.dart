import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/density/density_constants.dart';
import 'package:kratos/density/model/density_block.dart';
import 'package:kratos/density/model/density_material.dart';
import 'package:kratos/density/model/intro_state.dart';
import 'package:kratos/density/solver/density_relation.dart';

void main() {
  group('DensityRelation ρ = m / V', () {
    test('wood 2 kg at default intro volume is 0.005 m³ and 400 kg/m³', () {
      final block = DensityRelation.createWithMass(
        id: 'a',
        tag: 'A',
        materialId: DensityMaterialId.wood,
        mass: 2,
      );
      expect(block.volume, closeTo(0.005, 1e-12));
      expect(DensityRelation.densityOf(block), 400);
      expect(DensityRelation.massOf(block), closeTo(2, DensityConstants.tolerance));
    });

    test('aluminum intro B is 13.5 kg at 0.005 m³', () {
      final block = DensityRelation.createWithMass(
        id: 'b',
        tag: 'B',
        materialId: DensityMaterialId.aluminum,
        mass: 13.5,
      );
      expect(block.volume, closeTo(0.005, 1e-12));
      expect(DensityRelation.massOf(block), closeTo(13.5, 1e-9));
    });

    test('rejects zero volume', () {
      expect(
        () => DensityRelation.massOf(
          const DensityBlock(
            id: 'z',
            tag: 'Z',
            materialId: DensityMaterialId.wood,
            volume: 0,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('rejects negative volume', () {
      expect(
        () => DensityRelation.setVolume(
          DensityRelation.createWithMass(
            id: 'a',
            tag: 'A',
            materialId: DensityMaterialId.wood,
            mass: 2,
          ),
          -0.001,
        ),
        throwsArgumentError,
      );
    });

    test('rejects zero and negative mass', () {
      final block = DensityRelation.createWithMass(
        id: 'a',
        tag: 'A',
        materialId: DensityMaterialId.wood,
        mass: 2,
      );
      expect(() => DensityRelation.setMass(block, 0), throwsArgumentError);
      expect(() => DensityRelation.setMass(block, -1), throwsArgumentError);
    });

    test('clamps volume below min and above max', () {
      final block = DensityRelation.createWithMass(
        id: 'a',
        tag: 'A',
        materialId: DensityMaterialId.wood,
        mass: 2,
      );
      final tiny = DensityRelation.setVolume(block, 1e-9);
      expect(tiny.volume, DensityConstants.minVolume);
      final huge = DensityRelation.setVolume(block, 1);
      expect(huge.volume, DensityConstants.maxVolume);
    });
  });

  group('named material linkage', () {
    test('changing mass changes volume, density stays', () {
      final start = DensityRelation.createWithMass(
        id: 'a',
        tag: 'A',
        materialId: DensityMaterialId.wood,
        mass: 2,
      );
      final next = DensityRelation.setMass(start, 4);
      expect(DensityRelation.densityOf(next), 400);
      expect(next.volume, closeTo(0.01, 1e-12));
      expect(DensityRelation.massOf(next), closeTo(4, 1e-9));
    });

    test('changing volume changes mass, density stays', () {
      final start = DensityRelation.createWithMass(
        id: 'a',
        tag: 'A',
        materialId: DensityMaterialId.wood,
        mass: 2,
      );
      final next = DensityRelation.setVolume(start, 0.001);
      expect(DensityRelation.densityOf(next), 400);
      expect(DensityRelation.massOf(next), closeTo(0.4, 1e-9));
    });

    test('selecting aluminum keeps volume and recomputes mass', () {
      final start = DensityRelation.createWithMass(
        id: 'a',
        tag: 'A',
        materialId: DensityMaterialId.wood,
        mass: 2,
      );
      final next = DensityRelation.setMaterial(start, DensityMaterialId.aluminum);
      expect(next.volume, start.volume);
      expect(DensityRelation.densityOf(next), 2700);
      expect(DensityRelation.massOf(next), closeTo(13.5, 1e-9));
    });
  });

  group('custom material', () {
    test('changing mass changes density, volume stays', () {
      final start = DensityRelation.createWithVolume(
        id: 'c',
        tag: 'C',
        materialId: DensityMaterialId.custom,
        volume: 0.005,
        customDensity: 400,
      );
      final next = DensityRelation.setMass(start, 8);
      expect(next.volume, 0.005);
      expect(DensityRelation.densityOf(next), closeTo(1600, 1e-9));
    });

    test('changing volume keeps mass and updates density', () {
      final start = DensityRelation.createWithVolume(
        id: 'c',
        tag: 'C',
        materialId: DensityMaterialId.custom,
        volume: 0.005,
        customDensity: 400,
      );
      final next = DensityRelation.setVolume(start, 0.01);
      expect(DensityRelation.massOf(next), closeTo(2, 1e-6));
      expect(DensityRelation.densityOf(next), closeTo(200, 1e-6));
    });

    test('switching to custom copies previous density', () {
      final wood = DensityRelation.createWithMass(
        id: 'a',
        tag: 'A',
        materialId: DensityMaterialId.wood,
        mass: 2,
      );
      final custom = DensityRelation.setMaterial(wood, DensityMaterialId.custom);
      expect(custom.isCustom, isTrue);
      expect(DensityRelation.densityOf(custom), 400);
      expect(custom.volume, wood.volume);
    });
  });

  group('Intro defaults and materials', () {
    test('IntroState A/B match source createWithMass', () {
      final intro = IntroState.initial();
      expect(intro.mode, TwoBlockMode.oneBlock);
      expect(intro.blockA.materialId, DensityMaterialId.wood);
      expect(intro.blockB.materialId, DensityMaterialId.aluminum);
      expect(intro.blockB.visible, isFalse);
      expect(DensityRelation.massOf(intro.blockA), closeTo(2, 1e-9));
      expect(DensityRelation.massOf(intro.blockB), closeTo(13.5, 1e-9));
    });

    test('Two Blocks only reveals B', () {
      final two = IntroState.initial().withMode(TwoBlockMode.twoBlocks);
      expect(two.blockB.visible, isTrue);
      expect(two.blockA.visible, isTrue);
    });

    test('SIMPLE_MASS_MATERIALS densities match Material.ts', () {
      expect(DensityMaterials.styrofoam.density, 150);
      expect(DensityMaterials.wood.density, 400);
      expect(DensityMaterials.ice.density, 919);
      expect(DensityMaterials.pvc.density, 1440);
      expect(DensityMaterials.brick.density, 2000);
      expect(DensityMaterials.aluminum.density, 2700);
      expect(DensityMaterials.simpleMassMaterials, hasLength(6));
    });

    test('cube side is volume^(1/3)', () {
      expect(
        DensityRelation.cubeSideLength(0.008),
        closeTo(0.2, 1e-12),
      );
    });
  });
}
