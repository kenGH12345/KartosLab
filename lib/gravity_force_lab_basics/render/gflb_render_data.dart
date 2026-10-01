import 'dart:ui';

import 'package:flutter/material.dart';

/// Immutable snapshot for GFLB painters / widgets.
class GflbRenderData {
  const GflbRenderData({
    required this.layoutSize,
    required this.mass1Center,
    required this.mass2Center,
    required this.mass1RadiusView,
    required this.mass2RadiusView,
    required this.mass1Color,
    required this.mass2Color,
    required this.constantSize,
    required this.force,
    required this.forceLabel,
    required this.showForceValues,
    required this.showDistance,
    required this.distanceKmLabel,
    required this.arrow1TipDx,
    required this.arrow2TipDx,
    required this.arrow1Y,
    required this.arrow2Y,
    required this.puller1Frame,
    required this.puller2Frame,
    required this.mass1Label,
    required this.mass2Label,
  });

  final Size layoutSize;

  final Offset mass1Center;
  final Offset mass2Center;
  final double mass1RadiusView;
  final double mass2RadiusView;
  final Color mass1Color;
  final Color mass2Color;
  final bool constantSize;

  final double force;
  final String forceLabel;
  final bool showForceValues;
  final bool showDistance;
  final String distanceKmLabel;

  /// Arrow tip X offset from mass center (view px); sign encodes direction.
  final double arrow1TipDx;
  final double arrow2TipDx;
  final double arrow1Y;
  final double arrow2Y;

  final int puller1Frame;
  final int puller2Frame;

  final String mass1Label;
  final String mass2Label;
}
