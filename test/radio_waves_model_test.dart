import 'package:flutter_test/flutter_test.dart';
import 'package:geometric_optics/radio_waves/model/radio_state.dart';

void main() {
  group('RadioState', () {
    test('default values', () {
      final r = RadioState();
      expect(r.antennaX, 120);
      expect(r.antennaY, 220);
      expect(r.antennaHalfLength, 80);
      expect(r.electronY, 0);
      expect(r.frequency, 0.5);
      expect(r.amplitude, 0.5);
      expect(r.time, 0);
      expect(r.staticFieldEnabled, true);
      expect(r.dynamicFieldEnabled, true);
      expect(r.showCurve, true);
      expect(r.showArrows, true);
      expect(r.fieldSampleSpacing, 18);
      expect(r.fieldValues, hasLength(RadioState.numFieldSamples));
      for (final v in r.fieldValues) {
        expect(v, 0);
      }
    });

    group('setFrequency', () {
      test('normal', () {
        final r = RadioState();
        r.setFrequency(1.0);
        expect(r.frequency, 1.0);
      });
      test('clamps below min', () {
        final r = RadioState();
        r.setFrequency(0.001);
        expect(r.frequency, 0.01);
      });
      test('clamps above max', () {
        final r = RadioState();
        r.setFrequency(5.0);
        expect(r.frequency, 2.0);
      });
      test('boundary min', () {
        final r = RadioState();
        r.setFrequency(0.01);
        expect(r.frequency, 0.01);
      });
      test('boundary max', () {
        final r = RadioState();
        r.setFrequency(2.0);
        expect(r.frequency, 2.0);
      });
    });

    group('setAmplitude', () {
      test('normal', () {
        final r = RadioState();
        r.setAmplitude(0.75);
        expect(r.amplitude, 0.75);
      });
      test('clamps negative', () {
        final r = RadioState();
        r.setAmplitude(-0.3);
        expect(r.amplitude, 0);
      });
      test('clamps above max', () {
        final r = RadioState();
        r.setAmplitude(1.5);
        expect(r.amplitude, 1.0);
      });
    });

    group('stepInTime', () {
      test('advances time', () {
        final r = RadioState();
        r.frequency = 1.0;
        r.amplitude = 0.5;
        r.stepInTime(0.1);
        expect(r.time, greaterThan(0));
      });

      test('electronY oscillates', () {
        final r = RadioState();
        r.frequency = 1.0;
        r.amplitude = 0.5;
        final vals = <double>[];
        for (int i = 0; i < 30; i++) {
          r.stepInTime(0.05);
          vals.add(r.electronY);
        }
        bool changed = false;
        for (int i = 1; i < vals.length; i++) {
          if ((vals[i] - vals[i - 1]).abs() > 0.0001) {
            changed = true;
            break;
          }
        }
        expect(changed, true);
      });

      test('electronY crosses zero', () {
        final r = RadioState();
        r.frequency = 1.0;
        r.amplitude = 0.5;
        final vals = <double>[];
        for (int i = 0; i < 50; i++) {
          r.stepInTime(0.05);
          vals.add(r.electronY);
        }
        bool crossesZero = false;
        for (int i = 1; i < vals.length; i++) {
          if (vals[i - 1].sign != vals[i].sign && vals[i - 1].abs() > 0.01) {
            crossesZero = true;
            break;
          }
        }
        expect(crossesZero, true);
      });

      test('dynamicFieldEnabled=false freezes electronY', () {
        final r = RadioState();
        r.frequency = 1.0;
        r.amplitude = 0.5;
        r.dynamicFieldEnabled = false;
        for (int i = 0; i < 10; i++) {
          r.stepInTime(0.1);
        }
        expect(r.electronY, 0);
      });

      test('fieldValues populated after enough time', () {
        final r = RadioState();
        r.frequency = 0.5;
        r.amplitude = 1.0;
        for (int i = 0; i < 100; i++) {
          r.stepInTime(0.1);
        }
        bool hasNonZero = false;
        for (final v in r.fieldValues) {
          if (v.abs() > 0.0001) {
            hasNonZero = true;
            break;
          }
        }
        expect(hasNonZero, true);
      });
    });

    group('toggles', () {
      test('toggleStaticField', () {
        final r = RadioState();
        expect(r.staticFieldEnabled, true);
        r.toggleStaticField();
        expect(r.staticFieldEnabled, false);
        r.toggleStaticField();
        expect(r.staticFieldEnabled, true);
      });
      test('toggleDynamicField', () {
        final r = RadioState();
        r.toggleDynamicField();
        expect(r.dynamicFieldEnabled, false);
        r.toggleDynamicField();
        expect(r.dynamicFieldEnabled, true);
      });
      test('toggleCurve', () {
        final r = RadioState();
        r.toggleCurve();
        expect(r.showCurve, false);
        r.toggleCurve();
        expect(r.showCurve, true);
      });
      test('toggleArrows', () {
        final r = RadioState();
        r.toggleArrows();
        expect(r.showArrows, false);
        r.toggleArrows();
        expect(r.showArrows, true);
      });
    });

    test('reset zeros time and fields', () {
      final r = RadioState();
      r.frequency = 1.0;
      r.amplitude = 1.0;
      for (int i = 0; i < 10; i++) {
        r.stepInTime(0.1);
      }
      r.reset();
      expect(r.time, 0);
      expect(r.electronY, 0);
      for (final v in r.fieldValues) {
        expect(v, 0);
      }
    });

    test('reset preserves toggle states', () {
      final r = RadioState();
      r.toggleDynamicField();
      r.toggleCurve();
      r.reset();
      expect(r.dynamicFieldEnabled, false);
      expect(r.showCurve, false);
    });

    test('dispose calls reset', () {
      final r = RadioState();
      r.frequency = 1.0;
      r.amplitude = 1.0;
      for (int i = 0; i < 5; i++) {
        r.stepInTime(0.1);
      }
      r.dispose();
      expect(r.time, 0);
      expect(r.electronY, 0);
      for (final v in r.fieldValues) {
        expect(v, 0);
      }
    });
  });
}
