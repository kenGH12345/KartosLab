/// Coins screen layout constants — source: CoinsScreenView / CoinsExperimentSceneView.
library;

import 'dart:math' as math;

import 'qm_global_layout_spec.dart';

class QmCoinsLayoutSpec {
  const QmCoinsLayoutSpec();

  /// CoinsScreenView SCENE_POSITION
  static const sceneTranslationX = 0.0;
  static const sceneTranslationY = 75.0;

  /// floor(1024 * 0.38) / ceil(1024 * 0.2)
  double get dividerXDuringPreparation =>
      (qmDesignWidth * 0.38).floorToDouble();
  double get dividerXDuringMeasurement =>
      (qmDesignWidth * 0.2).ceilToDouble();

  /// Start measurement arrow button
  static const startMeasurementButtonCenterY = 245.0;
  static const startMeasurementArrowLength = 60.0;

  /// New coin button gap below prep area
  static const newCoinButtonTopGap = 10.0;

  /// Test boxes
  static const singleCoinTestBoxWidth = 165.0;
  static const singleCoinTestBoxHeight = 145.0;
  static const multiCoinTestBoxSize = 200.0;

  /// Coin radii (InitialCoinStateSelectorNode)
  static const radioButtonCoinRadius = 16.0;
  static const indicatorCoinRadius = 36.0;

  /// CoinExperimentButtonSet BUTTON_WIDTH
  static const experimentButtonWidth = 180.0;

  /// Multi coin HBox spacing
  static const multiCoinAreaSpacing = 30.0;
  static const sectionHeaderSpacing = 20.0;

  /// 10000 coins pixel grid: SIDE_LENGTH = sqrt(MAX_COINS)
  int get pixelGridSideLength => math.sqrt(10000).round();

  /// Prep area centerX = dividerX / 2
  double preparationCenterX(double dividerX) => dividerX / 2;

  /// Measurement centerX = dividerX + (SCENE_WIDTH - dividerX) / 2
  double measurementCenterX(double dividerX) =>
      dividerX + (qmDesignWidth - dividerX) / 2;
}
