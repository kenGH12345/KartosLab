import 'dart:ui' show Color;

import 'package:kratos/under_pressure/model/under_pressure_constants.dart';
import 'package:kratos/under_pressure/model/under_pressure_math.dart';

/// Source: `fluid-pressure-and-flow/js/common/model/FluidColorModel.js`
class FluidColorModel {
  FluidColorModel({
    required double Function() getDensity,
    required this.densityMin,
    required this.densityMax,
  }) : _getDensity = getDensity {
    color = waterColor;
  }

  // Color constants from the Java / HTML5 version (RGB).
  static const List<int> gasRgb = [149, 142, 139];
  static const List<int> waterRgb = [20, 244, 255];
  static const List<int> honeyRgb = [255, 191, 0];

  static final Color gasColor = Color.fromARGB(255, gasRgb[0], gasRgb[1], gasRgb[2]);
  static final Color waterColor =
      Color.fromARGB(255, waterRgb[0], waterRgb[1], waterRgb[2]);
  static final Color honeyColor =
      Color.fromARGB(255, honeyRgb[0], honeyRgb[1], honeyRgb[2]);

  final double Function() _getDensity;
  final double densityMin;
  final double densityMax;

  late Color color;
  bool densityChanged = false;

  void markDensityChanged() => densityChanged = true;

  void reset() {
    color = waterColor;
    densityChanged = false;
  }

  void setColorDirect(Color c) {
    color = c;
  }

  /// Source `FluidColorModel.step`.
  void step() {
    if (!densityChanged) return;
    final density = _getDensity();
    if (density < UnderPressureConstants.waterDensity) {
      color = _lerpColor(densityMin, UnderPressureConstants.waterDensity,
          gasRgb, waterRgb, density);
    } else {
      color = _lerpColor(UnderPressureConstants.waterDensity, densityMax,
          waterRgb, honeyRgb, density);
    }
    densityChanged = false;
  }

  static Color _lerpColor(
    double x1,
    double x2,
    List<int> a,
    List<int> b,
    double x,
  ) {
    int ch(int i) => UnderPressureMath.linear(
          x1,
          x2,
          a[i].toDouble(),
          b[i].toDouble(),
          x,
        ).round().clamp(0, 255);
    return Color.fromARGB(255, ch(0), ch(1), ch(2));
  }
}
