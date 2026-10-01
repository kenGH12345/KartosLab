import '../domain/probe.dart';
import '../domain/qwi_random.dart';
import 'complex.dart';
import 'field_sample.dart';
import 'wave_kernel.dart';
import 'wave_kernel_types.dart';

/// Probe probability ∫_circle |ψ|² / ∫_all from grid samples (PhET `computeDetectorProbability`).
class ProbeSolver {
  const ProbeSolver();

  double computeProbability({
    required WaveParameters parameters,
    required double time,
    required double regionWidth,
    required double regionHeight,
    required int gridWidth,
    required int gridHeight,
    required DetectorProbe probe,
    Complex Function(int gx, int gy)? amplitudeAt,
  }) {
    var detectorSum = 0.0;
    var totalSum = 0.0;

    final cx = probe.normalizedX * gridWidth;
    final cy = probe.normalizedY * gridHeight;
    final r2 = (probe.radius * gridWidth) * (probe.radius * gridWidth);

    for (var gy = 0; gy < gridHeight; gy++) {
      for (var gx = 0; gx < gridWidth; gx++) {
        late final double density;
        if (amplitudeAt != null) {
          final c = amplitudeAt(gx, gy);
          density = c.magnitudeSquared;
        } else {
          final x = (gx + 0.5) / gridWidth * regionWidth;
          final y = (gy + 0.5) / gridHeight * regionHeight - regionHeight / 2;
          density = computeSampleIntensity(evaluateSample(parameters, x, y, time));
        }
        totalSum += density;
        final dx = gx - cx;
        final dy = gy - cy;
        if (dx * dx + dy * dy <= r2) {
          detectorSum += density;
        }
      }
    }

    return totalSum > 0 ? detectorSum / totalSum : 0;
  }

  /// Bernoulli sample against [probability].
  bool detect({required QwiRandom random, required double probability}) {
    return random.nextDouble() < probability;
  }
}
