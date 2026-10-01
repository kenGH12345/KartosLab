import 'dart:ui' show Offset;

import 'package:kratos/under_pressure/model/under_pressure_constants.dart';

/// Source: `UnderPressureScreenView` MVT
/// `ModelViewTransform2.createSinglePointScaleInvertedYMapping(ZERO, (0,245), 70)`
class UpMvt {
  const UpMvt({
    this.viewOrigin = const Offset(0, 245),
    this.scale = metersToPixels,
  });

  /// 1 m = 70 px (source).
  static const double metersToPixels = 70;

  /// Layout bounds from `Constants.SCREEN_VIEW_OPTIONS`.
  static const double layoutWidth = UnderPressureConstants.layoutWidth;
  static const double layoutHeight = UnderPressureConstants.layoutHeight;

  final Offset viewOrigin;
  final double scale;

  /// Model (x right, y up) → view (x right, y down).
  Offset modelToView(double x, double y) => Offset(
        viewOrigin.dx + x * scale,
        viewOrigin.dy - y * scale,
      );

  Offset modelToViewOffset(Offset model) => modelToView(model.dx, model.dy);

  /// View → model.
  Offset viewToModel(double vx, double vy) => Offset(
        (vx - viewOrigin.dx) / scale,
        (viewOrigin.dy - vy) / scale,
      );

  Offset viewToModelOffset(Offset view) => viewToModel(view.dx, view.dy);

  double modelToViewDeltaX(double dx) => dx * scale;

  /// Inverted-Y: positive model Δy → negative view Δy.
  double modelToViewDeltaY(double dy) => -dy * scale;

  double viewToModelDeltaX(double dvx) => dvx / scale;

  /// Source `viewToModelDeltaY`: positive view Δy (down) → negative model Δy.
  double viewToModelDeltaY(double dvy) => -dvy / scale;
}

/// Barometer geometry constants from `BarometerNode` + ScreenView options.
class UpBarometerMetrics {
  UpBarometerMetrics._();

  /// ScreenView: `scale: 1.5`
  static const double nodeScale = 1.5;

  /// Empirically determined distance center → tip (local px before node scale).
  /// Source option `pressureReadOffset: 51` matches gauge+stem+triangle extent.
  static const double pressureReadOffsetLocalPx = 51;

  /// Tip offset in **parent view** pixels (below center).
  static double get tipOffsetViewPx =>
      pressureReadOffsetLocalPx * nodeScale; // 76.5

  /// Model Δy from gauge center to tip (negative = below ground when tip lower).
  static double tipDeltaYModel(UpMvt mvt) =>
      mvt.viewToModelDeltaY(tipOffsetViewPx);

  /// Tip model position from sensor center (model meters).
  static Offset tipFromCenter(Offset center, UpMvt mvt) => Offset(
        center.dx,
        center.dy + tipDeltaYModel(mvt),
      );
}
