import 'field_sample.dart';
import 'wave_decoherence.dart';
import 'wave_kernel_types.dart';
import 'wave_measurement_projection.dart';
import 'wave_propagation.dart';

/// Port of `WaveKernel.evaluateSample`.
FieldSample evaluateSample(WaveParameters parameters, double x, double y, double t) {
  var sample = evaluateUndecoheredSample(parameters, x, y, t);
  sample = applyDecoherenceEvent(sample, parameters, x, y, t);
  return applyMeasurementProjections(
    sample,
    parameters.projections,
    parameters.source,
    x,
    y,
    t,
  );
}
