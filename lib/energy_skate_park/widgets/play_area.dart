import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kratos/energy_skate_park/controller/esp_controller.dart';
import 'package:kratos/energy_skate_park/controller/measure_controller.dart';
import 'package:kratos/energy_skate_park/controller/playground_controller.dart';
import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/esp_strings.dart';
import 'package:kratos/energy_skate_park/model/esp_vec.dart';
import 'package:kratos/energy_skate_park/painters/background_painter.dart';
import 'package:kratos/energy_skate_park/painters/grid_painter.dart';
import 'package:kratos/energy_skate_park/painters/pie_chart_painter.dart';
import 'package:kratos/energy_skate_park/painters/skater_painter.dart';
import 'package:kratos/energy_skate_park/painters/track_painter.dart';
import 'package:kratos/energy_skate_park/render/esp_mvt.dart';
import 'package:kratos/energy_skate_park/render/esp_render_builder.dart';
import 'package:kratos/energy_skate_park/widgets/energy_sensor.dart';
import 'package:kratos/energy_skate_park/widgets/measuring_tape.dart';
import 'package:kratos/energy_skate_park/widgets/reference_height_line.dart';
import 'package:kratos/energy_skate_park/widgets/skater_image_cache.dart';
import 'package:kratos/energy_skate_park/widgets/probe_node_painter.dart';
import 'package:kratos/energy_skate_park/widgets/sensor_wire_painter.dart';
import 'package:kratos/energy_skate_park/widgets/stopwatch_overlay.dart';
import 'package:kratos/energy_skate_park/widgets/toolbox_panel.dart';
import 'package:kratos/energy_skate_park/widgets/toolbox_return.dart';

class PlayArea extends StatefulWidget {
  const PlayArea({
    super.key,
    required this.controller,
    this.showToolbox = true,
  });

  final EspController controller;
  final bool showToolbox;

  @override
  State<PlayArea> createState() => _PlayAreaState();
}

class _PlayAreaState extends State<PlayArea> {
  bool _draggingSkater = false;
  bool _draggingProbe = false;
  bool _draggingCp = false;
  Offset? _tapeBodyStartView;
  EspVec? _tapeBodyStartBase;
  EspVec? _tapeBodyStartTip;
  Offset? _pointerDown;
  DateTime? _downAt;
  final GlobalKey _playAreaKey = GlobalKey();

