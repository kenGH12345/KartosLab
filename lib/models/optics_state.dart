import 'package:flutter/material.dart';

enum SimMode { lens, mirror }

enum LensKind { convex, concave }

enum MirrorKind { concave, convex, plane }

enum RayMode { edge, principal, many, none }

extension SimModeLabel on SimMode {
  String get label => switch (this) {
    SimMode.lens => '透镜',
    SimMode.mirror => '镜面',
  };
}

extension RayModeLabel on RayMode {
  String get label => switch (this) {
    RayMode.edge => '边缘光线',
    RayMode.principal => '主要光线',
    RayMode.many => '多光线',
    RayMode.none => '无光线',
  };
}

@immutable
class OpticsState {
  const OpticsState({
    this.mode = SimMode.lens,
    this.lensKind = LensKind.convex,
    this.mirrorKind = MirrorKind.concave,
    this.rayMode = RayMode.edge,
    this.radius = 80,
    this.refractiveIndex = 1.5,
    this.diameter = 80,
    this.objectX = -185,
    this.objectHeight = 78,
    this.showFocalPoints = true,
    this.showVirtualImage = true,
    this.showLabels = false,
    this.showSecondPoint = false,
    this.showHorizontalRuler = false,
    this.showVerticalRuler = false,
    this.dragLocked = false,
    this.zoom = 1,
  });

  final SimMode mode;
  final LensKind lensKind;
  final MirrorKind mirrorKind;
  final RayMode rayMode;
  final double radius;
  final double refractiveIndex;
  final double diameter;
  final double objectX;
  final double objectHeight;
  final bool showFocalPoints;
  final bool showVirtualImage;
  final bool showLabels;
  final bool showSecondPoint;
  final bool showHorizontalRuler;
  final bool showVerticalRuler;
  final bool dragLocked;
  final double zoom;

  OpticsState copyWith({
    SimMode? mode,
    LensKind? lensKind,
    MirrorKind? mirrorKind,
    RayMode? rayMode,
    double? radius,
    double? refractiveIndex,
    double? diameter,
    double? objectX,
    double? objectHeight,
    bool? showFocalPoints,
    bool? showVirtualImage,
    bool? showLabels,
    bool? showSecondPoint,
    bool? showHorizontalRuler,
    bool? showVerticalRuler,
    bool? dragLocked,
    double? zoom,
  }) {
    return OpticsState(
      mode: mode ?? this.mode,
      lensKind: lensKind ?? this.lensKind,
      mirrorKind: mirrorKind ?? this.mirrorKind,
      rayMode: rayMode ?? this.rayMode,
      radius: radius ?? this.radius,
      refractiveIndex: refractiveIndex ?? this.refractiveIndex,
      diameter: diameter ?? this.diameter,
      objectX: objectX ?? this.objectX,
      objectHeight: objectHeight ?? this.objectHeight,
      showFocalPoints: showFocalPoints ?? this.showFocalPoints,
      showVirtualImage: showVirtualImage ?? this.showVirtualImage,
      showLabels: showLabels ?? this.showLabels,
      showSecondPoint: showSecondPoint ?? this.showSecondPoint,
      showHorizontalRuler: showHorizontalRuler ?? this.showHorizontalRuler,
      showVerticalRuler: showVerticalRuler ?? this.showVerticalRuler,
      dragLocked: dragLocked ?? this.dragLocked,
      zoom: zoom ?? this.zoom,
    );
  }

  OpticsState resetForMode(SimMode nextMode) {
    if (nextMode == SimMode.lens) {
      return const OpticsState(mode: SimMode.lens);
    }
    return const OpticsState(
      mode: SimMode.mirror,
      radius: 180,
      objectX: -170,
      mirrorKind: MirrorKind.concave,
    );
  }

  OpticsState resetCurrent() => resetForMode(mode);
}
