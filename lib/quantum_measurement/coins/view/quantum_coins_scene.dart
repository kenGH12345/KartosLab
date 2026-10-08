/// Quantum Coins experiment scene — layout from CoinsComposer / LayoutSpec.
library;

import 'package:flutter/material.dart';

import '../../common/experiment_measurement_state.dart';
import '../../common/system_type.dart';
import '../../layout/qm_coins_layout_spec.dart';
import '../composer/coins_composer.dart';
import '../components/coin_bias_controls.dart';
import '../components/coin_controls.dart';
import '../components/coin_count_selector.dart';
import '../components/coin_result_display.dart';
import '../components/coins_scene_primitives.dart';
import '../components/multi_coin_display.dart';
import '../components/quantum_coin_display.dart';
import '../model/coins_model.dart';
import 'package:kratos/quantum_measurement/qm_strings.dart';

class QuantumCoinsScene extends StatefulWidget {
  const QuantumCoinsScene({
    super.key,
    required this.scene,
    required this.geometry,
    required this.onChanged,
  });

  final CoinsExperimentSceneModel scene;
  final CoinsLayoutGeometry geometry;
  final VoidCallback onChanged;

  @override
  State<QuantumCoinsScene> createState() => _QuantumCoinsSceneState();
}

class _QuantumCoinsSceneState extends State<QuantumCoinsScene> {
  late final ValueNotifier<String> _prepState;
  late final ValueNotifier<String> _measureState;
  late final ValueNotifier<double> _upProb;

  CoinsExperimentSceneModel get scene => widget.scene;
  CoinsLayoutGeometry get g => widget.geometry;

  @override
  void initState() {
    super.initState();
    _prepState = ValueNotifier(_prepVisualState());
    _measureState = ValueNotifier(scene.singleCoin.measuredValue);
    _upProb = ValueNotifier(scene.upProbability);
  }

  String _prepVisualState() {
    if (scene.initialCoinState == 'superposition') return 'superposition';
    return scene.initialCoinState;
  }

  @override
  void didUpdateWidget(covariant QuantumCoinsScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncNotifiers();
  }

  void _syncNotifiers() {
    final prep = _prepVisualState();
    if (_prepState.value != prep) _prepState.value = prep;
    final measured = scene.singleCoin.measuredValue;
    if (_measureState.value != measured) _measureState.value = measured;
    if (_upProb.value != scene.upProbability) {
      _upProb.value = scene.upProbability;
    }
  }

  void _bump() {
    _syncNotifiers();
    widget.onChanged();
  }

  @override
  void dispose() {
    _prepState.dispose();
    _measureState.dispose();
    _upProb.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preparing = scene.preparingExperiment;
    final singleRevealed =
        scene.singleCoin.measurementState == ExperimentMeasurementState.revealed;
    final multiRevealed =
        scene.coinSet.measurementState == ExperimentMeasurementState.revealed;
    final title = preparing ? QmStrings.quantumCoinToPrepare : QmStrings.preparedState;
    final showSuperpositionPrep = preparing &&
        (scene.initialCoinState == 'superposition' ||
            (scene.upProbability > 0 && scene.upProbability < 1));

    final prepWidth = preparing ? 300.0 : 180.0;
    final prepLeft = ((g.dividerX - prepWidth) / 2).clamp(8.0, g.dividerX - 8);

    // Basis chip selection: superposition maps to neither exclusive; show up if α≥0.5
    final basisValue = scene.initialCoinState == 'down'
        ? 'down'
        : scene.initialCoinState == 'up'
            ? 'up'
            : (scene.upProbability >= 0.5 ? 'up' : 'down');

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // ── Preparation column ──
        Positioned(
          left: prepLeft,
          top: 8,
          width: prepWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CoinsSectionTitle(title),
              const SizedBox(height: 8),
              if (preparing) ...[
                BasisStateSelector(
                  value: basisValue,
                  onChanged: (s) {
                    scene.setInitialCoinState(s);
                    _bump();
                  },
                ),
                const SizedBox(height: 8),
              ],
              QuantumCoinDisplay(
                coinState: _prepState,
                upProbability: _upProb,
                radius: QmCoinsLayoutSpec.indicatorCoinRadius,
                revealed: preparing ? true : singleRevealed,
                showSuperposition: showSuperpositionPrep,
              ),
              const SizedBox(height: 6),
              CoinResultDisplay(
                systemType: SystemType.quantum,
                upProbability: scene.upProbability,
              ),
              if (preparing) ...[
                const SizedBox(height: 6),
                CoinBiasControls(
                  systemType: SystemType.quantum,
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

        // ── Single Coin Measurements ──
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
                    child: QuantumCoinDisplay(
                      coinState: _measureState,
                      upProbability: _upProb,
                      radius: 36,
                      revealed: singleRevealed,
                      showSuperposition: false,
                    ),
                  ),
                  if (!preparing) ...[
                    const SizedBox(width: 16),
                    CoinControls(
                      systemType: SystemType.quantum,
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

        // ── Multiple Coin Measurements (geometry-anchored → no bottom clip) ──
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
                  MultiCoinDisplay(
                    systemType: SystemType.quantum,
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
                      systemType: SystemType.quantum,
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
