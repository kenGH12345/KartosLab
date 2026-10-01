import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../mp_colors.dart';
import '../mp_preferences.dart';

/// Port of `RealMoleculeColors.ts` colorizers (RGB in Color, not [0,1] triples).
abstract final class RealMoleculeSurfaceColors {
  static const double surfaceBackAlpha = 0.75;
  static const double surfaceFrontAlpha = 0.25;

  static Color colorizeEsp(double espValue, SurfaceColor mode) {
    return mode == SurfaceColor.rainbow
        ? colorizeElectrostaticPotentialRoygb(espValue)
        : colorizeElectrostaticPotentialRwb(espValue);
  }

  static Color colorizeElectrostaticPotentialRwb(double espValue) {
    final scaled = espValue * 15;
    const white = MpColors.surfaceRwbWhite;
    if (scaled > 0) {
      const blue = MpColors.surfaceRwbBlue;
      final v = (1 - scaled).clamp(0.0, 1.0);
      return Color.lerp(blue, white, v)!;
    }
    const red = MpColors.surfaceRwbRed;
    final v = (1 + scaled).clamp(0.0, 1.0);
    return Color.lerp(red, white, v)!;
  }

  static Color colorizeElectrostaticPotentialRoygb(double espValue) {
    final scaled = ((espValue * 8 + 1) / 2).clamp(0.0, 1.0);
    const gradient = [
      Color.fromRGBO(255, 0, 0, 1),
      Color.fromRGBO(255, 165, 0, 1),
      Color.fromRGBO(255, 255, 0, 1),
      Color.fromRGBO(0, 255, 0, 1),
      Color.fromRGBO(0, 0, 255, 1),
    ];
    final t = scaled * (gradient.length - 1);
    final i = t.floor().clamp(0, gradient.length - 1);
    final f = t - i;
    final i1 = math.min(i + 1, gradient.length - 1);
    return Color.lerp(gradient[i], gradient[i1], f)!;
  }

  /// Advanced electron density (polynomial easing).
  static Color colorizeRealElectronDensity(double densityValue) {
    var d = densityValue * 200;
    final clamped = _easing(3, _linear(0.1, 0.9, 1, 0, d).clamp(0.0, 1.0));
    return Color.lerp(MpColors.surfaceBwBlack, MpColors.surfaceBwWhite, clamped)!;
  }

  /// Basic/Java electron density.
  static Color colorizeJavaElectronDensity(double densityValue) {
    final clamped = (15 * densityValue / 2 + 0.5).clamp(0.0, 1.0);
    return Color.lerp(MpColors.surfaceBwBlack, MpColors.surfaceBwWhite, clamped)!;
  }

  static double _linear(double x0, double x1, double y0, double y1, double x) {
    if ((x1 - x0).abs() < 1e-12) return y0;
    return y0 + (x - x0) * (y1 - y0) / (x1 - x0);
  }

  static double _easing(double n, double t) {
    if (t <= 0.5) {
      return 0.5 * math.pow(2 * t, n).toDouble();
    }
    return 1 - _easing(n, 1 - t);
  }

  /// Fake opaque blend over screen background (SurfaceMesh background shader).
  static Color blendOverBackground(Color color, double alpha) {
    return Color.lerp(MpColors.screenBackground, color, alpha)!;
  }
}
