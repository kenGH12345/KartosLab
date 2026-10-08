import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../bending_light_constants.dart';
import '../phet_font.dart';
import '../components/source_nodes.dart';
import '../components/control_widgets.dart';
import '../components/intensity_meter_widget.dart';
import '../components/toolbox_icons.dart';
import '../components/laser_pointer_widget.dart';
import '../components/play_area_painters.dart';
import '../components/prism_knob.dart';
import '../components/protractor_widget.dart';
import '../interaction/laser_interaction.dart';
import '../interaction/layout_bump.dart';
import '../model/bl_vec2.dart';
import '../model/enums.dart';
import '../model/prism.dart';
import '../model/prism_geometry.dart';
import '../model/prisms_model.dart';
import '../model/substance.dart';
import '../screens/stage_scale.dart';
import '../transform/bl_mvt.dart';
import 'source_layout.dart';
import 'package:kratos/bending_light/bl_strings.dart';

/// Prisms play area: translate/rotate laser, prism toolbox, medium panels.
class PrismsPlayArea extends StatefulWidget {
  const PrismsPlayArea({super.key, required this.model});

  final PrismsModel model;

  @override
  State<PrismsPlayArea> createState() => _PrismsPlayAreaState();
}

class _PrismsPlayAreaState extends State<PrismsPlayArea> {
  final ProtractorTool protractor = ProtractorTool();
  final GlobalKey _toolboxKey = GlobalKey();
  Prism? _dragPrism;
  Prism? _flying;
  OverlayEntry? _flyEntry;
  Path? _flyPath;
  PrismKnobPlacement? _flyKnob;
  Offset _flyKnobGlobal = Offset.zero;
  Color _flyColor = const Color(0x88ABA9D4);

  PrismsModel get model => widget.model;

  double get _sx => StageScale.x(context);

  double get _sy => StageScale.y(context);

  BlMvt get mvt => BlMvt.prisms(viewScaleX: _sx, viewScaleY: _sy);

  static final Rect toolbox = Rect.fromLTWH(
    SourceLayout.prismToolboxLeft,
    BendingLightConstants.layoutBoundsHeight - 15 - 120,
    BendingLightConstants.layoutBoundsWidth - SourceLayout.prismToolboxLeft - 58,
    120,
  );

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

  void _translateLaser(DragUpdateDetails details) {
    applyLaserTranslationDrag(
      laser: model.laser,
      delta: mvt.viewToModelDelta(_viewDelta(details.delta)),
      limit: model.modelWidth,
    );
    model.updateModel();
  }

  void _rotateLaser(DragUpdateDetails details, BuildContext playContext) {
    final box = playContext.findRenderObject() as RenderBox?;
    if (box == null) return;
    applyKnobRotationDrag(
      laser: model.laser,
      worldPoint: mvt.screenToWorld(box.globalToLocal(details.globalPosition)),
    );
    model.updateModel();
  }

  void _beginFly(String typeName, Offset global) {
    if (model.prisms.where((p) => p.typeName == typeName).length >= 6) return;
    final proto = model.getPrismPrototypes().firstWhere((e) => e.$2 == typeName);
    final prism = Prism(proto.$1, proto.$2).copy();
    _placeFly(prism, global);
    _flying = prism;
    _syncFlyVisuals();
    _showFly();
  }

