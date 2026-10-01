import 'dart:ui';

import '../pm_constants.dart';

/// PhET `ModelViewTransform2.createSinglePointScaleInvertedYMapping(
///   Vector2.ZERO, VIEW_ORIGIN, DEFAULT_SCALE * zoom )`（ScreenView:116, 310-312）
///
/// model→view：vx = 70 + 30z·x；vy = 510 − 30z·y
class PmTransform {
  const PmTransform({this.zoom = PmConstants.defaultZoom});

  final double zoom;

  Offset get origin => PmConstants.viewOrigin;
  double get scale => PmConstants.defaultScale * zoom;

  Offset modelToView(Offset p) => Offset(
        origin.dx + scale * p.dx,
        origin.dy - scale * p.dy,
      );

  Offset viewToModel(Offset v) => Offset(
        (v.dx - origin.dx) / scale,
        (origin.dy - v.dy) / scale,
      );

  double modelToViewDeltaX(double dx) => scale * dx;
  double modelToViewDeltaY(double dy) => scale * dy;
  double viewToModelDeltaX(double dx) => dx / scale;
  double viewToModelDeltaY(double dy) => dy / scale;
}
