/// Classical Coins experiment scene — layout from CoinsComposer / LayoutSpec.
library;

import 'package:flutter/material.dart';

import 'package:kratos/quantum_coin_toss/common/quantum_measurement_colors.dart';

import '../../common/experiment_measurement_state.dart';
import '../../common/system_type.dart';
import '../../layout/qm_coins_layout_spec.dart';
import '../composer/coins_composer.dart';
import '../components/classical_coin_display.dart';
import '../components/coin_bias_controls.dart';
import '../components/coin_controls.dart';
import '../components/coin_count_selector.dart';
import '../components/coin_result_display.dart';
import '../components/coins_scene_primitives.dart';
import '../components/multi_coin_display.dart';
import '../model/coins_model.dart';
import 'package:kratos/quantum_measurement/qm_strings.dart';

class ClassicalCoinsScene extends StatefulWidget {
  const ClassicalCoinsScene({
    super.key,
    required this.scene,
    required this.geometry,
    required this.onChanged,
  });

  final CoinsExperimentSceneModel scene;
  final CoinsLayoutGeometry geometry;
  final VoidCallback onChanged;

  @override
  State<ClassicalCoinsScene> createState() => _ClassicalCoinsSceneState();
}

class _ClassicalCoinsSceneState extends State<ClassicalCoinsScene> {
  late final ValueNotifier<String> _face;

  CoinsExperimentSceneModel get scene => widget.scene;
  CoinsLayoutGeometry get g => widget.geometry;

  @override
  void initState() {
    super.initState();
    _face = ValueNotifier(scene.singleCoin.measuredValue);
  }

  @override
  void didUpdateWidget(covariant ClassicalCoinsScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncFace();
  }

  void _syncFace() {
    final nextFace = scene.singleCoin.measuredValue;
    if (_face.value != nextFace) _face.value = nextFace;
  }

  void _bump() {
    _syncFace();
    widget.onChanged();
  }

  @override
  void dispose() {
    _face.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preparing = scene.preparingExperiment;
    final singleRevealed =
        scene.singleCoin.measurementState == ExperimentMeasurementState.revealed;
    final multiRevealed =
        scene.coinSet.measurementState == ExperimentMeasurementState.revealed;
    final title = preparing ? QmStrings.coinToPrepare : QmStrings.coin;

    // Prep column top — content-driven VBox like CoinExperimentPreparationArea.
    final prepTop = 8.0;
    final prepWidth = preparing ? 300.0 : 180.0;
    final prepLeft = ((g.dividerX - prepWidth) / 2).clamp(8.0, g.dividerX - 8);

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // ── Preparation column ──
        Positioned(
          left: prepLeft,
          top: prepTop,
          width: prepWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CoinsSectionTitle(title),
              const SizedBox(height: 10),
              if (preparing) ...[
                InitialOrientationSelector(
                  value: scene.initialCoinState,
                  onChanged: (s) {
                    scene.setInitialCoinState(s);
                    _bump();
                  },
                ),
                const SizedBox(height: 10),
              ],
              ClassicalCoinDisplay(
                face: _face,
                radius: QmCoinsLayoutSpec.indicatorCoinRadius,
                revealed: preparing ? true : singleRevealed,
              ),
              const SizedBox(height: 8),
              CoinResultDisplay(
                systemType: SystemType.classical,
                upProbability: scene.upProbability,
              ),
              if (preparing) ...[
                const SizedBox(height: 8),
                CoinBiasControls(
                  systemType: SystemType.classical,
                  upProbability: scene.upProbability,
                  onChanged: (v) {
                    scene.setUpProbability(v);
                    _bump();
                  },
                ),
              ],
              if (!preparing) ...[
                const SizedBox(height: 16),
                NewCoinButton(
                  onPressed: () {
                    scene.setPreparingExperiment(true);
                    _bump();
                  },
                ),
              ],
            ],
          ),
        ),

        // ── Divider ──
        Positioned(
          left: g.dividerRect.left,
          top: 0,
          child: CoinsDashedDivider(height: g.dividerRect.height),
        ),

        // ── Start Measurement ──
        if (preparing)
          Positioned(
            left: g.startMeasurementCenter.dx - 36,
            top: g.startMeasurementCenter.dy - 24,
            child: StartMeasurementButton(
              onPressed: () {
                scene.setPreparingExperiment(false);
                _bump();
              },
            ),
          ),

        // ── Single Coin Measurements (geometry-anchored) ──
        Positioned(
          left: g.singleTestBox.left,
          top: g.singleTestBox.top - 36,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CoinsSectionTitle(QmStrings.singleCoinMeasurements),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CoinTestBoxFrame(
                    width: g.singleTestBox.width,
                    height: g.singleTestBox.height,
                    child: preparing
                        ? const SizedBox.shrink()
                        : ClassicalCoinDisplay(
                            face: _face,
                            radius: 36,
                            revealed: singleRevealed,
                          ),
                  ),
                  if (!preparing) ...[
                    const SizedBox(width: 16),
                    CoinControls(
                      systemType: SystemType.classical,
                      measurementState: scene.singleCoin.measurementState,
                      enabled: true,
                      onRevealOrObserve: () {
                        scene.singleCoin.reveal();
                        _bump();
                      },
                      onHide: () {
                        scene.singleCoin.hide();
                        _bump();
                      },
                      onPrepare: () {
                        scene.singleCoin.prepare(skipAnimation: true);
                        _bump();
                      },
                      onPrepareAndReveal: () {
                        scene.singleCoin.prepare(
                          revealWhenPrepared: true,
                          skipAnimation: true,
                        );
                        _bump();
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // ── Multiple Coin Measurements (geometry-anchored, square box) ──
        Positioned(
          left: g.multiTestBox.left,
          top: g.multiTestBox.top - 36,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CoinsSectionTitle(QmStrings.multipleCoinMeasurements),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  preparing
                      ? Container(
                          width: g.multiTestBox.width,
                          height: g.multiTestBox.height,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: QuantumMeasurementColors
                                  .testBoxRectangleStroke,
                              width: 2,
                            ),
                          ),
                        )
                      : MultiCoinDisplay(
                          systemType: SystemType.classical,
                          measuredValues: scene.coinSet.measuredValues,
                          count: scene.coinSet.numberOfCoins,
                          revealed: multiRevealed,
                          size: g.multiTestBox.width,
                        ),
                  const SizedBox(width: 20),
                  CoinCountSelector(
                    value: scene.coinSet.numberOfCoins,
                    visible: preparing,
                    onChanged: (n) {
                      scene.coinSet.numberOfCoins = n;
                      _bump();
                    },
                  ),
                  if (!preparing) ...[
                    const SizedBox(width: 20),
                    CoinControls(
                      systemType: SystemType.classical,
                      measurementState: scene.coinSet.measurementState,
                      enabled: true,
                      onRevealOrObserve: () {
                        scene.coinSet.reveal();
                        _bump();
                      },
                      onHide: () {
                        scene.coinSet.hide();
                        _bump();
                      },
                      onPrepare: () {
                        scene.coinSet.prepare(skipAnimation: true);
                        _bump();
                      },
                      onPrepareAndReveal: () {
                        scene.coinSet.prepare(
                          revealWhenPrepared: true,
                          skipAnimation: true,
                        );
                        _bump();
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
