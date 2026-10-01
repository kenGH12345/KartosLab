import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../gases_intro_constants.dart';
import '../model/hold_constant.dart';
import '../model/ideal_gas_law_model.dart';
import '../painters/play_area_painter.dart';
import '../render/render_data.dart';
import '../view/ideal_screen_anchors.dart';
import '../view/layout_policy.dart';
import '../view/tools_controller.dart';
import '../view/view_interaction_state.dart';
import 'instrument_controls.dart';
import 'instruments.dart';
import 'play_area_layout.dart';
import 'tool_nodes.dart';

/// V2 anchors + V3 tools + V4 interaction (radio / units / lid / oops / accordion).
class GasesIntroShell extends StatefulWidget {
  const GasesIntroShell({
    super.key,
    required this.model,
    required this.showHoldConstant,
    this.layoutScale = 1.0,
  });

  final IdealGasLawModel model;
  final bool showHoldConstant;
  final double layoutScale;

  static const Color accent = Color(0xFF0284C7);

  @override
  State<GasesIntroShell> createState() => _GasesIntroShellState();
}

class _GasesIntroShellState extends State<GasesIntroShell> {
  late final ToolsController tools;
  late final ViewInteractionState viewState;

  IdealGasLawModel get model => widget.model;

  @override
  void initState() {
    super.initState();
    tools = ToolsController();
    viewState = ViewInteractionState();
    model.addListener(_onModel);
  }

