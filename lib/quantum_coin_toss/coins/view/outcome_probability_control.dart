// Copyright 2024-2026, University of Colorado Boulder
/// Bias / state preparation sliders (OutcomeProbabilityControl.ts).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../common/quantum_measurement_colors.dart';
import '../../common/quantum_measurement_strings.dart';
import '../../common/view/probability_value_control.dart';
import '../model/coins_experiment_scene_model.dart';
import 'probability_of_symbol_box.dart';

class OutcomeProbabilityControl extends StatefulWidget {
  const OutcomeProbabilityControl({
    super.key,
    required this.scene,
    required this.isQuantum,
  });

  final CoinsExperimentSceneModel scene;
  final bool isQuantum;

  @override
  State<OutcomeProbabilityControl> createState() =>
      _OutcomeProbabilityControlState();
}

class _OutcomeProbabilityControlState extends State<OutcomeProbabilityControl> {
  late final ValueNotifier<double> _inverseProbability;
  var _linking = false;

  @override
  void initState() {
    super.initState();
    _inverseProbability = ValueNotifier(
      1.0 - widget.scene.upProbabilityProperty.value,
    );
    widget.scene.upProbabilityProperty.addListener(_onUpChanged);
    _inverseProbability.addListener(_onInverseChanged);
  }

  @override
  void dispose() {
    widget.scene.upProbabilityProperty.removeListener(_onUpChanged);
    _inverseProbability.removeListener(_onInverseChanged);
    _inverseProbability.dispose();
    super.dispose();
  }

  void _onUpChanged() {
    if (_linking) return;
    _linking = true;
    _inverseProbability.value =
        1.0 - widget.scene.upProbabilityProperty.value;
    _linking = false;
  }

  void _onInverseChanged() {
    if (_linking) return;
    _linking = true;
    widget.scene.upProbabilityProperty.value = ProbabilityValueControl.constrainValue(
      1.0 - _inverseProbability.value,
    );
    _linking = false;
  }

  @override
  Widget build(BuildContext context) {
    final up = widget.scene.upProbabilityProperty;
    final isQuantum = widget.isQuantum;

    return ListenableBuilder(
      listenable: up,
      builder: (context, _) {
        final p = up.value;
        final alpha = math.sqrt(p);
        final beta = math.sqrt(1 - p);

        return Column(
          children: [
            if (isQuantum) _quantumTitle() else _classicalTitle(),
            const SizedBox(height: 12),
            if (isQuantum) ...[
              _QuantumStateReadout(alpha: alpha, beta: beta),
              const SizedBox(height: 12),
            ],
            ProbabilityValueControl(
              title: isQuantum
                  ? _quantumSliderTitle(
                      up: true,
                      symbol: QuantumMeasurementStrings.spinUpSymbol,
                      suffix: '|α|²',
                      symbolColor: Colors.black,
                    )
                  : _classicalSliderTitle('heads'),
              valueListenable: up,
              onChanged: (v) => up.value = v,
            ),
            const SizedBox(height: 12),
            ProbabilityValueControl(
              title: isQuantum
                  ? _quantumSliderTitle(
                      up: false,
                      symbol: QuantumMeasurementStrings.spinDownSymbol,
                      suffix: '|β|²',
                      symbolColor: QuantumMeasurementColors.downColor,
                    )
                  : _classicalSliderTitle('tails'),
              valueListenable: _inverseProbability,
              onChanged: (v) => _inverseProbability.value = v,
            ),
          ],
        );
      },
    );
  }

  Widget _classicalTitle() {
    return Text(
      QuantumMeasurementStrings.coinBias,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _quantumTitle() {
    const ket = '⟩';
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: Colors.black),
        children: [
          const TextSpan(
            text: 'State to Prepare ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: '(α|↑'),
          TextSpan(text: ket, style: const TextStyle(fontFeatures: [])),
          const TextSpan(text: ' + '),
          TextSpan(
            text: 'β|',
            style: TextStyle(color: QuantumMeasurementColors.downColor),
          ),
          TextSpan(
            text: '↓$ket',
            style: TextStyle(color: QuantumMeasurementColors.downColor),
          ),
          const TextSpan(text: ')'),
        ],
      ),
    );
  }

  Widget _classicalSliderTitle(String face) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          QuantumMeasurementStrings.probabilityLabel,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 5),
        ProbabilityOfSymbolBox(face: face, fontSize: 16),
      ],
    );
  }

  Widget _quantumSliderTitle({
    required bool up,
    required String symbol,
    required String suffix,
    required Color symbolColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          QuantumMeasurementStrings.probabilityLabel,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(
          'P(',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          symbol,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: symbolColor,
          ),
        ),
        const Text(
          ') = ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          suffix,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: up ? Colors.black : QuantumMeasurementColors.downColor,
          ),
        ),
      ],
    );
  }
}

class _QuantumStateReadout extends StatelessWidget {
  const _QuantumStateReadout({required this.alpha, required this.beta});

  final double alpha;
  final double beta;

  @override
  Widget build(BuildContext context) {
    const ket = '⟩';
    final aStr = alpha.toStringAsFixed(3);
    final bStr = beta.toStringAsFixed(3);
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(fontSize: 16, color: Colors.black),
        children: [
          TextSpan(text: '$aStr|↑$ket + '),
          TextSpan(
            text: '$bStr|↓$ket',
            style: TextStyle(color: QuantumMeasurementColors.downColor),
          ),
        ],
      ),
    );
  }
}