  void _placeFly(Prism prism, Offset global) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final world = mvt.screenToWorld(box.globalToLocal(global));
    final center = prism.shape.getRotationCenter();
    prism.setPosition(BlVec2(world.x - center.x, world.y - center.y));
  }

  void _moveFly(Offset global) {
    final prism = _flying;
    if (prism == null) return;
    _placeFly(prism, global);
    _syncFlyVisuals();
    _flyEntry?.markNeedsBuild();
  }

  void _syncFlyVisuals() {
    final prism = _flying;
    final stage = _stage;
    if (prism == null || stage == null || !stage.attached) return;
    final origin = stage.localToGlobal(Offset.zero);
    _flyPath = prismViewPath(mvt, prism)?.shift(origin);
    _flyColor = _prismFill();
    final reference = prism.translatedShape.getReferencePoint();
    if (reference == null) {
      _flyKnob = null;
      return;
    }
    final knob = placePrismKnob(
      reference: mvt.worldToScreen(reference),
      rotationCenter: mvt.worldToScreen(prism.translatedShape.getRotationCenter()),
      viewScale: StageScale.of(context),
    );
    _flyKnob = knob;
    _flyKnobGlobal = origin + knob.topLeft;
  }

  /// Source `createForwardingListener`: the copy follows the pointer, and a drop
  /// whose outline still meets the dock puts it back (the icon never left).
  void _endFly(Offset global) {
    final prism = _flying;
    _flying = null;
    _hideFly();
    if (prism == null) return;
    _placeFly(prism, global);
    final path = prismViewPath(mvt, prism);
    if (path != null && path.getBounds().overlaps(_toolboxRect)) return;
    model.addPrism(prism);
  }

  void _cancelFly() {
    _flying = null;
    _hideFly();
  }

  void _showFly() {
    _hideFly();
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    _flyEntry = OverlayEntry(builder: _flyBuilder);
    overlay.insert(_flyEntry!);
  }

  void _hideFly() {
    _flyEntry?.remove();
    _flyEntry = null;
  }

  Color _prismFill() => Color(
        model.mediumColorFactory.getColor(
          model.prismMedium.substance.indexOfRefractionForRedLight,
          lightType: model.laser.colorMode,
        ),
      ).withValues(alpha: BendingLightConstants.prismNodeAlpha);

  Widget _flyBuilder(BuildContext _) {
    final path = _flyPath;
    final knob = _flyKnob;
    return IgnorePointer(
      child: Stack(
        children: [
          if (path != null)
            Positioned.fill(
              child: CustomPaint(
                painter: _FlyPrismPainter(path, _flyColor),
              ),
            ),
          if (knob != null)
            Positioned(
              left: _flyKnobGlobal.dx,
              top: _flyKnobGlobal.dy,
              width: knob.width,
              height: knob.height,
              child: Transform.rotate(
                angle: knob.angle,
                alignment: Alignment.topLeft,
                child: Image.asset(
                  'assets/simulations/bending_light/knob.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hideFly();
    super.dispose();
  }

  bool _paintedContains(Prism prism, Offset local) {
    final path = prismViewPath(mvt, prism);
    return path != null && path.contains(local);
  }

  void _onPrismPanStart(DragStartDetails details) {
    _dragPrism = null;
    for (final prism in model.prisms.reversed) {
      if (_paintedContains(prism, details.localPosition)) {
        _dragPrism = prism;
        break;
      }
    }
  }

  void _onPrismPanUpdate(DragUpdateDetails details) {
    final prism = _dragPrism;
    if (prism == null) return;
    final delta = mvt.viewToModelDelta(_viewDelta(details.delta));
    if (!delta.x.isFinite || !delta.y.isFinite) return;
    prism.translate(delta.x, delta.y);
    model.updateModel();
  }

  void _onPrismPanEnd(DragEndDetails details) {
    final prism = _dragPrism;
    _dragPrism = null;
    if (prism == null) return;
    final path = prismViewPath(mvt, prism);
    if (path != null && path.getBounds().overlaps(_toolboxRect)) {
      model.removePrism(prism);
    }
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
        final white = model.laser.colorMode == ColorModeEnum.white;
        final prismFill = Color(
          model.mediumColorFactory.getColor(
            model.prismMedium.substance.indexOfRefractionForRedLight,
            lightType: model.laser.colorMode,
          ),
        );
        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (white)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: WhiteLightPainter(mvt: mvt, rays: model.rays),
                  ),
                ),
              ),
            Positioned.fill(
              child: CustomPaint(
                painter: PrismScenePainter(
                  mvt: mvt,
                  prisms: List.of(model.prisms),
                  rays: model.rays,
                  intersections: model.intersections,
                  prismMedium: model.prismMedium.substance,
                  prismFill: prismFill.withValues(
                    alpha: BendingLightConstants.prismNodeAlpha,
                  ),
                  showNormals: model.showNormals,
                  includeRays: !white,
                  paintPrisms: false,
                  fillBackground: !white,
                ),
              ),
            ),
            if (model.showProtractor)
              ProtractorWidget(
                mvt: mvt,
                tool: protractor,
                onAngle: (delta) => setState(() => protractor.angle += delta),
                scale: 0.46,
                onDragDelta: (delta) {
                  final d = mvt.viewToModelDelta(_viewDelta(delta));
                  setState(() {
                    protractor.center = clampModelPoint(
                      protractor.center.plusXY(d.x, d.y),
                      model.modelWidth,
                    );
                  });
                },
              ),
            LaserPointerWidget(
              laser: model.laser,
              mvt: mvt,
              showKnob: true,
              onPowerTap: () => model.setLaserOn(!model.laser.on),
              onBodyPanUpdate: _translateLaser,
              onKnobPanUpdate: (d) => _rotateLaser(d, context),
            ),
            Positioned(
              right: SourceLayout.edgePadding * sx,
              top: SourceLayout.topBottomPadding * sy,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MediumControlPanel(
                    title: BlStrings.environment,
                    substance: model.environmentMedium.substance,
                    decimals: 2,
                    showReadout: false,
                    yMargin: SourceLayout.mediumYMarginPrisms,
                    onSubstance: model.setEnvironmentSubstance,
                    onCustomIndex: (n) =>
                        model.setCustomIndex(environment: true, indexForRed: n),
                  ),
                  SizedBox(height: 15 * sy),
                  _LaserTypePanel(
                    manyRays: model.manyRays,
                    white: white,
                    wavelength: model.wavelength,
                    onType: model.setLightType,
                    onWavelength: model.setWavelength,
                  ),
                ],
              ),
            ),
            Positioned(
              left: SourceLayout.prismToolboxLeft * sx,
              right: 58 * sx,
              bottom: SourceLayout.topBottomPadding * sy,
              child: _PrismToolboxBar(
                key: _toolboxKey,
                prismFill: prismFill,
                substance: model.prismMedium.substance,
                reflections: model.showReflections,
                normals: model.showNormals,
                protractorOn: model.showProtractor,
                onDragStart: _beginFly,
                onDragUpdate: _moveFly,
                onDrag: (_, global) => _endFly(global),
                onDragCancel: _cancelFly,
                placedCount: (name) =>
                    model.prisms.where((p) => p.typeName == name).length,
                onSubstance: model.setPrismSubstance,
                onCustomIndex: (n) =>
                    model.setCustomIndex(environment: false, indexForRed: n),
                onReflections: model.setShowReflections,
                onNormals: model.setShowNormals,
                onProtractor: (v) {
                  model.setShowProtractor(v);
                  setState(() => protractor.enabled = v);
                },
              ),
            ),
            Positioned(
              right: SourceLayout.edgePadding * sx,
              bottom: SourceLayout.topBottomPadding * sy,
              child: ResetAllCorner(onPressed: _resetAll),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: PrismScenePainter(
                    mvt: mvt,
                    prisms: List.of(model.prisms),
                    rays: const [],
                    intersections: const [],
                    prismMedium: model.prismMedium.substance,
                    prismFill: prismFill.withValues(
                      alpha: BendingLightConstants.prismNodeAlpha,
                    ),
                    showNormals: false,
                    includeRays: false,
                    paintPrisms: true,
                    fillBackground: false,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: _PrismGrabber(
                contains: (local) =>
                    model.prisms.any((prism) => _paintedContains(prism, local)),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: _onPrismPanStart,
                  onPanUpdate: _onPrismPanUpdate,
                  onPanEnd: _onPrismPanEnd,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            for (final prism in model.prisms)
              _RotateHandle(
                mvt: mvt,
                shape: prism.translatedShape,
                playContext: context,
                onRotate: (prev, current) {
                  final delta = rotationDelta(
                    center: prism.translatedShape.getRotationCenter(),
                    previous: prev,
                    current: current,
                  );
                  if (delta == null || delta == 0) return;
                  prism.rotate(delta);
                  model.updateModel();
                },
              ),
          ],
        );
      },
    );
  }
}

