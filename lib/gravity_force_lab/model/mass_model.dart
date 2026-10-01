import 'dart:ui' show Color;

import 'gravity_force_constants.dart';

/// One spherical mass — PhET `Mass` / `ISLCObject` for Gravity Force Lab Full.
class MassModel {
  MassModel({
    required this.value,
    required this.positionX,
    required this.baseColor,
    required bool Function() constantRadiusGetter,
  }) : _constantRadiusGetter = constantRadiusGetter;

  double value;
  double positionX;
  bool isDragging = false;
  final Color baseColor;
  final bool Function() _constantRadiusGetter;

  /// Flags used by ISLCModel.step push semantics.
  bool radiusLastChanged = false;
  bool valueChangedSinceLastStep = false;
  bool constantRadiusChangedSinceLastStep = false;

  double get radius {
    if (_constantRadiusGetter()) {
      return GravityForceConstants.constantRadius;
    }
    return GravityForceConstants.calculateRadius(value);
  }

  /// PhET `Mass.baseColorProperty`.
  Color get displayColor {
    if (_constantRadiusGetter()) {
      final amount = 1 - value.abs() / GravityForceConstants.massMax;
      return brighter(baseColor, amount);
    }
    return brighter(baseColor, GravityForceConstants.baseColorModifier);
  }

  void onStepEnd() {
    valueChangedSinceLastStep = false;
    constantRadiusChangedSinceLastStep = false;
  }

  void reset({
    required double value,
    required double positionX,
  }) {
    this.value = value;
    this.positionX = positionX;
    isDragging = false;
    radiusLastChanged = false;
    valueChangedSinceLastStep = false;
    constantRadiusChangedSinceLastStep = false;
  }

  /// Scenery `Color.colorUtilsBrighter`.
  static Color brighter(Color c, double amount) {
    final a = amount.clamp(0.0, 1.0);
    int channel(double unit) {
      final v = (unit * 255.0).round().clamp(0, 255);
      return (v + ((255 - v) * a)).round().clamp(0, 255);
    }

    return Color.fromARGB(
      (c.a * 255.0).round().clamp(0, 255),
      channel(c.r),
      channel(c.g),
      channel(c.b),
    );
  }
}
