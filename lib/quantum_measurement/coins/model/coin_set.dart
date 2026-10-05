/// CoinSet -?mirrors `js/coins/model/CoinSet.ts`.
///
/// Sampling rule (source):
///   for each active coin i:
///     measuredValues[i] = validValues[ random.nextDouble() < bias ? 0 : 1 ]
///
/// Seed special cases: seed == 0 -?all validValues[0]; seed == 1 -?all validValues[1].
library;

import '../../common/experiment_measurement_state.dart';
import '../../common/qm_random.dart';
import '../../common/system_type.dart';
import 'coin_states.dart';

const measurementPreparationTime = 1.0;

const multiCoinExperimentQuantities = [10, 100, 10000];
const maxCoins = 10000;

class CoinSet {
  CoinSet({
    required this.coinType,
    required this.maxNumberOfActiveCoins,
    required int initialNumberOfActiveCoins,
    required String initialFaceState,
    required double initialBias,
    QmRandom? random,
    bool classicalStartHidden = false,
  })  : _random = random ?? SystemQmRandom(),
        bias = initialBias.clamp(0.0, 1.0),
        numberOfCoins = initialNumberOfActiveCoins,
        initiallyHidden = coinType == SystemType.quantum || classicalStartHidden {
    if (coinType == SystemType.classical) {
      validValues = List<String>.from(classicalCoinStateValues);
      measurementState = initiallyHidden
          ? ExperimentMeasurementState.measuredAndHidden
          : ExperimentMeasurementState.revealed;
    } else {
      validValues = List<String>.from(quantumMeasuredStateValues);
      measurementState = ExperimentMeasurementState.readyToBeMeasured;
      initiallyHidden = true;
    }

    final idx = validValues.indexOf(initialFaceState);
    _initialSeed = (idx >= 0 ? idx : 0).toDouble();
    seed = _initialSeed;
    measuredValues = List<String>.filled(maxNumberOfActiveCoins, validValues[idx >= 0 ? idx : 0]);
    _applySeed();
  }

  final SystemType coinType;
  final int maxNumberOfActiveCoins;
  final QmRandom _random;

  late final List<String> validValues;
  late final double _initialSeed;
  late final int _initialNumberOfCoins = numberOfCoins;

  double bias;
  late double seed;
  int numberOfCoins;
  bool initiallyHidden;
  late ExperimentMeasurementState measurementState;
  late List<String> measuredValues;

  /// Simulated preparation timer remaining (seconds). Null = not preparing.
  double? preparingRemainingSeconds;

  int measuredDataGeneration = 0;

  void _applySeed() {
    if (seed == 0.0 || seed == 1.0) {
      final valueToSet = validValues[seed.toInt()];
      for (var i = 0; i < maxNumberOfActiveCoins; i++) {
        measuredValues[i] = valueToSet;
      }
    } else {
      final rng = SeededQmRandom.fromUnitInterval(seed);
      final count = numberOfCoins;
      for (var i = 0; i < count; i++) {
        final valueSetIndex = rng.nextDouble() < bias ? 0 : 1;
        measuredValues[i] = validValues[valueSetIndex];
      }
    }
    measuredDataGeneration++;
  }

  void generateNewRandomMeasurementValues() {
    seed = _random.nextNonZeroDouble();
    _applySeed();
  }

  /// Flip / Reprepare. Optionally auto-reveal when preparation completes.
  void prepare({bool revealWhenPrepared = false, bool skipAnimation = false}) {
    if (skipAnimation) {
      prepareNow();
      if (revealWhenPrepared) reveal();
      return;
    }
    measurementState = ExperimentMeasurementState.preparingToBeMeasured;
    preparingRemainingSeconds = measurementPreparationTime;
    _pendingRevealWhenPrepared = revealWhenPrepared;
  }

  bool _pendingRevealWhenPrepared = false;

  /// Advance preparation timer. Call from a clock or tests.
  void stepPreparation(double dt) {
    final remaining = preparingRemainingSeconds;
    if (remaining == null) return;
    final next = remaining - dt;
    if (next <= 0) {
      preparingRemainingSeconds = null;
      prepareNow();
      if (_pendingRevealWhenPrepared) {
        reveal();
      }
      _pendingRevealWhenPrepared = false;
    } else {
      preparingRemainingSeconds = next;
    }
  }

  void prepareNow() {
    preparingRemainingSeconds = null;
    if (coinType == SystemType.classical) {
      generateNewRandomMeasurementValues();
      measurementState = ExperimentMeasurementState.measuredAndHidden;
    } else {
      measurementState = ExperimentMeasurementState.readyToBeMeasured;
    }
  }

  void reveal() {
    if (measurementState == ExperimentMeasurementState.readyToBeMeasured) {
      assert(coinType == SystemType.quantum);
      generateNewRandomMeasurementValues();
    }
    measurementState = ExperimentMeasurementState.revealed;
  }

  void hide() {
    measurementState = ExperimentMeasurementState.measuredAndHidden;
  }

  /// Measure: if readyToBeMeasured, sample then reveal; else return current values.
  ({int length, List<String> measuredValues}) measure() {
    if (measurementState == ExperimentMeasurementState.readyToBeMeasured) {
      generateNewRandomMeasurementValues();
      measurementState = ExperimentMeasurementState.revealed;
    }
    return (
      length: numberOfCoins,
      measuredValues: List<String>.from(measuredValues.take(numberOfCoins)),
    );
  }

  void setMeasurementValuesImmediate(String value) {
    preparingRemainingSeconds = null;
    final valueIndex = validValues.indexOf(value);
    assert(valueIndex == 0 || valueIndex == 1);
    seed = valueIndex.toDouble();
    _applySeed();
    if (coinType == SystemType.classical) {
      measurementState = initiallyHidden
          ? ExperimentMeasurementState.measuredAndHidden
          : ExperimentMeasurementState.revealed;
    } else {
      measurementState = ExperimentMeasurementState.readyToBeMeasured;
    }
  }

  void reset() {
    preparingRemainingSeconds = null;
    numberOfCoins = _initialNumberOfCoins;
    seed = _initialSeed;
    _applySeed();
    if (coinType == SystemType.classical) {
      measurementState = initiallyHidden
          ? ExperimentMeasurementState.measuredAndHidden
          : ExperimentMeasurementState.revealed;
    } else {
      measurementState = ExperimentMeasurementState.readyToBeMeasured;
    }
  }

  /// Active-slice outcome counts for statistics tests.
  Map<String, int> outcomeCounts() {
    final counts = <String, int>{for (final v in validValues) v: 0};
    for (var i = 0; i < numberOfCoins; i++) {
      counts[measuredValues[i]] = (counts[measuredValues[i]] ?? 0) + 1;
    }
    return counts;
  }
}

/// Single coin = CoinSet with n=1 -?mirrors `Coin.ts`.
class Coin extends CoinSet {
  Coin({
    required super.coinType,
    required String initialState,
    required super.initialBias,
    super.random,
    super.classicalStartHidden,
  }) : super(
          maxNumberOfActiveCoins: 1,
          initialNumberOfActiveCoins: 1,
          initialFaceState: initialState,
        );

  String get measuredValue => measuredValues[0];
}