class _PrismGrabber extends SingleChildRenderObjectWidget {
  const _PrismGrabber({required this.contains, required super.child});

  final bool Function(Offset local) contains;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderPrismGrabber(contains);

  @override
  void updateRenderObject(BuildContext context, _RenderPrismGrabber renderObject) {
    renderObject.contains = contains;
  }
}

class _RenderPrismGrabber extends RenderProxyBox {
  _RenderPrismGrabber(this.contains);

  bool Function(Offset local) contains;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!size.contains(position) || !contains(position)) return false;
    return hitTestChildren(result, position: position);
  }
}

class _RotateHandle extends StatefulWidget {
  const _RotateHandle({
    required this.mvt,
    required this.shape,
    required this.playContext,
    required this.onRotate,
  });

  final BlMvt mvt;
  final PrismShape shape;
  final BuildContext playContext;
  final void Function(BlVec2 previous, BlVec2 current) onRotate;

  @override
  State<_RotateHandle> createState() => _RotateHandleState();
}

class _RotateHandleState extends State<_RotateHandle> {
  BlVec2? _last;

  BlVec2? _world(Offset global) {
    final box = widget.playContext.findRenderObject() as RenderBox?;
    if (box == null) return null;
    return widget.mvt.screenToWorld(box.globalToLocal(global));
  }

