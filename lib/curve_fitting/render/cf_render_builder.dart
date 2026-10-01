import 'dart:ui';

import '../curve_fitting_constants.dart';
import '../model/curve_fitting_model.dart';
import '../transform/math_coordinate_transform.dart';
import 'cf_render_data.dart';

/// Builds [CfRenderData] from model + transform (no painter-side math).
class CfRenderBuilder {
  const CfRenderBuilder();

  CfRenderData build(
    CurveFittingModel model, {
    MathCoordinateTransform? transform,
    Size? layoutSize,
  }) {
    final layout = layoutSize ??
        const Size(
          CurveFittingConstants.layoutWidth,
          CurveFittingConstants.layoutHeight,
        );
    final t = transform ??
        MathCoordinateTransform.forLayout(
          width: layout.width,
          height: layout.height,
        );

    final curve = model.curve;
    final samplesModel = curve.isCurvePresent ? curve.getShapeSamples() : const <Offset>[];
    final samplesView =
        samplesModel.map(t.modelToView).toList(growable: false);

    final pointRenders = <CfPointRender>[];
    for (final p in model.points.points) {
      pointRenders.add(
        CfPointRender(
          viewCenter: t.modelToView(Offset(p.x, p.y)),
          deltaViewHalf: t.modelToViewDeltaY(p.delta).abs(),
          x: p.x,
          y: p.y,
          delta: p.delta,
          isInsideGraph: p.isInsideGraph,
          dragging: p.dragging,
        ),
      );
    }

    final residualRenders = <CfResidualRender>[];
    if (model.residualsVisible && curve.isCurvePresent) {
      for (final p in model.points.getRelevantPoints()) {
        final yFit = curve.getYValueAt(p.x);
        residualRenders.add(
          CfResidualRender(
            fromView: t.modelToView(Offset(p.x, p.y)),
            toView: t.modelToView(Offset(p.x, yFit)),
            yObs: p.y,
            yFit: yFit,
          ),
        );
      }
    }

    return CfRenderData(
      layoutSize: layout,
      graphBackgroundView:
          t.modelToViewRect(CurveFittingConstants.graphBackgroundModelBounds),
      graphAxesView: t.modelToViewRect(CurveFittingConstants.graphAxesBounds),
      originView: t.modelToView(Offset.zero),
      curveVisible: model.curveVisible,
      residualsVisible: model.residualsVisible,
      valuesVisible: model.valuesVisible,
      isCurvePresent: curve.isCurvePresent,
      curveSamplesView: samplesView,
      points: pointRenders,
      residuals: residualRenders,
      order: model.order,
      coefficients: List<double>.from(curve.coefficients),
      rSquared: curve.rSquared,
      chiSquared: curve.chiSquared,
    );
  }
}
