import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/quantum_coin_toss/coins/model/coin_set.dart';
import 'package:kratos/quantum_coin_toss/common/model/experiment_measurement_state.dart';
import 'package:kratos/quantum_coin_toss/common/model/system_type.dart';

void main() {
  test('prepareNow generates a new random seed and changes classical faces', () {
    final bias = ValueNotifier(0.5);
    final set = CoinSet(
      coinType: SystemType.classical,
      maxCoins: 100,
      animatedCoins: 100,
      initialState: 'heads',
      biasProperty: bias,
    );

    // Enter measurement with prepared heads → all heads
    set.setMeasurementValuesImmediate('heads');
    expect(set.measuredValues.take(10).every((v) => v == 'heads'), isTrue);

    set.prepareNow();
    expect(
      set.measurementStateProperty.value,
      ExperimentMeasurementState.measuredAndHidden,
    );
    // After flip prep, seed is random → not all heads at 0.5 bias
    final mixed = set.measuredValues.take(100).toSet();
    expect(mixed.length, greaterThan(1));

    final first = List<String>.from(set.measuredValues.take(20));
    set.prepareNow();
    final second = List<String>.from(set.measuredValues.take(20));
    expect(first, isNot(equals(second)));

    set.dispose();
    bias.dispose();
  });

  test('quantum reveal collapses from readyToBeMeasured', () {
    final bias = ValueNotifier(0.5);
    final set = CoinSet(
      coinType: SystemType.quantum,
      maxCoins: 100,
      animatedCoins: 100,
      initialState: 'up',
      biasProperty: bias,
    );

    set.setMeasurementValuesImmediate('up');
    expect(
      set.measurementStateProperty.value,
      ExperimentMeasurementState.readyToBeMeasured,
    );

    set.reveal();
    expect(
      set.measurementStateProperty.value,
      ExperimentMeasurementState.revealed,
    );
    expect(set.measuredValues.take(100).toSet().length, greaterThan(1));

    set.dispose();
    bias.dispose();
  });

  test('reset restores coin count to 100', () {
    final bias = ValueNotifier(0.5);
    final set = CoinSet(
      coinType: SystemType.classical,
      maxCoins: 10000,
      animatedCoins: 100,
      initialState: 'heads',
      biasProperty: bias,
    );
    set.numberOfCoinsProperty.value = 10000;
    set.reset();
    expect(set.numberOfCoinsProperty.value, 100);
    set.dispose();
    bias.dispose();
  });
}
