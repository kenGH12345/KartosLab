/// Intro or Lab canvas + Loop 3 overlays.
library;

import 'package:flutter/material.dart';

import '../../../common/controls/kratos_combo_box.dart';
import '../../../common/simulation_clock.dart';
import '../../../common/widgets/nine_grid_layout.dart';
import '../config/mss_scenario.dart';
import '../config/mss_scenario_manager.dart';
import '../controller/my_solar_system_controller.dart';
import '../my_solar_system_colors.dart';
import '../my_solar_system_constants.dart';
import '../my_solar_system_strings.dart';
import '../painters/bodies_painter.dart';
import '../painters/center_of_mass_painter.dart';
import '../painters/gravity_vectors_painter.dart';
import '../painters/grid_painter.dart';
import '../painters/path_painter.dart';
import '../painters/velocity_vectors_painter.dart';
import '../render/body_hit_test.dart';
import '../render/mss_mvt.dart';
import '../render/mss_render_data.dart';
import '../render/velocity_vector.dart';
import '../widgets/mss_bodies_control.dart';
import '../widgets/mss_measuring_tape.dart';
import '../widgets/mss_time_controls.dart';
import '../widgets/mss_values_panel.dart';
import '../widgets/mss_visibility_panel.dart';

class MySolarSystemScreen extends StatefulWidget {
  const MySolarSystemScreen({
    super.key,
    required this.isLab,
    this.embedded = false,
    this.controller,
  });

  final bool isLab;
  final bool embedded;
  final MySolarSystemController? controller;

  @override
  State<MySolarSystemScreen> createState() => _MySolarSystemScreenState();
}

