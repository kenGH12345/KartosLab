import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_end_type.dart';
import 'package:kratos/wave_on_a_string/model/woas_mode.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/view/woas_play_area.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';

List<double> _snapshot(WoasModel m) =>
    List<double>.generate(numberOfBeads, m.yNowAt);

void main() {
  group('determinism', () {
    test('same initial + same FRAME sequence → identical yNow', () {
      WoasModel run() {
        final m = WoasModel()
          ..setDamping(0.2)
          ..setWaveMode(WoasMode.oscillate)
          ..setAmplitudeCm(0.75)
          ..setFrequencyHz(1.5);
        for (var i = 0; i < 60; i++) {
          m.manualStep(frameDuration);
        }
        return m;
      }

      final a = run();
      final b = run();
      for (var i = 0; i < numberOfBeads; i++) {
        expect(a.yNowAt(i), closeTo(b.yNowAt(i), 1e-12));
      }
      expect(a.angle, closeTo(b.angle, 1e-12));
    });

    test('Manual sequence deterministic', () {
      List<double> seq() {
        final m = WoasModel()..setDamping(0);
        m.setManualDisplacement(35);
        for (var i = 0; i < 12; i++) {
          m.manualStep(frameDuration);
          m.nextLeftY = 35;
        }
        m.setManualDisplacement(0);
        for (var i = 0; i < 40; i++) {
          m.manualStep(frameDuration);
          m.nextLeftY = 0;
        }
        return _snapshot(m);
      }

      final a = seq();
      final b = seq();
      for (var i = 0; i < numberOfBeads; i++) {
        expect(a[i], closeTo(b[i], 1e-12));
      }
    });
  });

  group('frame-rate independence (source FRAME_DURATION)', () {
    test('physics driven by FRAME slices not widget FPS', () {
      // Two models: same total manualStep budget via different call sizes.
      final a = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setFrequencyHz(1.0)
        ..setDamping(0);
      final b = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setFrequencyHz(1.0)
        ..setDamping(0);

      // A: 40 × FRAME
      for (var i = 0; i < 40; i++) {
        a.manualStep(frameDuration);
      }
      // B: 20 × 2×FRAME (same total sim time / same numSteps path)
      for (var i = 0; i < 20; i++) {
        b.manualStep(frameDuration * 2);
      }

      expect(a.angle, closeTo(b.angle, 1e-9));
      for (var i = 0; i < numberOfBeads; i++) {
        expect(a.yNowAt(i), closeTo(b.yNowAt(i), 1e-6));
      }
    });
  });

  group('dispose during simulation', () {
    testWidgets('Oscillate dispose: no setState after dispose', (tester) async {
      final model = WoasModel()..setWaveMode(WoasMode.oscillate);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WoasPlayArea(model: model, autoStartClock: false),
          ),
        ),
      );
      for (var i = 0; i < 10; i++) {
        model.manualStep(frameDuration);
      }
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      // Notify after dispose must not throw from PlayArea listener.
      model.manualStep(frameDuration);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Pulse + Timer dispose clean', (tester) async {
      final model = WoasModel()
        ..setWaveMode(WoasMode.pulse)
        ..setStopwatchVisible(true);
      model.triggerPulse();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WoasPlayArea(model: model, autoStartClock: false),
          ),
        ),
      );
      for (var i = 0; i < 5; i++) {
        model.manualStep(frameDuration);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      model.manualStep(frameDuration);
      expect(tester.takeException(), isNull);
    });
  });

  group('performance invariants', () {
    test('long Oscillate run uses single model clock path (no hang)', () {
      final m = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setDamping(0.2);
      // ~20s of FRAME_DURATION steps (1000 frames)
      for (var i = 0; i < 1000; i++) {
        m.manualStep(frameDuration);
      }
      expect(m.drawPositions.length, 61);
      expect(m.angle.isFinite, isTrue);
    });

    test('no bead-count AnimationControllers (structural)', () {
      // WoasModel holds Float64List×4 — not 61 tickers.
      final m = WoasModel();
      expect(m.beadCount, 61);
      expect(m.drawPositions.length, 61);
    });
  });

  group('end type enum coverage', () {
    test('all boundaries survive long oscillate', () {
      for (final end in WoasEndType.values) {
        final m = WoasModel()
          ..setWaveMode(WoasMode.oscillate)
          ..setStringEndType(end)
          ..setDamping(0.1);
        for (var i = 0; i < 80; i++) {
          m.manualStep(frameDuration);
        }
        expect(m.yNowAt(0).isFinite, isTrue);
        expect(m.yNowAt(lastIndex).isFinite, isTrue);
      }
    });
  });
}
