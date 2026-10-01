import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

import '../model/abs_colors.dart';
import '../model/abs_constants.dart';
import '../model/abs_view_properties.dart';
import 'abs_beaker_painter.dart';
import 'abs_concentration_graph.dart';
import 'abs_conductivity_layer.dart';
import 'abs_particles_layer.dart';
import 'abs_ph_meter_layer.dart';
import 'abs_ph_paper_layer.dart';
import 'abs_reaction_equation.dart';
import 'abs_tools_radio_group.dart';
import 'abs_views_panel.dart';
import 'intro_controller.dart';
import 'intro_solution_panel.dart';

/// Intro screen — PhET `IntroScreen` / `IntroScreenView` / `ABSScreenView`.
///
/// Layout bounds: 768×504, model≡view 1:1 (no MVT).
class AbsIntroScreen extends StatefulWidget {
  const AbsIntroScreen({super.key, this.controller});

  final IntroController? controller;

  @override
  State<AbsIntroScreen> createState() => _AbsIntroScreenState();
}

class _AbsIntroScreenState extends State<AbsIntroScreen>
    with SingleTickerProviderStateMixin {
  late final IntroController _controller;
  late final bool _ownsController;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  /// PhET `ScreenView.DEFAULT_LAYOUT_BOUNDS` width is typically 1024.
  static const double _defaultLayoutWidth = 1024;
  static final double _resetScale =
      AbsConstants.layoutBounds.width / _defaultLayoutWidth;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? IntroController();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final dt = _lastElapsed == Duration.zero
        ? 0.0
        : (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (dt > 0 && dt < 0.25) {
      _controller.step(dt);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AbsColors.screenBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: AbsConstants.layoutBounds.width,
              height: AbsConstants.layoutBounds.height,
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => _buildScene(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScene() {
    final model = _controller.model;
    final beaker = model.beaker;
    final view = _controller.viewProperties;
    final lensRight = absLensCenter(beaker).dx +
        absLensRadius(beaker) +
        absLensRadius(beaker) * 0.9;

    // Controls centered in space right of magnifier handle (ABSScreenView).
    final controlsCenterX =
        lensRight + (AbsConstants.layoutBounds.width - lensRight) / 2;

    return Stack(
      children: [
        // Tools under beaker chrome (source z-order: tools, beaker, equation, particles, graph, controls, reset)
        AbsPhMeterLayer(
          meter: model.pHMeter,
          toolMode: view.toolMode,
          onPressedChanged: (v) {
            _controller.meterPressed = v;
            _controller.notifyModelChanged();
          },
          onDrag: (p) {
            model.pHMeter.position = p;
            _controller.notifyModelChanged();
          },
        ),
        AbsPhPaperLayer(
          paper: model.pHPaper,
          beaker: beaker,
          toolMode: view.toolMode,
          onPressedChanged: (v) {
            _controller.paperPressed = v;
            _controller.notifyModelChanged();
          },
          onDrag: (p) {
            model.pHPaper.position = p;
            _controller.notifyModelChanged();
          },
        ),
        AbsConductivityLayer(
          tester: model.conductivityTester,
          beaker: beaker,
          toolMode: view.toolMode,
          onPositivePressed: (v) {
            _controller.positiveProbePressed = v;
          },
          onNegativePressed: (v) {
            _controller.negativeProbePressed = v;
          },
          onPositiveDrag: (p) {
            model.conductivityTester.positiveProbePosition = p;
            _controller.notifyModelChanged();
          },
          onNegativeDrag: (p) {
            model.conductivityTester.negativeProbePosition = p;
            _controller.notifyModelChanged();
          },
        ),

        // Beaker
        Positioned.fill(
          child: CustomPaint(painter: AbsBeakerPainter(beaker)),
        ),

        AbsReactionEquation(beaker: beaker, solution: model.solution),

        AbsParticlesLayer(
          beaker: beaker,
          particles: _controller.particles,
          showSolvent: _controller.preferences.showSolvent,
          visible: view.viewMode == AbsViewMode.particles,
        ),

        AbsConcentrationGraph(
          beaker: beaker,
          solution: model.solution,
          viewMode: view.viewMode,
        ),

        // Controls
        Positioned(
          left: controlsCenterX - 110,
          top: AbsConstants.layoutBounds.height / 2 - 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IntroSolutionPanel(
                model: model,
                onSelected: _controller.selectSolution,
              ),
              const SizedBox(height: 10),
              AbsViewsPanel(
                viewMode: view.viewMode,
                onChanged: _controller.setViewMode,
              ),
              const SizedBox(height: 10),
              AbsToolsRadioGroup(
                toolMode: view.toolMode,
                onChanged: _controller.setToolMode,
              ),
            ],
          ),
        ),

        // Reset All
        Positioned(
          right: 20,
          bottom: 20,
          child: KratosResetAllButton(
            radius: 20.5 * _resetScale,
            onPressed: _controller.resetAll,
          ),
        ),
      ],
    );
  }
}

/// Convenience alias matching other sims' `*Screen` naming.
typedef IntroScreen = AbsIntroScreen;