class _MySolarSystemScreenState extends State<MySolarSystemScreen>
    with TickerProviderStateMixin {
  MySolarSystemController? _controller;
  late final SimulationClock _clock;
  late final bool _ownsController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _clock = SimulationClock(fps: 60);
    _clock.attach(this);
    _clock.onTick = (dt, _) => _controller?.tick(dt);
    _clock.play();
    if (widget.controller != null) {
      _controller = widget.controller;
      _controller!.addListener(_onNotify);
      _loading = false;
    } else {
      _boot();
    }
  }

  Future<void> _boot() async {
    final manager = MssScenarioManager();
    await manager.loadScenarios();
    if (!mounted) return;
    final catalog = manager.scenarios;
    final initial = manager.findById('sun_planet') ??
        MssScenarioManager.sunPlanetFallback();
    final c = MySolarSystemController(
      isLab: widget.isLab,
      initialScenario: initial,
      catalog: catalog,
    );
    c.addListener(_onNotify);
    setState(() {
      _controller = c;
      _loading = false;
    });
  }

  void _onNotify() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _clock.dispose();
    _controller?.removeListener(_onNotify);
    if (_ownsController) _controller?.dispose();
    super.dispose();
  }

  MssRenderData _renderData(Size canvas, MySolarSystemController c) {
    final mvt = MssMvt(
      center: Offset(canvas.width / 2, canvas.height / 2),
      scale: c.zoomScale,
    );
    final com = c.centerOfMass;
    return MssRenderData(
      mvt: mvt,
      velocityVisible: c.velocityVisible,
      gravityVisible: c.gravityVisible,
      gridVisible: c.gridVisible,
      pathVisible: c.pathVisible,
      centerOfMassVisible: c.centerOfMassVisible,
      comPosition: com.position,
      gravityArrowScale: c.gravityArrowScale,
      velocityArrowScale: c.velocityArrowScale,
      bodies: [
        for (final b in c.activeBodies)
          BodyRenderDot(
            position: b.position,
            velocity: b.velocity,
            gravityForce: b.gravityForce,
            radiusAu: b.radius,
            color: b.color,
            path: c.pathVisible ? List.of(b.pathPoints) : const [],
            velocityOffscale: isVelocityVectorOffscale(b.velocity),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _controller == null) {
      return const Scaffold(
        backgroundColor: MySolarSystemColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final c = _controller!;
    const margin = MySolarSystemConstants.screenMargin;
    final screenW = MediaQuery.sizeOf(context).width;
    final screenH = MediaQuery.sizeOf(context).height;
    final overlayMaxW = MySolarSystemConstants.overlayMaxWidth(screenW);
    final overlayBottomH =
        MySolarSystemConstants.overlayBottomMaxHeight(screenH, screenW);
    final body = Stack(
      fit: StackFit.expand,
      children: [
        NineGridLayout(
          backgroundColor: MySolarSystemColors.background,
          center: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              final data = _renderData(size, c);
              return _PlayArea(data: data, controller: c);
            },
          ),
        ),
        // Left-top: Lab preset + zoom
        Positioned(
          left: margin,
          top: margin,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: overlayMaxW),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isLab) _presetBox(c, overlayMaxW),
                const SizedBox(height: 8),
                _zoomControls(c),
              ],
            ),
          ),
        ),
        // Right-top: TimePanel + Visibility
        Positioned(
          right: margin,
          top: margin,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: overlayMaxW),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                KeyedSubtree(
                  key: const ValueKey('mss-time-panel'),
                  child: MssTimePanel(controller: c),
                ),
                const SizedBox(height: 8),
                MssVisibilityPanel(controller: c, maxWidth: overlayMaxW),
              ],
            ),
          ),
        ),
        // Top-center: Return Bodies + gravity offscale
        if (c.bodiesAreReturnable || c.showOffscaleMessage)
          Positioned(
            top: margin,
            left: 0,
            right: 0,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: overlayMaxW +
                      MySolarSystemConstants.offscaleCenterExtraWidth,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    if (c.bodiesAreReturnable)
                      Material(
                        color: MySolarSystemColors.panel,
                        borderRadius: BorderRadius.circular(4),
                        child: InkWell(
                          key: const ValueKey('mss-return-bodies'),
                          onTap: c.returnBodies,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Text(
                              MySolarSystemStrings.returnBodies,
                              style: TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    if (c.showOffscaleMessage)
                      const Padding(
                        key: ValueKey('mss-offscale'),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          MySolarSystemStrings.offscaleMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        // Bottom-left: ValuesPanel + Bodies + Follow CoM
        Positioned(
          left: margin,
          bottom: margin,
          child: SizedBox(
            width: overlayMaxW,
            height: overlayBottomH,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: MssValuesPanel(controller: c),
                  ),
                ),
                if (widget.isLab) ...[
                  const SizedBox(height: 6),
                  MssBodiesControl(controller: c),
                ],
                if (c.showFollowCenterOfMassButton)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Material(
                      color: MySolarSystemColors.resetOrange,
                      borderRadius: BorderRadius.circular(4),
                      child: InkWell(
                        key: const ValueKey('mss-follow-com'),
                        onTap: c.followAndCenterCenterOfMass,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Text(
                            MySolarSystemStrings.followCenterOfMass,
                            style:
                                TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          right: margin,
          bottom: margin,
          child: Material(
            color: MySolarSystemColors.resetOrange,
            shape: const CircleBorder(),
            child: InkWell(
              key: const ValueKey('mss-reset-all'),
              customBorder: const CircleBorder(),
              onTap: c.resetAll,
              child: SizedBox(
                width: MySolarSystemConstants.resetAllButtonSize,
                height: MySolarSystemConstants.resetAllButtonSize,
                child: Icon(Icons.refresh, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );

    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text(MySolarSystemStrings.title)),
      body: body,
    );
  }

  Widget _zoomControls(MySolarSystemController c) {
    return Material(
      key: const ValueKey('mss-zoom'),
      color: MySolarSystemColors.panel,
      borderRadius:
          BorderRadius.circular(MySolarSystemConstants.panelCornerRadius),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: const ValueKey('mss-zoom-out'),
            onPressed: c.zoomLevel > MySolarSystemConstants.zoomLevelMin
                ? c.zoomOut
                : null,
            icon: const Icon(Icons.remove, color: Colors.white),
          ),
          Text(
            '${c.zoomLevel}',
            style: const TextStyle(color: Colors.white),
          ),
          IconButton(
            key: const ValueKey('mss-zoom-in'),
            onPressed: c.zoomLevel < MySolarSystemConstants.zoomLevelMax
                ? c.zoomIn
                : null,
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _presetBox(MySolarSystemController c, double maxWidth) {
    final items = c.comboScenarios;
    if (items.isEmpty) return const SizedBox.shrink();
    final value = c.comboSelection;
    // Ensure custom is in items for ComboBox value equality
    final comboItems = [
      for (final s in items)
        if (s.scenarioId != 'custom') s,
      ...[
        for (final s in items)
          if (s.scenarioId == 'custom') s,
      ],
    ];
    final hasCustom = comboItems.any((s) => s.scenarioId == 'custom');
    final effectiveItems = hasCustom
        ? comboItems
        : [
            ...comboItems,
            const MssScenario(
              scenarioId: 'custom',
              name: 'Custom',
              comboVisible: true,
              bodies: [],
            ),
          ];
    MssScenario selected = effectiveItems.first;
    for (final s in effectiveItems) {
      if (s.scenarioId == value.scenarioId) {
        selected = s;
        break;
      }
    }
    return ColoredBox(
      key: const ValueKey('mss-preset-combo'),
      color: MySolarSystemColors.panel,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: KratosComboBox<MssScenario>(
          label: 'Orbital System',
          items: effectiveItems,
          itemLabels: [for (final s in effectiveItems) s.name],
          value: selected,
          width: maxWidth.clamp(
            MySolarSystemConstants.presetComboMinWidth,
            MySolarSystemConstants.presetComboMaxWidth,
          ),
          onChanged: c.selectOrbitalSystem,
        ),
      ),
    );
  }
}

class _PlayArea extends StatelessWidget {
  const _PlayArea({
    required this.data,
    required this.controller,
  });

  final MssRenderData data;
  final MySolarSystemController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      key: const ValueKey('mss-play-area'),
      child: ColoredBox(
        color: MySolarSystemColors.background,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: GridPainter(mvt: data.mvt, visible: data.gridVisible),
            ),
            CustomPaint(
              painter: PathPainter(data),
              foregroundPainter: BodiesPainter(data),
              child: const SizedBox.expand(),
            ),
            CustomPaint(painter: GravityVectorsPainter(data)),
            CustomPaint(painter: VelocityVectorsPainter(data)),
            CustomPaint(painter: CenterOfMassPainter(data)),
            MssMeasuringTapeOverlay(controller: controller, mvt: data.mvt),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (d) {
                final p = d.localPosition;
                if (controller.velocityVisible) {
                  final vHit = hitTestVelocityHandle(
                    localView: p,
                    bodies: controller.bodies,
                    mvt: data.mvt,
                  );
                  if (vHit != null) {
                    controller.beginBodyVelocityDrag(vHit);
                    return;
                  }
                }
                final bHit = hitTestBody(
                  localView: p,
                  bodies: controller.bodies,
                  mvt: data.mvt,
                );
                if (bHit != null) {
                  controller.beginBodyPositionDrag(bHit);
                }
              },
              onPanUpdate: (d) {
                final index = controller.draggingBodyIndex;
                if (index == null) return;
                if (controller.draggingVelocity) {
                  controller.updateBodyVelocityFromViewTip(
                    index,
                    d.localPosition,
                    mvt: data.mvt,
                  );
                } else {
                  controller.updateBodyPosition(
                    index,
                    data.mvt.toModel(d.localPosition),
                    canvasSize: data.mvt.canvasSize,
                    mvt: data.mvt,
                  );
                }
              },
              onPanEnd: (_) => controller.endBodyDrag(),
              onPanCancel: controller.endBodyDrag,
            ),
          ],
        ),
      ),
    );
  }
}
