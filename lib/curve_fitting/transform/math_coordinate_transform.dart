import 'dart:math' as math;
import 'dart:ui';

import '../curve_fitting_constants.dart';

/// Model ↔ view transform.
///
/// PhET `ModelViewTransform2.createSinglePointScaleInvertedYMapping`:
/// model origin (0,0) → [viewOrigin], scale [scale], +y model → −y view.
/// **All Y inversion lives here** — painters must not flip Y themselves.
class MathCoordinateTransform {
  const MathCoordinateTransform({
    required this.viewOrigin,
    this.scale = CurveFittingConstants.mvtScale,
  });

  /// View pixel where model (0,0) maps (layout center for full ScreenView).
  final Offset viewOrigin;

  /// Uniform scale (model unit → view px). Default 25.5.
  final double scale;

  /// Full-layout transform: origin at layout center (1024×618).
  factory MathCoordinateTransform.forLayout({
    double width = CurveFittingConstants.layoutWidth,
    double height = CurveFittingConstants.layoutHeight,
    double scale = CurveFittingConstants.mvtScale,
  }) {
    return MathCoordinateTransform(
      viewOrigin: Offset(width / 2, height / 2),
      scale: scale,
    );
  }

  /// Graph viewport transform: scale fits model background span [-10, 10]
  /// (= 20) into the smaller side of [graphSize].
  ///
  /// [viewOriginInParent] is where model (0,0) maps in the *parent* coordinate
  /// system (full-bleed interaction layer). Defaults to graphSize center when
  /// the graph fills its parent.
  factory MathCoordinateTransform.forGraphViewport(
    Size graphSize, {
    Offset? viewOriginInParent,
  }) {
    final scale = math.min(graphSize.width, graphSize.height) /
        CurveFittingConstants.graphBackgroundSpan;
    return MathCoordinateTransform(
      viewOrigin: viewOriginInParent ??
          Offset(graphSize.width / 2, graphSize.height / 2),
      scale: scale <= 0 ? CurveFittingConstants.mvtScale : scale,
    );
  }

  Offset modelToView(Offset p) =>
      Offset(viewOrigin.dx + p.dx * scale, viewOrigin.dy - p.dy * scale);

  Offset viewToModel(Offset p) => Offset(
        (p.dx - viewOrigin.dx) / scale,
        (viewOrigin.dy - p.dy) / scale,
      );

  Offset modelToViewDelta(Offset d) => Offset(d.dx * scale, -d.dy * scale);

  Offset viewToModelDelta(Offset d) => Offset(d.dx / scale, -d.dy / scale);

  double modelToViewDeltaX(double dx) => dx * scale;
  double modelToViewDeltaY(double dy) => -dy * scale;
  double viewToModelDeltaX(double dx) => dx / scale;
  double viewToModelDeltaY(double dy) => -dy / scale;

  Rect modelToViewRect(Rect r) {
    final a = modelToView(Offset(r.left, r.top));
    final b = modelToView(Offset(r.right, r.bottom));
    return Rect.fromPoints(a, b);
  }
}
