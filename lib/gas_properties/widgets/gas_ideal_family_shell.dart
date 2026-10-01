import 'package:flutter/material.dart';

import '../controller/gas_simulation_controller.dart';
import '../controller/throttled_listenable.dart';
import '../gas_properties_colors.dart';
import '../gas_properties_constants.dart';
import '../interaction/drag_state.dart';
import '../interaction/scene_drag_layer.dart';
import '../layout/ideal_layout_slots.dart';
import '../model/ideal_gas_law_model.dart';
import '../painters/gas_play_area_painter.dart';
import '../painters/histogram_painter.dart';
import '../painters/ideal_instruments_painters.dart';
import '../solver/hold_constant_solver.dart';
import '../transform/gas_coordinate_transform.dart';
import 'ideal_phet_controls.dart';

/// Shared shell for Ideal / Explore / Energy.
/// Interaction: discrete hit regions — no full-screen gesture guessing.
class GasIdealFamilyShell extends StatefulWidget {
  const GasIdealFamilyShell({
    super.key,
    required this.controller,
    required this.layoutScale,
  });

  final GasSimulationController controller;
  final double layoutScale;

  @override
  State<GasIdealFamilyShell> createState() => _GasIdealFamilyShellState();
}

class _GasIdealFamilyShellState extends State<GasIdealFamilyShell> {
  GasSimulationController get c => widget.controller;
  final _transform = const GasCoordinateTransform();
  final _drag = SceneDragState();
  late final ThrottledListenable _panelTick;

