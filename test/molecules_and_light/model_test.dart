import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/molecules_and_light/model/micro_photon.dart';
import 'package:kratos/molecules_and_light/model/molecules_and_light_model.dart';
import 'package:kratos/molecules_and_light/molecules_and_light_constants.dart';

void main() {
  MoleculesAndLightModel modelFor(MoleculeType type) {
    final model = MoleculesAndLightModel(random: math.Random(1));
    model.setMolecule(type);
    for (final strategy in model.molecule.strategies.values) {
      strategy.absorptionProbability = 1;
    }
    return model;
  }

  void offer(MoleculesAndLightModel model, LightType light) {
    final photon = MicroPhoton(light.wavelength)..x = 0;
    model.photons.add(photon);
    model.manualStep(0.02);
  }

  test('defaults are infrared, off, carbon monoxide', () {
    final model = MoleculesAndLightModel();
    expect(model.light, LightType.infrared);
    expect(model.emitterOn, isFalse);
    expect(model.moleculeType, MoleculeType.carbonMonoxide);
    expect(model.running, isTrue);
    expect(model.photons, isEmpty);
  });

  test('emitter creates a rightward infrared photon', () {
    final model = modelFor(MoleculeType.carbonMonoxide);
    model.setEmitterOn(true);
    model.manualStep(0.02);
    expect(model.photons.single.wavelength, LightType.infrared.wavelength);
    expect(model.photons.single.vx, MoleculesAndLightConstants.photonVelocity);
  });

  test('pause freezes photons and vibration does not advance', () {
    final model = modelFor(MoleculeType.carbonMonoxide);
    offer(model, LightType.infrared);
    expect(model.molecule.vibrating, isTrue);
    model.setEmitterOn(true);
    model.manualStep(0.02);
    final x = model.photons.first.x;
    model.running = false;
    model.step(0.5);
    expect(model.photons.first.x, x);
    expect(model.molecule.vibrating, isTrue);
  });

  test('step forward advances a paused sim one step', () {
    final model = modelFor(MoleculeType.nitrogen);
    model.setEmitterOn(true);
    model.running = false;
    model.step(1);
    expect(model.photons, isEmpty);
    model.manualStep(0.02);
    expect(model.photons, isNotEmpty);
  });

  test('absorbed infrared identity survives a switch to visible', () {
    final model = modelFor(MoleculeType.carbonMonoxide);
    offer(model, LightType.infrared);
    expect(model.molecule.vibrating, isTrue);
    expect(model.photons, isEmpty);
    model.setLight(LightType.visible);
    model.manualStep(1.4);
    expect(model.molecule.vibrating, isFalse);
    expect(model.photons, isNotEmpty);
    expect(
      model.photons.any((p) => p.wavelength == LightType.infrared.wavelength),
      isTrue,
    );
    expect(
      model.photons.any((p) => p.wavelength == LightType.visible.wavelength),
      isFalse,
    );
  });

  test('reset restores defaults', () {
    final model = modelFor(MoleculeType.ozone);
    model.setLight(LightType.ultraviolet);
    model.setEmitterOn(true);
    model.running = false;
    model.timeSpeed = TimeSpeed.slow;
    model.reset();
    expect(model.moleculeType, MoleculeType.carbonMonoxide);
    expect(model.light, LightType.infrared);
    expect(model.emitterOn, isFalse);
    expect(model.running, isTrue);
    expect(model.timeSpeed, TimeSpeed.normal);
    expect(model.photons, isEmpty);
    expect(model.molecule.vibrating, isFalse);
  });

  test('8x4 matrix matches source strategies', () {
    const expected = {
      MoleculeType.carbonMonoxide: {
        LightType.microwave: 'rotation',
        LightType.infrared: 'vibration',
      },
      MoleculeType.nitrogen: {},
      MoleculeType.oxygen: {},
      MoleculeType.carbonDioxide: {LightType.infrared: 'vibration'},
      MoleculeType.methane: {LightType.infrared: 'vibration'},
      MoleculeType.water: {
        LightType.microwave: 'rotation',
        LightType.infrared: 'vibration',
      },
      MoleculeType.nitrogenDioxide: {
        LightType.microwave: 'rotation',
        LightType.infrared: 'vibration',
        LightType.visible: 'excitation',
        LightType.ultraviolet: 'break',
      },
      MoleculeType.ozone: {
        LightType.microwave: 'rotation',
        LightType.infrared: 'vibration',
        LightType.ultraviolet: 'break',
      },
    };

    for (final type in MoleculeType.values) {
      for (final light in LightType.values) {
        final model = modelFor(type);
        offer(model, light);
        final reaction = expected[type]![light];
        if (reaction == null) {
          expect(model.photons, isNotEmpty, reason: '$type $light should transmit');
          expect(model.molecule.vibrating, isFalse);
          expect(model.molecule.rotating, isFalse);
          expect(model.molecule.brokenApart, isFalse);
        } else if (reaction == 'vibration') {
          expect(model.molecule.vibrating, isTrue, reason: '$type $light');
          expect(model.photons, isEmpty);
        } else if (reaction == 'rotation') {
          expect(model.molecule.rotating, isTrue, reason: '$type $light');
        } else if (reaction == 'excitation') {
          expect(model.molecule.highElectronicEnergy, isTrue, reason: '$type $light');
        } else if (reaction == 'break') {
          expect(model.molecule.brokenApart, isTrue, reason: '$type $light');
          expect(model.photons, isEmpty);
        }
      }
    }
  });
}
