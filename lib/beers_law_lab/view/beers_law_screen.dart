import 'package:flutter/material.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

import '../model/beers_law_model.dart';
import 'beers_law_beam_node.dart';
import 'beers_law_cuvette_node.dart';
import 'beers_law_detector_node.dart';
import 'beers_law_layout.dart';
import 'beers_law_light_node.dart';
import 'beers_law_mvt.dart';
import 'beers_law_ruler_node.dart';
import 'beers_law_solution_panel.dart';
import 'beers_law_viewport.dart';
import 'beers_law_wavelength_panel.dart';

/// PhET `BeersLawScreen` / `BeersLawScreenView`.
class BeersLawScreen extends StatefulWidget {
  const BeersLawScreen({super.key, this.model, this.showAppBar = true});

  static const String title = "Beer's Law";
  static const String subtitle = '光路 · 透过率 · 吸光度';
  static const Color accentColor = Color(0xFF2E7D32);

  final BeersLawModel? model;
  final bool showAppBar;

  @override
  State<BeersLawScreen> createState() => _BeersLawScreenState();
}

class _BeersLawScreenState extends State<BeersLawScreen> {
  late final BeersLawModel _model;
  late final bool _ownsModel;
  static const _mvt = BeersLawMvt();

  @override
  void initState() {
    super.initState();
    _ownsModel = widget.model == null;
    _model = widget.model ?? BeersLawModel();
    _model.addListener(_onModel);
  }

  void _onModel() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _model.removeListener(_onModel);
    if (_ownsModel) _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = BeersLawViewport(
      layoutKey: const Key('beers_law_layout_1100x700'),
      child: BeersLawPlayArea(model: _model, mvt: _mvt),
    );

    if (!widget.showAppBar) return body;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: BeersLawScreen.accentColor,
        foregroundColor: Colors.white,
        title: const Text(BeersLawScreen.title),
      ),
      body: body,
    );
  }
}

/// Scene graph order mirrors `BeersLawScreenView` children.
class BeersLawPlayArea extends StatelessWidget {
  const BeersLawPlayArea({
    super.key,
    required this.model,
    this.mvt = const BeersLawMvt(),
  });

  final BeersLawModel model;
  final BeersLawMvt mvt;

  @override
  Widget build(BuildContext context) {
    final lightTip = mvt.modelToView(model.light.position);
    final lightLeft = lightTip.dx -
        (BeersLawLayout.lightBodySize.width +
            BeersLawLayout.lightNozzleSize.width);
    final lightBottom =
        lightTip.dy + BeersLawLayout.lightBodySize.height / 2;
    final wavelengthTop = lightBottom + BeersLawLayout.wavelengthPanelGap;

    final cuvettePos = mvt.modelToView(model.cuvette.position);
    final cuvetteBottom =
        cuvettePos.dy + mvt.modelToViewDelta(model.cuvette.height);
    final solutionTop = cuvetteBottom + BeersLawLayout.solutionPanelGap;

    return SizedBox(
      width: BeersLawLayout.layoutBounds.width,
      height: BeersLawLayout.layoutBounds.height,
      child: Material(
        color: BeersLawLayout.screenBackground,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
          // Source order: wavelengthPanel, reset, solutionPanel, detector,
          // cuvette, beam, light, ruler (later = on top)
          BeersLawWavelengthPanel(
            model: model,
            left: lightLeft,
            top: wavelengthTop,
          ),

          Positioned(
            right: BeersLawLayout.layoutBounds.width - BeersLawLayout.resetRight,
            bottom:
                BeersLawLayout.layoutBounds.height - BeersLawLayout.resetBottom,
            child: Transform.scale(
              scale: BeersLawLayout.resetScale,
              child: KratosResetAllButton(
                key: const Key('beers_law_reset_all'),
                radius: BeersLawLayout.resetRadius,
                onPressed: model.reset,
              ),
            ),
          ),

          BeersLawSolutionPanel(
            model: model,
            left: cuvettePos.dx,
            top: solutionTop,
          ),

          BeersLawDetectorNode(model: model, mvt: mvt),
          BeersLawCuvetteNode(model: model, mvt: mvt),
          BeersLawBeamNode(model: model, mvt: mvt),
          BeersLawLightNode(model: model, mvt: mvt),
          BeersLawRulerNode(model: model, mvt: mvt),
        ],
        ),
      ),
    );
  }
}
