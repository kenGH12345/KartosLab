import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../density_constants.dart';
import '../model/density_vec.dart';

/// World (metres, y-up) ↔ screen (logical px, y-down).
///
/// Physics stays in SI. Painters and pointers only talk through this transform.
class DensityMvt {
  const DensityMvt({
    required this.origin,
    required this.scale,
    required this.canvasSize,
  });

  /// Screen pixel of world (0, 0) — ground center.
  final Offset origin;

  /// px per metre.
  final double scale;
  final Size canvasSize;

  static const double worldLeft = -0.95;
  static const double worldRight = 0.95;
  static const double worldBottom = -0.50;
  static const double worldTop = 0.58;

  static double get poolHeight =>
      DensityConstants.poolGeometricVolume /
      DensityConstants.poolWidth /
      DensityConstants.poolDepth;

  static double get poolMinX => -DensityConstants.poolWidth / 2;
  static double get poolMaxX => DensityConstants.poolWidth / 2;
  static double get poolMinY => -poolHeight;
  static const double poolMaxY = 0;
  static double get poolMinZ => -DensityConstants.poolDepth / 2;
  static double get poolMaxZ => DensityConstants.poolDepth / 2;

  /// Invisible barrier default (`DensityBuoyancyModel.ts`).
  static const double barrierMinX = -0.875;
  static const double barrierMaxX = 0.875;

  factory DensityMvt.fit(Size canvas) {
    const worldW = worldRight - worldLeft;
    const worldH = worldTop - worldBottom;
    final scale = math.min(canvas.width / worldW, canvas.height / worldH);
    final origin = Offset(
      canvas.width / 2 - ((worldLeft + worldRight) / 2) * scale,
      canvas.height / 2 + ((worldTop + worldBottom) / 2) * scale,
    );
    return DensityMvt(origin: origin, scale: scale, canvasSize: canvas);
  }

  Offset toScreen(DensityVec world) => Offset(
        origin.dx + world.x * scale,
        origin.dy - world.y * scale,
      );

  DensityVec toWorld(Offset screen) => DensityVec(
        (screen.dx - origin.dx) / scale,
        (origin.dy - screen.dy) / scale,
      );

  double toScreenDelta(double metres) => metres * scale;

  double toWorldDelta(double pixels) => pixels / scale;

  /// Axis-aligned front-face of a cube centered at [center] with volume [volume].
  Rect cubeFrontRect(DensityVec center, double volume) {
    final side = math.pow(volume, 1 / 3).toDouble();
    final half = toScreenDelta(side / 2);
    final c = toScreen(center);
    return Rect.fromCenter(center: c, width: half * 2, height: half * 2);
  }
}

/// Pool water surface y from fluid volume. Fills from pool floor.
double fluidSurfaceYFromVolume(double fluidVolumeM3) {
  final area = DensityConstants.poolWidth * DensityConstants.poolDepth;
  return DensityMvt.poolMinY + fluidVolumeM3 / area;
}
