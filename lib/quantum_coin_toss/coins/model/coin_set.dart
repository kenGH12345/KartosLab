// Copyright 2024-2026, University of Colorado Boulder
/// CoinSet 建模一组经典或量子硬币
/// 每枚硬币可处于两种状态之一，量子情况下还可处于叠加态
///
/// 对应官方：js/coins/model/CoinSet.ts
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../common/model/experiment_measurement_state.dart';
import '../../common/model/system_type.dart';
import 'classical_coin_states.dart';
import 'quantum_coin_states.dart';

// 准备时间：1秒
const measurementPreparationTime = 1.0;

class CoinSet extends ChangeNotifier {
  final SystemType coinType;
  final int maxCoins;
  final int animatedCoins;

  // 核心属性
  final ValueNotifier<bool> initiallyHiddenProperty;
  final ValueNotifier<ExperimentMeasurementState> measurementStateProperty;
  final ValueNotifier<int> numberOfCoinsProperty;
  final ValueNotifier<double> biasProperty;
  final ValueNotifier<double> seedProperty;

  late final int _initialNumberOfCoins;
  late final double _initialSeed;

  // 有效的测量值列表
  late final List<String> validValues;

  // 最近一次测量的结果数组
  late List<String> measuredValues;

  // 测量数据变化事件
  final ValueNotifier<int> measuredDataChangedNotifier = ValueNotifier(0);

  Timer? _preparingTimer;

  CoinSet({
    required this.coinType,
    required this.maxCoins,
    required this.animatedCoins,
    required String initialState,
    required this.biasProperty,
    bool initiallyHidden = false,
  })  : initiallyHiddenProperty = ValueNotifier(initiallyHidden),
        measurementStateProperty = ValueNotifier(
          ExperimentMeasurementState.measuredAndHidden,
        ),
        numberOfCoinsProperty = ValueNotifier(maxCoins > 1 ? 100 : 1),
        seedProperty = ValueNotifier(0) {
    _initialNumberOfCoins = maxCoins > 1 ? 100 : 1;

    // 根据系统类型设置有效值
    if (coinType == SystemType.classical) {
      validValues = List.from(classicalCoinStateValues);
      measurementStateProperty.value = initiallyHidden
          ? ExperimentMeasurementState.measuredAndHidden
          : ExperimentMeasurementState.revealed;
    } else {
      validValues =
          quantumCoinStateValues.where((s) => s != 'superposition').toList();
      measurementStateProperty.value =
          ExperimentMeasurementState.readyToBeMeasured;
      initiallyHiddenProperty.value = true;
    }

    final initialIndex = validValues.indexOf(initialState);
    final safeIndex = initialIndex >= 0 ? initialIndex : 0;
    _initialSeed = safeIndex.toDouble();
    seedProperty.value = _initialSeed;

    measuredValues = List.filled(maxCoins, validValues[safeIndex]);

    seedProperty.addListener(_onSeedChanged);
    biasProperty.addListener(_onSeedChanged);
    _onSeedChanged();
  }

  void _cancelPreparingTimeout() {
    _preparingTimer?.cancel();
    _preparingTimer = null;
  }

  void _onSeedChanged() {
    final seed = seedProperty.value;
    final bias = biasProperty.value;

    if (seed == 0.0 || seed == 1.0) {
      final valueToSet = validValues[seed.toInt()];
      for (var i = 0; i < maxCoins; i++) {
        measuredValues[i] = valueToSet;
      }
    } else {
      final random = math.Random((seed * 1e9).toInt());
      final count = numberOfCoinsProperty.value;
      for (var i = 0; i < count; i++) {
        final valueSetIndex = random.nextDouble() < bias ? 0 : 1;
        measuredValues[i] = validValues[valueSetIndex];
      }
    }

    measuredDataChangedNotifier.value++;
    notifyListeners();
  }

  void generateNewRandomMeasurementValues() {
    final random = math.Random();
    double newSeed;
    do {
      newSeed = random.nextDouble();
    } while (newSeed == 0.0);
    seedProperty.value = newSeed;
  }

  /// 启动准备流程
  void prepare({bool revealWhenPrepared = false}) {
    _cancelPreparingTimeout();
    measurementStateProperty.value =
        ExperimentMeasurementState.preparingToBeMeasured;

    _preparingTimer = Timer(
      Duration(
        milliseconds: (measurementPreparationTime * 1000).round(),
      ),
      () {
        _preparingTimer = null;
        prepareNow();
        if (revealWhenPrepared) {
          reveal();
        }
      },
    );
  }

  /// 跳过动画，直接完成准备
  void prepareNow() {
    _cancelPreparingTimeout();

    if (coinType == SystemType.classical) {
      generateNewRandomMeasurementValues();
      measurementStateProperty.value =
          ExperimentMeasurementState.measuredAndHidden;
    } else {
      measurementStateProperty.value =
          ExperimentMeasurementState.readyToBeMeasured;
    }
  }

  /// 揭示硬币结果
  void reveal() {
    if (coinType == SystemType.quantum &&
        measurementStateProperty.value ==
            ExperimentMeasurementState.readyToBeMeasured) {
      generateNewRandomMeasurementValues();
    }

    measurementStateProperty.value = ExperimentMeasurementState.revealed;
  }

  /// 测量并返回结果
  Map<String, dynamic> measure() {
    reveal();
    return {
      'length': numberOfCoinsProperty.value,
      'measuredValues': List<String>.from(measuredValues),
    };
  }

  /// 隐藏硬币
  void hide() {
    measurementStateProperty.value =
        ExperimentMeasurementState.measuredAndHidden;
  }

  /// 立即将所有硬币设置为指定值
  void setMeasurementValuesImmediate(String value) {
    _cancelPreparingTimeout();

    final valueIndex = validValues.indexOf(value);
    assert(valueIndex == 0 || valueIndex == 1);
    seedProperty.value = valueIndex.toDouble();

    if (coinType == SystemType.classical) {
      measurementStateProperty.value = initiallyHiddenProperty.value
          ? ExperimentMeasurementState.measuredAndHidden
          : ExperimentMeasurementState.revealed;
    } else {
      measurementStateProperty.value =
          ExperimentMeasurementState.readyToBeMeasured;
    }
  }

  /// 重置
  void reset() {
    _cancelPreparingTimeout();
    numberOfCoinsProperty.value = _initialNumberOfCoins;
    seedProperty.value = _initialSeed;

    if (coinType == SystemType.classical) {
      measurementStateProperty.value = initiallyHiddenProperty.value
          ? ExperimentMeasurementState.measuredAndHidden
          : ExperimentMeasurementState.revealed;
    } else {
      measurementStateProperty.value =
          ExperimentMeasurementState.readyToBeMeasured;
    }
  }

  @override
  void dispose() {
    _cancelPreparingTimeout();
    seedProperty.removeListener(_onSeedChanged);
    biasProperty.removeListener(_onSeedChanged);
    initiallyHiddenProperty.dispose();
    measurementStateProperty.dispose();
    numberOfCoinsProperty.dispose();
    seedProperty.dispose();
    measuredDataChangedNotifier.dispose();
    super.dispose();
  }
}
