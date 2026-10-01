import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_end_type.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';

void main() {
  group('Fixed End', () {
    test('endpoint forced to zero in evolve', () {
      final model = WoasModel();
      model.debugSeedBead(index: lastIndex, yNow: 12, yLast: 12, yDraw: 12);
      model.debugSeedBead(index: nextToLastIndex, yNow: 8, yLast: 8);
      model.evolve();
      expect(model.yNowAt(lastIndex), 0);
      expect(model.yLastAt(lastIndex), 0);
    });

    test('zeroOutEndPoint on switch to Fixed', () {
      final model = WoasModel()..setStringEndType(WoasEndType.looseEnd);
      model.debugSeedBead(index: lastIndex, yNow: 7, yDraw: 7);
      model.setStringEndType(WoasEndType.fixedEnd);
      expect(model.yNowAt(lastIndex), 0);
      expect(model.yDrawAt(lastIndex), 0);
    });

    test('boundary switch to Fixed does NOT clear whole string', () {
      final model = WoasModel()..setStringEndType(WoasEndType.looseEnd);
      model.debugSeedBead(index: 15, yNow: 4, yLast: 4, yDraw: 4);
      model.setStringEndType(WoasEndType.fixedEnd);
      expect(model.yNowAt(15), 4);
    });
  });

  group('Loose End', () {
    test('y[LAST] mirrors y[NEXT_TO_LAST] after evolve', () {
      final model = WoasModel()
        ..setStringEndType(WoasEndType.looseEnd)
        ..setDamping(0);
      model.debugSeedBead(index: nextToLastIndex, yNow: 5, yLast: 5);
      model.debugSeedBead(index: lastIndex, yNow: 0, yLast: 0);
      model.debugSeedBead(index: nextToLastIndex - 1, yNow: 5, yLast: 5);

      model.evolve();
      expect(model.yNowAt(lastIndex), model.yNowAt(nextToLastIndex));
    });
  });

  group('No End', () {
    test('post-rotate uses yLast[NEXT_TO_LAST] for LAST', () {
      final model = WoasModel()
        ..setStringEndType(WoasEndType.noEnd)
        ..setDamping(0);

      model.debugSeedBead(index: nextToLastIndex, yLast: 3, yNow: 9);
      model.debugSeedBead(index: nextToLastIndex - 1, yLast: 0, yNow: 0);
      model.debugSeedBead(index: lastIndex, yLast: 1, yNow: 2);

      model.evolve();
      expect(
        model.yNowAt(lastIndex),
        closeTo(model.yLastAt(nextToLastIndex), 1e-12),
      );
    });

    test('No End allows nonzero LAST; Fixed LAST stays 0', () {
      double peakAtEnd(WoasEndType end) {
        final m = WoasModel()
          ..setDamping(0)
          ..setTension(0.8)
          ..setStringEndType(end);
        m.setManualDisplacement(40);
        for (var i = 0; i < 5; i++) {
          m.manualStep(frameDuration);
          m.nextLeftY = 40;
        }
        m.setManualDisplacement(0);
        var peak = 0.0;
        for (var i = 0; i < 200; i++) {
          m.manualStep(frameDuration);
          m.nextLeftY = 0;
          final v = m.yNowAt(lastIndex).abs();
          if (v > peak) peak = v;
        }
        return peak;
      }

      expect(peakAtEnd(WoasEndType.fixedEnd), 0);
      expect(peakAtEnd(WoasEndType.noEnd), greaterThan(0));
    });
  });

  group('boundary switching', () {
    test('Loose → No End does not restart', () {
      final model = WoasModel()..setStringEndType(WoasEndType.looseEnd);
      model.debugSeedBead(index: 8, yNow: 2.5, yLast: 2.5);
      model.setStringEndType(WoasEndType.noEnd);
      expect(model.yNowAt(8), 2.5);
    });

    test('No End → Fixed zeros endpoint only', () {
      final model = WoasModel()..setStringEndType(WoasEndType.noEnd);
      model.debugSeedBead(index: 8, yNow: 2.5);
      model.debugSeedBead(index: lastIndex, yNow: 3, yDraw: 3);
      model.setStringEndType(WoasEndType.fixedEnd);
      expect(model.yNowAt(8), 2.5);
      expect(model.yNowAt(lastIndex), 0);
    });
  });
}
