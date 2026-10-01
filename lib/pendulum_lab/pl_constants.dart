/// Pendulum Lab layout, MVT, ranges, and friction mapping.
///
/// Source: `PendulumLabConstants.js`, `Pendulum.js`, `PendulumLabModel.js`,
/// `FrictionSliderNode.js`.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

class PlConstants {
  PlConstants._();

  static const double layoutWidth = 1024;
  static const double layoutHeight = 618;
  static const Size layoutSize = Size(layoutWidth, layoutHeight);

  /// Screen height in model meters (comment in PendulumLabConstants).
  static const double modelHeightMeters = 1.33;

  /// `ModelViewTransform2.createSinglePointScaleInvertedYMapping(
  ///    ZERO, (1024/2, 15), 618/1.33)`
  static const Offset mvtOrigin = Offset(layoutWidth / 2, 15);
  static const double mvtScale = layoutHeight / modelHeightMeters;

  static const double panelPadding = 10;
  static const double panelCornerRadius = 5;
  static const double panelXMargin = 10;
  static const double panelYMargin = 8;
  static const double rightContentWidth = 170;
  static const double checkRadioSpacing = 7;

  static const Size thumbSize = Size(13, 22);
  static const double trackHeight = 0.5;
  static const int sliderPrecision = 1;
  static const int tweakersPrecision = 2;

  static const double bobRectWidth = 73;
  static const double bobRectHeight = 98;

  static const double protractorRadius = 106;
  static const double protractorTick1 = 3.6;
  static const double protractorTick5 = 7.3;
  static const double protractorTick10 = 11;
  static const double pendulumTickLength = 14.7;

  static const double arrowHeadWidth = 12;
  static const double arrowTailWidth = 6;
  static const double arrowSizeDefault = 25;

  static const double rulerHeight = 34;
  static const int rulerTickIntervalCm = 5;

  static const double periodTimerBackgroundScale = 0.6;

  static const double periodTimerOffsetFactor = 1.007;
  static const double maxWallDt = 0.05;
  static const double manualStepDt = 0.01;
  static const double dampThreshold = 1e-3;
  static const double framesPerSecond = 60;

  static const double lengthMin = 0.1;
  static const double lengthMax = 1.0;
  static const double massMin = 0.1;
  static const double massMax = 1.50;
  static const double gravityMin = 0;
  static const double gravityMax = 25;
  static const double frictionMax = 0.5115;

  static const double pendulum0Mass = 1;
  static const double pendulum0Length = 0.7;
  static const double pendulum1Mass = 0.5;
  static const double pendulum1Length = 1.0;

  /// `PhysicalConstants.GRAVITY_ON_EARTH` — not model.md 9.81.
  static const double earthGravity = 9.8;
  static const double moonGravity = 1.62;
  static const double jupiterGravity = 24.79;
  static const double planetXGravity = 14.2;

  static const double slowTimeSpeed = 1 / 8;
  static const double normalTimeSpeed = 1;

  static const double energyBarScale = 40;
  static const double energyZoomMultiplier = 1.3;

  static const double closestDragTouchMeters = 0.15;

  static const double stopwatchMaxSeconds = 59.99;

  static double massToScale(double mass) =>
      0.3 + 0.4 * math.sqrt(mass / 1.5);

  /// `FrictionSliderNode.sliderValueToFriction`
  static double sliderValueToFriction(double sliderValue) =>
      0.0005 * (math.pow(2, sliderValue) - 1);

  /// `FrictionSliderNode.frictionToSliderValue` + `Utils.roundSymmetric`
  static double frictionToSliderValue(double friction) {
    final raw = math.log(friction / 0.0005 + 1) / math.ln2;
    return roundSymmetric(raw);
  }

  /// PhET `Utils.roundSymmetric` ≡ Dart `round` (half away from zero).
  static double roundSymmetric(double value) => value.roundToDouble();

  static double toDegrees(double radians) => radians * 180 / math.pi;

  static double toRadians(double degrees) => degrees * math.pi / 180;
}
