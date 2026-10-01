import 'package:flutter/material.dart';

import '../gflb_colors.dart';
import '../gflb_constants.dart';
import '../gflb_strings.dart';
import '../model/gravity_model.dart';
import '../painters/sphere_force_painter.dart';
import '../render/gflb_render_builder.dart';
import '../transform/math_coordinate_transform.dart';
import '../widgets/distance_arrow_widget.dart';
import '../widgets/gflb_checkbox_panel.dart';
import '../widgets/mass_drag_layer.dart';
import '../widgets/mass_number_picker.dart';
import '../widgets/puller_image_widget.dart';

/// Full ScreenView layout — PhET `GFLBScreenView` positions.
class GflbScreenBody extends StatefulWidget {
  const GflbScreenBody({super.key, required this.model});

  final GravityModel model;

  @override
  State<GflbScreenBody> createState() => _GflbScreenBodyState();
}

class _GflbScreenBodyState extends State<GflbScreenBody> {
  final GlobalKey _layoutKey = GlobalKey();
  static const _builder = GflbRenderBuilder();

  GravityModel get model => widget.model;

  @override
  Widget build(BuildContext context) {
    final transform = MathCoordinateTransform.forLayout();

    return ColoredBox(
      color: GflbColors.screenBackground,
      child: ValueListenableBuilder<int>(
        valueListenable: model.paintEpoch,
        builder: (context, _, child) {
          return ListenableBuilder(
            listenable: model,
            builder: (context, _) {
              final render = _builder.build(model, transform: transform);
              return SizedBox(
                key: _layoutKey,
                width: GflbConstants.layoutWidth,
                height: GflbConstants.layoutHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    PullerImageWidget(
                      frameIndex: render.puller1Frame,
                      massCenter: render.mass1Center,
                      massRadiusView: render.mass1RadiusView,
                      flipHorizontal: false,
                    ),
                    PullerImageWidget(
                      frameIndex: render.puller2Frame,
                      massCenter: render.mass2Center,
                      massRadiusView: render.mass2RadiusView,
                      flipHorizontal: true,
                    ),
                    CustomPaint(
                      size: render.layoutSize,
                      painter: SphereForcePainter(render: render),
                    ),
                    DistanceArrowWidget(render: render),
                    MassDragTarget(
                      model: model,
                      transform: transform,
                      layoutKey: _layoutKey,
                      which: 1,
                      center: render.mass1Center,
                      radiusView: render.mass1RadiusView,
                    ),
                    MassDragTarget(
                      model: model,
                      transform: transform,
                      layoutKey: _layoutKey,
                      which: 2,
                      center: render.mass2Center,
                      radiusView: render.mass2RadiusView,
                    ),
                    Positioned(
                      right: GflbConstants.checkboxPanelRightInset,
                      top: GflbConstants.massControlsY - 110,
                      child: GflbCheckboxPanel(model: model),
                    ),
                    Positioned(
                      right: GflbConstants.checkboxPanelRightInset +
                          180 +
                          GflbConstants.panelSpacing,
                      top: GflbConstants.massControlsY - 110,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MassNumberPicker(
                            model: model,
                            which: 1,
                            title: GflbStrings.mass1,
                            accent: GflbColors.mass1Base,
                          ),
                          const SizedBox(width: GflbConstants.panelSpacing),
                          MassNumberPicker(
                            model: model,
                            which: 2,
                            title: GflbStrings.mass2,
                            accent: GflbColors.mass2Base,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: _ResetButton(onPressed: model.reset),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: GflbStrings.resetAll,
      child: Material(
        color: Colors.orange.shade700,
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.refresh, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