  @override
  Widget build(BuildContext context) {
    final reference = widget.shape.getReferencePoint();
    if (reference == null) return const SizedBox.shrink();
    final place = placePrismKnob(
      reference: widget.mvt.worldToScreen(reference),
      rotationCenter: widget.mvt.worldToScreen(widget.shape.getRotationCenter()),
      viewScale: StageScale.of(context),
    );
    return Positioned(
      left: place.topLeft.dx,
      top: place.topLeft.dy,
      width: place.width,
      height: place.height,
      child: GestureDetector(
        onPanStart: (d) => _last = _world(d.globalPosition),
        onPanUpdate: (d) {
          final last = _last;
          final current = _world(d.globalPosition);
          if (last == null || current == null) return;
          widget.onRotate(last, current);
          _last = current;
        },
        child: Transform.rotate(
          angle: place.angle,
          alignment: Alignment.topLeft,
          child: Image.asset(
            'assets/simulations/bending_light/knob.png',
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}

class _PrismToolboxBar extends StatelessWidget {
  const _PrismToolboxBar({
    super.key,
    required this.prismFill,
    required this.substance,
    required this.reflections,
    required this.normals,
    required this.protractorOn,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDrag,
    required this.onDragCancel,
    required this.onSubstance,
    required this.onCustomIndex,
    required this.onReflections,
    required this.onNormals,
    required this.onProtractor,
    required this.placedCount,
  });

  final Color prismFill;
  final Substance substance;
  final bool reflections;
  final bool normals;
  final bool protractorOn;
  final void Function(String typeName, Offset global) onDragStart;
  final void Function(Offset global) onDragUpdate;
  final void Function(String typeName, Offset global) onDrag;
  final VoidCallback onDragCancel;
  final int Function(String typeName) placedCount;
  final ValueChanged<Substance> onSubstance;
  final ValueChanged<double> onCustomIndex;
  final ValueChanged<bool> onReflections;
  final ValueChanged<bool> onNormals;
  final ValueChanged<bool> onProtractor;

  static const _names = [
    'triangle',
    'trapezoid',
    'square',
    'circle',
    'semicircle',
    'diverging-lens',
  ];

  @override
  Widget build(BuildContext context) {
    final s = StageScale.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(12 * s, 4 * s, 12 * s, 4 * s),
      decoration: BoxDecoration(
        color: SourceLayout.panelFill,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: SourceLayout.panelStroke, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final name in _names) ...[
            ToolboxSlot(
              inToolbox: placedCount(name) < 6,
              child: ToolboxChip(
                semanticsLabel: name,
                onDragStart: (global) => onDragStart(name, global),
                onDragUpdate: onDragUpdate,
                onDragEnd: (global) => onDrag(name, global),
                onDragCancel: onDragCancel,
                child: PrismToolboxIcon(typeName: name, fill: prismFill),
              ),
            ),
            SizedBox(width: 8 * s),
          ],
          _ToolboxDivider(),
          SizedBox(width: 8 * s),
          MediumControlPanel(
            title: BlStrings.objects,
            substance: substance,
            decimals: 2,
            showReadout: false,
            framed: false,
            yMargin: 4,
            width: 188,
            onSubstance: onSubstance,
            onCustomIndex: onCustomIndex,
          ),
          SizedBox(width: 8 * s),
          _ToolboxDivider(),
          SizedBox(width: 8 * s),
          _PrismChecks(
            reflections: reflections,
            normals: normals,
            protractorOn: protractorOn,
            onReflections: onReflections,
            onNormals: onNormals,
            onProtractor: onProtractor,
          ),
        ],
      ),
    );
  }
}

class _ToolboxDivider extends StatelessWidget {
  const _ToolboxDivider();

  @override
  Widget build(BuildContext context) {
    final s = StageScale.of(context);
    return Container(width: 1, height: 72 * s, color: const Color(0xFF808080));
  }
}

class _LaserTypePanel extends StatelessWidget {
  const _LaserTypePanel({
    required this.manyRays,
    required this.white,
    required this.wavelength,
    required this.onType,
    required this.onWavelength,
  });

  final int manyRays;
  final bool white;
  final double wavelength;
  final ValueChanged<LightType> onType;
  final ValueChanged<double> onWavelength;

  @override
  Widget build(BuildContext context) {
    final s = StageScale.of(context);
    return Container(
      width: 186 * s,
      padding: EdgeInsets.fromLTRB(10 * s, 6 * s, 10 * s, 6 * s),
      decoration: BoxDecoration(
        color: SourceLayout.panelFill,
        borderRadius: BorderRadius.circular(SourceLayout.panelCornerRadius),
        border: Border.all(
          color: SourceLayout.panelStroke,
          width: SourceLayout.panelLineWidth,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _LaserTypeIcon(
                rays: 1,
                selected: !white && manyRays == 1,
                onPressed: () => onType(LightType.singleColor),
              ),
              _LaserTypeIcon(
                rays: 5,
                selected: !white && manyRays != 1,
                onPressed: () => onType(LightType.singleColor5x),
              ),
              _LaserTypeIcon(
                rays: 0,
                selected: white,
                onPressed: () => onType(LightType.white),
              ),
            ],
          ),
          WavelengthControl(
            wavelengthMeters: wavelength,
            enabled: !white,
            trackWidth: 146,
            onChangedMeters: onWavelength,
          ),
        ],
      ),
    );
  }
}

