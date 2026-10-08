import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../common/widgets/kratos_reset_all_button.dart';
import '../a11y/gfl_a11y_strings.dart';
import '../audio/gfl_audio.dart';
import '../gfl_colors.dart';
import '../gfl_strings.dart';
import '../model/gravity_force_constants.dart';
import '../model/gravity_force_lab_model.dart';
import '../painters/sphere_force_painter.dart';
import '../render/gfl_render_builder.dart';
import '../transform/math_coordinate_transform.dart';
import '../widgets/force_values_panel.dart';
import '../widgets/gfl_keyboard_help.dart';
import '../widgets/mass_control.dart';
import '../widgets/mass_drag_layer.dart';
import '../widgets/puller_image_widget.dart';
import '../widgets/ruler_widget.dart';

/// Full ScreenView layout — PhET `GravityForceLabScreenView`.
///
/// Focus order (NumericFocusOrder):
/// 1–2 spheres, 3 ruler, 10–11 mass controls, 40–43 force/constant,
/// 50 reset, 60 keyboard help.
class GflScreenBody extends StatefulWidget {
  const GflScreenBody({
    super.key,
    required this.model,
    this.audio,
  });

  final GravityForceLabModel model;
  final GflAudio? audio;

  @override
  State<GflScreenBody> createState() => _GflScreenBodyState();
}

class _GflScreenBodyState extends State<GflScreenBody>
    with SingleTickerProviderStateMixin {
  final GlobalKey _layoutKey = GlobalKey();
  static const _builder = GflRenderBuilder();

  late final GflAudio _audio;
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  GravityForceLabModel get model => widget.model;

  @override
  void initState() {
    super.initState();
    _audio = widget.audio ?? GflAudio();
    _audio.attach(model);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant GflScreenBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model) {
      _audio.attach(widget.model);
    }
  }

  void _onTick(Duration elapsed) {
    final dt = _lastTick == Duration.zero
        ? 0.0
        : (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dt > 0 && dt < 0.25) {
      _audio.step(dt);
    }
  }

  void _onReset() {
    _audio.beginReset();
    model.reset();
    _audio.endReset();
  }

  @override
  void dispose() {
    _ticker.dispose();
    if (widget.audio == null) {
      _audio.dispose();
    } else {
      _audio.detach();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transform = MathCoordinateTransform.forLayout();

    return Semantics(
      container: true,
      label: GflA11yStrings.screen,
      child: ColoredBox(
        color: GflColors.screenBackground,
        child: ValueListenableBuilder<int>(
          valueListenable: model.paintEpoch,
          builder: (context, _, child) {
            return ListenableBuilder(
              listenable: model,
              builder: (context, _) {
                final render = _builder.build(model, transform: transform);
                const layoutW = GravityForceConstants.layoutWidth;
                const layoutH = GravityForceConstants.layoutHeight;

                const resetRadius = 20.8 * 0.81;
                const resetBottom = 7.4;
                const resetRight = 15.0;

                return RulerKeyboardShortcuts(
                  model: model,
                  child: FocusTraversalGroup(
                    policy: OrderedTraversalPolicy(),
                    child: SizedBox(
                      key: _layoutKey,
                      width: layoutW,
                      height: layoutH,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Decorative paint — not focusable.
                          ExcludeSemantics(
                            child: IgnorePointer(
                              child: PullerImageWidget(
                                frameIndex: render.puller1Frame,
                                massCenter: render.mass1Center,
                                massRadiusView: render.mass1RadiusView,
                                flipHorizontal: false,
                              ),
                            ),
                          ),
                          ExcludeSemantics(
                            child: IgnorePointer(
                              child: PullerImageWidget(
                                frameIndex: render.puller2Frame,
                                massCenter: render.mass2Center,
                                massRadiusView: render.mass2RadiusView,
                                flipHorizontal: true,
                              ),
                            ),
                          ),
                          ExcludeSemantics(
                            child: IgnorePointer(
                              child: CustomPaint(
                                size: render.layoutSize,
                                painter: SphereForcePainter(render: render),
                              ),
                            ),
                          ),

                          Semantics(
                            container: true,
                            label: GflA11yStrings.spherePositionsGroup,
                            child: Stack(
                              children: [
                                MassDragTarget(
                                  model: model,
                                  transform: transform,
                                  layoutKey: _layoutKey,
                                  which: 1,
                                  center: render.mass1Center,
                                  radiusView: render.mass1RadiusView,
                                  focusOrder: 1,
                                ),
                                MassDragTarget(
                                  model: model,
                                  transform: transform,
                                  layoutKey: _layoutKey,
                                  which: 2,
                                  center: render.mass2Center,
                                  radiusView: render.mass2RadiusView,
                                  focusOrder: 2,
                                ),
                              ],
                            ),
                          ),

                          RulerWidget(
                            model: model,
                            render: render,
                            transform: transform,
                            layoutKey: _layoutKey,
                            audio: _audio,
                            focusOrder: 3,
                          ),

                          Positioned(
                            right: resetRight + resetRadius * 2 + 15,
                            bottom: resetBottom,
                            child: ForceValuesPanel(
                              model: model,
                              focusOrderStart: 40,
                            ),
                          ),
                          Positioned(
                            right:
                                resetRight + resetRadius * 2 + 15 + 160 + 35,
                            bottom: resetBottom,
                            child: MassControlPanel(
                              model: model,
                              which: 2,
                              title: GflStrings.mass2,
                              accent: GflColors.mass2Base,
                              audio: _audio,
                              focusOrder: 11,
                            ),
                          ),
                          Positioned(
                            right: resetRight +
                                resetRadius * 2 +
                                15 +
                                160 +
                                35 +
                                168 +
                                35,
                            bottom: resetBottom,
                            child: MassControlPanel(
                              model: model,
                              which: 1,
                              title: GflStrings.mass1,
                              accent: GflColors.mass1Base,
                              audio: _audio,
                              focusOrder: 10,
                            ),
                          ),
                          Positioned(
                            right: resetRight - 4,
                            bottom: resetBottom - 4,
                            child: FocusTraversalOrder(
                              order: const NumericFocusOrder(50),
                              // Semantics come from KratosResetAllButton (loc.shared).
                              child: KratosResetAllButton(
                                onPressed: _onReset,
                                radius: resetRadius,
                                tooltip: GflStrings.resetAll,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            bottom: 4,
                            child: GflKeyboardHelpButton(focusOrder: 60),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
