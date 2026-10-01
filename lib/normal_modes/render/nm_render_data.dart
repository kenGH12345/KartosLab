import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/amplitude_direction.dart';
import '../normal_modes_constants.dart';

class SpringRender {
  const SpringRender({required this.p1, required this.p2, required this.visible});
  final Offset p1;
  final Offset p2;
  final bool visible;
}

class MassRender {
  const MassRender({
    required this.center,
    required this.visible,
    required this.index,
    this.indexI,
    this.indexJ,
    required this.showArrows,
    required this.arrowDirection,
    this.rotateArrows = false,
  });
  final Offset center;
  final bool visible;
  final int index;
  final int? indexI;
  final int? indexJ;
  final bool showArrows;
  final AmplitudeDirection arrowDirection;
  final bool rotateArrows;
}

class WallRender {
  const WallRender({required this.center});
  final Offset center;
}

class ModeGraphRender {
  const ModeGraphRender({
    required this.modeIndex,
    required this.ys,
    required this.drawWalls,
  });
  final int modeIndex;
  final List<double> ys;
  final bool drawWalls;
}

class NmRenderData {
  const NmRenderData({
    required this.springs,
    required this.masses,
    required this.walls,
    required this.border,
    required this.staticGraphs,
    required this.modeGraphs,
    required this.numberOfMasses,
    required this.amplitudes,
    required this.phases,
    required this.frequencyLabels,
    required this.ampX,
    required this.ampY,
    required this.maxAmplitude2D,
    required this.amplitudeDirection,
    required this.phasesVisible,
    required this.springsVisible,
    required this.playing,
    required this.time,
  });

  final List<SpringRender> springs;
  final List<MassRender> masses;
  final List<WallRender> walls;
  final Rect? border;
  final List<ModeGraphRender> staticGraphs;
  final List<ModeGraphRender> modeGraphs;
  final int numberOfMasses;
  final List<double> amplitudes;
  final List<double> phases;
  final List<String> frequencyLabels;
  final List<List<double>> ampX;
  final List<List<double>> ampY;
  final double maxAmplitude2D;
  final AmplitudeDirection amplitudeDirection;
  final bool phasesVisible;
  final bool springsVisible;
  final bool playing;
  final double time;
}

/// Curve samples from StaticModeGraphCanvasNode / ModeGraphCanvasNode.
class ModeCurveMath {
  ModeCurveMath._();

  static List<double> curveYs({
    required int modeIndex,
    required int resolution,
    required double graphHeight,
    required double amplitude,
    required double cosTerm,
  }) {
    final heightFactor = -(2 * graphHeight / 3);
    final ys = List<double>.filled(resolution, 0);
    for (var i = 0; i < resolution; i++) {
      final x = i / resolution;
      final sin = math.sin(x * (modeIndex + 1) * math.pi);
      ys[i] = heightFactor *
          (amplitude * sin * cosTerm) /
          NormalModesConstants.maxAmplitude;
    }
    return ys;
  }
}