/// `LaserTypeRadioButtonGroup`: clip `laser.png` at (100,0,44,100), scale 0.6 * 0.875.
class _LaserTypeIcon extends StatelessWidget {
  const _LaserTypeIcon({
    required this.rays,
    required this.selected,
    required this.onPressed,
  });

  /// 1, 5, or 0 for white.
  final int rays;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final s = StageScale.of(context);
    final scale = 0.6 * 0.875 * s;
    final clipW = 44.0 * scale;
    final clipH = 57.0 * scale;
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 36 * s,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFF3C4) : null,
            border: Border.all(color: selected ? const Color(0xFFE6A817) : Colors.transparent),
          ),
          child: SizedBox(
            width: clipW + 20 * s,
            height: clipH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (rays == 0)
                  Positioned(
                    left: 8 * s,
                    top: 0,
                    width: 28 * s,
                    height: clipH,
                    child: const ColoredBox(color: Color(0xFF261F21)),
                  ),
                for (final dy in _lineOffsets(rays))
                  Positioned(
                    left: clipW * 0.35,
                    top: clipH / 2 + dy * scale - 1,
                    width: 37 * scale,
                    height: 2 * s,
                    child: ColoredBox(color: rays == 0 ? Colors.white : Colors.red),
                  ),
                ClipRect(
                  child: SizedBox(
                    width: clipW,
                    height: clipH,
                    child: OverflowBox(
                      alignment: Alignment.centerLeft,
                      minWidth: 144 * scale,
                      maxWidth: 144 * scale,
                      minHeight: clipH,
                      maxHeight: clipH,
                      child: Transform.translate(
                        offset: Offset(-100 * scale, 0),
                        child: Image.asset(
                          'assets/simulations/bending_light/laser.png',
                          width: 144 * scale,
                          height: 57 * scale,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static List<double> _lineOffsets(int rays) {
    if (rays == 0) return const [0];
    if (rays == 1) return const [0];
    const dy = 6.25;
    return const [0, -dy, -dy * 2, dy, dy * 2];
  }
}

class _PrismChecks extends StatelessWidget {
  const _PrismChecks({
    required this.reflections,
    required this.normals,
    required this.protractorOn,
    required this.onReflections,
    required this.onNormals,
    required this.onProtractor,
  });

  final bool reflections;
  final bool normals;
  final bool protractorOn;
  final ValueChanged<bool> onReflections;
  final ValueChanged<bool> onNormals;
  final ValueChanged<bool> onProtractor;

  @override
  Widget build(BuildContext context) {
    final s = StageScale.of(context);
    Widget row(
      String label,
      bool value,
      ValueChanged<bool> onChanged, {
      bool icon = false,
    }) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhetCheckbox(checked: value, onChanged: onChanged),
          SizedBox(width: 5 * s),
          Text(label, style: PhetFont.of(10)),
          if (icon) ...[
            SizedBox(width: 6 * s),
            Image.asset(
              'assets/simulations/bending_light/protractor.png',
              width: 20 * s,
              height: 20 * s,
            ),
          ],
        ],
      );
    }

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          row(BlStrings.reflections, reflections, onReflections),
          row(BlStrings.normal, normals, onNormals),
          row(BlStrings.protractor, protractorOn, onProtractor, icon: true),
        ],
    );
  }
}

class _FlyPrismPainter extends CustomPainter {
  _FlyPrismPainter(this.path, this.fill);

  final Path path;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF808080),
    );
  }

  @override
  bool shouldRepaint(covariant _FlyPrismPainter oldDelegate) => true;
}
