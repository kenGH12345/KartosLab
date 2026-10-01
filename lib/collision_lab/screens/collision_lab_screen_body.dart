import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../common/widgets/nine_grid_layout.dart';
import '../collision_lab_colors.dart';
import '../collision_lab_constants.dart';
import '../controller/collision_lab_controller.dart';
import '../widgets/ball_values_panel.dart';
import '../widgets/cl_layout.dart';
import '../widgets/control_panel.dart';
import '../widgets/momenta_diagram_panel.dart';
import '../widgets/play_area_widget.dart';
import '../widgets/time_control.dart';

/// Shared screen shell for all Collision Lab tabs.
class CollisionLabScreenBody extends StatefulWidget {
  const CollisionLabScreenBody({
    super.key,
    required this.controller,
    required this.config,
    this.embedded = false,
  });

  final CollisionLabController controller;
  final ControlPanelConfig config;
  final bool embedded;

  @override
  State<CollisionLabScreenBody> createState() => _CollisionLabScreenBodyState();
}

class _CollisionLabScreenBodyState extends State<CollisionLabScreenBody>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTick);
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
    widget.controller.tick(dt);
  }

  @override
  void dispose() {
    _ticker.dispose();
    widget.controller.removeListener(_onTick);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final c = widget.controller;
    final body = Material(
      color: CollisionLabColors.screenBackground,
      child: NineGridLayout(
        backgroundColor: CollisionLabColors.screenBackground,
        center: LayoutBuilder(
          builder: (context, constraints) {
            final m = ClPageMetrics.compute(constraints);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: SimulationViewport(
                          logicalWidth: CollisionLabConstants.layoutWidth -
                              ClPageMetrics.rightReserveLogical,
                          logicalHeight: CollisionLabConstants.layoutHeight -
                              ClPageMetrics.bottomReserveLogical,
                          child: PlayAreaWidget(controller: c),
                        ),
                      ),
                      BottomPanel(
                        height: m.bottomPanelHeight,
                        child: Column(
                          children: [
                            Expanded(child: BallValuesPanel(controller: c)),
                            const SizedBox(height: 6),
                            TimeControl(
                              playing: c.model.isPlaying,
                              speed: c.model.timeSpeed,
                              canStepBackward: c.canStepBackward,
                              onPlayPause: c.playPause,
                              onStepForward: c.stepForward,
                              onStepBackward: c.stepBackward,
                              onSpeed: c.setTimeSpeed,
                              onRestart: c.restart,
                              onReset: c.reset,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ControlColumn(
                  width: m.rightPanelWidth,
                  children: [
                    ControlPanel(controller: c, config: widget.config),
                    MomentaDiagramPanel(controller: c),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );

    if (widget.embedded) return body;
    return Scaffold(body: SafeArea(child: body));
  }
}
