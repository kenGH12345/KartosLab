import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_mode.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';

void main() {
  group('Manual', () {
    test('setManualDisplacement writes nextLeftY and clamps', () {
      final model = WoasModel();
      model.setManualDisplacement(50);
      expect(model.nextLeftY, 50);

      final maxY = maxStartAmplitudeCm * modelUnitsPerCm;
      model.setManualDisplacement(9999);
      expect(model.nextLeftY, maxY);
      model.setManualDisplacement(-9999);
      expect(model.nextLeftY, -maxY);
    });

    test('manual drag forces playing and interpolates into yNow[0]', () {
      final model = WoasModel()..setPlaying(false);
      model.setManualDisplacement(40);
      expect(model.isPlaying, isTrue);

      model.manualStep(frameDuration);
      expect(model.yNowAt(0), closeTo(40, 1e-9));
    });

    test('amplitude does not drive Manual left end', () {
      final model = WoasModel()
        ..setAmplitudeCm(1.3)
        ..setManualDisplacement(0);
      model.manualStep(frameDuration);
      expect(model.yNowAt(0), closeTo(0, 1e-12));
    });

    test('manual displacement propagates via evolve', () {
      final model = WoasModel()..setDamping(0);
      model.setManualDisplacement(60);
      for (var i = 0; i < 20; i++) {
        model.manualStep(frameDuration);
        model.nextLeftY = 60;
      }
      expect(model.yNowAt(1).abs() + model.yNowAt(2).abs(), greaterThan(0));
    });
  });

  group('Oscillate', () {
    test('mode switch to oscillate clears string (manualRestart)', () {
      final model = WoasModel();
      model.debugSeedBead(index: 5, yNow: 3, yLast: 3, yDraw: 3);
      model.setWaveMode(WoasMode.oscillate);
      expect(model.yNowAt(5), 0);
      expect(model.angle, 0);
    });

    test('driver uses A_cm * 80 * sin(-angle)', () {
      final model = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setAmplitudeCm(0.75)
        ..setFrequencyHz(1.5);

      model.manualStep(frameDuration);
      final expectedAngle = (2 * math.pi * 1.5 * frameDuration) % (2 * math.pi);
      final expectedY = 0.75 * modelUnitsPerCm * math.sin(-expectedAngle);
      expect(model.angle, closeTo(expectedAngle, 1e-12));
      expect(model.yNowAt(0), closeTo(expectedY, 1e-12));
    });

    test('frequency 0 holds angle; amplitude 0 drives y0=0', () {
      final model = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setFrequencyHz(0)
        ..setAmplitudeCm(1.0);
      model.manualStep(frameDuration);
      expect(model.angle, 0);
      expect(model.yNowAt(0), 0);

      model.setFrequencyHz(1);
      model.setAmplitudeCm(0);
      model.manualStep(frameDuration);
      expect(model.yNowAt(0), 0);
    });

    test('changing amplitude does not clear existing wave', () {
      final model = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setFrequencyHz(2);
      for (var i = 0; i < 30; i++) {
        model.manualStep(frameDuration);
      }
      final mid = model.yNowAt(10);
      model.setAmplitudeCm(0.1);
      expect(model.yNowAt(10), mid);
    });
  });

  group('Pulse', () {
    test('triggerPulse arms pending triangular pulse', () {
      final model = WoasModel()..setWaveMode(WoasMode.pulse);
      model.triggerPulse();
      expect(model.pulsePending, isTrue);
      expect(model.isPulseActive, isFalse);

      model.manualStep(frameDuration);
      expect(model.pulsePending, isFalse);
      expect(model.isPulseActive, isTrue);
      final da = math.pi * frameDuration / 0.5;
      expect(model.angle, closeTo(da, 1e-12));
      final expectedY =
          0.75 * modelUnitsPerCm * (-model.angle / (math.pi / 2));
      expect(model.yNowAt(0), closeTo(expectedY, 1e-12));
    });

    test('pulse completes and returns left end toward zero', () {
      final model = WoasModel()
        ..setWaveMode(WoasMode.pulse)
        ..setPulseWidthS(0.2)
        ..setAmplitudeCm(1.0);
      model.triggerPulse();

      for (var i = 0; i < 40; i++) {
        model.manualStep(frameDuration);
      }
      expect(model.isPulseActive, isFalse);
      expect(model.angle, 0);
      expect(model.yNowAt(0), closeTo(0, 1e-9));
    });

    test('pulse is not a one-frame bump', () {
      final model = WoasModel()
        ..setWaveMode(WoasMode.pulse)
        ..setPulseWidthS(0.5);
      model.triggerPulse();
      model.manualStep(frameDuration);
      final y1 = model.yNowAt(0);
      model.manualStep(frameDuration);
      final y2 = model.yNowAt(0);
      expect(model.isPulseActive, isTrue);
      expect(y2.abs(), greaterThan(y1.abs()));
    });
  });
}
