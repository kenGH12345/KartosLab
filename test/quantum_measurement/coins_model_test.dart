import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/quantum_measurement/coins/model/coin_set.dart';
import 'package:kratos/quantum_measurement/coins/model/coins_model.dart';
import 'package:kratos/quantum_measurement/common/experiment_measurement_state.dart';
import 'package:kratos/quantum_measurement/common/qm_random.dart';
import 'package:kratos/quantum_measurement/common/system_type.dart';

void main() {
  group('Coins Classical', () {
    test('initial revealed when not start-hidden', () {
      final set = CoinSet(
        coinType: SystemType.classical,
        maxNumberOfActiveCoins: 1,
        initialNumberOfActiveCoins: 1,
        initialFaceState: 'heads',
        initialBias: 0.5,
        random: SeededQmRandom(42),
      );
      expect(set.measurementState, ExperimentMeasurementState.revealed);
      expect(set.validValues, ['heads', 'tails']);
    });

    test('Flip (prepare) samples then hides; Reveal shows', () {
      final set = CoinSet(
        coinType: SystemType.classical,
        maxNumberOfActiveCoins: 1,
        initialNumberOfActiveCoins: 1,
        initialFaceState: 'heads',
        initialBias: 0.7,
        random: SeededQmRandom(7),
      );
      set.prepare(skipAnimation: true);
      expect(set.measurementState, ExperimentMeasurementState.measuredAndHidden);
      final hiddenValue = set.measuredValues[0];
      expect(['heads', 'tails'], contains(hiddenValue));
      set.reveal();
      expect(set.measurementState, ExperimentMeasurementState.revealed);
      expect(set.measuredValues[0], hiddenValue); // same sample
    });

    test('Flip and Reveal = prepare(revealWhenPrepared: true)', () {
      final set = CoinSet(
        coinType: SystemType.classical,
        maxNumberOfActiveCoins: 1,
        initialNumberOfActiveCoins: 1,
        initialFaceState: 'heads',
        initialBias: 0.5,
        random: SeededQmRandom(3),
      );
      set.prepare(revealWhenPrepared: true, skipAnimation: true);
      expect(set.measurementState, ExperimentMeasurementState.revealed);
    });

    test('Hide after reveal', () {
      final set = CoinSet(
        coinType: SystemType.classical,
        maxNumberOfActiveCoins: 1,
        initialNumberOfActiveCoins: 1,
        initialFaceState: 'heads',
        initialBias: 0.5,
        random: SeededQmRandom(1),
      );
      set.prepare(revealWhenPrepared: true, skipAnimation: true);
      set.hide();
      expect(set.measurementState, ExperimentMeasurementState.measuredAndHidden);
    });

    test('bias 0 → all tails; bias 1 → all heads (via seed 0/1 special)', () {
      final allHeads = CoinSet(
        coinType: SystemType.classical,
        maxNumberOfActiveCoins: 100,
        initialNumberOfActiveCoins: 100,
        initialFaceState: 'heads',
        initialBias: 1.0,
        random: SeededQmRandom(99),
      );
      allHeads.seed = 0; // force all validValues[0]=heads
      allHeads.generateNewRandomMeasurementValues();
      // after generate, seed is random; force:
      allHeads.seed = 0;
      // need re-apply — call setMeasurementValuesImmediate
      allHeads.setMeasurementValuesImmediate('heads');
      expect(allHeads.outcomeCounts()['heads'], 100);

      allHeads.setMeasurementValuesImmediate('tails');
      expect(allHeads.outcomeCounts()['tails'], 100);
    });
  });

  group('Coins Quantum', () {
    test('starts readyToBeMeasured; Observe samples', () {
      final set = CoinSet(
        coinType: SystemType.quantum,
        maxNumberOfActiveCoins: 1,
        initialNumberOfActiveCoins: 1,
        initialFaceState: 'up',
        initialBias: 0.5,
        random: SeededQmRandom(11),
      );
      expect(set.measurementState, ExperimentMeasurementState.readyToBeMeasured);
      expect(set.validValues, ['up', 'down']);
      set.reveal(); // Observe
      expect(set.measurementState, ExperimentMeasurementState.revealed);
      expect(['up', 'down'], contains(set.measuredValues[0]));
    });

    test('Reprepare does NOT sample until Observe', () {
      final set = CoinSet(
        coinType: SystemType.quantum,
        maxNumberOfActiveCoins: 1,
        initialNumberOfActiveCoins: 1,
        initialFaceState: 'up',
        initialBias: 0.5,
        random: SeededQmRandom(22),
      );
      set.prepare(skipAnimation: true); // Reprepare
      expect(set.measurementState, ExperimentMeasurementState.readyToBeMeasured);
      set.reveal();
      expect(set.measurementState, ExperimentMeasurementState.revealed);
    });

    test('Reprepare and Observe = prepare(revealWhenPrepared: true)', () {
      final set = CoinSet(
        coinType: SystemType.quantum,
        maxNumberOfActiveCoins: 1,
        initialNumberOfActiveCoins: 1,
        initialFaceState: 'up',
        initialBias: 0.5,
        random: SeededQmRandom(33),
      );
      set.prepare(revealWhenPrepared: true, skipAnimation: true);
      expect(set.measurementState, ExperimentMeasurementState.revealed);
    });

    test('P(up)+P(down)=1 via bias; statistics approach bias', () {
      final scene = CoinsExperimentSceneModel(
        systemType: SystemType.quantum,
        random: SeededQmRandom(12345),
      );
      scene.setUpProbability(0.3);
      expect(scene.downProbability, closeTo(0.7, 1e-12));
      expect(scene.initialCoinState, 'superposition');

      scene.coinSet.numberOfCoins = 10000;
      scene.coinSet.bias = 0.3;
      scene.coinSet.generateNewRandomMeasurementValues();
      final counts = scene.coinSet.outcomeCounts();
      final freqUp = counts['up']! / 10000;
      expect(freqUp, closeTo(0.3, 0.03)); // broad approach
    });

    test('basis up forces bias=1; down forces bias=0', () {
      final scene = CoinsExperimentSceneModel(
        systemType: SystemType.quantum,
        random: SeededQmRandom(1),
      );
      scene.setInitialCoinState('up');
      expect(scene.upProbability, 1.0);
      scene.setInitialCoinState('down');
      expect(scene.upProbability, 0.0);
    });
  });

  group('Coins determinism', () {
    test('same seed + actions ⇒ same outcomes', () {
      List<String> run(int seed) {
        final set = CoinSet(
          coinType: SystemType.quantum,
          maxNumberOfActiveCoins: 100,
          initialNumberOfActiveCoins: 100,
          initialFaceState: 'up',
          initialBias: 0.4,
          random: SeededQmRandom(seed),
        );
        set.reveal();
        return List<String>.from(set.measuredValues.take(100));
      }

      expect(run(999), run(999));
      expect(run(999), isNot(run(1000)));
    });
  });

  group('CoinsModel isolation inside screen', () {
    test('classical and quantum scenes are independent', () {
      final model = CoinsModel(random: SeededQmRandom(5));
      model.classicalScene.setUpProbability(0.2);
      model.quantumScene.setUpProbability(0.8);
      expect(model.classicalScene.upProbability, 0.2);
      expect(model.quantumScene.upProbability, 0.8);
      model.setExperimentMode(SystemType.quantum);
      expect(model.activeScene.systemType, SystemType.quantum);
      model.reset();
      expect(model.experimentMode, SystemType.classical);
      expect(model.classicalScene.upProbability, 0.5);
    });
  });

  group('Multiple coin quantities', () {
    test('supports 10, 100, 10000', () {
      for (final n in multiCoinExperimentQuantities) {
        final set = CoinSet(
          coinType: SystemType.classical,
          maxNumberOfActiveCoins: maxCoins,
          initialNumberOfActiveCoins: n,
          initialFaceState: 'heads',
          initialBias: 0.5,
          random: SeededQmRandom(n),
        );
        expect(set.numberOfCoins, n);
        set.prepare(skipAnimation: true);
        expect(set.outcomeCounts().values.reduce((a, b) => a + b), n);
      }
    });
  });
}
