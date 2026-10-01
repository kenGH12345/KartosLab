import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../bending_light_constants.dart';
import '../components/control_widgets.dart';
import '../components/intensity_meter_widget.dart';
import '../components/toolbox_icons.dart';
import '../components/laser_pointer_widget.dart';
import '../components/play_area_painters.dart';
import '../components/wave_view.dart';
import '../interaction/layout_bump.dart';
import '../components/protractor_widget.dart';
import '../interaction/laser_interaction.dart';
import '../model/bl_vec2.dart';
import '../model/enums.dart';
import '../model/intro_model.dart';
import '../screens/stage_scale.dart';
import '../transform/bl_mvt.dart';
import 'source_layout.dart';

/// Intro play area plus the original control set (no wavelength / angles).
class IntroPlayArea extends StatefulWidget {
  const IntroPlayArea({super.key, required this.model});

  final IntroModel model;

  @override
  State<IntroPlayArea> createState() => _IntroPlayAreaState();
}

class _IntroPlayAreaState extends State<IntroPlayArea>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ProtractorTool protractor = ProtractorTool();
  final GlobalKey _toolboxKey = GlobalKey();

  IntroModel get model => widget.model;

  double get _sx => StageScale.x(context);

  double get _sy => StageScale.y(context);

  double get _s => StageScale.of(context);

  BlMvt get mvt => BlMvt.intro(viewScaleX: _sx, viewScaleY: _sy);

  static final Rect toolbox = Rect.fromLTWH(
    SourceLayout.edgePadding,
    BendingLightConstants.layoutBoundsHeight - 168,
    120,
    160,
  );

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      if (model.laserView == LaserViewEnum.wave) {
        model.step();
      }
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

  void _moveMeterBody(Offset delta) {
    final d = mvt.viewToModelDelta(_viewDelta(delta));
    model.intensityMeter.bodyPosition = clampModelPoint(
      model.intensityMeter.bodyPosition.plusXY(d.x, d.y),
      model.modelWidth,
    );
    model.updateModel();
  }

  void _moveMeterProbe(Offset delta) {
    final d = mvt.viewToModelDelta(_viewDelta(delta));
    model.intensityMeter.sensorPosition = clampModelPoint(
      model.intensityMeter.sensorPosition.plusXY(d.x, d.y),
      model.modelWidth,
    );
    model.updateModel();
  }

  void _putBackMeter() {
    final p = mvt.worldToScreen(model.intensityMeter.bodyPosition);
    if (_hitsToolbox(Rect.fromLTWH(p.dx, p.dy, 90 * _sx, 57 * _sy))) {
      model.intensityMeter.enabled = false;
      model.updateModel();
    }
  }

  void _resetAll() {
    model.reset();
    protractor.reset();
    setState(() {});
  }

  List<Rect> get _rightPanels {
    final sx = _sx;
    final sy = _sy;
    return [
      Rect.fromLTWH(
        (BendingLightConstants.layoutBoundsWidth - 196) * sx,
        8 * sy,
        190 * sx,
        170 * sy,
      ),
      Rect.fromLTWH(
        (BendingLightConstants.layoutBoundsWidth - 196) * sx,
        188 * sy,
        190 * sx,
        170 * sy,
      ),
    ];
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
    final node = Rect.fromCenter(center: screen, width: 80 * _sx, height: 40 * _sy);
    final dx = bumpLeftViewDx(node, _rightPanels, pad: 20 * _sx);
    if (dx == 0) return;
    final d = mvt.viewToModelDelta(Offset(dx, 0));
    write(current.plusXY(d.x, d.y));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        final sx = _sx;
        final sy = _sy;
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
                  onBodyDelta: _moveMeterBody,
                  onProbeDelta: _moveMeterProbe,
                  onBodyPanEnd: _putBackMeter,
                ),
              ),
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
              child: RayViewRow(
                wave: model.laserView == LaserViewEnum.wave,
                showNormal: model.showNormal,
                includeChecks: false,
                onRay: () => model.setLaserView(LaserViewEnum.ray),
                onWave: () => model.setLaserView(LaserViewEnum.wave),
                onNormal: (v) => model.setShowNormal(v),
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
                decimals: 2,
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
                decimals: 2,
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
                            onDragEnd: (global) => _drop(global, (world) {
                              setState(() {
                                protractor.enabled = true;
                                protractor.center =
                                    clampModelPoint(world, model.modelWidth);
                              });
                            }),
                          ),
                        ),
                        ToolboxSlot(
                          inToolbox: !model.intensityMeter.enabled,
                          child: ToolboxChip(
                            semanticsLabel: 'Intensity',
                            child: const IntensityToolboxIcon(),
                            onDragEnd: (global) => _drop(global, (world) {
                              final meter = model.intensityMeter;
                              final dx = world.x - meter.bodyPosition.x;
                              final dy = world.y - meter.bodyPosition.y;
                              meter.bodyPosition = world;
                              meter.sensorPosition =
                                  meter.sensorPosition.plusXY(dx, dy);
                              _bump(meter.bodyPosition, (p) {
                                final ddx = p.x - meter.bodyPosition.x;
                                final ddy = p.y - meter.bodyPosition.y;
                                meter.bodyPosition = p;
                                meter.sensorPosition =
                                    meter.sensorPosition.plusXY(ddx, ddy);
                              });
                              meter.enabled = true;
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
                      includeViewButtons: false,
                      onRay: () => model.setLaserView(LaserViewEnum.ray),
                      onWave: () => model.setLaserView(LaserViewEnum.wave),
                      onNormal: (v) => model.setShowNormal(v),
                    ),
                  ),
                ],
              ),
            ),
            if (model.laserView == LaserViewEnum.wave)
              Positioned(
                left: SourceLayout.introNormalX * sx,
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
          ],
        );
      },
    );
  }
}
