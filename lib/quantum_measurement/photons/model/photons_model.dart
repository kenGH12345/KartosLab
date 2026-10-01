/// Photon polarization + PBS math — mirrors Laser + PolarizingBeamSplitter.
library;

import 'dart:math' as math;

import '../../common/qm_random.dart';
import '../../common/system_type.dart';

enum PolarizationPreset {
  vertical,
  horizontal,
  fortyFiveDegrees,
  unpolarized,
  custom,
}

enum PhotonExperimentMode {
  singlePhoton,
  manyPhotons,
}

/// Malus-law reflection probability at PBS.
/// Source: `probabilityOfReflection = 1 - cos²(θ)` with θ in radians from
/// polarization angle (degrees in Laser: H=0, V=90, 45=45).
///
/// Reflect path → vertical detector (UP).
/// Transmit path → horizontal detector (RIGHT then mirror).
double probabilityOfReflection(double polarizationAngleDegrees) {
  final radians = polarizationAngleDegrees * math.pi / 180.0;
  return 1.0 - math.pow(math.cos(radians), 2).toDouble();
}

double probabilityOfTransmission(double polarizationAngleDegrees) =>
    1.0 - probabilityOfReflection(polarizationAngleDegrees);

/// Normalized expectation ∈ [-1, 1], or null if unpolarized.
/// Source formula for custom: `1 - 2 * cos²(θ)`.
double? normalizedExpectationValue({
  required PolarizationPreset preset,
  double customAngleDegrees = 45,
}) {
  switch (preset) {
    case PolarizationPreset.vertical:
      return 1.0;
    case PolarizationPreset.horizontal:
      return -1.0;
    case PolarizationPreset.fortyFiveDegrees:
      return 0.0;
    case PolarizationPreset.unpolarized:
      return null;
    case PolarizationPreset.custom:
      final radians = customAngleDegrees * math.pi / 180.0;
      return 1.0 - 2.0 * math.pow(math.cos(radians), 2).toDouble();
  }
}

double? polarizationAngleDegrees({
  required PolarizationPreset preset,
  double customAngleDegrees = 45,
  QmRandom? randomForUnpolarized,
}) {
  switch (preset) {
    case PolarizationPreset.vertical:
      return 90;
    case PolarizationPreset.horizontal:
      return 0;
    case PolarizationPreset.fortyFiveDegrees:
      return 45;
    case PolarizationPreset.custom:
      return customAngleDegrees;
    case PolarizationPreset.unpolarized:
      return (randomForUnpolarized ?? SystemQmRandom()).nextDouble() * 360;
  }
}

enum PhotonPathOutcome { vertical, horizontal, split }

/// Classical: sample one path. Quantum: always split (both paths with weights).
PhotonPathOutcome classicalPathOutcome(
  double polarizationAngleDegrees,
  QmRandom random,
) {
  final pReflect = probabilityOfReflection(polarizationAngleDegrees);
  return random.nextDouble() <= pReflect
      ? PhotonPathOutcome.vertical
      : PhotonPathOutcome.horizontal;
}

class PhotonsExperimentSceneModel {
  PhotonsExperimentSceneModel({
    required this.emissionMode,
    QmRandom? random,
  }) : _random = random ?? SystemQmRandom();

  final PhotonExperimentMode emissionMode;
  final QmRandom _random;

  SystemType photonBehaviorMode = SystemType.classical;
  PolarizationPreset preset = PolarizationPreset.fortyFiveDegrees;
  double customPolarizationAngle = 45; // degrees [0, 90]
  bool isPlaying = true;
  /// TimeSpeed: normal | slow (PhET scenery-phet TimeSpeed).
  bool slowMotion = false;

  int verticalDetectionCount = 0;
  int horizontalDetectionCount = 0;

  double get pVertical {
    if (preset == PolarizationPreset.unpolarized) {
      // Ensemble average of sin²(θ) over uniform polarization = 1/2.
      return 0.5;
    }
    final angle = polarizationAngleDegrees(
      preset: preset,
      customAngleDegrees: customPolarizationAngle,
    )!;
    return probabilityOfReflection(angle);
  }

  double get pHorizontal => 1.0 - pVertical;

  double? get expectation => normalizedExpectationValue(
        preset: preset,
        customAngleDegrees: customPolarizationAngle,
      );

  double get normalizedOutcome {
    final v = verticalDetectionCount.toDouble();
    final h = horizontalDetectionCount.toDouble();
    if (v + h == 0) return 0;
    return (v - h) / (v + h);
  }

  /// Emit and immediately resolve one photon through PBS (model-level abstraction
  /// of emission → interaction → detection without spatial stepping).
  PhotonPathOutcome emitAndResolveOne() {
    final angle = polarizationAngleDegrees(
      preset: preset,
      customAngleDegrees: customPolarizationAngle,
      randomForUnpolarized: _random,
    )!;

    if (photonBehaviorMode == SystemType.classical) {
      final outcome = classicalPathOutcome(angle, _random);
      if (outcome == PhotonPathOutcome.vertical) {
        verticalDetectionCount++;
      } else {
        horizontalDetectionCount++;
      }
      return outcome;
    }

    // Quantum: both paths until detector collapses — model samples at detection
    // using reflection probability (same Malus law).
    final outcome = classicalPathOutcome(angle, _random);
    if (outcome == PhotonPathOutcome.vertical) {
      verticalDetectionCount++;
    } else {
      horizontalDetectionCount++;
    }
    return PhotonPathOutcome.split; // semantic: was in superposition until detect
  }

  void resetDetectionCounts() {
    verticalDetectionCount = 0;
    horizontalDetectionCount = 0;
  }

  void reset() {
    preset = PolarizationPreset.fortyFiveDegrees;
    customPolarizationAngle = 45;
    photonBehaviorMode = SystemType.classical;
    isPlaying = true;
    slowMotion = false;
    resetDetectionCounts();
  }
}

class PhotonsModel {
  PhotonsModel({QmRandom? random})
      : experimentMode = PhotonExperimentMode.singlePhoton {
    final rng = random ?? SystemQmRandom();
    singlePhotonScene = PhotonsExperimentSceneModel(
      emissionMode: PhotonExperimentMode.singlePhoton,
      random: rng,
    );
    manyPhotonsScene = PhotonsExperimentSceneModel(
      emissionMode: PhotonExperimentMode.manyPhotons,
      random: rng,
    );
  }

  PhotonExperimentMode experimentMode;
  late final PhotonsExperimentSceneModel singlePhotonScene;
  late final PhotonsExperimentSceneModel manyPhotonsScene;

  PhotonsExperimentSceneModel get activeScene =>
      experimentMode == PhotonExperimentMode.singlePhoton
          ? singlePhotonScene
          : manyPhotonsScene;

  void reset() {
    experimentMode = PhotonExperimentMode.singlePhoton;
    singlePhotonScene.reset();
    manyPhotonsScene.reset();
  }
}
