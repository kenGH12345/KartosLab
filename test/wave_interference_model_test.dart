import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:geometric_optics/wave_interference/model/wave_engine.dart';

void main() {
  group('WaveEngine', () {
    late WaveEngine engine;

    setUp(() {
      engine = WaveEngine(width: 80, height: 55);
    });

    tearDown(() {
      engine.dispose();
    });

    test('constructor allocates buffers and zeros them', () {
      expect(engine.width, 80);
      expect(engine.height, 55);
      expect(engine.time, 0);
      final curr = engine.current;
      for (int i = 0; i < 80; i++) {
        for (int j = 0; j < 55; j++) {
          expect(curr[i][j], 0);
        }
      }
    });

    group('setBarrier', () {
      test('blocks cell after propagate', () {
        engine.setBarrier(10, 10);
        engine.propagate(0.1);
        expect(engine.current[10][10], 0);
      });

      test('out-of-bounds is safe', () {
        engine.setBarrier(-1, -1);
        engine.setBarrier(999, 999);
      });
    });

    test('clearBarriers removes all barriers', () {
      engine.setBarrier(5, 5);
      engine.setBarrier(20, 30);
      engine.clearBarriers();
      engine.setSource(5, 5, 2, 1.0);
      engine.setSource(20, 30, 2, 1.0);
      engine.propagate(0.1);
      expect(engine.current[5][5].abs(), greaterThan(0));
      expect(engine.current[20][30].abs(), greaterThan(0));
    });

    group('setDoubleSlit', () {
      test('slit area is open', () {
        engine.setDoubleSlit(40, 2, 10, 24);
        // Slit 1: rows 10-19; use row 14 which is inside the open slit
        final slitRow = 14;
        engine.setSource(40, slitRow, 2, 2.0);
        engine.propagate(0.1);
        expect(engine.current[40][slitRow].abs(), greaterThan(0));
      });
    });

    group('setSingleSlit', () {
      test('slit area is open', () {
        engine.setSingleSlit(40, 2, 10);
        // Single slit centered: rows 22-31 (for height=55, slitSize=10)
        // mid=27, topBarH=22, slit rows 22-31, bottom bar rows 32-54
        final slitRow = 27;
        engine.setSource(40, slitRow, 2, 2.0);
        engine.propagate(0.1);
        expect(engine.current[40][slitRow].abs(), greaterThan(0));
      });

      test('barrier blocks above slit', () {
        engine.setSingleSlit(40, 2, 10);
        // Top barrier row
        engine.setSource(40, 10, 2, 2.0);
        engine.propagate(0.1);
        expect(engine.current[40][10], 0);
      });

      test('barrier blocks below slit', () {
        engine.setSingleSlit(40, 2, 10);
        // Bottom barrier row
        engine.setSource(40, 40, 2, 2.0);
        engine.propagate(0.1);
        expect(engine.current[40][40], 0);
      });
    });

    group('setSource', () {
      test('sets circular region values', () {
        engine.setSource(40, 27, 3, 1.5);
        expect(engine.current[40][27], closeTo(1.5, 0.01));
      });

      test('out-of-bounds is safe', () {
        engine.setSource(-5, -5, 3, 1.0);
        engine.setSource(100, 100, 3, 1.0);
      });
    });

    group('propagate', () {
      test('advances time', () {
        engine.propagate(0.1);
        expect(engine.time, greaterThan(0));
      });

      test('spreads wave from source', () {
        engine.setSource(40, 27, 2, 2.0);
        for (int step = 0; step < 30; step++) {
          engine.propagate(0.05);
        }
        bool found = false;
        for (int i = 35; i <= 45; i++) {
          for (int j = 22; j <= 32; j++) {
            if (engine.current[i][j].abs() > 0.001) found = true;
          }
        }
        expect(found, true);
      });

      test('produces symmetric wave', () {
        engine.setSource(40, 27, 1, 3.0);
        for (int step = 0; step < 20; step++) {
          engine.propagate(0.05);
        }
        final left = engine.current[35][27].abs();
        final right = engine.current[45][27].abs();
        expect((left - right).abs(), lessThan(0.5));
      });
    });

    test('barrier blocks wave propagation', () {
      for (int j = 0; j < engine.height; j++) {
        engine.setBarrier(50, j);
      }
      engine.setSource(40, 27, 2, 3.0);
      for (int step = 0; step < 30; step++) {
        engine.propagate(0.05);
      }
      double behindMax = 0;
      for (int j = 10; j < 45; j++) {
        behindMax = max(behindMax, engine.current[51][j].abs());
      }
      double beforeMax = 0;
      for (int j = 10; j < 45; j++) {
        beforeMax = max(beforeMax, engine.current[45][j].abs());
      }
      expect(beforeMax, greaterThan(behindMax * 2));
    });

    group('reset', () {
      test('zeros all fields', () {
        engine.setSource(40, 27, 3, 2.0);
        for (int step = 0; step < 10; step++) {
          engine.propagate(0.1);
        }
        engine.reset();
        expect(engine.time, 0);
        final curr = engine.current;
        for (int i = 0; i < engine.width; i++) {
          for (int j = 0; j < engine.height; j++) {
            expect(curr[i][j], 0);
          }
        }
      });

      test('does not clear barriers', () {
        engine.setBarrier(30, 27);
        engine.reset();
        engine.setSource(30, 27, 2, 2.0);
        engine.propagate(0.1);
        expect(engine.current[30][27], 0);
      });
    });

    test('edges are damped', () {
      engine.setSource(40, 27, 3, 5.0);
      for (int step = 0; step < 40; step++) {
        engine.propagate(0.05);
      }
      double edgeMax = 0, interiorMax = 0;
      for (int j = 0; j < engine.height; j++) {
        edgeMax = max(edgeMax, engine.current[0][j].abs());
        interiorMax = max(interiorMax, engine.current[40][j].abs());
      }
      expect(interiorMax, greaterThan(edgeMax));
    });

    test('dispose calls reset', () {
      engine.setSource(40, 27, 3, 2.0);
      for (int step = 0; step < 5; step++) {
        engine.propagate(0.1);
      }
      engine.dispose();
      expect(engine.time, 0);
      final curr = engine.current;
      for (int i = 0; i < engine.width; i++) {
        for (int j = 0; j < engine.height; j++) {
          expect(curr[i][j], 0);
        }
      }
    });
  });
}
