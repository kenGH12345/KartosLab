// Copyright 2024-2026, University of Colorado Boulder
/// CoinsExperimentSceneModel 是 Coins 实验场景的模型
/// 包含单硬币和多硬币实验
///
/// 对应官方：js/coins/model/CoinsExperimentSceneModel.ts
library;


import 'package:flutter/foundation.dart';
import '../../common/model/experiment_measurement_state.dart';
import '../../common/model/system_type.dart';
import 'coin.dart';
import 'coin_set.dart';

// 多硬币实验支持的数量
const multiCoinExperimentQuantities = [10, 100, 10000];

// 动画中使用的数量（排除 10000）
const multiCoinAnimationQuantities = [10, 100];

// 所有实验中硬币的最大数量
const maxCoins = 10000;

class CoinsExperimentSceneModel extends ChangeNotifier {
  final SystemType systemType;
  
  // 核心属性
  final ValueNotifier<bool> activeProperty;
  final ValueNotifier<bool> preparingExperimentProperty;
  final ValueNotifier<String> initialCoinStateProperty;
  final ValueNotifier<double> upProbabilityProperty;
  late final ValueNotifier<double> downProbabilityProperty;
  
  // 单硬币和多硬币对象
  late final Coin singleCoin;
  late final CoinSet coinSet;

  CoinsExperimentSceneModel({
    this.systemType = SystemType.classical,
    bool initiallyActive = false,
    double initialBias = 0.5,
  })  : activeProperty = ValueNotifier(initiallyActive),
        preparingExperimentProperty = ValueNotifier(true),
        upProbabilityProperty = ValueNotifier(initialBias),
        initialCoinStateProperty = ValueNotifier(
          systemType == SystemType.classical ? 'heads' : 'up',
        ) {
    
    // 下概率 = 1 - 上概率
    downProbabilityProperty = ValueNotifier(1.0 - initialBias);
    upProbabilityProperty.addListener(() {
      downProbabilityProperty.value = 1.0 - upProbabilityProperty.value;
    });
    
    // 创建单硬币和硬币集
    final initialState = systemType == SystemType.classical ? 'heads' : 'up';
    
    singleCoin = Coin(
      coinType: systemType,
      initialState: initialState,
      biasProperty: upProbabilityProperty,
    );
    
    coinSet = CoinSet(
      coinType: systemType,
      maxCoins: maxCoins,
      animatedCoins: 100,
      initialState: initialState,
      biasProperty: upProbabilityProperty,
    );
    
    // 监听准备阶段切换
    preparingExperimentProperty.addListener(_onPreparingExperimentChanged);
    
    // 量子系统：双向同步 initialCoinState 和 upProbability
    if (systemType == SystemType.quantum) {
      initialCoinStateProperty.addListener(_onInitialCoinStateChanged);
      upProbabilityProperty.addListener(_onUpProbabilityChanged);
    }
    
    // 经典系统：监听隐藏状态
    if (systemType == SystemType.classical) {
      singleCoin.initiallyHiddenProperty.addListener(_onInitiallyHiddenChanged);
      coinSet.initiallyHiddenProperty.addListener(_onInitiallyHiddenChanged);
    }
  }

  void _onPreparingExperimentChanged() {
    if (preparingExperimentProperty.value) {
      // 切换到准备阶段
      singleCoin.prepareNow();
      coinSet.prepareNow();
      
      // 经典系统：如果不是初始隐藏，立即揭示硬币
      if (systemType == SystemType.classical && !coinSet.initiallyHiddenProperty.value) {
        singleCoin.reveal();
        coinSet.reveal();
      }
    } else {
      // 切换到测量阶段
      // 量子叠加态 → 用 'up' 代替
      final initialState = (initialCoinStateProperty.value == 'superposition')
          ? 'up'
          : initialCoinStateProperty.value;
      
      singleCoin.setMeasurementValuesImmediate(initialState);
      coinSet.setMeasurementValuesImmediate(initialState);
    }
  }

  void _onInitialCoinStateChanged() {
    final state = initialCoinStateProperty.value;
    if (state != 'superposition') {
      upProbabilityProperty.value = state == 'up' ? 1.0 : 0.0;
    }
  }

  void _onUpProbabilityChanged() {
    final bias = upProbabilityProperty.value;
    if (bias != 0.0 && bias != 1.0) {
      initialCoinStateProperty.value = 'superposition';
    } else {
      initialCoinStateProperty.value = bias == 1.0 ? 'up' : 'down';
    }
  }

  void _onInitiallyHiddenChanged() {
    if (preparingExperimentProperty.value) {
      final measurementState = singleCoin.measurementStateProperty.value;
      final initiallyHidden = singleCoin.initiallyHiddenProperty.value;
      
      if (initiallyHidden && measurementState == ExperimentMeasurementState.revealed) {
        singleCoin.hide();
        coinSet.hide();
      } else if (measurementState == ExperimentMeasurementState.measuredAndHidden || 
                 measurementState == ExperimentMeasurementState.readyToBeMeasured) {
        singleCoin.reveal();
        coinSet.reveal();
      }
    }
  }

  void reset() {
    preparingExperimentProperty.value = true;
    initialCoinStateProperty.value = systemType == SystemType.classical ? 'heads' : 'up';
    upProbabilityProperty.value = 0.5;
    singleCoin.reset();
    coinSet.reset();
  }

  @override
  void dispose() {
    preparingExperimentProperty.removeListener(_onPreparingExperimentChanged);
    if (systemType == SystemType.quantum) {
      initialCoinStateProperty.removeListener(_onInitialCoinStateChanged);
      upProbabilityProperty.removeListener(_onUpProbabilityChanged);
    }
    if (systemType == SystemType.classical) {
      singleCoin.initiallyHiddenProperty.removeListener(_onInitiallyHiddenChanged);
      coinSet.initiallyHiddenProperty.removeListener(_onInitiallyHiddenChanged);
    }
    
    activeProperty.dispose();
    preparingExperimentProperty.dispose();
    initialCoinStateProperty.dispose();
    upProbabilityProperty.dispose();
    downProbabilityProperty.dispose();
    singleCoin.dispose();
    coinSet.dispose();
    super.dispose();
  }
}