  @override
  void initState() {
    super.initState();
    _panelTick = ThrottledListenable(
      c,
      interval: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _drag.clear();
    c.clearTransientInteraction();
    _panelTick.dispose();
    super.dispose();
  }

  void _onDragChanged() {
    if (mounted) setState(() {});
  }

  void _resetAll() {
    _drag.clear();
    c.clearTransientInteraction();
    c.reset();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.layoutScale;
    final lw = IdealLayoutSlots.width;
    final lh = IdealLayoutSlots.height;

    return ColoredBox(
      color: const Color(GasPropertiesColors.screenBackground),
      child: SizedBox(
        width: lw * scale,
        height: lh * scale,
        child: FittedBox(
          fit: BoxFit.fill,
          child: SizedBox(
            width: lw,
            height: lh,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ListenableBuilder(
                    listenable: c,
                    builder: (context, _) {
                      final state = c.renderState;
                      final dim = c.model.container.userIsAdjustingWidth &&
                          !c.model.container.leftWallDoesWork;
                      return CustomPaint(
                        painter: GasPlayAreaPainter(
                          state: state,
                          transform: _transform,
                          dimParticles: dim,
                        ),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: ListenableBuilder(
                    listenable: c,
                    builder: (context, _) => SceneLidWallOverlay(
                      controller: c,
                      transform: _transform,
                      drag: _drag,
                      onDragChanged: _onDragChanged,
                      lidOnTop: false,
                    ),
                  ),
                ),
                ListenableBuilder(
                  listenable: _panelTick,
                  builder: (context, _) {
                    final state = c.renderState;
                    final profile = c.profile;
                    final (thermCx, thermBottom) =
                        IdealLayoutSlots.thermometerAnchor(
                      _transform,
                      state.containerTop,
                    );
                    final (gaugeLeft, gaugeCy) =
                        IdealLayoutSlots.pressureGaugeAnchor(
                      _transform,
                      state.containerTop,
                    );
                    final (pumpLeft, pumpBottom) =
                        IdealLayoutSlots.pumpAnchor(_transform);
                    final (heaterLeft, heaterBottom) =
                        IdealLayoutSlots.heaterAnchor(_transform);
                    final (timeLeft, timeBottom) =
                        IdealLayoutSlots.timeControlAnchor(_transform);
                    final (resetRight, resetBottom) =
                        IdealLayoutSlots.resetAnchor();

                    const thermW = 72.0;
                    const thermH = 150.0;
                    const gaugeW = 100.0;
                    const gaugeH = 120.0;
                    const heaterW = 120.0;
                    // Extra top space so flames / ice can rise out of the opening.
                    const heaterH = 150.0;

                    final heaterLeftPos = heaterLeft +
                        (_transform.modelToViewDelta(
                              GasPropertiesConstants.widthMin,
                            ) /
                            2) -
                        heaterW / 2;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: thermCx - thermW / 2,
                          top: thermBottom - thermH,
                          width: thermW,
                          height: thermH,
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: IdealThermometerPainter(
                                fill01: state.temperatureK == null
                                    ? 0
                                    : (state.temperatureK! / 1000).clamp(0, 1),
                                label: state.temperatureDisplay,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: gaugeLeft,
                          top: gaugeCy - 46,
                          width: gaugeW,
                          height: gaugeH,
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: IdealPressureGaugePainter(
                                fraction: (state.displayedPressureKpa /
                                        GasPropertiesConstants.maxPressureKpa)
                                    .clamp(0.0, 1.0),
                                label: state.pressureDisplay,
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: SceneUnitSelectors(
                            controller: c,
                            transform: _transform,
                          ),
                        ),
                        // Lid handle above instruments so it stays draggable
                        // (PhET handle sits at the right end of the lid bar).
                        Positioned.fill(
                          child: SceneLidWallOverlay(
                            controller: c,
                            transform: _transform,
                            drag: _drag,
                            onDragChanged: _onDragChanged,
                            wallEnabledOverride: false,
                            lidOnTop: true,
                          ),
                        ),
                        Positioned(
                          left: heaterLeftPos,
                          top: heaterBottom - heaterH,
                          width: heaterW,
                          height: heaterH,
                          child: Semantics(
                            label: 'Heat Cool',
                            child: SceneHeaterDrag(
                              controller: c,
                              drag: _drag,
                              onDragChanged: _onDragChanged,
                              child: CustomPaint(
                                painter: IdealHeaterCoolerPainter(
                                  factor: _drag.kind == SceneDragKind.heater
                                      ? _drag.heatFactor
                                      : state.heatCoolFactor,
                                ),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                        ),
                        // Bottom-right cluster: pump + radios + eraser + tools + reset
                        ..._bottomRightCluster(
                          pumpLeft: pumpLeft,
                          pumpBottom: pumpBottom,
                          resetRight: resetRight,
                          resetBottom: resetBottom,
                        ),
                        if (profile == IdealGasProfile.energy)
                          Positioned(
                            left: IdealLayoutSlots.margin,
                            top: IdealLayoutSlots.margin,
                            width: GasLayoutPolicy.leftEnergyPanelWidth,
                            child: _EnergyLeftPanels(controller: c),
                          ),
                        Positioned(
                          left: IdealLayoutSlots.panelsLeft,
                          top: IdealLayoutSlots.panelsTop,
                          width: IdealLayoutSlots.rightPanelWidth,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: IdealLayoutSlots.panelsMaxHeight,
                            ),
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: _RightControlRail(controller: c),
                            ),
                          ),
                        ),
                        Positioned(
                          left: timeLeft,
                          top: timeBottom - 56,
                          child: Row(
                            children: [
                              IdealPhETCircleButton(
                                size: 52,
                                color: const Color(0xFF38BDF8),
                                icon: c.model.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                onTap: c.togglePlayPause,
                              ),
                              const SizedBox(width: 10),
                              IdealPhETCircleButton(
                                size: 40,
                                color: const Color(0xFF38BDF8),
                                icon: Icons.skip_next,
                                onTap: c.stepOnce,
                                iconSize: 22,
                              ),
                            ],
                          ),
                        ),
                        if (!state.lidIsOn)
                          Positioned(
                            left: _transform.modelToViewX(state.containerLeft) +
                                20,
                            top: _transform.modelToViewY(state.containerTop) -
                                36,
                            child: TextButton(
                              onPressed: c.returnLid,
                              child: const Text('Return Lid'),
                            ),
                          ),
                        if (c.stopwatchVisible)
                          Positioned(
                            left: 240,
                            top: 15,
                            child: _StopwatchPanel(controller: c),
                          ),
                        if (c.collisionCounterVisible)
                          Positioned(
                            left: IdealLayoutSlots.panelsLeft - 160,
                            top: IdealLayoutSlots.margin + 40,
                            child: _CollisionCounterBadge(
                              count: c.model.collisionCount,
                            ),
                          ),
                        if (c.lastOops != null)
                          Positioned.fill(
                            child: _OopsOverlay(
                              oops: c.lastOops!,
                              onDismiss: c.clearOops,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// PhET bottom-right composition for Ideal / Explore / Energy:
  /// ```
  /// [hose][ Pump ][ Tools panel ]
  /// [eraser][ Heavy Light ]
  ///                    [ Reset ]
  /// ```
  List<Widget> _bottomRightCluster({
    required double pumpLeft,
    required double pumpBottom,
    required double resetRight,
    required double resetBottom,
  }) {
    const pumpW = 100.0;
    const pumpH = 148.0;
    const selectorH = 36.0;
    // Pump sits above particle radios; radios sit just above bottom margin.
    final pumpTop = pumpBottom - selectorH - pumpH;
    return [
      // Bicycle pump
      Positioned(
        left: pumpLeft,
        top: pumpTop,
        width: pumpW,
        height: pumpH,
        child: Stack(
          children: [
            IgnorePointer(
              child: CustomPaint(
                painter: IdealBicyclePumpPainter(handleLift: _drag.pumpLift),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: pumpW * 0.28,
              top: 0,
              width: pumpW * 0.55,
              height: pumpH * 0.55,
              child: ScenePumpHandle(
                controller: c,
                drag: _drag,
                onDragChanged: _onDragChanged,
                width: pumpW * 0.55,
                height: pumpH * 0.55,
              ),
            ),
          ],
        ),
      ),
      // Particle type radios — under pump base
      Positioned(
        left: pumpLeft + 18,
        top: pumpBottom - selectorH,
        child: IdealParticleTypeSelector(controller: c),
      ),
      // Eraser — left of pump base
      Positioned(
        left: pumpLeft - 42,
        top: pumpBottom - selectorH - 40,
        child: GestureDetector(
          onTap: c.eraseParticles,
          child: SizedBox(
            width: 36,
            height: 36,
            child: CustomPaint(painter: IdealEraserPainter()),
          ),
        ),
      ),
      // Tools panel — right of pump body (Width / Stopwatch / …)
      Positioned(
        left: pumpLeft + pumpW + 6,
        top: pumpTop + 36,
        width: 210,
        child: IdealToolsPanel(controller: c),
      ),
      // Reset All — far bottom-right
      Positioned(
        left: resetRight - 56,
        top: resetBottom - 56,
        child: IdealPhETCircleButton(
          size: 52,
          color: const Color(0xFFF97316),
          icon: Icons.refresh,
          onTap: _resetAll,
        ),
      ),
    ];
  }
}

class _RightControlRail extends StatelessWidget {
  const _RightControlRail({required this.controller});
  final GasSimulationController controller;

  @override
  Widget build(BuildContext context) {
    final profile = controller.profile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IdealParticlesPanel(controller: controller),
        const SizedBox(height: IdealLayoutSlots.panelsYSpacing),
        if (profile == IdealGasProfile.ideal) ...[
          IdealHoldConstantPanel(controller: controller),
          const SizedBox(height: IdealLayoutSlots.panelsYSpacing),
        ],
        if (profile == IdealGasProfile.energy) ...[
          _InjectionPanel(controller: controller),
          const SizedBox(height: IdealLayoutSlots.panelsYSpacing),
        ],
        // Tools panel lives in bottom-right cluster (next to pump), not here.
      ],
    );
  }
}

class _StopwatchPanel extends StatelessWidget {
  const _StopwatchPanel({required this.controller});
  final GasSimulationController controller;

  @override
  Widget build(BuildContext context) {
    final ps = controller.stopwatchPs;
    return Material(
      color: const Color(GasPropertiesColors.stopwatchBg),
      borderRadius: BorderRadius.circular(8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Stopwatch',
                style: TextStyle(color: Colors.white70, fontSize: 11)),
            Text(
              '${ps.toStringAsFixed(2)} ps',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => controller
                      .setStopwatchRunning(!controller.stopwatchRunning),
                  icon: Icon(
                    controller.stopwatchRunning
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: controller.resetStopwatch,
                  icon: const Icon(Icons.refresh, color: Colors.white70, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CollisionCounterBadge extends StatelessWidget {
  const _CollisionCounterBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(GasPropertiesColors.collisionCounterBg),
      borderRadius: BorderRadius.circular(8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Collisions',
                style: TextStyle(color: Colors.black87, fontSize: 11)),
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InjectionPanel extends StatelessWidget {
  const _InjectionPanel({required this.controller});
  final GasSimulationController controller;

  @override
  Widget build(BuildContext context) {
    final tm = controller.model.temperatureSolver;
    return IdealPanelChrome(
      title: 'Injection Temperature',
      child: Column(
        children: [
          IdealCheckRow(
            label: 'Set to',
            value: tm.setInjectionTemperatureEnabled,
            onChanged: (v) {
              if (v) {
                controller.setInjectionTemperature(tm.injectionTemperature);
              } else {
                controller.matchContainerInjectionTemperature();
              }
            },
          ),
          if (tm.setInjectionTemperatureEnabled)
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(GasPropertiesColors.accent),
                thumbColor: const Color(GasPropertiesColors.accent),
              ),
              child: Slider(
                min: 50,
                max: 1000,
                value: tm.injectionTemperature.clamp(50, 1000),
                onChanged: controller.setInjectionTemperature,
              ),
            ),
          Text(
            tm.setInjectionTemperatureEnabled
                ? '${tm.injectionTemperature.round()} K'
                : 'Match Container',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _EnergyLeftPanels extends StatelessWidget {
  const _EnergyLeftPanels({required this.controller});
  final GasSimulationController controller;

  @override
  Widget build(BuildContext context) {
    final e = controller.renderState.energy;
    return Column(
      children: [
        AverageSpeedPanel(energy: e),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          width: double.infinity,
          child: CustomPaint(
            painter: HistogramPainter(
              heavyBins: e?.heavySpeedBins ?? const [],
              lightBins: e?.lightSpeedBins ?? const [],
              yMax: e?.zoomYMax ?? 100,
              title: 'Speed',
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          width: double.infinity,
          child: CustomPaint(
            painter: HistogramPainter(
              heavyBins: e?.heavyKeBins ?? const [],
              lightBins: e?.lightKeBins ?? const [],
              yMax: e?.zoomYMax ?? 100,
              title: 'Kinetic Energy',
              heavyColor: const Color(GasPropertiesColors.keHistogramBar),
              lightColor: const Color(0xFFFFAA88),
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: controller.zoomOut,
              icon: const Icon(Icons.zoom_out, color: Colors.white70),
            ),
            Text(
              'Zoom ${e?.zoomLevelIndex ?? 0}',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            IconButton(
              onPressed: controller.zoomIn,
              icon: const Icon(Icons.zoom_in, color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }
}

class _OopsOverlay extends StatelessWidget {
  const _OopsOverlay({required this.oops, required this.onDismiss});
  final HoldConstantOops oops;
  final VoidCallback onDismiss;

  String get _message => switch (oops) {
        HoldConstantOops.temperatureContainerEmpty =>
          'Temperature cannot be held constant when the container is empty.',
        HoldConstantOops.temperatureLidOpen =>
          'Temperature cannot be held constant when the container is open.',
        HoldConstantOops.pressureContainerEmpty =>
          'Pressure cannot be held constant when the container is empty.',
        HoldConstantOops.pressureVolumeTooLarge =>
          'Pressure cannot be held constant. Volume would be too large.',
        HoldConstantOops.pressureVolumeTooSmall =>
          'Pressure cannot be held constant. Volume would be too small.',
        HoldConstantOops.maximumTemperature => 'Maximum temperature reached.',
      };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/gases_intro/phetGirlLabCoat.png',
                height: 80,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.info, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 12),
              Text(
                'Oops!\n\n$_message',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: onDismiss, child: const Text('OK')),
            ],
          ),
        ),
      ),
    );
  }
}
