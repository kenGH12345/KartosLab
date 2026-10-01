import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../common/widgets/nine_grid_layout.dart';
import '../controller/two_dimensions_controller.dart';
import '../normal_modes_colors.dart';
import '../normal_modes_constants.dart';
import '../normal_modes_strings.dart';
import '../render/nm_render_builder.dart';
import '../widgets/amplitudes_accordion.dart';
import '../widgets/nm_control_panel.dart';
import '../widgets/nm_page_shell.dart';
import '../widgets/two_dimensions_play_area.dart';

class TwoDimensionsScreen extends StatefulWidget {
  const TwoDimensionsScreen({
    super.key,
    this.controller,
    this.embedded = false,
  });

  final TwoDimensionsController? controller;
  final bool embedded;

  @override
  State<TwoDimensionsScreen> createState() => _TwoDimensionsScreenState();
}

class _TwoDimensionsScreenState extends State<TwoDimensionsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final TwoDimensionsController _controller;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  late final bool _ownsController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TwoDimensionsController();
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
    final data = NmRenderBuilder.from2D(_controller);
    final n = _controller.model.numberOfMasses;
    final body = Material(
      color: NormalModesColors.screenBackground,
      child: NineGridLayout(
        backgroundColor: NormalModesColors.screenBackground,
        center: LayoutBuilder(
          builder: (context, constraints) {
            final m = NmPageMetrics.twoDimensions(constraints);
            // Logical sim region matches PhET twoDRightReserve (420).
            final logicalSimW = NormalModesConstants.layoutWidth -
                NmPageMetrics.twoDRightReserveLogical;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SimulationViewport(
                    logicalWidth: logicalSimW,
                    logicalHeight: NormalModesConstants.layoutHeight,
                    child: TwoDimensionsPlayArea(controller: _controller),
                  ),
                ),
                ControlColumn(
                  width: m.rightPanelWidth,
                  children: [
                    NmControlPanel(
                      numberOfMasses: n,
                      numberOfMassesDisplay: '${n * n}',
                      springsVisible: _controller.model.springsVisible,
                      playing: _controller.model.playing,
                      speed: _controller.model.timeSpeed,
                      onInitialPositions: _controller.initialPositions,
                      onZeroPositions: _controller.zeroPositions,
                      onNumberOfMasses: _controller.setNumberOfMasses,
                      onSpringsVisible: _controller.setSpringsVisible,
                      onPlayPause: _controller.playPause,
                      onStep: _controller.stepOnce,
                      onSpeed: _controller.setTimeSpeed,
                    ),
                    AmplitudesAccordion(
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
        title: const Text(NormalModesStrings.twoDimensions),
        backgroundColor: NormalModesColors.accent,
        foregroundColor: Colors.white,
        toolbarHeight: 44,
      ),
      body: body,
    );
  }
}
