import 'dart:ui';

import 'concentration_constants.dart';
import 'solute_form.dart';

/// Dropper model — beers-law-lab `Dropper.ts`.
///
/// Fixed position; button toggles [isDispensing].
class DropperModel {
  DropperModel({
    Offset? position,
    this.maxFlowRate = ConcentrationConstants.dropperFlowRate,
  }) : position = position ?? ConcentrationConstants.dropperPosition;

  final Offset position;
  final double maxFlowRate; // L/s

  bool enabled = true;
  bool isDispensing = false;
  bool isEmpty = false;
  double flowRate = 0;

  bool isVisible(SoluteForm form) => form == SoluteForm.solution;

  void setDispensing(bool value) {
    if (!enabled) {
      isDispensing = false;
      flowRate = 0;
      return;
    }
    isDispensing = value;
    flowRate = isDispensing ? maxFlowRate : 0;
  }

  void syncEnabled({
    required double volume,
    required double soluteMoles,
    required bool visible,
  }) {
    final containsMaxSolute =
        soluteMoles >= ConcentrationConstants.soluteAmountMax;
    isEmpty = containsMaxSolute;

    if (isEmpty) {
      enabled = false;
    } else {
      enabled = visible &&
          volume < ConcentrationConstants.solutionVolumeMax &&
          !containsMaxSolute;
    }

    if (!enabled) {
      isDispensing = false;
      flowRate = 0;
    }
    if (!visible) {
      flowRate = 0;
    }
  }

  void reset() {
    isDispensing = false;
    enabled = true;
    isEmpty = false;
    flowRate = 0;
  }
}