  @override
  void didUpdateWidget(covariant GasesIntroShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model) {
      oldWidget.model.removeListener(_onModel);
      model.addListener(_onModel);
      tools.reset();
      viewState.reset();
    }
  }

  @override
  void dispose() {
    model.removeListener(_onModel);
    tools.dispose();
    viewState.dispose();
    super.dispose();
  }

  void _onModel() {
    tools.syncFromModel(model);
    viewState.syncFromModel(model);
  }

  void _resetAll() {
    model.reset();
    tools.reset();
    viewState.reset();
  }

  static final Rect _logicalBounds = Rect.fromLTWH(
    0,
    0,
    GasesIntroLayoutPolicy.logicalWidth,
    GasesIntroLayoutPolicy.logicalHeight,
  );

  @override
  Widget build(BuildContext context) {
    final scale = widget.layoutScale;
    return ListenableBuilder(
      listenable: Listenable.merge([model, tools, viewState]),
      builder: (context, _) {
        final data = model.renderData;
        final a = IdealScreenAnchors(data, layoutScale: scale);
        final swFirst = tools.frontTool != ToolKind.collision;
        final physW = GasesIntroLayoutPolicy.logicalWidth * scale;
        final physH = GasesIntroLayoutPolicy.logicalHeight * scale;

        final stopwatchLayer = model.stopwatchVisible
            ? Positioned(
                left: tools.stopwatchPosition.dx * scale,
                top: tools.stopwatchPosition.dy * scale,
                child: GasPropertiesStopwatchTool(
                  tools: tools,
                  logicalBounds: _logicalBounds,
                  layoutScale: scale,
                ),
              )
            : null;

        final collisionLayer = model.collisionCounterVisible
            ? Positioned(
                left: tools.collisionPosition.dx * scale,
                top: tools.collisionPosition.dy * scale,
                child: CollisionCounterTool(
                  tools: tools,
                  logicalBounds: _logicalBounds,
                  layoutScale: scale,
                ),
              )
            : null;

        final toolLayers = <Widget>[
          if (swFirst) ...[
            ?collisionLayer,
            ?stopwatchLayer,
          ] else ...[
            ?stopwatchLayer,
            ?collisionLayer,
          ],
        ];

        return ColoredBox(
          color: const Color(GasesIntroConstants.playAreaBackground),
          child: SizedBox(
            width: physW,
            height: physH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: _PlayCanvas(
                    model: model,
                    layout: a.layout,
                    viewState: viewState,
                  ),
                ),
                Positioned(
                  left: a.gaugeLeft,
                  top: a.gaugeTop - 28 * scale,
                  width: a.gaugeW,
                  child: PressureGaugeInstrument(
                    displayedKpa: data.displayedPressureKpa,
                    units: viewState.pressureUnits,
                    onUnitsChanged: viewState.setPressureUnits,
                  ),
                ),
                Positioned(
                  left: a.thermometerLeft - 20 * scale,
                  top: a.thermometerTop - 36 * scale,
                  child: ThermometerInstrument(
                    temperatureK: data.temperatureK,
                    units: viewState.temperatureUnits,
                    onUnitsChanged: viewState.setTemperatureUnits,
                  ),
                ),
                Positioned(
                  left: a.eraseLeft,
                  top: a.eraseTop,
                  width: a.eraseW,
                  height: a.eraseH,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: 'Erase particles',
                    onPressed: model.numberOfParticles == 0
                        ? null
                        : model.eraseParticles,
                    icon: SvgPicture.asset(
                      'assets/gases_intro/eraser.svg',
                      width: 28 * scale.clamp(0.7, 1.0),
                      height: 28 * scale.clamp(0.7, 1.0),
                    ),
                  ),
                ),
                if (!data.lidIsOn)
                  Positioned(
                    left: a.returnLidLeft,
                    top: a.returnLidTop,
                    width: a.returnLidW,
                    height: a.returnLidH,
                    child: TextButton(
                      onPressed: model.returnLid,
                      child: const Text('Return Lid'),
                    ),
                  ),
                Positioned(
                  left: a.pumpLeft,
                  top: a.pumpTop,
                  width: a.pumpW,
                  height: a.pumpBodyH,
                  child: BicyclePumpWidget(
                    model: model,
                    width: a.pumpW,
                    height: a.pumpBodyH,
                  ),
                ),
                Positioned(
                  left: a.particleTypeLeft,
                  top: a.particleTypeTop,
                  child: ParticleTypeRadioButtonGroup(model: model),
                ),
                Positioned(
                  left: a.heaterLeft,
                  top: a.heaterTop,
                  width: a.heaterW,
                  height: a.heaterH,
                  child: HeaterCoolerWidget(model: model),
                ),
                Positioned(
                  left: a.timeLeft,
                  top: a.timeTop,
                  width: a.timeW,
                  height: a.timeH,
                  child: _TimeControl(model: model),
                ),
                Positioned(
                  left: a.panelLeft,
                  top: a.panelTop,
                  width: a.panelW,
                  bottom: 20 * scale + a.resetH + 8 * scale,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        IdealControlPanel(
                          model: model,
                          showHoldConstant: widget.showHoldConstant,
                          viewState: viewState,
                        ),
                        SizedBox(height: 15 * scale),
                        ParticlesAccordionBox(
                          model: model,
                          viewState: viewState,
                          layoutScale: scale,
                        ),
                      ],
                    ),
                  ),
                ),
                ...toolLayers,
                Positioned(
                  left: a.resetLeft,
                  top: a.resetTop,
                  width: a.resetW,
                  height: a.resetH,
                  child: IconButton(
                    tooltip: 'Reset All',
                    onPressed: _resetAll,
                    icon: Image.asset(
                      'assets/gases_intro/resetArrow.png',
                      width: 28 * scale.clamp(0.7, 1.0),
                      height: 28 * scale.clamp(0.7, 1.0),
                    ),
                  ),
                ),
                if (viewState.pendingOopsMessage != null)
                  Positioned.fill(
                    child: GasPropertiesOopsDialog(
                      message: viewState.pendingOopsMessage!,
                      onDismiss: viewState.dismissOops,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlayCanvas extends StatelessWidget {
  const _PlayCanvas({
    required this.model,
    required this.layout,
    required this.viewState,
  });

  final IdealGasLawModel model;
  final PlayAreaLayout layout;
  final ViewInteractionState viewState;

  @override
  Widget build(BuildContext context) {
    final data = model.renderData;
    final dimming = model.container.userIsAdjustingWidth;
    final handleHit = layout.leftHandleHit(data);
    final lidHit = _lidHandleHit(data);

    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: dimming ? 0.6 : 1,
            child: CustomPaint(
              painter: PlayAreaPainter(data: data, layout: layout),
            ),
          ),
        ),
        Positioned.fromRect(
          rect: handleHit,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (_) => model.beginWidthAdjust(),
            onHorizontalDragUpdate: (d) {
              model.setWidth(model.width - d.delta.dx / layout.scale);
            },
            onHorizontalDragEnd: (_) => model.endWidthAdjust(),
          ),
        ),
        // LidNode handle — horizontal drag changes lidWidth / opening (not piston).
        if (data.lidIsOn && !dimming)
          Positioned.fromRect(
            rect: lidHit,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (d) {
                final openingLeftView =
                    layout.vx(model.container.getOpeningLeft()) + d.delta.dx;
                viewState.setLidWidthFromOpeningLeft(
                  model,
                  layout.mx(openingLeftView),
                );
              },
            ),
          ),
      ],
    );
  }

  Rect _lidHandleHit(RenderData data) {
    final top = layout.vy(data.containerTop);
    final lidLeft = layout.vx(data.containerRight - data.lidWidth);
    // Grip near left edge of lid (HandleNode on LidNode).
    return Rect.fromLTRB(lidLeft - 8 * layout.layoutScale, top - 22 * layout.layoutScale,
        lidLeft + 36 * layout.layoutScale, top + 14 * layout.layoutScale);
  }
}

