import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_end_type.dart';
import 'package:kratos/wave_on_a_string/model/woas_mode.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/model/woas_time_speed.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';

void main() {
  group('Restart vs ResetAll', () {
    test('Restart clears wave but preserves controls', () {
      final model = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setStringEndType(WoasEndType.looseEnd)
        ..setAmplitudeCm(1.1)
        ..setFrequencyHz(2.5)
        ..setDamping(0.7)
        ..setTension(0.4)
        ..setPulseWidthS(0.8)
        ..setTimeSpeed(WoasTimeSpeed.slow)
        ..setPlaying(false);
      model.rulersVisible = true;
      model.referenceLineVisible = true;
      model.stopwatch.isVisible = true;
      model.stopwatch.isRunning = false;
      model.stopwatch.time = 3.5;

      for (var i = 0; i < 20; i++) {
        model.manualStep(frameDuration);
      }
      expect(model.yNowAt(0), isNot(0));

      model.restart();

      for (var i = 0; i < numberOfBeads; i++) {
        expect(model.yNowAt(i), 0);
        expect(model.yLastAt(i), 0);
        expect(model.yDrawAt(i), 0);
      }
      expect(model.angle, 0);
      expect(model.isPulseActive, isFalse);

      // Controls preserved
      expect(model.waveMode, WoasMode.oscillate);
      expect(model.stringEndType, WoasEndType.looseEnd);
      expect(model.amplitudeCm, 1.1);
      expect(model.frequencyHz, 2.5);
      expect(model.damping, 0.7);
      expect(model.tension, 0.4);
      expect(model.pulseWidthS, 0.8);
      expect(model.timeSpeed, WoasTimeSpeed.slow);
      expect(model.isPlaying, isFalse);
      expect(model.rulersVisible, isTrue);
      expect(model.referenceLineVisible, isTrue);
      expect(model.stopwatch.isVisible, isTrue);
      expect(model.stopwatch.time, 3.5);
    });

    test('ResetAll restores source initial state', () {
      final model = WoasModel()
        ..setWaveMode(WoasMode.pulse)
        ..setStringEndType(WoasEndType.noEnd)
        ..setAmplitudeCm(1.2)
        ..setFrequencyHz(2.0)
        ..setDamping(0.9)
        ..setTension(0.3)
        ..setPulseWidthS(0.9)
        ..setTimeSpeed(WoasTimeSpeed.slow)
        ..setPlaying(false);
      model.rulersVisible = true;
      model.referenceLineVisible = true;
      model.stopwatch.isVisible = true;
      model.stopwatch.isRunning = true;
      model.stopwatch.time = 12;
      model.horizontalRulerX = 50;
      model.triggerPulse();
      for (var i = 0; i < 15; i++) {
        model.manualStep(frameDuration);
      }

      model.resetAll();

      expect(model.waveMode, WoasMode.manual);
      expect(model.stringEndType, WoasEndType.fixedEnd);
      expect(model.damping, closeTo(0.2, 1e-12));
      expect(model.tension, closeTo(0.8, 1e-12));
      expect(model.amplitudeCm, closeTo(0.75, 1e-12));
      expect(model.frequencyHz, closeTo(1.50, 1e-12));
      expect(model.pulseWidthS, closeTo(0.5, 1e-12));
      expect(model.isPlaying, isTrue);
      expect(model.timeSpeed, WoasTimeSpeed.normal);
      expect(model.rulersVisible, isFalse);
      expect(model.referenceLineVisible, isFalse);
      expect(model.stopwatch.isVisible, isFalse);
      expect(model.stopwatch.time, 0);
      expect(model.stopwatch.isRunning, isFalse);
      expect(model.wrenchArrowsVisible, isTrue);
      expect(model.horizontalRulerX, viewOriginX - 14);
      expect(model.lastDt, defaultLastDt);
      expect(model.isPulseActive, isFalse);
      for (var i = 0; i < numberOfBeads; i++) {
        expect(model.yNowAt(i), 0);
        expect(model.yDrawAt(i), 0);
      }
    });

    test('mode switch triggers Restart not ResetAll', () {
      final model = WoasModel()
        ..setAmplitudeCm(1.0)
        ..setDamping(0.5);
      model.debugSeedBead(index: 4, yNow: 9, yLast: 9);
      model.setWaveMode(WoasMode.oscillate);
      expect(model.yNowAt(4), 0);
      expect(model.amplitudeCm, 1.0);
      expect(model.damping, 0.5);
    });
  });
}
