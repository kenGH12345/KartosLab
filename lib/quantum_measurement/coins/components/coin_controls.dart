/// Experiment button set -?Classical Flip/Reveal vs Quantum Reprepare/Observe.
library;

import 'package:flutter/material.dart';

import '../../common/experiment_measurement_state.dart';
import '../../common/system_type.dart';
import '../../common/qm_visual.dart';
import '../../layout/qm_coins_layout_spec.dart';
import 'package:kratos/quantum_measurement/qm_strings.dart';

class CoinControls extends StatelessWidget {
  const CoinControls({
    super.key,
    required this.systemType,
    required this.measurementState,
    required this.enabled,
    required this.onRevealOrObserve,
    required this.onHide,
    required this.onPrepare,
    required this.onPrepareAndReveal,
  });

  final SystemType systemType;
  final ExperimentMeasurementState measurementState;
  final bool enabled;
  final VoidCallback onRevealOrObserve;
  final VoidCallback onHide;
  final VoidCallback onPrepare;
  final VoidCallback onPrepareAndReveal;

  bool get _isRevealed =>
      measurementState == ExperimentMeasurementState.revealed;

  String get _revealLabel {
    if (_isRevealed) return QmStrings.hide;
    return systemType == SystemType.classical ? QmStrings.reveal : QmStrings.observe;
  }

  String get _prepareLabel =>
      systemType == SystemType.classical ? QmStrings.flip : QmStrings.reprepare;

  String get _prepareRevealLabel => systemType == SystemType.classical
      ? QmStrings.flipAndReveal
      : QmStrings.reprepareAndObserve;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: QmCoinsLayoutSpec.experimentButtonWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QmPhetTextButton(
            label: _revealLabel,
            enabled: enabled,
            width: QmCoinsLayoutSpec.experimentButtonWidth,
            onPressed: _isRevealed ? onHide : onRevealOrObserve,
          ),
          const SizedBox(height: 10),
          QmPhetTextButton(
            label: _prepareLabel,
            enabled: enabled,
            width: QmCoinsLayoutSpec.experimentButtonWidth,
            onPressed: onPrepare,
          ),
          const SizedBox(height: 10),
          QmPhetTextButton(
            label: _prepareRevealLabel,
            enabled: enabled,
            width: QmCoinsLayoutSpec.experimentButtonWidth,
            onPressed: onPrepareAndReveal,
          ),
        ],
      ),
    );
  }
}
