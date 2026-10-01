import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../curve_fitting_colors.dart';
import '../curve_fitting_constants.dart';
import '../curve_fitting_strings.dart';
import '../model/curve_fitting_model.dart';
import '../painters/curve_painter.dart';
import '../painters/graph_area_painter.dart';
import '../painters/residual_painter.dart';
import '../render/cf_render_builder.dart';
import '../transform/math_coordinate_transform.dart';
import '../widgets/bucket_widget.dart';
import '../widgets/control_panels_column.dart';
import '../widgets/data_point_widget.dart';
import '../widgets/deviations_panel.dart';
import '../widgets/equation_overlay.dart';

/// Full ScreenView layout — PhET `CurveFittingScreenView`.
///
/// Graph paint + bucket + points share a full-bleed interaction layer so the
/// bucket (model x≈−13.5) is not stolen by a full-height left column.
/// Side panels use intrinsic hit bounds only.
///
/// Curve / residual painters listen to [CurveFittingModel.paintEpoch] so drag
/// updates repaint without rebuilding gesture widgets.
class CfScreenBody extends StatefulWidget {
  const CfScreenBody({super.key, required this.model});

  final CurveFittingModel model;

  @override
  State<CfScreenBody> createState() => _CfScreenBodyState();
}

class _CfScreenBodyState extends State<CfScreenBody> {
  final GlobalKey _interactionKey = GlobalKey();
  final GlobalKey<ControlPanelsColumnState> _controlsKey =
      GlobalKey<ControlPanelsColumnState>();
  final _builder = const CfRenderBuilder();

  static const _bumpDilation = 0.45;

  CurveFittingModel get model => widget.model;

  void bumpOut(MathCoordinateTransform transform) {
    if (!model.curveVisible) return;
    final btnCenter = const Offset(-9.2, 9.2);
    final push = Rect.fromCenter(
      center: btnCenter,
      width: 1.2 + 2 * _bumpDilation,
      height: 1.2 + 2 * _bumpDilation,
    );
    var guard = 0;
    while (guard++ < 40) {
      final under = model.points.points.where((p) {
        return p.x >= push.left &&
            p.x <= push.right &&
            p.y >= push.top &&
            p.y <= push.bottom;
      }).toList();
      if (under.isEmpty) break;
      for (final p in under) {
        var dx = p.x - push.center.dx;
        var dy = p.y - push.center.dy;
        if (dx.abs() < 1e-9 && dy.abs() < 1e-9) {
          dx = 0.05;
          dy = 0.05;
        }
        final len = math.sqrt(dx * dx + dy * dy);
        p.setPosition(p.x + dx / len * 0.05, p.y + dy / len * 0.05);
      }
    }
  }

  void _resetAll() {
    model.reset();
    _controlsKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CurveFittingColors.screenBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final colW = CurveFittingConstants.columnOuterWidth;
          final graphW = math.max(1.0, w - 2 * colW);
          final graphSize = Size(graphW, h);

          final transform = MathCoordinateTransform.forGraphViewport(
            graphSize,
            viewOriginInParent: Offset(colW + graphW / 2, h / 2),
          );

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Stack(
                  key: _interactionKey,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ValueListenableBuilder<int>(
                          valueListenable: model.paintEpoch,
                          builder: (context, _, child) {
                            final render = _builder.build(
                              model,
                              transform: transform,
                              layoutSize: Size(w, h),
                            );
                            return CustomPaint(
                              painter: GraphAreaPainter(
                                render: render,
                                transform: transform,
                              ),
                              child: CustomPaint(
                                painter: CurvePainter(
                                  render: render,
                                  transform: transform,
                                ),
                                child: CustomPaint(
                                  painter: ResidualPainter(
                                    render: render,
                                    transform: transform,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    BucketWidget(
                      model: model,
                      transform: transform,
                      layoutKey: _interactionKey,
                      onBumpOut: () => bumpOut(transform),
                    ),
                    for (final p in model.points.points)
                      DataPointWidget(
                        key: ObjectKey(p),
                        model: model,
                        point: p,
                        transform: transform,
                        layoutKey: _interactionKey,
                        onBumpOut: () => bumpOut(transform),
                      ),
                    Positioned(
                      left:
                          transform.modelToView(const Offset(-10, 0)).dx + 10,
                      top: transform.modelToView(const Offset(0, 10)).dy + 10,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: transform
                                  .modelToView(const Offset(10, 0))
                                  .dx -
                              (transform
                                      .modelToView(const Offset(-10, 0))
                                      .dx +
                                  10) -
                              65,
                        ),
                        child: EquationOverlay(model: model),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: (colW - CurveFittingConstants.panelMaxWidth) / 2,
                top: CurveFittingConstants.screenViewYMargin,
                width: CurveFittingConstants.panelMaxWidth,
                child: ValueListenableBuilder<int>(
                  valueListenable: model.paintEpoch,
                  builder: (context, _, child) => DeviationsPanel(model: model),
                ),
              ),
              Positioned(
                right: (colW - CurveFittingConstants.panelMaxWidth) / 2,
                top: CurveFittingConstants.screenViewYMargin,
                width: CurveFittingConstants.panelMaxWidth,
                child: ControlPanelsColumn(
                  key: _controlsKey,
                  model: model,
                ),
              ),
              Positioned(
                right: CurveFittingConstants.screenViewXMargin,
                bottom: CurveFittingConstants.screenViewYMargin,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onPressed: _resetAll,
                  child: const Text(CurveFittingStrings.resetAll),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
