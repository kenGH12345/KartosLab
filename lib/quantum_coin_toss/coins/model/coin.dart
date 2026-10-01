// Copyright 2024-2026, University of Colorado Boulder
/// Coin 类是单枚经典或量子硬币的模型
/// 通过继承 CoinSet 并固定数量为 1 实现
///
/// 对应官方：js/coins/model/Coin.ts
library;


import 'package:flutter/foundation.dart';
import 'coin_set.dart';

class Coin extends CoinSet {
  // 最近一次测量的值
  final ValueNotifier<String> measuredValueProperty;

  Coin({
    required super.coinType,
    required super.initialState,
    required super.biasProperty,
    super.initiallyHidden,
  })  : measuredValueProperty = ValueNotifier(initialState),
        super(
          maxCoins: 1,
          animatedCoins: 1,
        ) {
    // 监听测量数据变化，同步更新 measuredValueProperty
    measuredDataChangedNotifier.addListener(() {
      measuredValueProperty.value = measuredValues[0];
    });
  }

  @override
  void dispose() {
    measuredValueProperty.dispose();
    super.dispose();
  }
}
