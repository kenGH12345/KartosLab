import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/widgets/kratos_phet_time_control.dart';
import '../../common/widgets/kratos_reset_all_button.dart';
import '../../gases_intro/painters/play_area_painter.dart';
import '../../gases_intro/view/view_interaction_state.dart';
import '../../gases_intro/widgets/instrument_controls.dart';
import '../../gases_intro/widgets/instruments.dart';
import '../controller/gas_simulation_controller.dart';
import '../controller/throttled_listenable.dart';
import '../gas_properties_colors.dart';
import '../gas_properties_constants.dart';
import '../interaction/drag_state.dart';
import '../interaction/scene_drag_layer.dart';
import '../layout/ideal_layout_slots.dart';
import '../model/hold_constant.dart';
import '../model/ideal_gas_law_model.dart';
import '../model/particle_type.dart';
import '../painters/gas_play_area_painter.dart';
import '../painters/histogram_painter.dart';
import '../solver/hold_constant_solver.dart';
import '../transform/gas_coordinate_transform.dart';
import 'ideal_phet_controls.dart';
import 'package:kratos/gas_properties/gas_properties_strings.dart';

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

                    final containerLeft = _transform.modelToViewX(state.containerLeft);
                    final containerRight = _transform.modelToViewX(state.containerRight);
                    final containerBottom = _transform.modelToViewY(state.containerBottom);
                    const widthArrowsH = 22.0;
                    final widthArrowsTop = containerBottom + 8;
                    const eraseW = 40.0;
                    const eraseH = 40.0;
                    const thermW = 72.0;
                    const thermH = 172.0;
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
                          left: containerLeft,
                          top: widthArrowsTop,
                          width: containerRight - containerLeft,
                          height: widthArrowsH,
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: ContainerWidthArrowsPainter(
                                visible: state.widthVisible,
                                widthNm: state.widthPm / 1000,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: containerRight - eraseW,
                          top: widthArrowsTop + widthArrowsH + 5,
                          width: eraseW,
                          height: eraseH,
                          child: Material(
                            color: const Color(0xFFDCDCDC),
                            borderRadius: BorderRadius.circular(4),
                            elevation: 2,
                            child: InkWell(
                              onTap: c.model.numberOfParticles == 0
                                  ? null
                                  : c.eraseParticles,
                              borderRadius: BorderRadius.circular(4),
                              child: Opacity(
                                opacity:
                                    c.model.numberOfParticles == 0 ? 0.35 : 1,
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/gases_intro/eraser.svg',
                                    width: 28,
                                    height: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: thermCx - thermW / 2,
                          top: thermBottom - thermH,
                          width: thermW,
                          height: thermH,
                          child: ThermometerInstrument(
                            temperatureK: state.temperatureK,
                            units: c.temperatureUnitsKelvin
                                ? TemperatureUnits.kelvin
                                : TemperatureUnits.celsius,
                            onUnitsChanged: (u) => c.setTemperatureUnitsKelvin(
                              u == TemperatureUnits.kelvin,
                            ),
                          ),
                        ),
                        Positioned(
                          left: gaugeLeft,
                          top: gaugeCy - 46,
                          width: gaugeW,
                          height: gaugeH,
                          child: PressureGaugeInstrument(
                            displayedKpa: state.displayedPressureKpa,
                            units: c.pressureUnitsAtm
                                ? PressureUnits.atmospheres
                                : PressureUnits.kilopascals,
                            onUnitsChanged: (u) => c.setPressureUnitsAtm(
                              u == PressureUnits.atmospheres,
                            ),
                          ),
                        ),
                        // Lid handle above instruments (left edge of lid, like Gases Intro).
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
                            label: GasPropertiesStrings.heatCool,
                            child: HeaterCoolerWidget(
                              listenable: c,
                              factorOf: () => c.model.heatCoolFactor,
                              enabledOf: () =>
                                  c.model.isPlaying &&
                                  c.model.numberOfParticles > 0,
                              hideOf: () =>
                                  c.model.holdConstant ==
                                      HoldConstant.temperature ||
                                  c.model.holdConstant ==
                                      HoldConstant.pressureT,
                              onChanged: c.setHeatCool,
                              onReleased: () => c.setHeatCool(0),
                            ),
                          ),
                        ),
                        // Pump + particle radios + Reset All (tools live on the right rail).
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
                          top: timeBottom - 48,
                          child: KratosPhetTimeControl(
                            isPlaying: c.model.isPlaying,
                            onPlayPause: c.togglePlayPause,
                            onStep: c.stepOnce,
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
                              child: Text(GasPropertiesStrings.returnLid),
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

  /// Pump + Heavy/Light radios + Reset All.
  /// Eraser and Width arrows sit on the container (same as Gases Intro).
  List<Widget> _bottomRightCluster({
    required double pumpLeft,
    required double pumpBottom,
    required double resetRight,
    required double resetBottom,
  }) {
    const pumpW = 112.0;
    const pumpH = 176.0;
    const selectorH = 48.0;
    const selectorW = 120.0;
    final pumpTop = pumpBottom - selectorH - 15 - pumpH;
    return [
      Positioned(
        left: pumpLeft,
        top: pumpTop,
        width: pumpW,
        height: pumpH,
        child: BicyclePumpWidget(
          listenable: c,
          bodyColorOf: () => c.model.particleType == ParticleType.heavy
              ? const Color(GasPropertiesColors.heavyParticle)
              : const Color(GasPropertiesColors.lightParticle),
          onPump: () => c.pump(),
          width: pumpW,
          height: pumpH,
        ),
      ),
      Positioned(
        left: pumpLeft + pumpW * 0.68 - selectorW / 2,
        top: pumpBottom - selectorH,
        child: ParticleTypeRadioButtonGroup(
          heavySelected: c.model.particleType == ParticleType.heavy,
          onSelectHeavy: () => c.setParticleType(ParticleType.heavy),
          onSelectLight: () => c.setParticleType(ParticleType.light),
        ),
      ),
      Positioned(
        left: resetRight - 56,
        top: resetBottom - 56,
        child: KratosResetAllButton(
          key: const Key('reset_all_button'),
          onPressed: _resetAll,
          radius: 20.5,
          tooltip: GasPropertiesStrings.resetAll,
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
        IdealToolsPanel(controller: controller),
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
            Text(GasPropertiesStrings.stopwatch,
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
            Text(GasPropertiesStrings.collisions,
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
      title: GasPropertiesStrings.injectionTemperature,
      child: Column(
        children: [
          IdealCheckRow(
            label: GasPropertiesStrings.setTo,
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
                : GasPropertiesStrings.matchContainer,
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
              title: GasPropertiesStrings.speed,
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
              title: GasPropertiesStrings.kineticEnergy,
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
              '${GasPropertiesStrings.zoom} ${e?.zoomLevelIndex ?? 0}',
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
          GasPropertiesStrings.tempEmpty,
        HoldConstantOops.temperatureLidOpen => GasPropertiesStrings.tempOpen,
        HoldConstantOops.pressureContainerEmpty =>
          GasPropertiesStrings.pressureEmpty,
        HoldConstantOops.pressureVolumeTooLarge =>
          GasPropertiesStrings.pressureVolumeLarge,
        HoldConstantOops.pressureVolumeTooSmall =>
          GasPropertiesStrings.pressureVolumeSmall,
        HoldConstantOops.maximumTemperature => GasPropertiesStrings.maxTemperature,
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
                '${GasPropertiesStrings.oops}\n\n$_message',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: onDismiss, child: Text(GasPropertiesStrings.ok)),
            ],
          ),
        ),
      ),
    );
  }
}
