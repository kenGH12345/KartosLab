import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kratos/energy_skate_park/controller/esp_controller.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';
import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/widgets/bottom_visibility_panel.dart';
import 'package:kratos/energy_skate_park/widgets/control_panel.dart';
import 'package:kratos/energy_skate_park/widgets/esp_layout.dart';
import 'package:kratos/energy_skate_park/widgets/play_area.dart';
import 'package:kratos/energy_skate_park/widgets/time_control.dart';

/// PhET-like shell: left panel | play area | right controls; bottom visibility + time bar.
class EspScreenBody extends StatefulWidget {
  const EspScreenBody({
    super.key,
    required this.controller,
    required this.config,
    this.embedded = false,
    this.leftPanel,
    this.topPanel,
    this.playOverlay,
    this.bottomCenter,
  });

  final EspController controller;
  final ControlPanelConfig config;
  final bool embedded;

  /// Energy bar / sensor panel slot (left of play area).
  final Widget? leftPanel;

  /// Page-level top area above simulation (Graphs Energy Graph).
  /// When set, occupies reserved height — does **not** overlay PlayArea.
  final Widget? topPanel;

  /// Floating overlay on play area (legacy; prefer [topPanel] for Graphs).
  final Widget? playOverlay;

  /// Extra widgets in bottom bar center (Playground track tools).
  final Widget? bottomCenter;

  @override
  State<EspScreenBody> createState() => _EspScreenBodyState();
}

class _EspScreenBodyState extends State<EspScreenBody>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  static Size get _logicalPlaySize => Size(
        EspConstants.layoutWidth - EspPageMetrics.rightReserveLogical,
        EspConstants.layoutHeight - EspPageMetrics.bottomReserveLogical,
      );

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
    widget.controller.tick(dt.clamp(0.0, 0.05));
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
    final cfg = widget.config;

    final body = Material(
      color: EspColors.screenBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final m = EspPageMetrics.compute(constraints);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (widget.leftPanel != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: widget.leftPanel!,
                              ),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (widget.topPanel != null)
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                    child: widget.topPanel!,
                                  ),
                                Expanded(
                                  child: EspSimulationViewport(
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        PlayArea(
                                          controller: c,
                                          showToolbox: false,
                                        ),
                                        if (widget.playOverlay != null)
                                          widget.playOverlay!,
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: m.bottomPanelHeight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: Row(
                          children: [
                            if (cfg.showBottomVisibility)
                              BottomVisibilityPanel(controller: c),
                            if (cfg.showBottomVisibility)
                              const SizedBox(width: 8),
                            if (widget.bottomCenter != null) ...[
                              widget.bottomCenter!,
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: TimeControl(
                                playing: c.isPlaying,
                                slow: c.model.slow,
                                onPlayPause: c.playPause,
                                onStep: c.stepForward,
                                onSlow: c.setSlow,
                                onReset: c.reset,
                                onReturnSkater: c.returnSkater,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: m.rightPanelWidth,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: ControlPanel(
                    controller: c,
                    config: cfg,
                    playAreaSize: _logicalPlaySize,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (widget.embedded) return body;
    return Scaffold(body: SafeArea(child: body));
  }
}
