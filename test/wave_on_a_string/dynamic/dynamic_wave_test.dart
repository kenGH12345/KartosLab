import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_end_type.dart';
import 'package:kratos/wave_on_a_string/model/woas_mode.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';

/// Phase 4 — Manual / Oscillate / Pulse continuous simulation.
void main() {
  group('initial dynamic state', () {
    test('source defaults', () {
      final m = WoasModel();
      expect(m.waveMode, WoasMode.manual);
      expect(m.stringEndType, WoasEndType.fixedEnd);
      expect(m.amplitudeCm, closeTo(0.75, 1e-12));
      expect(m.frequencyHz, closeTo(1.50, 1e-12));
      expect(m.pulseWidthS, closeTo(0.5, 1e-12));
      expect(m.damping, closeTo(0.2, 1e-12));
      expect(m.tension, closeTo(0.8, 1e-12));
      expect(m.isPlaying, isTrue);
      expect(m.rulersVisible, isFalse);
      expect(m.referenceLineVisible, isFalse);
      expect(m.stopwatch.isVisible, isFalse);
      for (var i = 0; i < numberOfBeads; i++) {
        expect(m.yNowAt(i), 0);
        expect(m.yDrawAt(i), 0);
      }
    });
  });

  group('Manual dynamic', () {
    test('displace → step → propagation via y buffers', () {
      final m = WoasModel()
        ..setDamping(0)
        ..setTension(0.8);
      m.setManualDisplacement(40);
      for (var i = 0; i < 8; i++) {
        m.manualStep(frameDuration);
        m.nextLeftY = 40; // hold while interpolating (source drag)
      }
      expect(m.yNowAt(0), closeTo(40, 1e-6));
      // Interior should have received energy after several evolves.
      var interiorEnergy = 0.0;
      for (var i = 1; i < 20; i++) {
        interiorEnergy += m.yNowAt(i).abs();
      }
      expect(interiorEnergy, greaterThan(0));
    });

    test('release keeps displacement; wave continues (not forced to zero)', () {
      final m = WoasModel()..setDamping(0);
      m.setManualDisplacement(30);
      for (var i = 0; i < 5; i++) {
        m.manualStep(frameDuration);
        m.nextLeftY = 30;
      }
      // Release: nextLeftY stays at current (source keeps last displacement).
      final held = m.yNowAt(0);
      for (var i = 0; i < 40; i++) {
        m.manualStep(frameDuration);
        m.nextLeftY = held;
      }
      expect(m.yNowAt(0), closeTo(held, 1e-6));
      // Mid-string still dynamic.
      expect(m.yNowAt(15).abs() + m.yNowAt(25).abs(), greaterThan(0));
    });

    test('repeated Manual pulses leave history (overwrite left end, not new object)',
        () {
      final m = WoasModel()..setDamping(0);
      m.setManualDisplacement(40);
      for (var i = 0; i < 10; i++) {
        m.manualStep(frameDuration);
        m.nextLeftY = 40;
      }
      m.setManualDisplacement(-40);
      for (var i = 0; i < 10; i++) {
        m.manualStep(frameDuration);
        m.nextLeftY = -40;
      }
      expect(m.yNowAt(0), closeTo(-40, 1e-6));
      // Earlier positive crest still exists somewhere on string.
      var sawPositive = false;
      for (var i = 5; i < 40; i++) {
        if (m.yNowAt(i) > 1) sawPositive = true;
      }
      expect(sawPositive, isTrue);
    });

    test('amplitude does not drive Manual left end', () {
      final m = WoasModel()
        ..setAmplitudeCm(1.3)
        ..setManualDisplacement(0);
      for (var i = 0; i < 20; i++) {
        m.manualStep(frameDuration);
      }
      expect(m.yNowAt(0), closeTo(0, 1e-9));
    });
  });

  group('Oscillate dynamic', () {
    test('20+ frames produce periodic driver and propagation', () {
      final m = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setAmplitudeCm(0.75)
        ..setFrequencyHz(1.5)
        ..setDamping(0);

      final y0 = <double>[];
      for (var i = 0; i < 40; i++) {
        m.manualStep(frameDuration);
        y0.add(m.yNowAt(0));
      }
      expect(y0.any((v) => v.abs() > 1), isTrue);
      // Sign changes ⇒ oscillation.
      var signChanges = 0;
      for (var i = 1; i < y0.length; i++) {
        if (y0[i].sign != 0 && y0[i - 1].sign != 0 && y0[i].sign != y0[i - 1].sign) {
          signChanges++;
        }
      }
      expect(signChanges, greaterThan(0));

      var mid = 0.0;
      for (var i = 5; i < 30; i++) {
        mid += m.yNowAt(i).abs();
      }
      expect(mid, greaterThan(0));
    });

    test('frequency min / default / max change phase advance rate', () {
      // Compare unwrapped phase after few frames (avoid 2π wrap ambiguity).
      double unwrapped(double f, int frames) {
        return math.pi * 2 * f * frameDuration * frames;
      }

      expect(unwrapped(0, 10), 0);
      expect(unwrapped(1.5, 10), lessThan(unwrapped(3.0, 10)));

      final mLow = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setFrequencyHz(1.5);
      final mHigh = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setFrequencyHz(3.0);
      for (var i = 0; i < 10; i++) {
        mLow.manualStep(frameDuration);
        mHigh.manualStep(frameDuration);
      }
      expect(mLow.angle, closeTo(unwrapped(1.5, 10) % (math.pi * 2), 1e-12));
      expect(mHigh.angle, closeTo(unwrapped(3.0, 10) % (math.pi * 2), 1e-12));
      // Higher f advances farther before wrap in this short window.
      expect(mHigh.angle, greaterThan(mLow.angle));
    });

    test('amplitude 0 / 0.75 / 1.3 maps driver via A*80', () {
      double peakAbs(double amp) {
        final m = WoasModel()
          ..setWaveMode(WoasMode.oscillate)
          ..setAmplitudeCm(amp)
          ..setFrequencyHz(1.5)
          ..setDamping(0);
        var peak = 0.0;
        for (var i = 0; i < 50; i++) {
          m.manualStep(frameDuration);
          peak = math.max(peak, m.yNowAt(0).abs());
        }
        return peak;
      }

      expect(peakAbs(0), closeTo(0, 1e-12));
      expect(peakAbs(0.75), closeTo(0.75 * modelUnitsPerCm, 1e-6));
      expect(peakAbs(1.3), closeTo(1.3 * modelUnitsPerCm, 1e-6));
    });

    test('live amplitude / frequency change does not clear string', () {
      final m = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setDamping(0);
      for (var i = 0; i < 30; i++) {
        m.manualStep(frameDuration);
      }
      final midBefore = m.yNowAt(20);
      m.setAmplitudeCm(1.2);
      m.setFrequencyHz(2.5);
      expect(m.yNowAt(20), midBefore); // no restart
      m.manualStep(frameDuration);
      expect(m.amplitudeCm, 1.2);
      expect(m.frequencyHz, 2.5);
    });
  });

  group('Pulse dynamic', () {
    test('pulse starts, evolves, ends (not one-frame)', () {
      final m = WoasModel()
        ..setWaveMode(WoasMode.pulse)
        ..setAmplitudeCm(0.75)
        ..setPulseWidthS(0.5)
        ..setDamping(0);
      m.triggerPulse();
      expect(m.pulsePending, isTrue);

      final samples = <double>[];
      for (var i = 0; i < 80; i++) {
        m.manualStep(frameDuration);
        samples.add(m.yNowAt(0));
      }
      expect(samples.where((v) => v.abs() > 1).length, greaterThan(5));
      expect(m.isPulseActive, isFalse);
      expect(m.yNowAt(0), closeTo(0, 1e-9));
      // Propagation left residue on string.
      var energy = 0.0;
      for (var i = 1; i < numberOfBeads; i++) {
        energy += m.yNowAt(i).abs();
      }
      expect(energy, greaterThan(0));
    });

    test('pulse width 0.2 / 0.5 / 1.0 changes active duration', () {
      int activeFrames(double width) {
        final m = WoasModel()
          ..setWaveMode(WoasMode.pulse)
          ..setPulseWidthS(width)
          ..setAmplitudeCm(0.75);
        m.triggerPulse();
        var frames = 0;
        for (var i = 0; i < 200; i++) {
          m.manualStep(frameDuration);
          if (m.isPulseActive || m.yNowAt(0).abs() > 1e-9) frames++;
          if (!m.isPulseActive && !m.pulsePending && i > 2 && m.yNowAt(0).abs() < 1e-9) {
            break;
          }
        }
        return frames;
      }

      final f02 = activeFrames(0.2);
      final f05 = activeFrames(0.5);
      final f10 = activeFrames(1.0);
      expect(f02, lessThan(f05));
      expect(f05, lessThan(f10));
    });

    test('live pulse width change does not ResetAll', () {
      final m = WoasModel()
        ..setWaveMode(WoasMode.pulse)
        ..setAmplitudeCm(1.1);
      m.setPulseWidthS(0.9);
      expect(m.amplitudeCm, 1.1);
      expect(m.waveMode, WoasMode.pulse);
    });
  });

  group('Damping / Tension dynamic', () {
    test('damping 0 vs 1: energy decay differs (source β)', () {
      double residual(double damp) {
        final m = WoasModel()
          ..setDamping(damp)
          ..setTension(0.8)
          ..setStringEndType(WoasEndType.looseEnd);
        m.debugSeedBead(index: 30, yLast: 20, yNow: 20);
        for (var i = 0; i < 40; i++) {
          m.evolve();
        }
        return m.yNowAt(30).abs();
      }

      expect(residual(0), greaterThan(residual(1)));
    });

    test('tension minDt: higher tension → more evolves for same wall time', () {
      int evolvesViaManual(double tension) {
        final m = WoasModel()
          ..setDamping(0)
          ..setTension(tension);
        m.debugSeedBead(index: 30, yLast: 5, yNow: 5);
        final y0 = m.yNowAt(30);
        var flips = 0;
        var prev = y0;
        for (var i = 0; i < 50; i++) {
          m.manualStep(frameDuration);
          if ((m.yNowAt(30) - prev).abs() > 1e-9) {
            flips++;
            prev = m.yNowAt(30);
          }
        }
        return flips;
      }

      expect(evolvesViaManual(0.8), greaterThan(evolvesViaManual(0.2)));
      expect(minDtFor(tension: 0.8, speedMultiplier: 1),
          lessThan(minDtFor(tension: 0.2, speedMultiplier: 1)));
    });

    test('tension does not change alpha (always 1)', () {
      final m = WoasModel()..setTension(0.2);
      m.evolve();
      expect(m.alpha, 1);
      m.setTension(0.8);
      m.evolve();
      expect(m.alpha, 1);
    });
  });
}
