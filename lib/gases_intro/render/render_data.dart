import 'dart:ui' show Color;

import '../model/hold_constant.dart';
import '../model/particle.dart';

/// Immutable snapshot for painters — no physics in the view.
class RenderData {
  const RenderData({
    required this.containerLeft,
    required this.containerRight,
    required this.containerBottom,
    required this.containerTop,
    required this.wallThickness,
    required this.lidIsOn,
    required this.lidWidth,
    required this.isOpen,
    required this.openingLeft,
    required this.openingRight,
    required this.particles,
    required this.temperatureK,
    required this.pressureKpa,
    required this.displayedPressureKpa,
    required this.volumePm3,
    required this.numberOfHeavy,
    required this.numberOfLight,
    required this.isPlaying,
    required this.heatCoolFactor,
    required this.holdConstant,
    required this.widthVisible,
    required this.widthPm,
  });

  final double containerLeft;
  final double containerRight;
  final double containerBottom;
  final double containerTop;
  final double wallThickness;
  final bool lidIsOn;
  final double lidWidth;
  final bool isOpen;
  final double openingLeft;
  final double openingRight;
  final List<ParticleRender> particles;
  final double? temperatureK;
  final double pressureKpa;
  final double displayedPressureKpa;
  final double volumePm3;
  final int numberOfHeavy;
  final int numberOfLight;
  final bool isPlaying;
  final double heatCoolFactor;
  final HoldConstant holdConstant;
  final bool widthVisible;
  final double widthPm;
}

class ParticleRender {
  const ParticleRender({
    required this.x,
    required this.y,
    required this.radius,
    required this.kind,
    required this.color,
    required this.highlight,
  });

  final double x;
  final double y;
  final double radius;
  final ParticleKind kind;
  final Color color;
  final Color highlight;
}
