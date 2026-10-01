import 'dart:ui';

import 'package:flutter/material.dart';

import '../model/force_values_display.dart';

/// Immutable snapshot for Full GFL painters / widgets.
class GflRenderData {
  const GflRenderData({
    required this.layoutSize,
    required this.mass1Center,
    required this.mass2Center,
    required this.mass1RadiusView,
    required this.mass2RadiusView,
    required this.mass1Color,
    required this.mass2Color,
    required this.constantRadius,
    required this.force,
    required this.forceLabel1,
    required this.forceLabel2,
    required this.forceValuesDisplay,
    required this.showForceValues,
    required this.arrow1TipDx,
    required this.arrow2TipDx,
    required this.arrow1Y,
    required this.arrow2Y,
    required this.puller1Frame,
    required this.puller2Frame,
    required this.mass1Label,
    required this.mass2Label,
    required this.rulerCenterView,
    required this.rulerWidthView,
    required this.rulerHeightView,
    required this.majorTickSpacingView,
  });

  final Size layoutSize;

  final Offset mass1Center;
  final Offset mass2Center;
  final double mass1RadiusView;
  final double mass2RadiusView;
  final Color mass1Color;
  final Color mass2Color;
  final bool constantRadius;

  final double force;
  final String forceLabel1;
  final String forceLabel2;
  final ForceValuesDisplay forceValuesDisplay;
  final bool showForceValues;

  final double arrow1TipDx;
  final double arrow2TipDx;
  final double arrow1Y;
  final double arrow2Y;

  final int puller1Frame;
  final int puller2Frame;

  final String mass1Label;
  final String mass2Label;

  final Offset rulerCenterView;
  final double rulerWidthView;
  final double rulerHeightView;
  final double majorTickSpacingView;
}