  ui.Image? _skaterLeft;
  ui.Image? _skaterRight;
  ui.Image? _mountains;
  ui.Image? _cementTexture;
  int _loadedSkaterIndex = -1;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
    _loadAssets();
    _loadMountains();
    _loadCementTexture();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }

  void _onController() {
    final idx = widget.controller.view.selectedSkaterIndex;
    if (idx != _loadedSkaterIndex) _loadSkaterImages(idx);
  }

  Future<void> _loadMountains() async {
    try {
      final img = await _decode(EspConstants.mountainsAsset);
      if (mounted) setState(() => _mountains = img);
    } catch (_) {}
  }

  Future<void> _loadCementTexture() async {
    try {
      final img = await _decode(EspConstants.cementTextureAsset);
      if (mounted) setState(() => _cementTexture = img);
    } catch (_) {}
  }

  Future<void> _loadSkaterImages(int index) async {
    final pair = await SkaterImageCache.instance.loadSet(index);
    if (!mounted) return;
    setState(() {
      _skaterLeft = pair.left;
      _skaterRight = pair.right;
      _loadedSkaterIndex = index;
    });
  }

  Future<void> _loadAssets() async {
    await _loadSkaterImages(widget.controller.view.selectedSkaterIndex);
  }

  Future<ui.Image> _decode(String asset) async {
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    return (await codec.getNextFrame()).image;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final mvt = EspMvt.forPlayArea(size);
        final data = EspRenderBuilder.build(widget.controller, size: size);
        final c = widget.controller;

        return Stack(
          fit: StackFit.expand,
          children: [
            Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (e) =>
                  _onPointerDown(e.localPosition, mvt, data.skaterCenter, size),
              onPointerMove: (e) => _onPointerMove(e.localPosition, mvt, size),
              onPointerUp: (e) => _onPointerUp(e.localPosition, mvt),
              onPointerCancel: (_) => _onPointerUp(null, mvt),
              child: Stack(
                key: _playAreaKey,
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: BackgroundPainter(
                      mvt: mvt,
                      mountains: _mountains,
                      cementTexture: _cementTexture,
                    ),
                    size: size,
                  ),
                  CustomPaint(
                    painter: GridPainter(mvt: mvt, visible: data.gridVisible),
                    size: size,
                  ),
                  CustomPaint(
                    painter: TrackPainter(data: data),
                    size: size,
                  ),
                  CustomPaint(
                    painter: SkaterPainter(
                      data: data,
                      leftImage: _skaterLeft,
                      rightImage: _skaterRight,
                    ),
                    size: size,
                  ),
                  CustomPaint(
                    painter: PieChartPainter(data: data),
                    size: size,
                  ),
                  if (c is MeasureController)
                    _buildSensorLayer(c, mvt, size),
                  ReferenceHeightLineOverlay(
                    controller: c,
                    mvt: mvt,
                    onDragStart: () {},
                    onDragUpdate: (y) => c.setReferenceHeight(y),
                    onDragEnd: () {},
                  ),
                  MeasuringTapeOverlay(
                    controller: c,
                    mvt: mvt,
                    onHandleDown: (_) {},
                    onHandleMove: (h, local) =>
                        _onTapeHandleMove(h, local, mvt),
                    onHandleUp: (h) {
                      if (h == MeasuringTapeHandle.base) {
                        _tryReturnMeasuringTape(c, mvt);
                      }
                      _tapeBodyStartView = null;
                      _tapeBodyStartBase = null;
                      _tapeBodyStartTip = null;
                    },
                  ),
                  StopwatchOverlay(
                    controller: c,
                    playAreaSize: size,
                  ),
                  if (c is PlaygroundController) _buildCpOverlay(c, mvt, size),
                ],
              ),
            ),
            if (widget.showToolbox)
              Positioned(
                left: 8,
                bottom: 8,
                child: ToolboxPanel(
                  controller: c,
                  mvt: mvt,
                  playAreaSize: size,
                  onDragStart: () {},
                  onDragUpdate: (local, tool) {
                    if (tool == ToolboxTool.stopwatch) {
                      c.placeStopwatchFromToolbox(
                        local - const Offset(50, 24),
                        size,
                      );
                    } else {
                      c.placeMeasuringTapeFromToolbox(mvt.viewToModel(local));
                    }
                  },
                  onDragEnd: () {},
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSensorLayer(MeasureController c, EspMvt mvt, Size size) {
    final mm = c.measureModel;
    final sample = mm.findNearestSample(mm.sensorProbePosition, mvt);
    final probeView = mvt.modelToView(mm.sensorProbePosition);
    final halo = sample == null
        ? null
        : mvt.modelToViewXY(sample.positionX, sample.positionY);
    final bodyAnchor =
        SensorWirePainter.defaultBodyAnchor(size.height);
    final probeAnchor = SensorWirePainter.probeLeft(probeView);

    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          size: size,
          painter: SensorWirePainter(
            bodyAnchor: bodyAnchor,
            probeAnchor: probeAnchor,
          ),
        ),
        CustomPaint(
          size: size,
          painter: EnergySensorPainter(probeView: probeView, haloView: halo),
        ),
      ],
    );
  }

  Widget _buildCpOverlay(
      PlaygroundController c, EspMvt mvt, Size size) {
    final track = c.selectedTrack;
    final idx = c.selectedControlPointIndex;
    if (track == null || idx == null || track.controlPoints.length <= idx) {
      return const SizedBox.shrink();
    }
    final cp = track.controlPoints[idx];
    final view = mvt.modelToView(cp.position);
    return Positioned(
      left: (view.dx - 70).clamp(0.0, size.width - 140),
      top: (view.dy - 52).clamp(0.0, size.height - 44),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFFCF6A0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed:
                    c.canSplitSelected ? c.splitSelectedControlPoint : null,
                child: const Text(EspStrings.splitTrack,
                    style: TextStyle(fontSize: 11)),
              ),
              TextButton(
                onPressed: c.canDeleteSelected
                    ? c.deleteSelectedControlPoint
                    : null,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text(EspStrings.deleteControlPoint,
                    style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _tryReturnMeasuringTape(EspController c, EspMvt mvt) {
    final playBox = _playAreaKey.currentContext?.findRenderObject();
    if (playBox is! RenderBox) return;
    final baseView = mvt.modelToView(c.model.measuringTapeBase);
    final globalBase = playBox.localToGlobal(baseView);
    final bounds = ToolboxReturn.measuringTapeBaseBounds(baseView: globalBase);
    c.onMeasuringTapeBaseDragEnd(bounds);
  }

  void _onTapeHandleMove(
      MeasuringTapeHandle handle, Offset local, EspMvt mvt) {
    final c = widget.controller;
    if (handle == MeasuringTapeHandle.base) {
      c.setMeasuringTapeBase(mvt.viewToModel(local));
    } else if (handle == MeasuringTapeHandle.tip) {
      c.setMeasuringTapeTip(mvt.viewToModel(local));
    } else {
      _tapeBodyStartView ??= local;
      _tapeBodyStartBase ??= c.model.measuringTapeBase;
      _tapeBodyStartTip ??= c.model.measuringTapeTip;
      final startModel = mvt.viewToModel(_tapeBodyStartView!);
      final curModel = mvt.viewToModel(local);
      final delta = curModel - startModel;
      c.translateMeasuringTape(delta);
    }
  }

  void _onPointerDown(
      Offset local, EspMvt mvt, Offset skaterCenter, Size size) {
    final c = widget.controller;
    _pointerDown = local;
    _downAt = DateTime.now();

    if (c is MeasureController) {
      final probeView = mvt.modelToView(c.measureModel.sensorProbePosition);
      if ((local - probeView).distance <= ProbeNodePainter.hitRadius()) {
        _draggingProbe = true;
        return;
      }
    }

    if (c is PlaygroundController) {
      if (c.beginControlPointDrag(mvt.viewToModel(local))) {
        _draggingCp = true;
        return;
      }
    }

    final pickR = EspConstants.skaterPickRadius * mvt.scale * 1.4;
    if ((local - skaterCenter).distance <= pickR) {
      _draggingSkater = true;
      c.beginSkaterDrag();
      c.dragSkater(mvt.viewToModel(local));
    }
  }

  void _onPointerMove(Offset local, EspMvt mvt, Size size) {
    final c = widget.controller;
    if (_draggingProbe && c is MeasureController) {
      c.setSensorProbe(mvt.viewToModel(local));
      return;
    }
    if (_draggingCp && c is PlaygroundController) {
      c.dragControlPoint(mvt.viewToModel(local));
      return;
    }
    if (_draggingSkater) {
      c.dragSkater(mvt.viewToModel(local));
    }
  }

  void _onPointerUp(Offset? local, EspMvt mvt) {
    final c = widget.controller;
    final down = _pointerDown;
    final at = _downAt;
    _pointerDown = null;
    _downAt = null;

    if (_draggingProbe) {
      _draggingProbe = false;
      return;
    }
    if (_draggingCp && c is PlaygroundController) {
      _draggingCp = false;
      final moved =
          down != null && local != null && (local - down).distance > 8;
      c.endControlPointDrag();
      if (!moved &&
          at != null &&
          DateTime.now().difference(at).inMilliseconds >= 450 &&
          local != null) {
        c.splitAt(mvt.viewToModel(local));
      }
      return;
    }
    if (_draggingSkater) {
      _draggingSkater = false;
      c.endSkaterDrag();
      return;
    }

    if (c is PlaygroundController && local != null && down != null) {
      if ((local - down).distance <= 8) {
        c.selectNearestControlPoint(mvt.viewToModel(local));
      }
    }
  }
}
