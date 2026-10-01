import 'package:flutter/services.dart';

import '../model/gravity_force_constants.dart';
import '../model/gravity_force_lab_model.dart';

/// Keyboard deltas — PhET AccessibleSlider / MassControl / ISLCRulerNode.
class GflKeyboardActions {
  GflKeyboardActions._();

  static bool get shiftDown => HardwareKeyboard.instance.isShiftPressed;

  /// MassControl Full: left/right arrows; shift → 10 kg; page → 100 kg.
  static double massDelta({
    required bool increase,
    required bool page,
  }) {
    final step = page
        ? GravityForceConstants.massPageKeyboardStep
        : (shiftDown
            ? GravityForceConstants.massShiftKeyboardStep
            : GravityForceConstants.massKeyboardStep);
    return increase ? step : -step;
  }

  /// ISLCObjectNode AccessibleSlider: keyboardStep=0.5, shift=0.1, page=1.0.
  static double positionDelta({
    required bool increase,
    required bool page,
  }) {
    final step = page
        ? GravityForceConstants.positionPageStepSize
        : (shiftDown
            ? GravityForceConstants.positionSnap
            : GravityForceConstants.positionStepSize);
    return increase ? step : -step;
  }

  /// ISLCRulerNode KeyboardDragListener: normal 0.2 m, shift 0.1 m.
  static double rulerDelta({required bool fine}) {
    return fine
        ? GravityForceConstants.rulerShiftKeyboardStep
        : GravityForceConstants.rulerKeyboardStep;
  }

  static void applyMassStep(
    GravityForceLabModel model,
    int which, {
    required bool increase,
    required bool page,
  }) {
    final m = which == 1 ? model.mass1 : model.mass2;
    model.setMassValue(which, m.value + massDelta(increase: increase, page: page));
  }

  static void jumpMassMin(GravityForceLabModel model, int which) {
    model.setMassValue(which, GravityForceConstants.massMin);
  }

  static void jumpMassMax(GravityForceLabModel model, int which) {
    model.setMassValue(which, GravityForceConstants.massMax);
  }

  static void applyPositionStep(
    GravityForceLabModel model,
    int which, {
    required bool increase,
    required bool page,
  }) {
    final m = which == 1 ? model.mass1 : model.mass2;
    model.setPosition(
      which,
      m.positionX + positionDelta(increase: increase, page: page),
    );
  }

  static void jumpPositionMin(GravityForceLabModel model, int which) {
    final min = which == 1 ? model.mass1EnabledMin : model.mass2EnabledMin;
    model.setPosition(which, min);
  }

  static void jumpPositionMax(GravityForceLabModel model, int which) {
    final max = which == 1 ? model.mass1EnabledMax : model.mass2EnabledMax;
    model.setPosition(which, max);
  }

  static void nudgeRuler(
    GravityForceLabModel model, {
    double dx = 0,
    double dy = 0,
  }) {
    model.setRulerPosition(
      model.ruler.positionX + dx,
      model.ruler.positionY + dy,
    );
  }
}
