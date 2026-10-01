
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_forms_and_changes/common/model/beaker.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/efac_intro_model.dart';
import 'package:kratos/energy_forms_and_changes/intro/model/thermal_block.dart';

void main() {
  group('EfacIntroModel', () {
    test('default elements: iron, brick, water, oliveOil + 2 burners', () {
      final m = EfacIntroModel();
      expect(m.energyChunksVisible, isFalse);
      expect(m.linkedHeaters, isFalse);
      expect(m.isPlaying, isTrue);
      expect(m.blocks, hasLength(2));
      expect(m.beakers, hasLength(2));
      expect(m.thermometers, hasLength(4));
      expect(m.blocks[0].blockType, BlockType.iron);
      expect(m.blocks[1].blockType, BlockType.brick);
      expect(m.beakers[0].beakerType, BeakerType.water);
      expect(m.beakers[1].beakerType, BeakerType.oliveOil);
      expect(m.groundSpotXPositions, hasLength(6));
      expect(m.blocks[0].temperature, closeTo(EfacConstants.roomTemperature, 1e-6));
    });

    test('ground spots use PhET rounded layout', () {
      final m = EfacIntroModel();
      // Burners at indices 2 and 3
      expect(m.leftBurner.position.dx, m.groundSpotXPositions[2]);
      expect(m.rightBurner.position.dx, m.groundSpotXPositions[3]);
      expect(m.beakers[0].position.dx, m.groundSpotXPositions[4]);
      expect(m.beakers[1].position.dx, m.groundSpotXPositions[5]);
    });

    test('heating a burner raises block temperature when placed on it', () {
      final m = EfacIntroModel();
      final brick = m.blocks[1];
      // Place on burner top; fall settles onto burner surface.
      brick.position =
          Offset(m.rightBurner.position.dx, m.rightBurner.bounds.maxY + 0.01);
      brick.userControlled = false;
      brick.supportingSurface = null;
      for (var i = 0; i < 30; i++) {
        m.stepModel(1 / 60);
      }
      expect(m.rightBurner.inContactWith(brick.bounds), isTrue);
      m.setHeatCoolLevel(m.rightBurner, 1);
      final t0 = brick.temperature;
      m.stepModel(1.0);
      expect(brick.temperature, greaterThan(t0));
    });

    test('snap-fall moves raised block toward ground', () {
      final m = EfacIntroModel();
      final iron = m.blocks[0];
      iron.position = Offset(iron.position.dx, 0.2);
      iron.supportingSurface = null;
      iron.userControlled = false;
      m.stepModel(0.05);
      expect(iron.position.dy, lessThan(0.2));
    });

    test('block falls onto beaker inner floor and immerses in fluid', () {
      // PhET: Beaker.topSurface is minY+MATERIAL_THICKNESS (not the rim).
      final m = EfacIntroModel();
      final iron = m.blocks[0];
      final water = m.beakers[0];
      iron.position = Offset(water.position.dx, water.position.dy + 0.15);
      iron.supportingSurface = null;
      iron.userControlled = false;
      for (var i = 0; i < 90; i++) {
        m.stepModel(1 / 60);
      }
      expect(
        iron.position.dy,
        closeTo(
          water.position.dy + EfacIntroBeaker.materialThickness,
          1e-4,
        ),
      );
      expect(water.thermalContactArea.intersects(iron.bounds), isTrue);
      expect(
        water.fluidProportion,
        greaterThan(EfacConstants.initialFluidProportion),
      );
    });

    test('beaker steaming increases near boiling', () {
      final m = EfacIntroModel();
      final water = m.beakers[0];
      // Force near boiling
      water.energy = water.mass *
          water.specificHeat *
          (EfacConstants.waterBoilingPointTemperature - 5);
      water.step(0);
      expect(water.steamingProportion, greaterThan(0));
    });

    test('reset restores heat levels and room temperature', () {
      final m = EfacIntroModel();
      m.setHeatCoolLevel(m.leftBurner, 0.5);
      m.setEnergyChunksVisible(true);
      m.setLinkedHeaters(true);
      m.setTimeSpeed(EfacTimeSpeed.fastForward);
      m.stepModel(2);
      m.reset();
      expect(m.leftBurner.heatCoolLevel, 0);
      expect(m.energyChunksVisible, isFalse);
      expect(m.linkedHeaters, isFalse);
      expect(m.timeSpeed, EfacTimeSpeed.normal);
      expect(m.blocks[0].temperature, closeTo(EfacConstants.roomTemperature, 0.5));
      expect(m.beakers[0].fluidProportion, EfacConstants.initialFluidProportion);
    });

    test('linked heaters sync levels', () {
      final m = EfacIntroModel();
      m.setLinkedHeaters(true);
      m.setHeatCoolLevel(m.leftBurner, -0.4);
      expect(m.rightBurner.heatCoolLevel, closeTo(-0.4, 1e-9));
    });
  });
}
