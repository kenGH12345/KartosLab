import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../gflb_constants.dart';

/// One spherical mass (PhET `Mass` / `ISLCObject`).
class MassModel {
  MassModel({
    required this.value,
    required this.positionX,
    required this.baseColor,
    required bool Function() constantSizeGetter,
  }) : _constantSizeGetter = constantSizeGetter;

  double value;
  double positionX;
  bool isDragging = false;
  final Color baseColor;
  final bool Function() _constantSizeGetter;

  /// Radius from constant-size flag + density formula.
  double get radius {
    if (_constantSizeGetter()) {
      return GflbConstants.constantRadius;
    }
    return calculateRadius(value, GflbConstants.density);
  }

  static double calculateRadius(double mass, double density) {
    return math.pow((3 * mass / density) / (4 * math.pi), 1 / 3).toDouble();
  }

  /// Display / fill color (Mass.baseColorProperty).
  Color get displayColor {
    if (_constantSizeGetter()) {
      final amount = 1 - value.abs() / GflbConstants.massMax;
      return _brighter(baseColor, amount);
    }
    return _brighter(baseColor, GflbConstants.baseColorModifier);
  }

  static Color _brighter(Color c, double amount) {
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

  void reset({
    required double value,
    required double positionX,
  }) {
    this.value = value;
    this.positionX = positionX;
    isDragging = false;
  }
}
