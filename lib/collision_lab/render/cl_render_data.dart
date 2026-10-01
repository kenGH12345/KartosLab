import 'dart:ui';

import 'package:flutter/material.dart';

/// Immutable snapshot for painters.
class ClRenderData {
  const ClRenderData({
    required this.playAreaRect,
    required this.reflectingBorder,
    required this.gridVisible,
    required this.is1d,
    required this.balls,
    required this.pathTrails,
    required this.velocityVectors,
    required this.momentumVectors,
    required this.changeInMomentumVectors,
    required this.changeInMomentumOpacity,
    required this.comPosition,
    required this.comVisible,
    required this.kineticEnergy,
    required this.kineticEnergyVisible,
    required this.valuesVisible,
    required this.showReturnBalls,
    required this.elapsedTime,
    required this.momentaExpanded,
    required this.momentaVectors,
    required this.totalMomenta,
    required this.momentaBounds,
    required this.momentaZoom,
  });

  final Rect playAreaRect;
  final bool reflectingBorder;
  final bool gridVisible;
  final bool is1d;
  final List<ClBallRender> balls;
  final List<ClPathTrailRender> pathTrails;
  final List<ClVectorRender> velocityVectors;
  final List<ClVectorRender> momentumVectors;
  final List<ClVectorRender> changeInMomentumVectors;
  final double changeInMomentumOpacity;
  final Offset? comPosition;
  final bool comVisible;
  final double kineticEnergy;
  final bool kineticEnergyVisible;
  final bool valuesVisible;
  final bool showReturnBalls;
  final double elapsedTime;
  final bool momentaExpanded;
  final List<ClVectorRender> momentaVectors;
  final ClVectorRender? totalMomenta;
  final Rect momentaBounds;
  final double momentaZoom;
}

class ClBallRender {
  const ClBallRender({
    required this.center,
    required this.radius,
    required this.color,
    required this.label,
    required this.rotation,
    this.valueLabel,
  });

  final Offset center;
  final double radius;
  final Color color;
  final String label;
  final double rotation;
  final String? valueLabel;
}

class ClPathTrailRender {
  const ClPathTrailRender({required this.points, required this.color});
  final List<Offset> points;
  final Color color;
}

class ClVectorRender {
  const ClVectorRender({
    required this.tail,
    required this.tip,
    required this.color,
    this.label,
  });

  final Offset tail;
  final Offset tip;
  final Color color;
  final String? label;
}
