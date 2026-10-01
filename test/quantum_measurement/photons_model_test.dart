import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/quantum_measurement/common/qm_random.dart';
import 'package:kratos/quantum_measurement/common/system_type.dart';
import 'package:kratos/quantum_measurement/photons/model/photons_model.dart';

void main() {
  group('Photon polarization probabilities', () {
    test('vertical → P(reflect)=1, expectation=+1', () {
      expect(probabilityOfReflection(90), closeTo(1.0, 1e-12));
      expect(probabilityOfTransmission(90), closeTo(0.0, 1e-12));
      expect(
        normalizedExpectationValue(preset: PolarizationPreset.vertical),
        1.0,
      );
    });

    test('horizontal → P(reflect)=0, expectation=-1', () {
      expect(probabilityOfReflection(0), closeTo(0.0, 1e-12));
      expect(
        normalizedExpectationValue(preset: PolarizationPreset.horizontal),
        -1.0,
      );
    });

    test('45° → P=0.5, expectation=0', () {
      expect(probabilityOfReflection(45), closeTo(0.5, 1e-12));
      expect(
        normalizedExpectationValue(preset: PolarizationPreset.fortyFiveDegrees),
        0.0,
      );
    });

    test('unpolarized expectation is null; P≈0.5', () {
      expect(
        normalizedExpectationValue(preset: PolarizationPreset.unpolarized),
        isNull,
      );
      final scene = PhotonsExperimentSceneModel(
        emissionMode: PhotonExperimentMode.singlePhoton,
        random: SeededQmRandom(1),
      );
      scene.preset = PolarizationPreset.unpolarized;
      expect(scene.pVertical, 0.5);
    });

    test('custom angle matches Malus / expectation formulas', () {
      const angle = 30.0;
      final pR = probabilityOfReflection(angle);
      final exp = normalizedExpectationValue(
        preset: PolarizationPreset.custom,
        customAngleDegrees: angle,
      )!;
      // expectation = 1 - 2 cos² = -(2cos² - 1) = -cos(2θ) ... also = 2sin²-1 = 2pR-1
      expect(exp, closeTo(2 * pR - 1, 1e-12));
    });

    test('P(V)+P(H)=1', () {
      final scene = PhotonsExperimentSceneModel(
        emissionMode: PhotonExperimentMode.singlePhoton,
      );
      for (final p in PolarizationPreset.values) {
        if (p == PolarizationPreset.unpolarized) continue;
        scene.preset = p;
        expect(scene.pVertical + scene.pHorizontal, closeTo(1.0, 1e-12));
      }
    });
  });

  group('Classical vs Quantum behavior', () {
    test('classical samples one path; counts increment', () {
      final scene = PhotonsExperimentSceneModel(
        emissionMode: PhotonExperimentMode.singlePhoton,
        random: SeededQmRandom(42),
      );
      scene.photonBehaviorMode = SystemType.classical;
      scene.preset = PolarizationPreset.fortyFiveDegrees;
      final outcome = scene.emitAndResolveOne();
      expect(
        outcome == PhotonPathOutcome.vertical ||
            outcome == PhotonPathOutcome.horizontal,
        isTrue,
      );
      expect(scene.verticalDetectionCount + scene.horizontalDetectionCount, 1);
    });

    test('quantum emit returns split semantic but still samples at detection', () {
      final scene = PhotonsExperimentSceneModel(
        emissionMode: PhotonExperimentMode.singlePhoton,
        random: SeededQmRandom(42),
      );
      scene.photonBehaviorMode = SystemType.quantum;
      scene.preset = PolarizationPreset.vertical;
      expect(scene.emitAndResolveOne(), PhotonPathOutcome.split);
      expect(scene.verticalDetectionCount, 1);
    });
  });

  group('Photon determinism', () {
    test('same seed ⇒ same detection sequence', () {
      List<int> run(int seed) {
        final scene = PhotonsExperimentSceneModel(
          emissionMode: PhotonExperimentMode.manyPhotons,
          random: SeededQmRandom(seed),
        );
        scene.preset = PolarizationPreset.fortyFiveDegrees;
        for (var i = 0; i < 50; i++) {
          scene.emitAndResolveOne();
        }
        return [scene.verticalDetectionCount, scene.horizontalDetectionCount];
      }

      expect(run(77), run(77));
      expect(run(77), isNot(run(78)));
    });
  });

  group('PhotonsModel', () {
    test('two scenes independent; reset restores defaults', () {
      final model = PhotonsModel(random: SeededQmRandom(9));
      model.singlePhotonScene.preset = PolarizationPreset.vertical;
      model.manyPhotonsScene.preset = PolarizationPreset.horizontal;
      expect(model.singlePhotonScene.preset, PolarizationPreset.vertical);
      expect(model.manyPhotonsScene.preset, PolarizationPreset.horizontal);
      model.reset();
      expect(model.experimentMode, PhotonExperimentMode.singlePhoton);
      expect(model.singlePhotonScene.preset, PolarizationPreset.fortyFiveDegrees);
    });
  });
}
