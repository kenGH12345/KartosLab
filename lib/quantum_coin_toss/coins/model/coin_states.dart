// Copyright 2025, University of Colorado Boulder
/// CoinStates 是表示经典或量子硬币面可能状态的类型
///
/// 对应官方：js/coins/model/CoinStates.ts
library;


import 'classical_coin_states.dart';
import 'quantum_coin_states.dart';

// 合并经典硬币状态值和量子硬币状态值
const coinStateValues = [
  ...classicalCoinStateValues,
  ...quantumCoinStateValues,
];

typedef CoinStates = String; // 'heads' | 'tails' | 'up' | 'down' | 'superposition'
