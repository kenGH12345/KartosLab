import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_end_type.dart';
import 'package:kratos/wave_on_a_string/model/woas_mode.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';

/// Phase 4 numeric fixtures F–G (plus lock that Phase 1 A–E suite still present).
void main() {
  group('dynamic fixture F · Manual disturbance propagation', () {
    test('y0 / yMid / yEnd sequence after fixed steps', () {
      final m = WoasModel()
        ..setDamping(0)
        ..setTension(0.8)
        ..setStringEndType(WoasEndType.fixedEnd);

      m.setManualDisplacement(40);
      for (var i = 0; i < 5; i++) {
        m.manualStep(frameDuration);
        m.nextLeftY = 40;
      }
      m.setManualDisplacement(0);
      for (var i = 0; i < 5; i++) {
        m.manualStep(frameDuration);
        m.nextLeftY = 0;
      }

      // Record after additional evolves.
      final frames = <Map<String, double>>[];
      for (var t = 0; t < 30; t++) {
        m.manualStep(frameDuration);
        m.nextLeftY = 0;
        if (t % 10 == 9) {
          frames.add({
            'y0': m.yNowAt(0),
            'yMid': m.yNowAt(30),
            'yEnd': m.yNowAt(lastIndex),
          });
        }
      }

      expect(frames.length, 3);
      expect(frames[0]['yEnd'], 0); // Fixed
      expect(frames[2]['yEnd'], 0);
      // Mid should have become nonzero at some recorded frame.
      final midEnergy =
          frames.map((f) => f['yMid']!.abs()).fold<double>(0, math.max);
      expect(midEnergy, greaterThan(0));

      // Golden: re-run identical → same snapshots.
      final m2 = WoasModel()
        ..setDamping(0)
        ..setTension(0.8);
      m2.setManualDisplacement(40);
      for (var i = 0; i < 5; i++) {
        m2.manualStep(frameDuration);
        m2.nextLeftY = 40;
      }
      m2.setManualDisplacement(0);
      for (var i = 0; i < 5; i++) {
        m2.manualStep(frameDuration);
        m2.nextLeftY = 0;
      }
      final frames2 = <Map<String, double>>[];
      for (var t = 0; t < 30; t++) {
        m2.manualStep(frameDuration);
        m2.nextLeftY = 0;
        if (t % 10 == 9) {
          frames2.add({
            'y0': m2.yNowAt(0),
            'yMid': m2.yNowAt(30),
            'yEnd': m2.yNowAt(lastIndex),
          });
        }
      }
      for (var k = 0; k < 3; k++) {
        expect(frames2[k]['y0'], closeTo(frames[k]['y0']!, 1e-12));
        expect(frames2[k]['yMid'], closeTo(frames[k]['yMid']!, 1e-12));
        expect(frames2[k]['yEnd'], closeTo(frames[k]['yEnd']!, 1e-12));
      }
    });
  });

  group('dynamic fixture G · Oscillate + Fixed reflection sample', () {
    test('angle and y0 match closed-form drive; Fixed LAST=0', () {
      final m = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setAmplitudeCm(0.75)
        ..setFrequencyHz(1.5)
        ..setDamping(0)
        ..setStringEndType(WoasEndType.fixedEnd);

      for (var k = 0; k < 25; k++) {
        m.manualStep(frameDuration);
        final expectedAngle =
            (math.pi * 2 * 1.5 * frameDuration * (k + 1)) % (math.pi * 2);
        expect(m.angle, closeTo(expectedAngle, 1e-12));
        final expectedY0 =
            0.75 * modelUnitsPerCm * math.sin(-m.angle);
        expect(m.yNowAt(0), closeTo(expectedY0, 1e-12));
        expect(m.yNowAt(lastIndex), 0);
      }
    });
  });

  group('dynamic fixture H · Pulse width timing', () {
    test('pulseWidth 0.5 produces multi-frame triangular drive then ends', () {
      final m = WoasModel()
        ..setWaveMode(WoasMode.pulse)
        ..setPulseWidthS(0.5)
        ..setAmplitudeCm(0.75)
        ..setDamping(0);
      m.triggerPulse();

      var peak = 0.0;
      var activeCount = 0;
      final y0Samples = <double>[];
      for (var i = 0; i < 100; i++) {
        m.manualStep(frameDuration);
        if (m.isPulseActive) activeCount++;
        peak = math.max(peak, m.yNowAt(0).abs());
        y0Samples.add(m.yNowAt(0));
      }
      // Peak reaches a substantial fraction of A*80 (triangular envelope).
      expect(peak, greaterThan(0.75 * modelUnitsPerCm * 0.5));
      expect(activeCount, greaterThan(10));
      expect(m.isPulseActive, isFalse);
      expect(y0Samples.where((v) => v.abs() > 1).length, greaterThan(5));
    });
  });
}
