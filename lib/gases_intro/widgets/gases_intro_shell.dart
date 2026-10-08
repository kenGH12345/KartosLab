import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/widgets/kratos_phet_time_control.dart';
import '../../common/widgets/kratos_reset_all_button.dart';
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
import 'package:kratos/gases_intro/gases_intro_strings.dart';

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
                  top: a.gaugeTop,
                  width: a.gaugeW,
                  child: PressureGaugeInstrument(
                    displayedKpa: data.displayedPressureKpa,
                    units: viewState.pressureUnits,
                    onUnitsChanged: viewState.setPressureUnits,
                  ),
                ),
                Positioned(
                  left: a.thermometerLeft,
                  top: a.thermometerTop,
                  child: ThermometerInstrument(
                    temperatureK: data.temperatureK,
                    units: viewState.temperatureUnits,
                    onUnitsChanged: viewState.setTemperatureUnits,
                  ),
                ),
                Positioned(
                  left: a.layout.vx(data.containerLeft),
                  top: a.widthArrowsTop,
                  width: a.containerNodeRight - a.layout.vx(data.containerLeft),
                  height: a.widthArrowsH,
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: ContainerWidthArrowsPainter(
                        visible: data.widthVisible,
                        widthNm: data.widthPm / 1000,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: a.eraseLeft,
                  top: a.eraseTop,
                  width: a.eraseW,
                  height: a.eraseH,
                  child: Material(
                    color: const Color(0xFFDCDCDC),
                    borderRadius: BorderRadius.circular(4),
                    elevation: 2,
                    child: InkWell(
                      onTap: model.numberOfParticles == 0
                          ? null
                          : model.eraseParticles,
                      borderRadius: BorderRadius.circular(4),
                      child: Opacity(
                        opacity: model.numberOfParticles == 0 ? 0.35 : 1,
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/gases_intro/eraser.svg',
                            width: 28 * scale.clamp(0.7, 1.0),
                            height: 22 * scale.clamp(0.7, 1.0),
                          ),
                        ),
                      ),
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
                      child: Text(GasesIntroStrings.returnLid),
                    ),
                  ),
                Positioned(
                  left: a.pumpLeft,
                  top: a.pumpTop,
                  width: a.pumpW,
                  height: a.pumpBodyH,
                  child: BicyclePumpWidget.forIntro(
                    model: model,
                    width: a.pumpW,
                    height: a.pumpBodyH,
                  ),
                ),
                Positioned(
                  left: a.particleTypeLeft,
                  top: a.particleTypeTop,
                  child: ParticleTypeRadioButtonGroup.forIntro(model: model),
                ),
                Positioned(
                  left: a.heaterLeft,
                  top: a.heaterTop,
                  width: a.heaterW,
                  height: a.heaterH,
                  child: HeaterCoolerWidget.forIntro(model: model),
                ),
                Positioned(
                  left: a.timeLeft,
                  top: a.timeTop,
                  child: KratosPhetTimeControl(
                    isPlaying: model.isPlaying,
                    onPlayPause: () => model.setPlaying(!model.isPlaying),
                    onStep: model.stepOnce,
                  ),
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
                        ParticlesAccordionBox(
                          model: model,
                          viewState: viewState,
                          layoutScale: scale,
                        ),
                        SizedBox(height: 15 * scale),
                        IdealControlPanel(
                          model: model,
                          showHoldConstant: widget.showHoldConstant,
                          viewState: viewState,
                        ),
                      ],
                    ),
                  ),
                ),
                ...toolLayers,
                Positioned(
                  left: a.resetLeft,
                  top: a.resetTop,
                  child: KratosResetAllButton(
                    key: const Key('reset_all_button'),
                    onPressed: _resetAll,
                    radius: 20.5,
                    tooltip: GasesIntroStrings.resetAll,
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
              // Handle follows the finger: drag right → lid's left edge moves right
              // → lidWidth shrinks (opening grows).
              viewState.nudgeLidWidth(model, -d.delta.dx / layout.scale);
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
      color: const Color(0xFF282828),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: const BorderSide(color: Color(0xFF373737)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showHoldConstant) ...[
              Text(
                GasesIntroStrings.holdConstant,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
            _toolCheckbox(
              label: GasesIntroStrings.width,
              value: model.widthVisible,
              onChanged: model.setWidthVisible,
              icon: const _WidthPreviewIcon(),
            ),
            _toolCheckbox(
              label: GasesIntroStrings.stopwatch,
              value: model.stopwatchVisible,
              onChanged: model.setStopwatchVisible,
              icon: const _StopwatchPreviewIcon(),
            ),
            _toolCheckbox(
              label: GasesIntroStrings.collisionCounter,
              value: model.collisionCounterVisible,
              onChanged: model.setCollisionCounterVisible,
              icon: const _CollisionPreviewIcon(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolCheckbox({
    required String label,
    required bool value,
    required void Function(bool) onChanged,
    required Widget icon,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                activeColor: GasesIntroShell.accent,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                onChanged: (v) => onChanged(v ?? false),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            icon,
          ],
        ),
      ),
    );
  }

  static String _holdLabel(HoldConstant m) {
    switch (m) {
      case HoldConstant.nothing:
        return GasesIntroStrings.nothing;
      case HoldConstant.volume:
        return GasesIntroStrings.volumeV;
      case HoldConstant.temperature:
        return GasesIntroStrings.temperatureT;
      case HoldConstant.pressureV:
        return GasesIntroStrings.pressureV;
      case HoldConstant.pressureT:
        return GasesIntroStrings.pressureT;
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
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFF373737)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: const Color(0xFFE8A441),
            borderRadius: expanded
                ? const BorderRadius.vertical(top: Radius.circular(4))
                : BorderRadius.circular(4),
            child: InkWell(
              onTap: () => viewState.setParticlesExpanded(!expanded),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4892E),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Icon(
                        expanded ? Icons.remove : Icons.add,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        GasesIntroStrings.particles,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NumberOfParticlesControl(
                    label: GasesIntroStrings.heavy,
                    color: const Color(GasesIntroConstants.heavyParticleColor),
                    value: model.particleSystem.numberOfHeavy,
                    onSet: model.setNumberHeavy,
                    layoutScale: layoutScale,
                  ),
                  const SizedBox(height: 15),
                  NumberOfParticlesControl(
                    label: GasesIntroStrings.light,
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
    final btn = (28 * s).clamp(18.0, 32.0);
    final valueW = (36 * s).clamp(22.0, 40.0);
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
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              _spinBtn(_ArrowKind.singleLeft, -1, btn),
              _spinBtn(_ArrowKind.doubleLeft, -50, btn),
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
              _spinBtn(_ArrowKind.doubleRight, 50, btn),
              _spinBtn(_ArrowKind.singleRight, 1, btn),
            ],
          ),
        ),
      ],
    );
  }

  Widget _spinBtn(_ArrowKind kind, int delta, double btn) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Material(
        color: const Color(0xFF4A4A4A),
        borderRadius: BorderRadius.circular(3),
        child: InkWell(
          onTap: () => onSet(
            (value + delta).clamp(0, GasesIntroConstants.particleMax),
          ),
          child: SizedBox(
            width: btn,
            height: btn,
            child: CustomPaint(painter: _SpinnerArrowPainter(kind)),
          ),
        ),
      ),
    );
  }
}

