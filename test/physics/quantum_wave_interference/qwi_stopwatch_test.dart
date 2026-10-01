import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/data/ruler_data.dart';
import 'package:kratos/physics/quantum_wave_interference/models/high_intensity_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/common/qwi_stopwatch.dart';

void main() {
  group('formatQwiStopwatch', () {
    test('selects femtoseconds for photon-scale intervals', () {
      final f = formatQwiStopwatch(2.5e-15);
      expect(f.unit, 'fs');
      expect(f.value, '2.50');
    });

    test('selects milliseconds near 1e-3 s', () {
      final f = formatQwiStopwatch(2.5e-3);
      expect(f.unit, 'ms');
      expect(f.value, '2.50');
    });
  });

  group('QwiStopwatchState + HI physicalDt', () {
    test('stopwatch advances only while running with physical dt', () {
      final model = HighIntensityModel();
      model.clock.isPlaying = true;
      model.stopwatch.isRunning = true;
      final before = model.stopwatch.timeSeconds;
      model.step(1 / 60);
      expect(model.stopwatch.timeSeconds, greaterThan(before));
      // Photons → physical dt is femtosecond-scale, far below 1 µs.
      expect(model.stopwatch.timeSeconds, lessThan(1e-6));
    });

    test('paused sim does not advance stopwatch', () {
      final model = HighIntensityModel();
      model.clock.isPlaying = false;
      model.stopwatch.isRunning = true;
      model.step(1 / 60);
      expect(model.stopwatch.timeSeconds, 0);
    });

    test('reset clears stopwatch', () {
      final sw = QwiStopwatchState(visible: true, isRunning: true, timeSeconds: 1.2);
      sw.reset();
      expect(sw.visible, isFalse);
      expect(sw.isRunning, isFalse);
      expect(sw.timeSeconds, 0);
    });
  });
}
