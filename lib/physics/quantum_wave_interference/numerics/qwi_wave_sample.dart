import '../domain/wave_display_mode.dart';
import '../numerics/analytical_wave_solver.dart';
import '../numerics/field_sample.dart';
import '../numerics/wave_kernel_types.dart';

/// Samples the displayed wave quantity at model (x, y) — PhET `evaluate` + `getDisplayedWaveValue`.
double qwiSampleDisplayedValue({
  required AnalyticalWaveSolver solver,
  required WaveSource source,
  required WaveDisplayMode mode,
  required double modelX,
  required double modelY,
  double? solverTime,
}) {
  final sample = solver.sampleAt(source, modelX, modelY, solverTime);
  final c = getRepresentativeComplex(sample);
  return mode.displayedValue(c.real, c.imaginary);
}
