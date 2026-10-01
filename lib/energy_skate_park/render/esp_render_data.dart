import 'dart:ui';

import 'package:flutter/material.dart';

/// Immutable snapshot for painters (no Model refs written back).
class EspRenderData {
  const EspRenderData({
    required this.size,
    required this.trackPolylines,
    required this.skaterCenter,
    required this.skaterAngle,
    required this.skaterDirectionLeft,
    required this.kineticEnergy,
    required this.potentialEnergy,
    required this.thermalEnergy,
    required this.totalEnergy,
    required this.speed,
    required this.pieChartVisible,
    required this.barGraphVisible,
    required this.speedVisible,
    required this.gridVisible,
    required this.pathDots,
    this.controlPointViews = const [],
    this.referenceHeight = 0,
    this.referenceHeightVisible = false,
    this.skaterMassScale = 0.46,
    this.selectedSkaterIndex = 0,
  });

  final Size size;
  final List<EspTrackPolyline> trackPolylines;
  final Offset skaterCenter;
  final double skaterAngle;
  final bool skaterDirectionLeft;
  final double kineticEnergy;
  final double potentialEnergy;
  final double thermalEnergy;
  final double totalEnergy;
  final double speed;
  final bool pieChartVisible;
  final bool barGraphVisible;
  final bool speedVisible;
  final bool gridVisible;
  final List<Offset> pathDots;
  final List<Offset> controlPointViews;
  final double referenceHeight;
  final bool referenceHeightVisible;
  final double skaterMassScale;
  final int selectedSkaterIndex;
}

class EspTrackPolyline {
  const EspTrackPolyline({required this.points, required this.physical});
  final List<Offset> points;
  final bool physical;
}