class _TimeControl extends StatelessWidget {
  const _TimeControl({required this.model});
  final IdealGasLawModel model;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0F172A),
      borderRadius: BorderRadius.circular(4),
      child: Row(
        children: [
          IconButton(
            tooltip: model.isPlaying ? 'Pause' : 'Play',
            onPressed: () => model.setPlaying(!model.isPlaying),
            icon: Icon(
              model.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
          ),
          IconButton(
            tooltip: 'Step',
            onPressed: model.stepOnce,
            icon: const Icon(Icons.skip_next, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// Port of IdealControlPanel — Hold Constant (optional) + three checkboxes.
class IdealControlPanel extends StatelessWidget {
  const IdealControlPanel({
    super.key,
    required this.model,
    required this.showHoldConstant,
    required this.viewState,
  });

  final IdealGasLawModel model;
  final bool showHoldConstant;
  final ViewInteractionState viewState;

  @override
  Widget build(BuildContext context) {
    // Material owns the panel fill so CheckboxListTile ink is not masked
    // by an intermediate DecoratedBox (Flutter framework assertion).
    return Material(
      color: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: Color(0xFF334155)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showHoldConstant) ...[
              const Text(
                'Hold Constant',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              for (final mode in HoldConstant.values)
                InkWell(
                  onTap: () => viewState.requestHoldConstant(model, mode),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          model.holdConstant == mode
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 22,
                          color: model.holdConstant == mode
                              ? GasesIntroShell.accent
                              : Colors.white54,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _holdLabel(mode),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Divider(color: Color(0xFF334155), height: 24),
            ],
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Width',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              value: model.widthVisible,
              activeColor: GasesIntroShell.accent,
              onChanged: (v) => model.setWidthVisible(v ?? false),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Stopwatch',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              value: model.stopwatchVisible,
              activeColor: GasesIntroShell.accent,
              onChanged: (v) => model.setStopwatchVisible(v ?? false),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Collision Counter',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              value: model.collisionCounterVisible,
              activeColor: GasesIntroShell.accent,
              onChanged: (v) =>
                  model.setCollisionCounterVisible(v ?? false),
            ),
          ],
        ),
      ),
    );
  }

  static String _holdLabel(HoldConstant m) {
    switch (m) {
      case HoldConstant.nothing:
        return 'Nothing';
      case HoldConstant.volume:
        return 'Volume (V)';
      case HoldConstant.temperature:
        return 'Temperature (T)';
      case HoldConstant.pressureV:
        return 'Pressure ↕ V';
      case HoldConstant.pressureT:
        return 'Pressure ↕ T';
    }
  }
}

/// Port of ParticlesAccordionBox (sun AccordionBox + NumberOfParticlesControl).
/// Expanded state = IdealGasLawViewProperties.particlesExpandedProperty (default false).
class ParticlesAccordionBox extends StatelessWidget {
  const ParticlesAccordionBox({
    super.key,
    required this.model,
    required this.viewState,
    this.layoutScale = 1.0,
  });

  final IdealGasLawModel model;
  final ViewInteractionState viewState;
  final double layoutScale;

  @override
  Widget build(BuildContext context) {
    final expanded = viewState.particlesExpanded;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                // expandCollapseButtonOptions.sideLength: 20
                SizedBox(
                  width: 20,
                  height: 20,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    onPressed: () =>
                        viewState.setParticlesExpanded(!expanded),
                    icon: Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(width: 10), // titleXSpacing
                const Expanded(
                  child: Text(
                    'Particles',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NumberOfParticlesControl(
                    label: 'Heavy',
                    color: const Color(GasesIntroConstants.heavyParticleColor),
                    value: model.particleSystem.numberOfHeavy,
                    onSet: model.setNumberHeavy,
                    layoutScale: layoutScale,
                  ),
                  const SizedBox(height: 15),
                  NumberOfParticlesControl(
                    label: 'Light',
                    color: const Color(GasesIntroConstants.lightParticleColor),
                    value: model.particleSystem.numberOfLight,
                    onSet: model.setNumberLight,
                    layoutScale: layoutScale,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Port of NumberOfParticlesControl: label + Fine/Coarse ±1 / ±50 (40×40).
/// [layoutScale] keeps Fine/Coarse proportional to right-panel width (V5).
class NumberOfParticlesControl extends StatelessWidget {
  const NumberOfParticlesControl({
    super.key,
    required this.label,
    required this.color,
    required this.value,
    required this.onSet,
    this.layoutScale = 1.0,
  });

  final String label;
  final Color color;
  final int value;
  final void Function(int) onSet;
  final double layoutScale;

  @override
  Widget build(BuildContext context) {
    final s = layoutScale <= 0 ? 1.0 : layoutScale;
    // Uniform with shell scale; floor keeps hit target usable (≥28).
    final btn = (40 * s).clamp(28.0, 40.0);
    final iconSize = (22 * s).clamp(16.0, 22.0);
    final valueW = (40 * s).clamp(28.0, 40.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 16 * s.clamp(0.7, 1.0),
              height: 16 * s.clamp(0.7, 1.0),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _spinBtn(Icons.remove, -1, btn, iconSize),
            _spinBtn(Icons.keyboard_double_arrow_down, -50, btn, iconSize),
            SizedBox(
              width: valueW,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _spinBtn(Icons.keyboard_double_arrow_up, 50, btn, iconSize),
            _spinBtn(Icons.add, 1, btn, iconSize),
          ],
        ),
      ],
    );
  }

  Widget _spinBtn(IconData icon, int delta, double btn, double iconSize) {
    return SizedBox(
      width: btn,
      height: btn,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: iconSize,
        onPressed: () => onSet(
          (value + delta).clamp(0, GasesIntroConstants.particleMax),
        ),
        icon: Icon(icon, color: Colors.white70),
      ),
    );
  }
}
