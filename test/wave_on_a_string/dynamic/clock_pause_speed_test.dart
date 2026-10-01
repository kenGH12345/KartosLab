import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_mode.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/model/woas_time_speed.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';

void main() {
  group('Pause / Play / Step', () {
    test('Pause freezes wave, angle, stopwatch', () {
      final m = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setFrequencyHz(1.5);
      m.stopwatch.isRunning = true;
      for (var i = 0; i < 10; i++) {
        m.manualStep(frameDuration);
      }
      final angle = m.angle;
      final yMid = m.yNowAt(10);
      final sw = m.stopwatch.time;

      m.setPlaying(false);
      m.step(1.0);
      m.step(1.0);
      expect(m.angle, angle);
      expect(m.yNowAt(10), yMid);
      expect(m.stopwatch.time, sw);
    });

    test('Step while paused advances one deterministic chunk', () {
      final m = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setPlaying(false)
        ..setFrequencyHz(1.0);
      final a0 = m.angle;
      m.manualStep(); // one FRAME_DURATION default
      final a1 = m.angle;
      expect(a1, isNot(a0));
      m.manualStep();
      final a2 = m.angle;
      expect(a2, isNot(a1));
      // Deterministic: same start → same step size.
      final m2 = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setPlaying(false)
        ..setFrequencyHz(1.0);
      m2.manualStep();
      expect(m2.angle, closeTo(a1, 1e-12));
    });

    test('Play resumes with phase continuity', () {
      final m = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setFrequencyHz(1.5);
      for (var i = 0; i < 8; i++) {
        m.manualStep(frameDuration);
      }
      m.setPlaying(false);
      final pausedAngle = m.angle;
      m.setPlaying(true);
      m.manualStep(frameDuration);
      expect(m.angle, isNot(pausedAngle));
      // Continuous advance (not reset to 0).
      expect(m.angle, greaterThan(0));
    });

    test('parameter change while paused applies after Play', () {
      final m = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setAmplitudeCm(0.5)
        ..setPlaying(false);
      m.setAmplitudeCm(1.2);
      m.setFrequencyHz(2.0);
      expect(m.yNowAt(5), 0); // frozen empty string
      m.setPlaying(true);
      m.manualStep(frameDuration);
      expect(m.amplitudeCm, 1.2);
      expect(m.frequencyHz, 2.0);
      expect(m.yNowAt(0).abs(), greaterThan(0));
    });

    test('Manual drag while paused forces playing (source wrench)', () {
      final m = WoasModel()..setPlaying(false);
      m.setManualDisplacement(20);
      expect(m.isPlaying, isTrue);
    });
  });

  group('Slow / Normal', () {
    test('same FRAME count: Slow angle = 0.25 × Normal', () {
      final n = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setFrequencyHz(1.0);
      final s = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setFrequencyHz(1.0)
        ..setTimeSpeed(WoasTimeSpeed.slow);
      for (var i = 0; i < 20; i++) {
        n.manualStep(frameDuration);
        s.manualStep(frameDuration);
      }
      expect(s.angle, closeTo(n.angle * 0.25, 1e-12));
    });

    test('Slow → Pause → Step → Play → Normal ordering', () {
      final m = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setFrequencyHz(1.0)
        ..setTimeSpeed(WoasTimeSpeed.slow);
      m.manualStep(frameDuration);
      m.setPlaying(false);
      final a1 = m.angle;
      m.manualStep(frameDuration);
      expect(m.angle, isNot(a1));
      m.setPlaying(true);
      m.setTimeSpeed(WoasTimeSpeed.normal);
      final a2 = m.angle;
      m.manualStep(frameDuration);
      final expectedDelta =
          math.pi * 2 * 1.0 * frameDuration * WoasTimeSpeed.normal.speedMultiplier;
      expect(m.angle, closeTo((a2 + expectedDelta) % (math.pi * 2), 1e-9));
    });
  });
}
