import 'dart:ui';

/// Immutable snapshot for curve-fitting painters.
class CfRenderData {
  const CfRenderData({
    required this.layoutSize,
    required this.graphBackgroundView,
    required this.graphAxesView,
    required this.originView,
    required this.curveVisible,
    required this.residualsVisible,
    required this.valuesVisible,
    required this.isCurvePresent,
    required this.curveSamplesView,
    required this.points,
    required this.residuals,
    required this.order,
    required this.coefficients,
    required this.rSquared,
    required this.chiSquared,
  });

  final Size layoutSize;
  final Rect graphBackgroundView;
  final Rect graphAxesView;
  final Offset originView;

  final bool curveVisible;
  final bool residualsVisible;
  final bool valuesVisible;
  final bool isCurvePresent;

  /// Polyline samples already in view coordinates.
  final List<Offset> curveSamplesView;

  final List<CfPointRender> points;

  /// Vertical residual segments in view coordinates:
  /// from observed (x, yObs) to fitted (x, yFit).
  final List<CfResidualRender> residuals;

  final int order;
  final List<double> coefficients;
  final double rSquared;
  final double chiSquared;
}

class CfPointRender {
  const CfPointRender({
    required this.viewCenter,
    required this.deltaViewHalf,
    required this.x,
    required this.y,
    required this.delta,
    required this.isInsideGraph,
    required this.dragging,
  });

  final Offset viewCenter;

  /// Half error-bar length in view px (model δ → view |Δy|).
  final double deltaViewHalf;

  final double x;
  final double y;
  final double delta;
  final bool isInsideGraph;
  final bool dragging;
}

class CfResidualRender {
  const CfResidualRender({
    required this.fromView,
    required this.toView,
    required this.yObs,
    required this.yFit,
  });

  /// View position of observed point (x, yObs).
  final Offset fromView;

  /// View position of curve at same x (x, yFit).
  final Offset toView;

  final double yObs;
  final double yFit;
}
