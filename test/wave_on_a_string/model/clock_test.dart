import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_mode.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/model/woas_time_speed.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';

void main() {
  group('pause / play', () {
    test('paused step does not advance wave or accumulate stepDt', () {
      final model = WoasModel()
        ..setDamping(0)
        ..setPlaying(false);
      model.debugSeedBead(index: 30, yLast: 10, yNow: 10);
      final before = model.yNowAt(30);
      model.step(frameDuration * 2);
      expect(model.yNowAt(30), before);
      expect(model.stepDt, 0);
    });

    test('playing step advances wave', () {
      final model = WoasModel()..setDamping(0);
      model.debugSeedBead(index: 30, yLast: 10, yNow: 10);
      // One evolve flips isolated bead 10 → -10; use manualStep to avoid soft-dt.
      model.manualStep(frameDuration);
      expect(model.yNowAt(30), closeTo(-10, 1e-12));
    });

    test('oscillator phase freezes while paused', () {
      final model = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setFrequencyHz(1.5);
      model.manualStep(frameDuration);
      final angle = model.angle;
      model.setPlaying(false);
      model.step(1.0);
      expect(model.angle, angle);
    });
  });

  group('slow motion', () {
    test('speedMultiplier is 0.25 and slows angle advance', () {
      expect(WoasTimeSpeed.normal.speedMultiplier, 1.0);
      expect(WoasTimeSpeed.slow.speedMultiplier, 0.25);

      final normal = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setFrequencyHz(1.0);
      final slow = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setFrequencyHz(1.0)
        ..setTimeSpeed(WoasTimeSpeed.slow);

      normal.manualStep(frameDuration);
      slow.manualStep(frameDuration);
      expect(slow.angle, closeTo(normal.angle * 0.25, 1e-12));
    });

    test('stopwatch advances with speedMultiplier when running', () {
      final model = WoasModel();
      model.stopwatch.isRunning = true;
      model.setTimeSpeed(WoasTimeSpeed.slow);
      model.manualStep(frameDuration);
      expect(model.stopwatch.time, closeTo(frameDuration * 0.25, 1e-12));
    });

    test('stopwatch does not advance when not running', () {
      final model = WoasModel();
      model.stopwatch.isRunning = false;
      model.manualStep(frameDuration);
      expect(model.stopwatch.time, 0);
    });
  });

  group('soft dt limiter', () {
    test('large jump from lastDt is limited to ±30%', () {
      final model = WoasModel();
      expect(model.lastDt, defaultLastDt);

      model.step(1.0);
      expect(model.lastDt, closeTo(0.03 * 1.3, 1e-12));
    });

    test('does not invent hard maxDT clamp at 0.1', () {
      final model = WoasModel();
      var target = defaultLastDt;
      for (var i = 0; i < 40; i++) {
        target = target * 1.3;
        model.step(target);
      }
      expect(model.lastDt, greaterThan(0.1));
    });
  });
}
