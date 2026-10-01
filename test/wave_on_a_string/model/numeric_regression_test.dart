import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_end_type.dart';
import 'package:kratos/wave_on_a_string/model/woas_mode.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';

/// Source-derived numeric fixtures — golden lock for evolve / drive.
void main() {
  group('numeric regression · evolve', () {
    test('fixture A: damping=0 center bead one evolve', () {
      final model = WoasModel()
        ..setDamping(0)
        ..setStringEndType(WoasEndType.looseEnd);

      const i = 30;
      model.debugSeedBead(index: i, yLast: 10, yNow: 10);
      model.debugSeedBead(index: i - 1, yLast: 0, yNow: 0);
      model.debugSeedBead(index: i + 1, yLast: 0, yNow: 0);

      model.evolve();

      expect(model.yNowAt(i), closeTo(-10.0, 1e-12));
      expect(model.yLastAt(i), closeTo(10.0, 1e-12));
      expect(model.yNowAt(i - 1), closeTo(10.0, 1e-12));
      expect(model.yNowAt(i + 1), closeTo(10.0, 1e-12));
    });

    test('fixture B: damping=0.2 three evolves tracked', () {
      final model = WoasModel()
        ..setDamping(0.2)
        ..setStringEndType(WoasEndType.looseEnd);

      const i = 25;
      model.debugSeedBead(index: i, yLast: 4, yNow: 4);

      final snapshots = <double>[];
      for (var step = 0; step < 3; step++) {
        model.evolve();
        snapshots.add(model.yNowAt(i));
      }

      const beta = 0.02;
      const a = 1 / (1 + beta);
      final step1 = a * ((beta - 1) * 4);
      expect(snapshots[0], closeTo(step1, 1e-12));

      // Golden chain from source formula (neighbors initially 0; then couple).
      // step1 = a*(β-1)*4
      // step2 = a*((β-1)*4 + 2*a*4)  after neighbors received a*4
      expect(snapshots[0], closeTo(-3.843137254901961, 1e-12));
      expect(snapshots[1], closeTo(3.8462129950019217, 1e-12));
      expect(snapshots[2], closeTo(-3.695381112844984, 1e-12));
    });

    test('fixture C: Fixed end keeps LAST=0 across evolves', () {
      final model = WoasModel()..setDamping(0);
      model.debugSeedBead(index: nextToLastIndex, yLast: 6, yNow: 6);
      model.debugSeedBead(index: nextToLastIndex - 1, yLast: 6, yNow: 6);
      model.debugSeedBead(index: lastIndex, yLast: 6, yNow: 6);

      for (var k = 0; k < 5; k++) {
        model.evolve();
        expect(model.yNowAt(lastIndex), 0);
        expect(model.yLastAt(lastIndex), 0);
      }
    });
  });

  group('numeric regression · oscillate drive', () {
    test('fixture D: oscillate y0 samples', () {
      final model = WoasModel()
        ..setWaveMode(WoasMode.oscillate)
        ..setAmplitudeCm(0.75)
        ..setFrequencyHz(1.50)
        ..setDamping(0);

      final samples = <double>[];
      for (var k = 0; k < 3; k++) {
        model.manualStep(frameDuration);
        samples.add(model.yNowAt(0));
      }

      double expected(int n) {
        final ang = (2 * math.pi * 1.5 * frameDuration * n) % (2 * math.pi);
        return 0.75 * modelUnitsPerCm * math.sin(-ang);
      }

      expect(samples[0], closeTo(expected(1), 1e-12));
      expect(samples[1], closeTo(expected(2), 1e-12));
      expect(samples[2], closeTo(expected(3), 1e-12));
    });
  });

  group('numeric regression · yDraw after evolve', () {
    test('fixture E: post-evolve yDraw equals yLast', () {
      final model = WoasModel()
        ..setDamping(0)
        ..setTension(0.8)
        ..setStringEndType(WoasEndType.looseEnd);
      model.debugSeedBead(index: 12, yLast: 3, yNow: 3);

      model.manualStep(frameDuration);

      for (var i = 0; i < numberOfBeads; i++) {
        expect(model.yDrawAt(i), closeTo(model.yLastAt(i), 1e-12));
      }
    });
  });
}
