// Copyright 2024-2026, University of Colorado Boulder
/// English UI strings for Quantum Coin Toss (coins screen subset).
library;

abstract final class QuantumMeasurementStrings {
  static const String reset = 'Reset All';

  static const String classicalCoin = 'Classical Coin';
  static const String quantumCoinQuoted = "Quantum 'Coin'";
  static const String classical = 'Classical';
  static const String quantum = 'Quantum';

  static const String coin = 'Coin';
  static const String preparedState = 'Prepared State';
  static const String itemToPreparePattern = '{{item}} to Prepare';

  static const String singleCoinMeasurements = 'Single Coin Measurements';
  static const String multipleCoinMeasurements = 'Multiple Coin Measurements';

  static const String newCoin = 'New Coin';

  static const String reveal = 'Reveal';
  static const String hide = 'Hide';
  static const String observe = 'Observe';
  static const String flip = 'Flip';
  static const String reprepare = 'Reprepare';
  static const String flipAndReveal = 'Flip and Reveal';
  static const String reprepareAndReveal = 'Reprepare and Observe';

  static const String identicalCoins = 'Identical Coins';
  static const String coinBias = 'Coin Bias (State)';
  static const String initialOrientation = 'Initial Orientation';
  static const String basisState = 'Basis State';

  static const String probabilityPrefix = 'P';
  static const String probabilityLabel = 'Probability';
  static const String spinUpSymbol = '↑';
  static const String spinDownSymbol = '↓';

  static const String heads = 'Heads';
  static const String tails = 'Tails';
  static const String up = 'Up';
  static const String down = 'Down';
  static const String superposition = 'Superposition';

  static String itemToPrepare(String item) =>
      itemToPreparePattern.replaceAll('{{item}}', item);

  static String numberOfCoinsLabel(int n) => 'N = $n';

  static String probabilityOf(String symbol) => 'P($symbol)';
}
