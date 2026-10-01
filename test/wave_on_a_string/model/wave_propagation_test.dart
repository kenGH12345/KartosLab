import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_end_type.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';

void main() {
  group('evolve formula', () {
    test('β = damping * 0.1 and α = 1', () {
      final model = WoasModel()..setDamping(0.2);
      model.evolve();
      expect(model.alpha, 1);
      expect(model.beta, closeTo(0.02, 1e-12));

      model.setDamping(1);
      model.evolve();
      expect(model.beta, closeTo(0.1, 1e-12));

      model.setDamping(0);
      model.evolve();
      expect(model.beta, 0);
    });

    test('zero damping single-bead update matches closed form', () {
      final model = WoasModel()
        ..setDamping(0)
        ..setStringEndType(WoasEndType.looseEnd);

      const i = 30;
      model.debugSeedBead(index: i, yLast: 10, yNow: 10);
      model.debugSeedBead(index: i - 1, yLast: 0, yNow: 0);
      model.debugSeedBead(index: i + 1, yLast: 0, yNow: 0);

      model.evolve();

      expect(model.yNowAt(i), closeTo(-10, 1e-12));
      expect(model.yLastAt(i), closeTo(10, 1e-12));
    });

    test('nonzero damping uses a = 1/(β+1)', () {
      final model = WoasModel()
        ..setDamping(1)
        ..setStringEndType(WoasEndType.looseEnd);

      const i = 20;
      model.debugSeedBead(index: i, yLast: 5, yNow: 5);
      model.debugSeedBead(index: i - 1, yNow: 1);
      model.debugSeedBead(index: i + 1, yNow: 2);

      const beta = 0.1;
      const a = 1 / (1 + beta);
      const alphaSq = 1.0;
      const c = 0.0;
      final expected =
          a * ((beta - 1) * 5 + c * 5 + alphaSq * (2 + 1));

      model.evolve();
      expect(model.yNowAt(i), closeTo(expected, 1e-12));
    });

    test('array rotate: yLast←yNow←yNext', () {
      final model = WoasModel()..setDamping(0);
      model.debugSeedBead(index: 10, yLast: 1, yNow: 2, yNext: 99);
      model.debugSeedBead(index: 9, yNow: 0);
      model.debugSeedBead(index: 11, yNow: 0);

      model.evolve();
      expect(model.yLastAt(10), 2);
      expect(model.yNowAt(10), closeTo(-1, 1e-12));
    });
  });

  group('propagation', () {
    test('center disturbance spreads to neighbors after evolves', () {
      final model = WoasModel()
        ..setDamping(0)
        ..setTension(0.8)
        ..setStringEndType(WoasEndType.looseEnd);

      const center = 30;
      model.debugSeedBead(index: center, yLast: 20, yNow: 20);

      for (var k = 0; k < 8; k++) {
        model.manualStep(frameDuration);
      }

      final energyNearby = model.yNowAt(center - 1).abs() +
          model.yNowAt(center + 1).abs() +
          model.yNowAt(center - 2).abs() +
          model.yNowAt(center + 2).abs();
      expect(energyNearby, greaterThan(0));
    });

    test('higher tension evolves more often than lower tension', () {
      WoasModel make(double t) {
        final m = WoasModel()
          ..setDamping(0)
          ..setTension(t)
          ..setStringEndType(WoasEndType.looseEnd);
        m.debugSeedBead(index: 30, yLast: 10, yNow: 10);
        return m;
      }

      final slow = make(0.2); // minDt = 0.1 → evolve after 5 frames
      final fast = make(0.8); // minDt = 0.02 → evolve every frame

      // After 3 FRAME_DURATION slices: fast evolved 3×, slow not yet.
      for (var i = 0; i < 3; i++) {
        slow.manualStep(frameDuration);
        fast.manualStep(frameDuration);
      }

      expect(slow.yNowAt(30), closeTo(10, 1e-12)); // no evolve yet
      expect(fast.yNowAt(30), isNot(closeTo(10, 1e-9)));
      expect(slow.timeElapsed, closeTo(0.06, 1e-12));
    });
  });

  group('tensionFactor', () {
    test('maps 0.2→0.2 and 0.8→1.0', () {
      expect(tensionFactorFor(0.2), closeTo(0.2, 1e-12));
      expect(tensionFactorFor(0.8), closeTo(1.0, 1e-12));
      expect(minDtFor(tension: 0.8, speedMultiplier: 1), closeTo(0.02, 1e-12));
      expect(minDtFor(tension: 0.2, speedMultiplier: 1), closeTo(0.1, 1e-12));
      expect(
        minDtFor(tension: 0.8, speedMultiplier: 0.25),
        closeTo(0.08, 1e-12),
      );
    });
  });
}
