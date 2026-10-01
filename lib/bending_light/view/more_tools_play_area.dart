import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../bending_light_constants.dart';
import '../phet_font.dart';
import '../components/control_widgets.dart';
import '../components/intensity_meter_widget.dart';
import '../components/toolbox_icons.dart';
import '../components/laser_pointer_widget.dart';
import '../components/play_area_painters.dart';
import '../components/protractor_widget.dart';
import '../components/probe_glyph.dart';
import '../components/velocity_sensor_widget.dart';
import '../components/wave_view.dart';
import '../interaction/laser_interaction.dart';
import '../interaction/layout_bump.dart';
import '../model/bl_vec2.dart';
import '../model/enums.dart';
import '../model/more_tools_model.dart';
import '../model/wire_geometry.dart';
import '../screens/stage_scale.dart';
import '../transform/bl_mvt.dart';
import 'source_layout.dart';

/// More Tools: Intro controls plus wavelength, angles, velocity and wave probes.
class MoreToolsPlayArea extends StatefulWidget {
  const MoreToolsPlayArea({super.key, required this.model});

  final MoreToolsModel model;

  @override
  State<MoreToolsPlayArea> createState() => _MoreToolsPlayAreaState();
}

class _MoreToolsPlayAreaState extends State<MoreToolsPlayArea>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ProtractorTool protractor = ProtractorTool();
  final GlobalKey _toolboxKey = GlobalKey();

  MoreToolsModel get model => widget.model;

  double get _sx => StageScale.x(context);

  double get _sy => StageScale.y(context);

  double get _s => StageScale.of(context);

  BlMvt get mvt => BlMvt.moreTools(viewScaleX: _sx, viewScaleY: _sy);

  static final Rect toolbox = Rect.fromLTWH(
    SourceLayout.edgePadding,
    BendingLightConstants.layoutBoundsHeight - 200,
    128,
    192,
  );

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      final showClock = model.laserView == LaserViewEnum.wave ||
          model.waveSensor.enabled;
      if (showClock) model.step();
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _rotateLaser(Offset screenPoint) {
    applyQuadrantRotationDrag(
      laser: model.laser,
      worldPoint: mvt.screenToWorld(screenPoint),
    );
    model.updateModel();
  }

  RenderBox? get _stage => context.findRenderObject() as RenderBox?;

  Offset _viewDelta(Offset globalDelta) {
    final stage = _stage;
    if (stage == null) return globalDelta;
    return stageDelta(stage, globalDelta);
  }

  Rect get _toolboxRect {
    final stage = _stage;
    final tool = _toolboxKey.currentContext?.findRenderObject() as RenderBox?;
    if (stage != null && tool != null) {
      final live = toolboxInStage(stage, tool);
      if (live != null) return live;
    }
    return Rect.fromLTWH(
      toolbox.left * _sx,
      toolbox.top * _sy,
      toolbox.width * _sx,
      toolbox.height * _sy,
    );
  }

  bool _hitsToolbox(Rect node) => _toolboxRect.overlaps(node);

  void _shift(BlVec2 Function() read, void Function(BlVec2) write, Offset delta) {
    final d = mvt.viewToModelDelta(_viewDelta(delta));
    if (!d.x.isFinite || !d.y.isFinite) return;
    write(clampModelPoint(read().plusXY(d.x, d.y), model.modelWidth));
    model.updateModel();
  }

  BlVec2 _screen(BlVec2 world) {
    final o = mvt.worldToScreen(world);
    return BlVec2(o.dx, o.dy);
  }

  Widget _chartAt(BlVec2 body) {
    final p = mvt.worldToScreen(body);
    // WaveSensorNode: Rectangle(0, 0, 135, 100) then scale 0.93, centered
    // on modelToView(bodyPosition). Title is PhetFont(16) inside that scale.
    final sx = _sx;
    final sy = _sy;
    const bodyScale = SourceLayout.chartBodyScale;
    final w = SourceLayout.chartOuterWidth * bodyScale * sx;
    final h = SourceLayout.chartOuterHeight * bodyScale * sy;
    final plot = SourceLayout.chartPlotLocal(Size(w, h));
    return Positioned(
      left: p.dx - w / 2,
      top: p.dy - h / 2,
      width: w,
      height: h,
      child: GestureDetector(
        onPanUpdate: (d) => _shift(
          () => model.waveSensor.bodyPosition,
          (p) => model.waveSensor.bodyPosition = p,
          d.delta,
        ),
        onPanEnd: (_) {
          final p = mvt.worldToScreen(model.waveSensor.bodyPosition);
          final w = SourceLayout.chartOuterWidth * SourceLayout.chartBodyScale * _sx;
          final h = SourceLayout.chartOuterHeight * SourceLayout.chartBodyScale * _sy;
          if (_hitsToolbox(Rect.fromCenter(center: p, width: w, height: h))) {
            model.waveSensor.enabled = false;
            model.updateModel();
          }
        },
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(
                painter: WaveSensorBodyPainter(),
              ),
            ),
            Positioned(
              left: plot.left,
              top: plot.top,
              width: plot.width,
              height: plot.height,
              child: ListenableBuilder(
                listenable: model.waveFrame,
                builder: (context, _) => CustomPaint(
                  painter: WaveChartPainter(
                    readTime: () => model.time,
                    probe1: model.waveSensor.probe1.series,
                    probe2: model.waveSensor.probe2.series,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: h * SourceLayout.timeLabelFraction,
              child: Text(
                'Time',
                textAlign: TextAlign.center,
                style: PhetFont.of(16 * bodyScale, color: Colors.white, height: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _drop(Offset global, void Function(BlVec2 world) place) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(global);
    if (!droppedOutsideToolbox(local, _toolboxRect)) return;
    place(clampModelPoint(mvt.screenToWorld(local), model.modelWidth));
  }

  void _bump(BlVec2 current, void Function(BlVec2) write) {
    final screen = mvt.worldToScreen(current);
    final sx = _sx;
    final sy = _sy;
    final node = Rect.fromCenter(center: screen, width: 80 * sx, height: 40 * sy);
    final panels = [
      Rect.fromLTWH(
        (BendingLightConstants.layoutBoundsWidth - 196) * sx,
        4 * sy,
        190 * sx,
        160 * sy,
      ),
      Rect.fromLTWH(
        (BendingLightConstants.layoutBoundsWidth - 196) * sx,
        168 * sy,
        190 * sx,
        200 * sy,
      ),
    ];
    final dx = bumpLeftViewDx(node, panels, pad: 20 * sx);
    if (dx == 0) return;
    final d = mvt.viewToModelDelta(Offset(dx, 0));
    write(current.plusXY(d.x, d.y));
  }

  void _resetAll() {
    model.reset();
    protractor.reset();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        final sx = _sx;
        final sy = _sy;
        final showClock = model.laserView == LaserViewEnum.wave ||
            model.waveSensor.enabled;
        final velocity = model.velocitySensor;
        final wave = model.waveSensor;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: IntroMediumPainter(
                  mvt: mvt,
                  topSubstance: model.topMedium.substance,
                  bottomSubstance: model.bottomMedium.substance,
                  showNormal: model.showNormal,
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: RaysPainter(mvt: mvt, rays: model.rays),
              ),
            ),
            if (model.laserView == LaserViewEnum.wave)
              Positioned.fill(
                child: ListenableBuilder(
                  listenable: model.waveFrame,
                  builder: (context, _) => CustomPaint(
                    painter: WaveFrontPainter(mvt: mvt, rays: model.rays),
                    foregroundPainter: WaveParticlePainter(mvt: mvt, rays: model.rays),
                  ),
                ),
              ),
            Positioned.fill(
              child: CustomPaint(
                painter: AngleArcsPainter(
                  mvt: mvt,
                  laserAngle: model.laser.getAngle(),
                  showAngles: model.showAngles,
                ),
              ),
            ),
            if (protractor.enabled)
              ProtractorWidget(
                mvt: mvt,
                tool: protractor,
                onAngle: (delta) => setState(() => protractor.angle += delta),
                onDragDelta: (delta) {
                  final d = mvt.viewToModelDelta(_viewDelta(delta));
                  setState(() {
                    protractor.center = clampModelPoint(
                      protractor.center.plusXY(d.x, d.y),
                      model.modelWidth,
                    );
                  });
                },
                onDragEnd: () {
                  final p = mvt.worldToScreen(protractor.center);
                  final radius = 302 * 0.8 / 2 * _s;
                  if (_hitsToolbox(Rect.fromCircle(center: p, radius: radius))) {
                    setState(() => protractor.enabled = false);
                  }
                },
              ),
            if (model.intensityMeter.enabled)
              Positioned.fill(
                child: IntensityMeterWidget(
                  mvt: mvt,
                  meter: model.intensityMeter,
                  onBodyDelta: (d) => _shift(
                    () => model.intensityMeter.bodyPosition,
                    (p) => model.intensityMeter.bodyPosition = p,
                    d,
                  ),
                  onProbeDelta: (d) => _shift(
                    () => model.intensityMeter.sensorPosition,
                    (p) => model.intensityMeter.sensorPosition = p,
                    d,
                  ),
                  onBodyPanEnd: () {
                    final p = mvt.worldToScreen(model.intensityMeter.bodyPosition);
                    if (_hitsToolbox(Rect.fromLTWH(p.dx, p.dy, 90 * _sx, 57 * _sy))) {
                      model.intensityMeter.enabled = false;
                      model.updateModel();
                    }
                  },
                ),
              ),
            if (velocity.enabled)
              VelocitySensorView(
                mvt: mvt,
                position: velocity.position,
                velocity: velocity.value,
                onDelta: (d) => _shift(
                  () => velocity.position,
                  (p) => velocity.position = p,
                  d,
                ),
                onEnd: () {
                  final p = mvt.worldToScreen(velocity.position);
                  final w = 62 * 0.7 * 2 * _sx;
                  final h = 37 * 0.7 * 2 * _sy;
                  if (_hitsToolbox(Rect.fromLTWH(p.dx, p.dy - h / 2, w + 40 * _sx, h))) {
                    velocity.enabled = false;
                    model.updateModel();
                  }
                },
              ),
            if (wave.enabled) ...[
              WaveWire(
                wire: CubicWire.between(
                  start: _screen(wave.bodyPosition).plusXY(
                    (SourceLayout.chartOuterWidth * SourceLayout.chartBodyScale / 2 - 2) * sx,
                    (SourceLayout.chartOuterHeight * SourceLayout.chartBodyScale / 2 -
                            (1 - 0.82) *
                                SourceLayout.chartOuterHeight *
                                SourceLayout.chartBodyScale) *
                        sy,
                  ),
                  startNormal: CubicWire.bodyNormal,
                  end: _screen(wave.probe1.position).plusXY(
                    0,
                    WaveSensorGraphic.probe1.centerBottomDy * sy,
                  ),
                  endNormal: CubicWire.sensorNormal,
                ),
                color: const Color.fromARGB(255, 88, 89, 91),
              ),
              WaveWire(
                wire: CubicWire.between(
                  start: _screen(wave.bodyPosition).plusXY(
                    (SourceLayout.chartOuterWidth * SourceLayout.chartBodyScale / 2 - 2) * sx,
                    (SourceLayout.chartOuterHeight * SourceLayout.chartBodyScale / 2 -
                            (1 - 0.82) *
                                SourceLayout.chartOuterHeight *
                                SourceLayout.chartBodyScale) *
                        sy,
                  ),
                  startNormal: CubicWire.bodyNormal,
                  end: _screen(wave.probe2.position).plusXY(
                    0,
                    WaveSensorGraphic.probe2.centerBottomDy * sy,
                  ),
                  endNormal: CubicWire.sensorNormal,
                ),
                color: const Color.fromARGB(255, 147, 149, 152),
              ),
              _ProbeGlyphAt(
                mvt: mvt,
                position: wave.probe1.position,
                color: const Color(0xFF5C5D5F),
                onDelta: (d) {
                  _shift(
                    () => wave.probe1.position,
                    (p) => wave.probe1.position = p,
                    d,
                  );
                },
              ),
              _ProbeGlyphAt(
                mvt: mvt,
                position: wave.probe2.position,
                color: const Color(0xFFCCCED0),
                onDelta: (d) => _shift(
                  () => wave.probe2.position,
                  (p) => wave.probe2.position = p,
                  d,
                ),
              ),
            ],
            LaserPointerWidget(
              laser: model.laser,
              mvt: mvt,
              onPowerTap: () => model.setLaserOn(!model.laser.on),
              onBodyPanUpdate: (details) {
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                _rotateLaser(box.globalToLocal(details.globalPosition));
              },
            ),
            Positioned(
              left: SourceLayout.edgePadding * sx,
              top: SourceLayout.topBottomPadding * sy,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RayViewRow(
                    wave: model.laserView == LaserViewEnum.wave,
                    showNormal: model.showNormal,
                    includeChecks: false,
                    onRay: () => model.setLaserView(LaserViewEnum.ray),
                    onWave: () => model.setLaserView(LaserViewEnum.wave),
                    onNormal: model.setShowNormal,
                  ),
                  WavelengthControl(
                    wavelengthMeters: model.wavelength,
                    enabled: true,
                    onChangedMeters: model.setWavelength,
                  ),
                ],
              ),
            ),
            Positioned(
              right: SourceLayout.edgePadding * sx,
              bottom: (BendingLightConstants.layoutBoundsHeight -
                      SourceLayout.introTopPanelBottom) *
                  sy,
              child: MediumControlPanel(
                title: 'Material',
                substance: model.topMedium.substance,
                decimals: 3,
                onSubstance: model.setTopSubstance,
                onCustomIndex: (n) =>
                    model.setCustomIndex(top: true, indexForRed: n),
              ),
            ),
            Positioned(
              right: SourceLayout.edgePadding * sx,
              top: SourceLayout.introBottomPanelTop * sy,
              child: MediumControlPanel(
                title: 'Material',
                substance: model.bottomMedium.substance,
                decimals: 3,
                onSubstance: model.setBottomSubstance,
                onCustomIndex: (n) =>
                    model.setCustomIndex(top: false, indexForRed: n),
              ),
            ),
            Positioned(
              left: SourceLayout.edgePadding * sx,
              bottom: SourceLayout.topBottomPadding * sy,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: toolbox.width * sx,
                    child: ToolBoxPanel(
                      key: _toolboxKey,
                      children: [
                        ToolboxSlot(
                          inToolbox: !protractor.enabled,
                          child: ToolboxChip(
                            semanticsLabel: 'Protractor',
                            child: const ProtractorToolboxIcon(),
                            onDragEnd: (g) => _drop(g, (world) {
                              setState(() {
                                protractor.enabled = true;
                                protractor.center = world;
                              });
                            }),
                          ),
                        ),
                        ToolboxSlot(
                          inToolbox: !model.intensityMeter.enabled,
                          child: ToolboxChip(
                            semanticsLabel: 'Intensity',
                            child: const IntensityToolboxIcon(),
                            onDragEnd: (g) => _drop(g, (world) {
                              final meter = model.intensityMeter;
                              final dx = world.x - meter.bodyPosition.x;
                              final dy = world.y - meter.bodyPosition.y;
                              meter.bodyPosition = world;
                              meter.sensorPosition =
                                  meter.sensorPosition.plusXY(dx, dy);
                              _bump(meter.bodyPosition, (p) => meter.bodyPosition = p);
                              meter.enabled = true;
                              model.updateModel();
                            }),
                          ),
                        ),
                        ToolboxSlot(
                          inToolbox: !velocity.enabled,
                          child: ToolboxChip(
                            semanticsLabel: 'Velocity',
                            child: const VelocityToolboxIcon(),
                            onDragEnd: (g) => _drop(g, (world) {
                              model.velocitySensor.position = world;
                              _bump(world, (p) => model.velocitySensor.position = p);
                              model.velocitySensor.enabled = true;
                              model.updateModel();
                            }),
                          ),
                        ),
                        ToolboxSlot(
                          inToolbox: !wave.enabled,
                          child: ToolboxChip(
                            semanticsLabel: 'Wave',
                            child: const WaveToolboxIcon(),
                            onDragEnd: (g) => _drop(g, (world) {
                              final sensor = model.waveSensor;
                              final dx = world.x - sensor.bodyPosition.x;
                              final dy = world.y - sensor.bodyPosition.y;
                              sensor.bodyPosition = world;
                              sensor.probe1.position =
                                  sensor.probe1.position.plusXY(dx, dy);
                              sensor.probe2.position =
                                  sensor.probe2.position.plusXY(dx, dy);
                              _bump(sensor.bodyPosition, (p) => sensor.bodyPosition = p);
                              sensor.enabled = true;
                              model.updateModel();
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: SourceLayout.edgePadding * sy),
                  Padding(
                    padding: EdgeInsets.only(left: SourceLayout.edgePadding * sx),
                    child: RayViewRow(
                      wave: model.laserView == LaserViewEnum.wave,
                      showNormal: model.showNormal,
                      showAngles: true,
                      anglesValue: model.showAngles,
                      includeViewButtons: false,
                      onRay: () => model.setLaserView(LaserViewEnum.ray),
                      onWave: () => model.setLaserView(LaserViewEnum.wave),
                      onNormal: model.setShowNormal,
                      onAngles: model.setShowAngles,
                    ),
                  ),
                ],
              ),
            ),
            if (showClock)
              Positioned(
                left: 388 * sx,
                bottom: SourceLayout.topBottomPadding * sy,
                child: BlTimeControl(
                  isPlaying: model.isPlaying,
                  speed: model.speed,
                  onPlayPause: model.togglePlaying,
                  onStep: model.stepOnce,
                  onSpeed: model.setSpeed,
                ),
              ),
            Positioned(
              right: SourceLayout.edgePadding * sx,
              bottom: SourceLayout.topBottomPadding * sy,
              child: ResetAllCorner(onPressed: _resetAll),
            ),
            if (wave.enabled) _chartAt(wave.bodyPosition),
          ],
        );
      },
    );
  }
}

class _ProbeGlyphAt extends StatelessWidget {
  const _ProbeGlyphAt({
    required this.mvt,
    required this.position,
    required this.color,
    required this.onDelta,
  });

  final BlMvt mvt;
  final BlVec2 position;
  final Color color;
  final void Function(Offset delta) onDelta;

  @override
  Widget build(BuildContext context) {
    final p = mvt.worldToScreen(position);
    final s = StageScale.of(context);
    final glyph = ProbeGlyph(
      color: color,
      radius: 43,
      innerRadius: 32,
      handleWidth: 40,
      handleHeight: 30,
      handleCornerRadius: 9,
      scale: 0.35 * s,
      crosshairs: true,
    );
    return Positioned(
      left: p.dx - glyph.sensorOrigin.dx,
      top: p.dy - glyph.sensorOrigin.dy,
      child: GestureDetector(
        onPanUpdate: (d) => onDelta(d.delta),
        child: glyph,
      ),
    );
  }
}

