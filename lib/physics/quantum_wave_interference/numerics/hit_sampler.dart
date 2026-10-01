import '../constants/qwi_constants.dart';
import '../domain/hit.dart';
import '../domain/qwi_random.dart';
import 'fraunhofer_solver.dart';

/// Experiment rejection sampling (`SceneModel.generateHitPosition`).
class ExperimentHitSampler {
  ExperimentHitSampler({required this.random});

  final QwiRandom random;

  /// Returns physical x on screen (meters relative center) after rejection sampling.
  /// Maps to normalized detector x ∈ [-1,1] via halfWidth.
  double samplePhysicalX({
    required double fullScreenHalfWidthM,
    required FraunhoferOptions Function(double positionOnScreenM) intensityOptions,
  }) {
    for (var i = 0; i < QwiConstants.experimentMaxRejectionIterations; i++) {
      final physicalX = (random.nextDouble() - 0.5) * 2 * fullScreenHalfWidthM;
      final intensity = FraunhoferSolver.getExactDetectorIntensity(intensityOptions(physicalX));
      if (random.nextDouble() < intensity) {
        return physicalX;
      }
    }
    return 0;
  }

  DetectorHit sampleHit({
    required double fullScreenHalfWidthM,
    required FraunhoferOptions Function(double positionOnScreenM) intensityOptions,
  }) {
    final physicalX = samplePhysicalX(
      fullScreenHalfWidthM: fullScreenHalfWidthM,
      intensityOptions: intensityOptions,
    );
    final xNorm = fullScreenHalfWidthM == 0 ? 0.0 : physicalX / fullScreenHalfWidthM;
    final y = (random.nextDouble() - 0.5) * 2; // HIT_VERTICAL_EXTENT = 1 → [-1,1]
    return DetectorHit(x: xNorm, y: y, domain: DetectorHitDomain.experiment);
  }
}

/// HI/SP discrete PDF roulette (`BaseSceneModel.generateHitPosition`).
///
/// [distribution] is already max-normalized (PhET). Sampling uses sum of bins then roulette.
class WaveRegionHitSampler {
  WaveRegionHitSampler({required this.random});

  final QwiRandom random;

  /// Returns normalized x ∈ [-1, 1] along detector, matching PhET bin mapping.
  double sampleXFromDistribution(List<double> distribution) {
    if (distribution.isEmpty) {
      return (random.nextDouble() - 0.5) * 2;
    }

    var totalSum = 0.0;
    for (final v in distribution) {
      totalSum += v < 0 ? 0 : v;
    }
    if (totalSum <= 0) {
      return (random.nextDouble() - 0.5) * 2;
    }

    var threshold = random.nextDouble() * totalSum;
    for (var i = 0; i < distribution.length; i++) {
      final bin = distribution[i] < 0 ? 0.0 : distribution[i];
      threshold -= bin;
      if (threshold <= 0) {
        final binWidth = 2 / distribution.length;
        final binCenter = -1 + (i + 0.5) * binWidth;
        return binCenter + (random.nextDouble() - 0.5) * binWidth;
      }
    }
    return 1;
  }

  DetectorHit sampleHit(List<double> distribution) {
    final x = sampleXFromDistribution(distribution);
    final y = random.nextDouble(); // [0, 1] — HIT_VERTICAL_EXTENT
    return DetectorHit(x: x, y: y, domain: DetectorHitDomain.waveRegion);
  }
}
