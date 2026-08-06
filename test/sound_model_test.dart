import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:geometric_optics/sound/model/sound_state.dart';

void main() {
  group('SoundState', () {
    test('default values', () {
      final s = SoundState();
      expect(s.frequency, 500);
      expect(s.amplitude, 0.5);
      expect(s.speakerX, 100);
      expect(s.speakerY, 200);
      expect(s.baseRadius, 80);
      expect(s.time, 0);
      expect(s.amplitudes, hasLength(SoundState.arrayLength));
      for (final a in s.amplitudes) {
        expect(a, 0);
      }
    });

    test('custom constructor values', () {
      final s = SoundState(
        frequency: 200,
        amplitude: 0.8,
        speakerX: 50,
        speakerY: 100,
        baseRadius: 120,
      );
      expect(s.frequency, 200);
      expect(s.amplitude, 0.8);
      expect(s.speakerX, 50);
      expect(s.speakerY, 100);
      expect(s.baseRadius, 120);
    });

    group('setFrequency', () {
      test('normal', () {
        final s = SoundState();
        s.setFrequency(300);
        expect(s.frequency, 300);
      });
      test('clamps negative', () {
        final s = SoundState();
        s.setFrequency(-100);
        expect(s.frequency, 0);
      });
      test('clamps over max', () {
        final s = SoundState();
        s.setFrequency(2000);
        expect(s.frequency, 1000);
      });
      test('boundary 0', () {
        final s = SoundState();
        s.setFrequency(0);
        expect(s.frequency, 0);
      });
      test('boundary 1000', () {
        final s = SoundState();
        s.setFrequency(1000);
        expect(s.frequency, 1000);
      });
    });

    group('setAmplitude', () {
      test('normal', () {
        final s = SoundState();
        s.setAmplitude(0.3);
        expect(s.amplitude, 0.3);
      });
      test('clamps negative', () {
        final s = SoundState();
        s.setAmplitude(-0.5);
        expect(s.amplitude, 0);
      });
      test('clamps over max', () {
        final s = SoundState();
        s.setAmplitude(2.0);
        expect(s.amplitude, 1.0);
      });
      test('boundary 0', () {
        final s = SoundState();
        s.setAmplitude(0);
        expect(s.amplitude, 0);
      });
      test('boundary 1.0', () {
        final s = SoundState();
        s.setAmplitude(1.0);
        expect(s.amplitude, 1.0);
      });
    });

    group('stepInTime', () {
      test('advances time', () {
        final s = SoundState(frequency: 100, amplitude: 0.5);
        s.stepInTime(0.1);
        expect(s.time, greaterThan(0));
      });

      test('produces non-zero with amp > 0', () {
        final s = SoundState(frequency: 443, amplitude: 1.0);
        for (int i = 0; i < 30; i++) {
          s.stepInTime(0.037);
        }
        bool hasNonZero = false;
        for (final a in s.amplitudes) {
          if (a.abs() > 0.001) {
            hasNonZero = true;
            break;
          }
        }
        expect(hasNonZero, true);
      });

      test('produces zeros with amp = 0', () {
        final s = SoundState(frequency: 440, amplitude: 0);
        for (int i = 0; i < 10; i++) {
          s.stepInTime(0.1);
        }
        for (final a in s.amplitudes) {
          expect(a, 0);
        }
      });

      test('sinusoidal at front crosses zero', () {
        final s = SoundState(frequency: 200, amplitude: 1.0);
        final vals = <double>[];
        for (int i = 0; i < 50; i++) {
          s.stepInTime(0.013);
          vals.add(s.amplitudes[0]);
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
    });

    group('amplitudeAt', () {
      test('returns double for valid index', () {
        final s = SoundState();
        expect(s.amplitudeAt(0), isA<double>());
      });
      test('clamps negative to 0', () {
        final s = SoundState();
        s.stepInTime(0.1);
        expect(s.amplitudeAt(-5), s.amplitudes[0]);
      });
      test('clamps overflow to last', () {
        final s = SoundState();
        expect(
          s.amplitudeAt(SoundState.arrayLength + 100),
          s.amplitudes[SoundState.arrayLength - 1],
        );
      });
    });

    test('wave attenuates with distance', () {
      final s = SoundState(frequency: 200, amplitude: 1.0);
      for (int i = 0; i < 50; i++) {
        s.stepInTime(0.05);
      }
      double frontMax = 0, tailMax = 0;
      for (int i = 0; i < SoundState.arrayLength; i++) {
        final v = s.amplitudes[i].abs();
        if (i < 10) frontMax = max(frontMax, v);
        if (i > 300) tailMax = max(tailMax, v);
      }
      expect(frontMax, greaterThan(tailMax));
    });

    test('reset zeros all', () {
      final s = SoundState(frequency: 440, amplitude: 1.0);
      for (int i = 0; i < 10; i++) {
        s.stepInTime(0.1);
      }
      s.reset();
      expect(s.time, 0);
      for (final a in s.amplitudes) {
        expect(a, 0);
      }
    });

    test('dispose calls reset', () {
      final s = SoundState(frequency: 440, amplitude: 1.0);
      for (int i = 0; i < 5; i++) {
        s.stepInTime(0.1);
      }
      s.dispose();
      expect(s.time, 0);
      for (final a in s.amplitudes) {
        expect(a, 0);
      }
    });
  });
}
