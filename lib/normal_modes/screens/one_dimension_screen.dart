import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../common/widgets/nine_grid_layout.dart';
import '../controller/one_dimension_controller.dart';
import '../normal_modes_colors.dart';
import '../normal_modes_constants.dart';
import '../normal_modes_strings.dart';
import '../render/nm_render_builder.dart';
import '../widgets/modes_accordion.dart';
import '../widgets/nm_control_panel.dart';
import '../widgets/nm_page_shell.dart';
import '../widgets/one_dimension_play_area.dart';
import '../widgets/spectrum_accordion.dart';

class OneDimensionScreen extends StatefulWidget {
  const OneDimensionScreen({
    super.key,
    this.controller,
    this.embedded = false,
  });

  final OneDimensionController? controller;
  final bool embedded;

  @override
  State<OneDimensionScreen> createState() => _OneDimensionScreenState();
}

class _OneDimensionScreenState extends State<OneDimensionScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final OneDimensionController _controller;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  late final bool _ownsController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? OneDimensionController();
    _controller.addListener(_onTick);
    _ticker = createTicker(_onFrame)..start();
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  void _onFrame(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    _controller.tick(dt);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.removeListener(_onTick);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final data = NmRenderBuilder.from1D(_controller);
    final body = Material(
      color: NormalModesColors.screenBackground,
      child: NineGridLayout(
        backgroundColor: NormalModesColors.screenBackground,
        center: LayoutBuilder(
          builder: (context, constraints) {
            final m = NmPageMetrics.oneDimension(constraints);
            // Left column: SimulationViewport + BottomSpectrum
            // Right column: ControlColumn (full height, never covered by spectrum)
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: SimulationViewport(
                          logicalWidth: NormalModesConstants.layoutWidth -
                              NmPageMetrics.oneDRightReserveLogical,
                          logicalHeight: NormalModesConstants.layoutHeight -
                              NmPageMetrics.oneDBottomReserveLogical,
                          child: OneDimensionPlayArea(controller: _controller),
                        ),
                      ),
                      SizedBox(
                        height: m.bottomPanelHeight,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                          child: SpectrumAccordion(
                            controller: _controller,
                            data: data,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ControlColumn(
                  width: m.rightPanelWidth,
                  children: [
                    NmControlPanel(
                      numberOfMasses: _controller.model.numberOfMasses,
                      numberOfMassesDisplay:
                          '${_controller.model.numberOfMasses}',
                      springsVisible: _controller.model.springsVisible,
                      playing: _controller.model.playing,
                      speed: _controller.model.timeSpeed,
                      phasesVisible: _controller.model.phasesVisible,
                      onInitialPositions: _controller.initialPositions,
                      onZeroPositions: _controller.zeroPositions,
                      onNumberOfMasses: _controller.setNumberOfMasses,
                      onSpringsVisible: _controller.setSpringsVisible,
                      onPhasesVisible: _controller.setPhasesVisible,
                      onPlayPause: _controller.playPause,
                      onStep: _controller.stepOnce,
                      onSpeed: _controller.setTimeSpeed,
                    ),
                    ModesAccordion(
                      controller: _controller,
                      data: data,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: NmResetButton(onPressed: _controller.reset),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );

    if (widget.embedded) return body;
    return Scaffold(
      backgroundColor: NormalModesColors.screenBackground,
      appBar: AppBar(
        title: const Text(NormalModesStrings.oneDimension),
        backgroundColor: NormalModesColors.accent,
        foregroundColor: Colors.white,
        toolbarHeight: 44,
      ),
      body: body,
    );
  }
}
