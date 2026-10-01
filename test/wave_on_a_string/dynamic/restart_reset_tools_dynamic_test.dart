import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_end_type.dart';
import 'package:kratos/wave_on_a_string/model/woas_mode.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/model/woas_time_speed.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';

void main() {
  group('mode switching dynamic', () {
    test('Manual→Oscillate→Pulse→Manual: restart wave, keep params', () {
      final m = WoasModel()
        ..setAmplitudeCm(1.1)
        ..setDamping(0.4);
      m.setManualDisplacement(20);
      m.manualStep(frameDuration);

      m.setWaveMode(WoasMode.oscillate);
      expect(m.yNowAt(0), 0);
      expect(m.amplitudeCm, 1.1);
      expect(m.damping, 0.4);

      for (var i = 0; i < 5; i++) {
        m.manualStep(frameDuration);
      }
      expect(m.yNowAt(0), isNot(0));

      m.setWaveMode(WoasMode.pulse);
      expect(m.yNowAt(0), 0);
      expect(m.amplitudeCm, 1.1);

      m.setWaveMode(WoasMode.manual);
      expect(m.yNowAt(0), 0);
      expect(m.waveMode, WoasMode.manual);
      expect(m.damping, 0.4);
    });

    test('mode switch ≠ ResetAll', () {
      final m = WoasModel()
        ..setFrequencyHz(2.5)
        ..setTension(0.3)
        ..setStringEndType(WoasEndType.looseEnd)
        ..setTimeSpeed(WoasTimeSpeed.slow)
        ..setRulersVisible(true);
      m.setWaveMode(WoasMode.oscillate);
      expect(m.frequencyHz, 2.5);
      expect(m.tension, 0.3);
      expect(m.stringEndType, WoasEndType.looseEnd);
      expect(m.timeSpeed, WoasTimeSpeed.slow);
      expect(m.rulersVisible, isTrue);
    });
  });

  group('Restart vs ResetAll dynamic', () {
    test('Scenario A: Restart clears wave keeps controls', () {
      final m = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setStringEndType(WoasEndType.noEnd)
        ..setAmplitudeCm(1.2)
        ..setFrequencyHz(2.0)
        ..setPulseWidthS(0.8)
        ..setDamping(0.55)
        ..setTension(0.35)
        ..setTimeSpeed(WoasTimeSpeed.slow)
        ..setPlaying(false)
        ..setRulersVisible(true)
        ..setReferenceLineVisible(true)
        ..setStopwatchVisible(true);
      m.stopwatch.isRunning = true;
      for (var i = 0; i < 20; i++) {
        m.manualStep(frameDuration);
      }
      m.stopwatch.time; // may be >0 from prior steps while playing was true briefly
      // Force some stopwatch time via manualStep while running:
      m.setPlaying(true);
      m.manualStep(frameDuration);
      final swBefore = m.stopwatch.time;

      m.restart();

      for (var i = 0; i < numberOfBeads; i++) {
        expect(m.yNowAt(i), 0);
        expect(m.yDrawAt(i), 0);
      }
      expect(m.angle, 0);
      expect(m.isPulseActive, isFalse);
      expect(m.waveMode, WoasMode.oscillate);
      expect(m.stringEndType, WoasEndType.noEnd);
      expect(m.amplitudeCm, 1.2);
      expect(m.frequencyHz, 2.0);
      expect(m.pulseWidthS, 0.8);
      expect(m.damping, 0.55);
      expect(m.tension, 0.35);
      expect(m.timeSpeed, WoasTimeSpeed.slow);
      expect(m.isPlaying, isTrue); // was set true before restart
      expect(m.rulersVisible, isTrue);
      expect(m.referenceLineVisible, isTrue);
      expect(m.stopwatch.isVisible, isTrue);
      expect(m.stopwatch.time, swBefore); // restart does not reset stopwatch
    });

    test('Scenario B: Reset All restores all source defaults', () {
      final m = WoasModel()
        ..setWaveMode(WoasMode.pulse)
        ..setStringEndType(WoasEndType.looseEnd)
        ..setAmplitudeCm(1.2)
        ..setFrequencyHz(2.5)
        ..setPulseWidthS(0.9)
        ..setDamping(0.9)
        ..setTension(0.3)
        ..setTimeSpeed(WoasTimeSpeed.slow)
        ..setPlaying(false)
        ..setRulersVisible(true)
        ..setReferenceLineVisible(true)
        ..setStopwatchVisible(true)
        ..setReferenceLineY(200);
      m.stopwatch.isRunning = true;
      m.triggerPulse();
      for (var i = 0; i < 15; i++) {
        m.manualStep(frameDuration);
      }

      m.resetAll();

      expect(m.waveMode, WoasMode.manual);
      expect(m.stringEndType, WoasEndType.fixedEnd);
      expect(m.amplitudeCm, closeTo(0.75, 1e-12));
      expect(m.frequencyHz, closeTo(1.50, 1e-12));
      expect(m.pulseWidthS, closeTo(0.5, 1e-12));
      expect(m.damping, closeTo(0.2, 1e-12));
      expect(m.tension, closeTo(0.8, 1e-12));
      expect(m.isPlaying, isTrue);
      expect(m.timeSpeed, WoasTimeSpeed.normal);
      expect(m.rulersVisible, isFalse);
      expect(m.referenceLineVisible, isFalse);
      expect(m.stopwatch.isVisible, isFalse);
      expect(m.stopwatch.time, 0);
      expect(m.referenceLineY, 120);
      for (var i = 0; i < numberOfBeads; i++) {
        expect(m.yNowAt(i), 0);
      }
    });

    test('Restart ≠ ResetAll', () {
      final m = WoasModel()
        ..setAmplitudeCm(1.0)
        ..setDamping(0.7)
        ..setWaveMode(WoasMode.oscillate);
      for (var i = 0; i < 10; i++) {
        m.manualStep(frameDuration);
      }
      m.restart();
      expect(m.amplitudeCm, 1.0);
      expect(m.waveMode, WoasMode.oscillate);
      m.resetAll();
      expect(m.amplitudeCm, closeTo(0.75, 1e-12));
      expect(m.waveMode, WoasMode.manual);
    });

    test('Reset while paused restores isPlaying=true', () {
      final m = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setPlaying(false);
      for (var i = 0; i < 5; i++) {
        m.manualStep(frameDuration);
      }
      m.resetAll();
      expect(m.isPlaying, isTrue);
      expect(m.waveMode, WoasMode.manual);
    });

    test('Reset during active Oscillate then re-run clean', () {
      final m = WoasModel()..setWaveMode(WoasMode.oscillate);
      for (var i = 0; i < 30; i++) {
        m.manualStep(frameDuration);
      }
      m.resetAll();
      expect(m.angle, 0);
      m.setWaveMode(WoasMode.oscillate);
      m.manualStep(frameDuration);
      expect(m.angle, greaterThan(0));
    });
  });

  group('tools dynamic', () {
    test('tools toggle does not reset wave', () {
      final m = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setDamping(0);
      for (var i = 0; i < 20; i++) {
        m.manualStep(frameDuration);
      }
      final mid = m.yNowAt(15);
      final angle = m.angle;
      m.setRulersVisible(true);
      m.setStopwatchVisible(true);
      m.setReferenceLineVisible(true);
      expect(m.yNowAt(15), mid);
      expect(m.angle, angle);
      m.setRulersVisible(false);
      m.setStopwatchVisible(false);
      m.setReferenceLineVisible(false);
      expect(m.yNowAt(15), mid);
    });

    test('stopwatch uses simulation time via manualStep speedMultiplier', () {
      final m = WoasModel();
      m.stopwatch.isRunning = true;
      m.setTimeSpeed(WoasTimeSpeed.slow);
      m.manualStep(frameDuration);
      expect(m.stopwatch.time, closeTo(frameDuration * 0.25, 1e-12));
      m.setPlaying(false);
      // paused step does not call manualStep — stopwatch frozen
      final t = m.stopwatch.time;
      m.step(1.0);
      expect(m.stopwatch.time, t);
    });

    test('reference line move does not alter wave buffers', () {
      final m = WoasModel();
      m.debugSeedBead(index: 10, yNow: 3, yLast: 3);
      m.setReferenceLineVisible(true);
      m.setReferenceLineY(180);
      expect(m.yNowAt(10), 3);
      expect(m.referenceLineY, 180);
    });
  });
}
