// Copyright 2024-2026, University of Colorado Boulder
/// Vertical experiment control buttons (CoinExperimentButtonSet.ts).
library;

import 'package:flutter/material.dart';

import '../../common/model/experiment_measurement_state.dart';
import '../../common/model/system_type.dart';
import '../../common/quantum_measurement_colors.dart';
import '../../common/quantum_measurement_strings.dart';
import '../model/coin_set.dart';

const _buttonWidth = 180.0;

class CoinExperimentButtonSet extends StatelessWidget {
  const CoinExperimentButtonSet({
    super.key,
    required this.coinSet,
    required this.coinsInTestBox,
    required this.visible,
  });

  final CoinSet coinSet;
  final bool coinsInTestBox;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox(width: _buttonWidth);
    }

    return ListenableBuilder(
      listenable: coinSet.measurementStateProperty,
      builder: (context, _) {
        final state = coinSet.measurementStateProperty.value;
        final enabled = coinsInTestBox &&
            state != ExperimentMeasurementState.preparingToBeMeasured;
        final isClassical = coinSet.coinType == SystemType.classical;

        final String revealHideLabel;
        if (state == ExperimentMeasurementState.revealed) {
          revealHideLabel = QuantumMeasurementStrings.hide;
        } else if (isClassical) {
          revealHideLabel = QuantumMeasurementStrings.reveal;
        } else {
          revealHideLabel = QuantumMeasurementStrings.observe;
        }

        final flipLabel = isClassical
            ? QuantumMeasurementStrings.flip
            : QuantumMeasurementStrings.reprepare;
        final flipAndRevealLabel = isClassical
            ? QuantumMeasurementStrings.flipAndReveal
            : QuantumMeasurementStrings.reprepareAndReveal;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ExperimentButton(
              label: revealHideLabel,
              enabled: enabled,
              onPressed: () {
                if (state == ExperimentMeasurementState.revealed) {
                  coinSet.hide();
                } else if (state ==
                        ExperimentMeasurementState.readyToBeMeasured ||
                    state == ExperimentMeasurementState.measuredAndHidden) {
                  coinSet.reveal();
                }
              },
            ),
            const SizedBox(height: 10),
            _ExperimentButton(
              label: flipLabel,
              enabled: enabled,
              onPressed: () => coinSet.prepare(),
            ),
            const SizedBox(height: 10),
            _ExperimentButton(
              label: flipAndRevealLabel,
              enabled: enabled,
              onPressed: () => coinSet.prepare(revealWhenPrepared: true),
            ),
          ],
        );
      },
    );
  }
}

class _ExperimentButton extends StatelessWidget {
  const _ExperimentButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _buttonWidth,
      height: 36,
      child: Material(
        color: enabled
            ? QuantumMeasurementColors.experimentButton
            : QuantumMeasurementColors.experimentButton.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(5),
        elevation: enabled ? 1.5 : 0,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(5),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: enabled ? Colors.black : Colors.black54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
