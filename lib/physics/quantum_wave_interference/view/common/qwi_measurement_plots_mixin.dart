import 'dart:ui';

import '../../data/measurement_plots_state.dart';
import '../../domain/wave_display_mode.dart';
import '../../numerics/analytical_wave_solver.dart';
import '../../numerics/qwi_wave_sample.dart';
import '../../numerics/wave_kernel_types.dart';

/// Shared Time/Position plot stepping for HI & SP controllers.
mixin QwiMeasurementPlotsMixin {
  MeasurementPlotsState get plots;
  AnalyticalWaveSolver get plotSolver;
  WaveSource createPlotSource();
  WaveDisplayMode get plotDisplayMode;
  double get plotRegionWidth;
  double get plotRegionHeight;

  bool stepTimePlotIfNeeded({required bool allowSample}) {
    if (!allowSample) return false;
    final rw = plotRegionWidth;
    final rh = plotRegionHeight;
    if (rw <= 0 || rh <= 0) return false;
    final source = createPlotSource();
    final modelX = plots.probeNormX * rw;
    final modelY = plots.probeNormY * rh - rh / 2;
    return plots.timeSeries.stepAtSolverTime(plotSolver.time, (t) {
      return qwiSampleDisplayedValue(
        solver: plotSolver,
        source: source,
        mode: plotDisplayMode,
        modelX: modelX,
        modelY: modelY,
        solverTime: t,
      );
    });
  }

  void resamplePositionPlot() {
    final rw = plotRegionWidth;
    final rh = plotRegionHeight;
    if (rw <= 0 || rh <= 0) {
      plots.positionPoints = const [];
      return;
    }
    final source = createPlotSource();
    // PhET: chartWidth == WAVE_REGION_WIDTH (420 design px)
    const designWaveW = 420.0;
    final numSamples = designWaveW * QwiPlotConstants.positionSamplesPerPixel;
    final modelY = plots.lineYFraction * rh - rh / 2;
    final points = <WavePlotPoint>[];
    for (var i = 0; i <= numSamples; i++) {
      final fraction = i / numSamples;
      final modelX = fraction * rw;
      final value = qwiSampleDisplayedValue(
        solver: plotSolver,
        source: source,
        mode: plotDisplayMode,
        modelX: modelX,
        modelY: modelY,
      );
      points.add(WavePlotPoint(x: modelX, value: value));
    }
    plots.positionPoints = points;
  }
}

Rect qwiDesignWaveRect({
  required double left,
  required double top,
  double width = 420,
  double height = 385,
}) =>
    Rect.fromLTWH(left, top, width, height);
