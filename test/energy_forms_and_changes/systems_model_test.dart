import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_forms_and_changes/common/model/energy_type.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/systems/model/systems_model.dart';

void main() {
  group('SystemsModel', () {
    test('default selection is biker + generator + beakerHeater', () {
      final m = SystemsModel();
      expect(m.sources.selected, EnergySourceId.biker);
      expect(m.converters.selected, EnergyConverterId.generator);
      expect(m.users.selected, EnergyUserId.beakerHeater);
      expect(m.beltVisible, isTrue);
    });

    test('biker + generator produces electrical energy when pedaling', () {
      final m = SystemsModel();
      m.bikerTargetCrankAngularVelocity = 3 * 3.141592653589793;
      m.stepModel(1 / 60);
      expect(m.lastFromSource!.type, EnergyType.mechanical);
      expect(m.lastFromSource!.amount, greaterThan(0));
      expect(m.lastFromConverter!.type, EnergyType.electrical);
      expect(m.lastFromConverter!.amount, closeTo(m.lastFromSource!.amount, 1e-9));
      expect(m.lastUserConsumed, closeTo(m.lastFromConverter!.amount, 1e-9));
    });

    test('biker + generator heats beaker toward boiling over time', () {
      final m = SystemsModel();
      m.bikerTargetCrankAngularVelocity = 3 * 3.141592653589793;
      final t0 = m.beakerHeaterBeaker.temperature;
      for (var i = 0; i < 600; i++) {
        m.stepModel(1 / 60);
      }
      expect(m.beakerHeaterBeaker.temperature, greaterThan(t0 + 20));
      expect(m.beakerHeaterHeatProportion, greaterThan(0.5));
    });

    test('biker energy depletes while pedaling', () {
      final m = SystemsModel();
      m.bikerTargetCrankAngularVelocity = 3 * 3.141592653589793;
      for (var i = 0; i < 1200; i++) {
        m.stepModel(1 / 60);
      }
      expect(m.bikerEnergyChunksRemaining, lessThan(21));
    });

    test('sun + generator yields zero electrical (type mismatch)', () {
      final m = SystemsModel();
      m.sources.selectId(EnergySourceId.sun);
      // Finish carousel animation
      while (m.sources.animationInProgress) {
        m.sources.step(0.1);
      }
      m.sunCloudinessProportion = 0;
      m.stepModel(1 / 60);
      expect(m.lastFromSource!.type, EnergyType.light);
      expect(m.lastFromConverter!.amount, 0);
    });

    test('sun + solarPanel yields electrical at 68% efficiency', () {
      final m = SystemsModel();
      m.sources.selectId(EnergySourceId.sun);
      m.converters.selectId(EnergyConverterId.solarPanel);
      while (m.sources.animationInProgress) {
        m.sources.step(0.1);
      }
      while (m.converters.animationInProgress) {
        m.converters.step(0.1);
      }
      m.sunCloudinessProportion = 0;
      m.stepModel(1 / 60);
      expect(m.lastFromConverter!.type, EnergyType.electrical);
      expect(
        m.lastFromConverter!.amount,
        closeTo(m.lastFromSource!.amount * 0.68, 1e-9),
      );
    });

    test('carousel CUBIC animation lasts 0.75s', () {
      final m = SystemsModel();
      m.sources.selectIndex(1);
      expect(m.sources.animationInProgress, isTrue);
      m.sources.step(0.3);
      expect(m.sources.animationInProgress, isTrue);
      expect(m.sources.elapsedTransitionTime, closeTo(0.3, 1e-9));
      m.sources.step(0.5);
      expect(m.sources.animationInProgress, isFalse);
      expect(EfacConstants.carouselTransitionDuration, 0.75);
    });

    test('reset returns carousels to index 0', () {
      final m = SystemsModel();
      m.sources.selectIndex(2);
      m.converters.selectIndex(1);
      m.users.selectIndex(3);
      m.faucetFlowProportion = 0.5;
      m.reset();
      expect(m.sources.targetIndex, 0);
      expect(m.converters.targetIndex, 0);
      expect(m.users.targetIndex, 0);
      expect(m.faucetFlowProportion, 0);
    });

    test('carousel still steps while paused', () {
      final m = SystemsModel();
      m.isPlaying = false;
      m.sources.selectIndex(1);
      expect(m.sources.animationInProgress, isTrue);
      m.step(0.5);
      expect(m.sources.elapsedTransitionTime, greaterThan(0));
      expect(m.lastFromSource, isNull);
    });

    test('path movers spawn when energy symbols on and energy flows', () {
      final m = SystemsModel();
      m.setEnergyChunksVisible(true);
      m.bikerTargetCrankAngularVelocity = 3 * 3.141592653589793;
      m.stepModel(1 / 60);
      expect(m.pathMovers, isNotEmpty);
    });
  });
}
