import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/data/time_plot_data_series.dart';
import 'package:kratos/physics/quantum_wave_interference/models/high_intensity_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/high_intensity/high_intensity_controller.dart';

void main() {
  group('TimePlotDataSeries', () {
    test('samples at fixed solver intervals', () {
      final series = TimePlotDataSeries();
      var calls = 0;
      series.stepAtSolverTime(0, (_) {
        calls++;
        return 0.5;
      });
      expect(calls, 1);
      series.stepAtSolverTime(TimePlotDataSeries.timeSampleInterval * 3.5, (t) {
        calls++;
        return t;
      });
      expect(series.points.length, greaterThan(2));
      final range = series.getChartTimeRange();
      expect(range.maxTime - range.minTime, closeTo(1.0, 1e-9));
    });
  });

  group('HI measurement plots', () {
    test('time plot advances while playing and visible', () {
      final c = HighIntensityController(model: HighIntensityModel());
      c.setTimePlotVisible(true);
      c.setEmitting(true);
      c.setPlaying(true);
      for (var i = 0; i < 30; i++) {
        c.stepWall(1 / 60);
      }
      expect(c.model.plots.timeSeries.points, isNotEmpty);
    });

    test('position plot fills samples when shown', () {
      final c = HighIntensityController(model: HighIntensityModel());
      c.setEmitting(true);
      c.setPositionPlotVisible(true);
      expect(c.model.plots.positionPoints.length, greaterThan(100));
    });
  });
}
