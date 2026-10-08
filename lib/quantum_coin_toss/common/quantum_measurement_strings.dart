// Copyright 2024-2026, University of Colorado Boulder
/// Quantum Coin Toss UI strings — Chinese defaults (PHASE 5).
library;

abstract final class QuantumMeasurementStrings {
  static const String reset = '全部重置';

  static const String classicalCoin = '经典硬币';
  static const String quantumCoinQuoted = '量子「硬币」';
  static const String classical = '经典';
  static const String quantum = '量子';

  static const String coin = '硬币';
  static const String preparedState = '制备态';
  static const String itemToPreparePattern = '待制备{{item}}';

  static const String singleCoinMeasurements = '单硬币测量';
  static const String multipleCoinMeasurements = '多硬币测量';

  static const String newCoin = '新硬币';

  static const String reveal = '揭示';
  static const String hide = '隐藏';
  static const String observe = '观测';
  static const String flip = '翻转';
  static const String reprepare = '重新制备';
  static const String flipAndReveal = '翻转并揭示';
  static const String reprepareAndReveal = '重新制备并观测';

  static const String identicalCoins = '相同硬币';
  static const String coinBias = '硬币偏置（态）';
  static const String initialOrientation = '初始取向';
  static const String basisState = '基态';

  static const String probabilityPrefix = 'P';
  static const String probabilityLabel = '概率';
  static const String spinUpSymbol = '↑';
  static const String spinDownSymbol = '↓';

  static const String heads = '正面';
  static const String tails = '反面';
  static const String up = '上';
  static const String down = '下';
  static const String superposition = '叠加态';

  static String itemToPrepare(String item) =>
      itemToPreparePattern.replaceAll('{{item}}', item);

  static String numberOfCoinsLabel(int n) => 'N = $n';

  static String probabilityOf(String symbol) => 'P($symbol)';
}
