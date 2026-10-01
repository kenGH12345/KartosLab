import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../common/simulation_clock.dart';
import '../../common/widgets/kratos_reset_all_button.dart';
import '../caf_assets.dart';
import '../caf_colors.dart';
import '../caf_constants.dart';
import '../caf_strings.dart';
import '../model/charged_particle.dart';
import '../model/charges_and_fields_model.dart';
import '../model/electric_field_sensor.dart';
import '../model/vec2.dart';
import '../painters/caf_scene_painters.dart';
import '../painters/potential_visual.dart';
import '../transform/caf_mvt.dart';
import '../widgets/charges_and_sensors_panel.dart';
import '../widgets/control_panel.dart';

/// Full Charges and Fields play area (single screen).
class ChargesAndFieldsScreen extends StatefulWidget {
  const ChargesAndFieldsScreen({
    super.key,
    this.model,
    this.autoStartClock = true,
  });

  final ChargesAndFieldsModel? model;

  /// Widget tests should set false — FakeAsync + perpetual ticker hangs settle.
  final bool autoStartClock;

  @override
  State<ChargesAndFieldsScreen> createState() => ChargesAndFieldsScreenState();
}

class ChargesAndFieldsScreenState extends State<ChargesAndFieldsScreen>
    with TickerProviderStateMixin {
  late final ChargesAndFieldsModel model;
  late final SimulationClock clock;
  late CafMvt mvt;

  final GlobalKey _binKey = GlobalKey();
  final GlobalKey _toolboxKey = GlobalKey();
  /// Layout-space (1024×618) scene — not the outer FittedBox / Home body.
  final GlobalKey _sceneKey = GlobalKey();

  Object? _dragging; // ChargedParticle | ElectricFieldSensor | 'voltmeter' | 'tape'
  Offset? _dragGrabOffset;

  ui.Image? _potentialImage;
  int _potentialCols = 0;
  int _potentialRows = 0;
  int _potentialBuildId = 0;

  @override
  void initState() {
    super.initState();
    model = widget.model ?? ChargesAndFieldsModel();
    model.onChanged = () {
      _schedulePotentialRebuild();
      if (mounted) setState(() {});
    };
    model.isChargesAndSensorsPanelDisplayed = () => true;

    mvt = CafMvt.fromLayout(
      const Size(CafConstants.layoutWidth, CafConstants.layoutHeight),
    );

    clock = SimulationClock(fps: 60);
    clock.attach(this);
    clock.onTick = (dt, _) {
      model.tick(dt);
      if (mounted) setState(() {});
    };
    if (widget.autoStartClock) {
      clock.play();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncEnclosure();
      _schedulePotentialRebuild();
    });
  }

  void _schedulePotentialRebuild() {
    final id = ++_potentialBuildId;
    () async {
      final result = await buildPotentialFieldImage(model, viewScale: mvt.scale);
      if (!mounted || id != _potentialBuildId) {
        result?.$1.dispose();
        return;
      }
      _potentialImage?.dispose();
      if (result == null) {
        setState(() {
          _potentialImage = null;
          _potentialCols = 0;
          _potentialRows = 0;
        });
      } else {
        setState(() {
          _potentialImage = result.$1;
          _potentialCols = result.$2.numHorizontal;
          _potentialRows = result.$2.numVertical;
        });
      }
    }();
  }

  @override
  void dispose() {
    clock.dispose();
    model.onChanged = null;
    _potentialImage?.dispose();
    super.dispose();
  }

  void _syncEnclosure() {
    final binBox =
        _binKey.currentContext?.findRenderObject() as RenderBox?;
    final sceneBox =
        _sceneKey.currentContext?.findRenderObject() as RenderBox?;
    if (binBox == null || !binBox.hasSize || sceneBox == null) return;
    final topLeft = sceneBox.globalToLocal(binBox.localToGlobal(Offset.zero));
    final rect = topLeft & binBox.size;
    model.chargesAndSensorsEnclosureBounds = mvt.viewToModelBounds(rect);
  }

  /// Convert screen/global → PhET layout coordinates inside [_sceneKey].
  Offset _sceneLocal(Offset global) {
    final box = _sceneKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return global;
    return box.globalToLocal(global);
  }

  void _bump() {
    _schedulePotentialRebuild();
    setState(() {});
  }

  // ─── Spawn from bin / toolbox ──────────────────────────────────────────

  void _onBinPositive(DragDownDetails details) {
    final local = _sceneLocal(details.globalPosition);
    final home = mvt.viewToModel(local);
    final p = model.addPositiveCharge(home);
    p.isUserControlled = true;
    p.position = home;
    _dragging = p;
    _dragGrabOffset = Offset.zero;
    _bump();
  }

  void _onBinNegative(DragDownDetails details) {
    final local = _sceneLocal(details.globalPosition);
    final home = mvt.viewToModel(local);
    final p = model.addNegativeCharge(home);
    p.isUserControlled = true;
    p.position = home;
    _dragging = p;
    _dragGrabOffset = Offset.zero;
    _bump();
  }

  void _onBinSensor(DragDownDetails details) {
    final local = _sceneLocal(details.globalPosition);
    final home = mvt.viewToModel(local);
    final s = model.addElectricFieldSensor(home);
    s.isUserControlled = true;
    s.isActive = false;
    s.position = home;
    _dragging = s;
    _dragGrabOffset = Offset.zero;
    _bump();
  }

  void _onToolboxVoltmeter(DragDownDetails details) {
    final local = _sceneLocal(details.globalPosition);
    // Source: initialViewPosition.plusXY(0, -outlineHeight * 6/25)
    // so crosshair (measurement point) is above the grab on the body.
    const outlineH = 535.0; // mipmap L0 height
    final tipOffset = Offset(0, -outlineH * 6 / 25 * 0.55);
    model.electricPotentialSensor.isActive = true;
    model.electricPotentialSensor
        .setPosition(mvt.viewToModel(local + tipOffset));
    _dragging = 'voltmeter';
    _dragGrabOffset = -tipOffset;
    _bump();
  }

  void _onToolboxTape(DragDownDetails details) {
    final local = _sceneLocal(details.globalPosition);
    final pos = mvt.viewToModel(local);
    model.measuringTape.isActive = true;
    model.measuringTape.basePosition = pos;
    model.measuringTape.tipPosition = pos + const CafVec2(0.2, 0);
    model.measuringTape.notify();
    _dragging = 'tapeBase';
    _dragGrabOffset = Offset.zero;
    _bump();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_dragging == null) return;
    final local =
        _sceneLocal(event.position) - (_dragGrabOffset ?? Offset.zero);
    final pos = mvt.viewToModel(local);

    if (_dragging is ChargedParticle) {
      final p = _dragging as ChargedParticle;
      p.position = pos;
      if (p.isActive) {
        model.clearElectricPotentialLines();
        model.updateAllSensors();
      }
      model.updateIsPlayAreaCharged();
    } else if (_dragging is ElectricFieldSensor) {
      (_dragging as ElectricFieldSensor).position = pos;
    } else if (_dragging == 'voltmeter') {
      model.electricPotentialSensor.setPosition(pos);
    } else if (_dragging == 'tapeBase') {
      final delta = pos - model.measuringTape.basePosition;
      model.measuringTape.basePosition = pos;
      model.measuringTape.tipPosition =
          model.measuringTape.tipPosition + delta;
      model.measuringTape.notify();
    } else if (_dragging == 'tapeTip') {
      model.measuringTape.tipPosition = pos;
      model.measuringTape.notify();
    }
    _bump();
  }

  void _onPointerEnd(PointerEvent event) {
    if (_dragging == null) return;
    if (_dragging is ChargedParticle) {
      model.handleChargeReleased(_dragging as ChargedParticle);
    } else if (_dragging is ElectricFieldSensor) {
      model.handleFieldSensorReleased(_dragging as ElectricFieldSensor);
    } else if (_dragging == 'voltmeter') {
      _maybeReturnVoltmeter();
      model.electricPotentialSensor
          .setPosition(model.snapPosition(model.electricPotentialSensor.position));
    } else if (_dragging == 'tapeBase' || _dragging == 'tapeTip') {
      _maybeReturnTape();
      model.measuringTape.basePosition =
          model.snapPosition(model.measuringTape.basePosition);
      model.measuringTape.tipPosition =
          model.snapPosition(model.measuringTape.tipPosition);
      model.measuringTape.notify();
    }
    _dragging = null;
    _dragGrabOffset = null;
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncEnclosure());
    _bump();
  }

  void _maybeReturnVoltmeter() {
    final box = _toolboxKey.currentContext?.findRenderObject() as RenderBox?;
    final scene = _sceneKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || scene == null) return;
    final topLeft = scene.globalToLocal(box.localToGlobal(Offset.zero));
    final rect = (topLeft & box.size).deflate(5);
    final tip = mvt.modelToView(model.electricPotentialSensor.position);
    if (rect.contains(tip)) {
      model.electricPotentialSensor.isActive = false;
      model.electricPotentialSensor.reset();
    }
  }

  void _maybeReturnTape() {
    final box = _toolboxKey.currentContext?.findRenderObject() as RenderBox?;
    final scene = _sceneKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || scene == null) return;
    final topLeft = scene.globalToLocal(box.localToGlobal(Offset.zero));
    final rect = (topLeft & box.size).deflate(5);
    final tip = mvt.modelToView(model.measuringTape.basePosition);
    if (rect.contains(tip)) {
      model.measuringTape.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Fit PhET layout bounds into available space (contain).
        final scale = math.min(
          constraints.maxWidth / CafConstants.layoutWidth,
          constraints.maxHeight / CafConstants.layoutHeight,
        );
        final w = CafConstants.layoutWidth * scale;
        final h = CafConstants.layoutHeight * scale;
        // Keep MVT in layout coordinates; we scale the whole scene.
        mvt = CafMvt.fromLayout(
          const Size(CafConstants.layoutWidth, CafConstants.layoutHeight),
        );

        return ColoredBox(
          color: CafColors.background,
          child: Center(
            child: SizedBox(
              width: w,
              height: h,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  key: _sceneKey,
                  width: CafConstants.layoutWidth,
                  height: CafConstants.layoutHeight,
                  // Listener (not GestureDetector): child onPanDown used to win the
                  // pan arena and swallow onPanUpdate — raw pointers always deliver.
                  child: Listener(
                    behavior: HitTestBehavior.translucent,
                    onPointerMove: _onPointerMove,
                    onPointerUp: _onPointerEnd,
                    onPointerCancel: _onPointerEnd,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Layers (bottom → top)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: ElectricPotentialGridPainter(
                              model: model,
                              mvt: mvt,
                              cachedImage: _potentialImage,
                              numHorizontal: _potentialCols,
                              numVertical: _potentialRows,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: CafGridPainter(model: model, mvt: mvt),
                          ),
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: ElectricFieldGridPainter(
                              model: model,
                              mvt: mvt,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: EquipotentialLinesPainter(
                              model: model,
                              mvt: mvt,
                            ),
                          ),
                        ),

                        // Control panel + toolbox (top-right column)
                        Positioned(
                          top: 30,
                          right: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CafControlPanel(
                                model: model,
                                onChanged: _bump,
                              ),
                              const SizedBox(height: 10),
                              KeyedSubtree(
                                key: _toolboxKey,
                                child: CafToolboxPanel(
                                  voltmeterInToolbox:
                                      !model.electricPotentialSensor.isActive,
                                  tapeInToolbox: !model.measuringTape.isActive,
                                  onVoltmeterDown: _onToolboxVoltmeter,
                                  onTapeDown: _onToolboxTape,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Reset bottom-right
                        Positioned(
                          right: 10,
                          bottom: 20,
                          child: KratosResetAllButton(
                            radius: CafConstants.resetAllRadius,
                            onPressed: () {
                              model.reset();
                              _bump();
                            },
                          ),
                        ),

                        // Charges bin bottom-center
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 15,
                          child: Center(
                            child: KeyedSubtree(
                              key: _binKey,
                              child: ChargesAndSensorsPanel(
                                onPositiveDown: _onBinPositive,
                                onNegativeDown: _onBinNegative,
                                onSensorDown: _onBinSensor,
                              ),
                            ),
                          ),
                        ),

                        // Draggable charges
                        ...model.chargedParticles.map(_buildCharge),

                        // E-field sensors
                        ...model.electricFieldSensors.map(_buildESensor),

                        // Voltmeter
                        if (model.electricPotentialSensor.isActive)
                          _buildVoltmeter(),

                        // Measuring tape
                        if (model.measuringTape.isActive) _buildTape(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCharge(ChargedParticle p) {
    final view = mvt.modelToView(p.position);
    final r = CafConstants.chargeRadius;
    return Positioned(
      left: view.dx - r,
      top: view.dy - r,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) {
          final local = _sceneLocal(e.position);
          _dragGrabOffset = local - view;
          p.isUserControlled = true;
          _dragging = p;
        },
        child: SizedBox(
          width: r * 2,
          height: r * 2,
          child: CustomPaint(painter: ChargePainter(positive: p.isPositive)),
        ),
      ),
    );
  }

  Widget _buildESensor(ElectricFieldSensor s) {
    final view = mvt.modelToView(s.position);
    final r = CafConstants.electricFieldSensorCircleRadius;
    final e = s.electricField;
    final mag = e.magnitude;
    final showArrow = mag < CafConstants.maxEFieldMagnitude && mag > 1e-12;
    final arrowLen = 15.0 * mag; // view px as in source

    return Positioned(
      left: view.dx - 80,
      top: view.dy - 80,
      child: SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (showArrow)
              CustomPaint(
                size: const Size(160, 160),
                painter: _SensorArrowPainter(
                  center: const Offset(80, 80),
                  angle: -e.angle,
                  length: arrowLen.clamp(0, 120),
                ),
              ),
            Positioned(
              left: 80 - r,
              top: 80 - r,
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (e) {
                  final local = _sceneLocal(e.position);
                  _dragGrabOffset = local - view;
                  s.isUserControlled = true;
                  _dragging = s;
                },
                child: Container(
                  width: r * 2,
                  height: r * 2,
                  decoration: BoxDecoration(
                    color: CafColors.electricFieldSensorCircleFill,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CafColors.electricFieldSensorCircleStroke,
                    ),
                  ),
                ),
              ),
            ),
            if (model.areValuesVisible)
              Positioned(
                left: 80 - 40,
                top: 80 + r + 4,
                child: SizedBox(
                  width: 80,
                  child: Text(
                    mag >= CafConstants.maxEFieldMagnitude
                        ? '-'
                        : '${_fmt(mag, 2)} ${CafStrings.eFieldUnit}\n'
                            '${_fmt(e.angle * 180 / math.pi, 1)} ${CafStrings.angleUnit}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: CafColors.electricFieldSensorLabel,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoltmeter() {
    final tip = mvt.modelToView(model.electricPotentialSensor.position);
    const circleR = 18.0;
    final v = model.electricPotentialSensor.electricPotential;
    final fill = CafPotentialColors.forCircle(v, 0.5);

    return Positioned(
      left: tip.dx - 55,
      top: tip.dy - circleR,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle = probe + panel chrome (buttons stay outside)
          Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (e) {
              final local = _sceneLocal(e.position);
              _dragGrabOffset = local - tip;
              _dragging = 'voltmeter';
            },
            child: Column(
              children: [
                SizedBox(
                  width: circleR * 2,
                  height: circleR * 2,
                  child: CustomPaint(
                    painter: _CrosshairPainter(fill: fill, lineWidth: 3),
                  ),
                ),
                Container(
                  width: 0.4 * circleR,
                  height: 0.4 * circleR,
                  color: CafColors.electricPotentialSensorCrosshairStroke,
                ),
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Image.asset(
                      CafAssets.electricPotentialPanelOutline,
                      width: 1.55 * 73.6,
                      fit: BoxFit.fitWidth,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        children: [
                          const Text(
                            CafStrings.equipotential,
                            style: TextStyle(
                              color: CafColors.electricPotentialPanelTitleText,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: CafColors
                                  .electricPotentialSensorTextPanelBackground,
                              border: Border.all(
                                color: CafColors
                                    .electricPotentialSensorTextPanelBorder,
                              ),
                            ),
                            child: Text(
                              '${EquipotentialLinesPainter.decimalAdjust(v)} ${CafStrings.voltageUnit}',
                              style: const TextStyle(
                                color: CafColors
                                    .electricPotentialSensorTextPanelTextFill,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -34),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _toolBtn(
                  child: Image.asset(
                    CafAssets.pencil,
                    width: 22,
                    height: 18,
                  ),
                  onTap: () {
                    model.addElectricPotentialLine();
                    _bump();
                  },
                ),
                const SizedBox(width: 6),
                _toolBtn(
                  child: CustomPaint(
                    size: const Size(20, 16),
                    painter: _EraserIconPainter(),
                  ),
                  onTap: () {
                    model.clearElectricPotentialLines();
                    _bump();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolBtn({required Widget child, required VoidCallback onTap}) {
    return Material(
      color: const Color(0xFFF2F2F2),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTape() {
    final base = mvt.modelToView(model.measuringTape.basePosition);
    final tip = mvt.modelToView(model.measuringTape.tipPosition);
    final angle = math.atan2(tip.dy - base.dy, tip.dx - base.dx);
    // MeasuringTapeNode: basePosition = rightBottom of image; baseScale 0.8
    const baseScale = CafToolboxLayout.tapeBaseScale;
    const tipR = CafToolboxLayout.tapeTipCircleRadius;
    final img = CafToolboxLayout.tapePngSize * baseScale;

    // Text: valueNode.centerTop = baseImage.center + textPosition*(baseScale)
    // textPosition default (0, 30)
    final baseCenter = Offset(base.dx - img / 2, base.dy - img / 2);
    final textAnchor = baseCenter + Offset(0, 30 * baseScale);

    return Positioned.fill(
      child: Stack(
        children: [
          CustomPaint(
            painter: _TapePainter(base: base, tip: tip, angle: angle),
            size: const Size(
              CafConstants.layoutWidth,
              CafConstants.layoutHeight,
            ),
          ),
          Positioned(
            left: base.dx - img,
            top: base.dy - img,
            width: img,
            height: img,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (e) {
                _dragGrabOffset = _sceneLocal(e.position) - base;
                _dragging = 'tapeBase';
              },
              child: Transform.rotate(
                angle: angle,
                alignment: Alignment.bottomRight,
                child: Image.asset(
                  CafAssets.measuringTape,
                  width: img,
                  height: img,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          ),
          Positioned(
            left: tip.dx - tipR,
            top: tip.dy - tipR,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (e) {
                _dragGrabOffset = _sceneLocal(e.position) - tip;
                _dragging = 'tapeTip';
              },
              child: SizedBox(
                width: tipR * 2,
                height: tipR * 2,
                child: CustomPaint(painter: _TapeTipPainter()),
              ),
            ),
          ),
          Positioned(
            left: textAnchor.dx - 40,
            top: textAnchor.dy,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xA6000000), // rgba(0,0,0,0.65)
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                '${model.measuringTape.lengthCm.toStringAsFixed(1)} ${CafStrings.centimeterUnit}',
                style: const TextStyle(
                  color: CafColors.measuringTapeText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v, int maxDecimals) {
    if (v.abs() >= 100) return v.toStringAsFixed(0);
    if (v.abs() >= 10) return v.toStringAsFixed(math.min(1, maxDecimals));
    return v.toStringAsFixed(maxDecimals);
  }
}

class _CrosshairPainter extends CustomPainter {
  _CrosshairPainter({required this.fill, this.lineWidth = 3});
  final Color fill;
  final double lineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;
    canvas.drawCircle(c, r, Paint()..color = fill);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = CafColors.electricPotentialSensorCircleStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth,
    );
    final cross = Paint()
      ..color = CafColors.electricPotentialSensorCrosshairStroke
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), cross);
    canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r), cross);
  }

  @override
  bool shouldRepaint(covariant _CrosshairPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.lineWidth != lineWidth;
}

class _SensorArrowPainter extends CustomPainter {
  _SensorArrowPainter({
    required this.center,
    required this.angle,
    required this.length,
  });

  final Offset center;
  final double angle;
  final double length;

  @override
  void paint(Canvas canvas, Size size) {
    if (length < 2) return;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final tip = Offset(length, 0);
    final paint = Paint()
      ..color = CafColors.electricFieldSensorArrow
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, tip - const Offset(8, 0), paint);
    final head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - 10, tip.dy - 5)
      ..lineTo(tip.dx - 10, tip.dy + 5)
      ..close();
    canvas.drawPath(
      head,
      Paint()..color = CafColors.electricFieldSensorArrow,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SensorArrowPainter oldDelegate) => true;
}

class _TapePainter extends CustomPainter {
  _TapePainter({required this.base, required this.tip, required this.angle});
  final Offset base;
  final Offset tip;
  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    // MeasuringTapeNode: gray tape line + rotating base crosshair at base
    canvas.drawLine(
      base,
      tip,
      Paint()
        ..color = CafToolboxLayout.tapeLineColor
        ..strokeWidth = CafToolboxLayout.tapeLineWidth,
    );

    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);
    final cross = Paint()
      ..color = CafToolboxLayout.tapeCrosshairColor
      ..strokeWidth = CafToolboxLayout.tapeCrosshairLineWidth;
    const cs = CafToolboxLayout.tapeCrosshairSize;
    canvas.drawLine(const Offset(-cs, 0), const Offset(cs, 0), cross);
    canvas.drawLine(const Offset(0, -cs), const Offset(0, cs), cross);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TapePainter oldDelegate) =>
      oldDelegate.base != base ||
      oldDelegate.tip != tip ||
      oldDelegate.angle != angle;
}

class _TapeTipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;
    canvas.drawCircle(c, r, Paint()..color = CafToolboxLayout.tapeTipCircleColor);
    final cross = Paint()
      ..color = CafToolboxLayout.tapeCrosshairColor
      ..strokeWidth = CafToolboxLayout.tapeCrosshairLineWidth
      ..strokeCap = StrokeCap.butt;
    const cs = CafToolboxLayout.tapeCrosshairSize;
    canvas.drawLine(c + const Offset(-cs, 0), c + const Offset(cs, 0), cross);
    canvas.drawLine(c + const Offset(0, -cs), c + const Offset(0, cs), cross);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple eraser glyph (scenery-phet EraserButton visual stand-in without Material Icons).
class _EraserIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 4, size.width - 4, size.height - 6),
      const Radius.circular(2),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFFFF8A80));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 4, size.width * 0.35, size.height - 6),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFEEEEEE),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
