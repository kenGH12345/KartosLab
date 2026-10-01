import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../bending_light_constants.dart';
import '../model/bl_vec2.dart';

/// Model-view transform matching PhET `createSinglePointScaleInvertedYMapping`.
///
/// Model +y up → view +y down. Maps model origin to [viewOrigin].
class BlMvt {
  const BlMvt({
    required this.viewOrigin,
    required this.scaleX,
    required this.scaleY,
  });

  final Offset viewOrigin;
  final double scaleX;
  final double scaleY;

  /// Stroke and icon scale. Matches [scaleX] when the axes are equal.
  double get scale => math.min(scaleX, scaleY);

  static double get stageHeight => BendingLightConstants.layoutBoundsHeight;
  static double get stageWidth => BendingLightConstants.layoutBoundsWidth;

  /// `scale = stageHeight / modelHeight`
  static double get defaultScale =>
      stageHeight / BendingLightConstants.modelHeight;

  /// Intro: horizontal=102, vertical=0 → (286, 252)
  ///
  /// [viewScale] keeps both axes equal for tests that paint an 834×504 picture.
  /// The viewport passes [viewScaleX] and [viewScaleY] so the stage fills the window.
  factory BlMvt.intro({
    double viewScale = 1,
    double? viewScaleX,
    double? viewScaleY,
  }) {
    final sx = viewScaleX ?? viewScale;
    final sy = viewScaleY ?? viewScale;
    return BlMvt(
      viewOrigin: Offset((388 - 102) * sx, (504 / 2) * sy),
      scaleX: defaultScale * sx,
      scaleY: defaultScale * sy,
    );
  }

  /// Prisms: horizontal=240, vertical=-43 → (148, 209)
  factory BlMvt.prisms({
    double viewScale = 1,
    double? viewScaleX,
    double? viewScaleY,
  }) {
    final sx = viewScaleX ?? viewScale;
    final sy = viewScaleY ?? viewScale;
    return BlMvt(
      viewOrigin: Offset((388 - 240) * sx, (504 / 2 - 43) * sy),
      scaleX: defaultScale * sx,
      scaleY: defaultScale * sy,
    );
  }

  /// More Tools: horizontal=0, vertical=0 → (388, 252)
  factory BlMvt.moreTools({
    double viewScale = 1,
    double? viewScaleX,
    double? viewScaleY,
  }) {
    final sx = viewScaleX ?? viewScale;
    final sy = viewScaleY ?? viewScale;
    return BlMvt(
      viewOrigin: Offset(388 * sx, (504 / 2) * sy),
      scaleX: defaultScale * sx,
      scaleY: defaultScale * sy,
    );
  }

  Offset worldToScreen(BlVec2 world) => Offset(
        viewOrigin.dx + world.x * scaleX,
        viewOrigin.dy - world.y * scaleY,
      );

  BlVec2 screenToWorld(Offset screen) => BlVec2(
        (screen.dx - viewOrigin.dx) / scaleX,
        (viewOrigin.dy - screen.dy) / scaleY,
      );

  Offset modelToViewDelta(BlVec2 delta) =>
      Offset(delta.x * scaleX, -delta.y * scaleY);

  BlVec2 viewToModelDelta(Offset delta) =>
      BlVec2(delta.dx / scaleX, -delta.dy / scaleY);
}
