import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_end_type.dart';
import 'package:kratos/wave_on_a_string/model/woas_mode.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/model/woas_time_speed.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';

void main() {
  group('WoasModel initial state', () {
    late WoasModel model;

    setUp(() => model = WoasModel());

    test('source defaults match Phase 0 / WOASModel', () {
      expect(model.waveMode, WoasMode.manual);
      expect(model.stringEndType, WoasEndType.fixedEnd);
      expect(model.damping, closeTo(0.2, 1e-12));
      expect(model.tension, closeTo(0.8, 1e-12));
      expect(model.amplitudeCm, closeTo(0.75, 1e-12));
      expect(model.frequencyHz, closeTo(1.50, 1e-12));
      expect(model.pulseWidthS, closeTo(0.5, 1e-12));
      expect(model.isPlaying, isTrue);
      expect(model.timeSpeed, WoasTimeSpeed.normal);
      expect(model.rulersVisible, isFalse);
      expect(model.referenceLineVisible, isFalse);
      expect(model.stopwatch.isVisible, isFalse);
      expect(model.stopwatch.time, 0);
      expect(model.wrenchArrowsVisible, isTrue);
      expect(model.beadCount, 61);
      expect(model.angle, 0);
      expect(model.nextLeftY, 0);
    });

    test('all y buffers are zero', () {
      for (var i = 0; i < numberOfBeads; i++) {
        expect(model.yLastAt(i), 0);
        expect(model.yNowAt(i), 0);
        expect(model.yNextAt(i), 0);
        expect(model.yDrawAt(i), 0);
      }
    });

    test('drawPositions is unmodifiable length 61', () {
      final d = model.drawPositions;
      expect(d.length, 61);
      expect(() => d[0] = 1, throwsUnsupportedError);
    });
  });

  group('control ranges', () {
    late WoasModel model;
    setUp(() => model = WoasModel());

    test('clamps amplitude / frequency / damping / tension / pulseWidth', () {
      model.setAmplitudeCm(99);
      expect(model.amplitudeCm, maxStartAmplitudeCm);
      model.setAmplitudeCm(-1);
      expect(model.amplitudeCm, 0);

      model.setFrequencyHz(10);
      expect(model.frequencyHz, 3);
      model.setFrequencyHz(-1);
      expect(model.frequencyHz, 0);

      model.setDamping(2);
      expect(model.damping, 1);
      model.setDamping(-1);
      expect(model.damping, 0);

      model.setTension(0);
      expect(model.tension, tensionMin);
      model.setTension(1);
      expect(model.tension, tensionMax);

      model.setPulseWidthS(0);
      expect(model.pulseWidthS, pulseWidthMinS);
      model.setPulseWidthS(5);
      expect(model.pulseWidthS, pulseWidthMaxS);
    });
  });
}
