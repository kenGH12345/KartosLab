// Copyright 2024-2026, University of Colorado Boulder
/// Left column: prepared / prepare coin state (CoinExperimentPreparationArea.ts).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../common/model/system_type.dart';
import '../../common/quantum_measurement_colors.dart';
import '../../common/quantum_measurement_strings.dart';
import '../model/coins_experiment_scene_model.dart';
import 'classical_coin_node.dart';
import 'outcome_probability_control.dart';
import 'probability_of_symbol_box.dart';
import 'quantum_coin_node.dart';
import 'scene_section_header.dart';

const _indicatorCoinRadius = 36.0;
const _radioCoinRadius = 16.0;

final _noSuperpositionDisplay = ValueNotifier(false);

/// Immutable [ValueListenable] for static radio coin previews.
class _FixedStringListenable implements ValueListenable<String> {
  _FixedStringListenable(this.value);
  @override
  final String value;
  @override
  void addListener(VoidCallback listener) {}
  @override
  void removeListener(VoidCallback listener) {}
}

class _FixedDoubleListenable implements ValueListenable<double> {
  _FixedDoubleListenable(this.value);
  @override
  final double value;
  @override
  void addListener(VoidCallback listener) {}
  @override
  void removeListener(VoidCallback listener) {}
}

class CoinExperimentPreparationArea extends StatelessWidget {
  const CoinExperimentPreparationArea({super.key, required this.scene});

  final CoinsExperimentSceneModel scene;

  @override
  Widget build(BuildContext context) {
    final isQuantum = scene.systemType == SystemType.quantum;
    final textColor = isQuantum
        ? QuantumMeasurementColors.quantumSceneText
        : QuantumMeasurementColors.classicalSceneText;

    return ListenableBuilder(
      listenable: Listenable.merge([
        scene.preparingExperimentProperty,
        scene.initialCoinStateProperty,
        scene.upProbabilityProperty,
        scene.downProbabilityProperty,
      ]),
      builder: (context, _) {
        final preparing = scene.preparingExperimentProperty.value;
        final header = _headerTitle(preparing, isQuantum);
        final maxHeaderWidth = preparing ? 250.0 : 150.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SceneSectionHeader(
                title: header,
                textColor: textColor,
                maxWidth: maxHeaderWidth,
              ),
              const SizedBox(height: 15),
              if (preparing) ...[
                _OrientationSelectorPanel(scene: scene, isQuantum: isQuantum),
                const SizedBox(height: 25),
              ],
              _IndicatorCoin(scene: scene, isQuantum: isQuantum),
              const SizedBox(height: 15),
              _ProbabilityEquations(scene: scene, isQuantum: isQuantum),
              if (preparing) ...[
                SizedBox(height: isQuantum ? 0 : 5),
                OutcomeProbabilityControl(scene: scene, isQuantum: isQuantum),
              ],
            ],
          ),
        );
      },
    );
  }

  String _headerTitle(bool preparing, bool isQuantum) {
    if (preparing) {
      final item = isQuantum
          ? QuantumMeasurementStrings.quantumCoinQuoted
          : QuantumMeasurementStrings.coin;
      return QuantumMeasurementStrings.itemToPrepare(item);
    }
    if (isQuantum) {
      return QuantumMeasurementStrings.preparedState;
    }
    return QuantumMeasurementStrings.coin;
  }
}

class _IndicatorCoin extends StatelessWidget {
  const _IndicatorCoin({required this.scene, required this.isQuantum});

  final CoinsExperimentSceneModel scene;
  final bool isQuantum;

  @override
  Widget build(BuildContext context) {
    if (isQuantum) {
      return QuantumCoinNode(
        coinStateNotifier: scene.initialCoinStateProperty,
        stateProbabilityNotifier: scene.upProbabilityProperty,
        radius: _indicatorCoinRadius,
      );
    }
    return ClassicalCoinNode(
      coinStateNotifier: scene.initialCoinStateProperty,
      radius: _indicatorCoinRadius,
    );
  }
}

class _OrientationSelectorPanel extends StatelessWidget {
  const _OrientationSelectorPanel({
    required this.scene,
    required this.isQuantum,
  });

  final CoinsExperimentSceneModel scene;
  final bool isQuantum;

  @override
  Widget build(BuildContext context) {
    final title = isQuantum
        ? QuantumMeasurementStrings.basisState
        : QuantumMeasurementStrings.initialOrientation;
    final states = isQuantum ? const ['up', 'down'] : const ['heads', 'tails'];

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < states.length; i++) ...[
              if (i > 0) const SizedBox(width: 22),
              _OrientationRadio(
                scene: scene,
                state: states[i],
                isQuantum: isQuantum,
                selected: scene.initialCoinStateProperty.value == states[i],
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _OrientationRadio extends StatelessWidget {
  const _OrientationRadio({
    required this.scene,
    required this.state,
    required this.isQuantum,
    required this.selected,
  });

  final CoinsExperimentSceneModel scene;
  final String state;
  final bool isQuantum;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: selected ? Colors.black : Colors.transparent,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => scene.initialCoinStateProperty.value = state,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: isQuantum
              ? QuantumCoinNode(
                  coinStateNotifier: _FixedStringListenable(state),
                  stateProbabilityNotifier:
                      _FixedDoubleListenable(state == 'up' ? 1.0 : 0.0),
                  radius: _radioCoinRadius,
                  showSuperpositionNotifier: _noSuperpositionDisplay,
                )
              : ClassicalCoinNode(
                  coinStateNotifier: _FixedStringListenable(state),
                  radius: _radioCoinRadius,
                ),
        ),
      ),
    );
  }
}

class _ProbabilityEquations extends StatelessWidget {
  const _ProbabilityEquations({
    required this.scene,
    required this.isQuantum,
  });

  final CoinsExperimentSceneModel scene;
  final bool isQuantum;

  @override
  Widget build(BuildContext context) {
    final up = scene.upProbabilityProperty.value;
    final down = scene.downProbabilityProperty.value;
    final upFace = isQuantum ? 'up' : 'heads';
    final downFace = isQuantum ? 'down' : 'tails';
    final downColor = isQuantum
        ? QuantumMeasurementColors.downColor
        : QuantumMeasurementColors.tailsColor;

    return Column(
      children: [
        _equationRow(
          ProbabilityOfSymbolBox(face: upFace),
          up,
          Colors.black,
        ),
        const SizedBox(height: 10),
        _equationRow(
          ProbabilityOfSymbolBox(face: downFace),
          down,
          downColor,
        ),
      ],
    );
  }

  Widget _equationRow(Widget label, double value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        label,
        const SizedBox(width: 5),
        Text(
          '= ${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