enum _ArrowKind { singleLeft, doubleLeft, singleRight, doubleRight }

class _SpinnerArrowPainter extends CustomPainter {
  _SpinnerArrowPainter(this.kind);
  final _ArrowKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    void triangle(double cx, bool right) {
      final path = Path();
      final y = size.height / 2;
      final h = size.height * 0.28;
      if (right) {
        path
          ..moveTo(cx - 4, y - h)
          ..lineTo(cx + 5, y)
          ..lineTo(cx - 4, y + h)
          ..close();
      } else {
        path
          ..moveTo(cx + 4, y - h)
          ..lineTo(cx - 5, y)
          ..lineTo(cx + 4, y + h)
          ..close();
      }
      canvas.drawPath(path, paint);
    }

    switch (kind) {
      case _ArrowKind.singleLeft:
        triangle(size.width * 0.5, false);
      case _ArrowKind.doubleLeft:
        triangle(size.width * 0.38, false);
        triangle(size.width * 0.62, false);
      case _ArrowKind.singleRight:
        triangle(size.width * 0.5, true);
      case _ArrowKind.doubleRight:
        triangle(size.width * 0.38, true);
        triangle(size.width * 0.62, true);
    }
  }

  @override
  bool shouldRepaint(covariant _SpinnerArrowPainter oldDelegate) =>
      oldDelegate.kind != kind;
}

class _WidthPreviewIcon extends StatelessWidget {
  const _WidthPreviewIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 16,
      child: CustomPaint(
        painter: _ChevronPairPainter(color: Colors.white70),
      ),
    );
  }
}

class _ChevronPairPainter extends CustomPainter {
  _ChevronPairPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final y = size.height / 2;
    final left = Path()
      ..moveTo(10, 2)
      ..lineTo(2, y)
      ..lineTo(10, size.height - 2);
    final right = Path()
      ..moveTo(size.width - 10, 2)
      ..lineTo(size.width - 2, y)
      ..lineTo(size.width - 10, size.height - 2);
    canvas.drawPath(left, p);
    canvas.drawPath(right, p);
    canvas.drawLine(Offset(12, y), Offset(size.width - 12, y), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StopwatchPreviewIcon extends StatelessWidget {
  const _StopwatchPreviewIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 18,
      decoration: BoxDecoration(
        color: const Color(0xFF5082E6),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.white24),
      ),
    );
  }
}

class _CollisionPreviewIcon extends StatelessWidget {
  const _CollisionPreviewIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 18,
      decoration: BoxDecoration(
        color: const Color(0xFFFED483),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFF8A6A20)),
      ),
    );
  }
}
