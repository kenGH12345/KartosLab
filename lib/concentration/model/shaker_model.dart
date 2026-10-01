import 'dart:ui';

import 'concentration_constants.dart';
import 'solute_form.dart';

/// Shaker model — beers-law-lab `Shaker.ts`.
class ShakerModel {
  ShakerModel({
    Offset? position,
    Rect? dragBounds,
    this.orientation = ConcentrationConstants.shakerOrientation,
    this.maxDispensingRate = ConcentrationConstants.shakerMaxDispensingRate,
  })  : position = position ?? ConcentrationConstants.shakerPosition,
        dragBounds = dragBounds ?? ConcentrationConstants.shakerDragBounds,
        _previousPosition = position ?? ConcentrationConstants.shakerPosition;

  Offset position;
  final Rect dragBounds;
  final double orientation; // radians
  final double maxDispensingRate; // mol/s

  bool isEmpty = false;
  double dispensingRate = 0;

  Offset _previousPosition;

  bool isVisible(SoluteForm form) => form == SoluteForm.solid;

  /// Moves shaker, clamped to [dragBounds].
  void setPosition(Offset value) {
    position = Offset(
      value.dx.clamp(dragBounds.left, dragBounds.right),
      value.dy.clamp(dragBounds.top, dragBounds.bottom),
    );
  }

  /// Source `step()` — dispensing rate from motion.
  void step() {
    if (isVisibleForStep && !isEmpty) {
      if (_previousPosition == position) {
        dispensingRate = 0;
      } else {
        dispensingRate = maxDispensingRate;
      }
    }
    _previousPosition = position;
  }

  /// Visibility is driven by solute form; kept separate for step when form known.
  bool isVisibleForStep = true;

  void syncVisibility(SoluteForm form) {
    isVisibleForStep = isVisible(form);
    if (!isVisibleForStep || isEmpty) {
      dispensingRate = 0;
    }
  }

  void syncEmpty(double soluteMoles) {
    isEmpty = soluteMoles >= ConcentrationConstants.soluteAmountMax;
    if (isEmpty) {
      dispensingRate = 0;
    }
  }

  void reset({Offset? position}) {
    this.position = position ?? ConcentrationConstants.shakerPosition;
    isEmpty = false;
    dispensingRate = 0;
    _previousPosition = this.position;
    isVisibleForStep = true;
  }
}
