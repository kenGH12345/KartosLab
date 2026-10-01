/// Single tab content: Model or To Scale play area + controls.
library;

import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_reset_all_button.dart';
import '../controller/gao_controller.dart';
import '../gao_colors.dart';
import '../model/gao_body.dart';
import '../painters/body_labels_painter.dart';
import '../painters/grid_painter.dart';
import '../painters/path_painter.dart';
import '../painters/vectors_painter.dart';
import '../render/gao_mvt.dart';
import '../widgets/bodies_layer.dart';
import '../widgets/checkbox_panel.dart';
import '../widgets/gao_time_control.dart';
import '../widgets/gao_measuring_tape.dart';
import '../widgets/mass_control_panel.dart';
import '../widgets/return_objects_button.dart';
import '../widgets/scene_selection_controls.dart';
import '../widgets/time_counter.dart';
import '../widgets/zoom_control.dart';

class GravityAndOrbitsScreen extends StatefulWidget {
  const GravityAndOrbitsScreen({
    super.key,
    required this.isModelScreen,
    this.embedded = false,
    this.controller,
  });

  final bool isModelScreen;
  final bool embedded;
  final GaoController? controller;

  @override
  State<GravityAndOrbitsScreen> createState() => _GravityAndOrbitsScreenState();
}

class _GravityAndOrbitsScreenState extends State<GravityAndOrbitsScreen>
    with TickerProviderStateMixin {
  late final GaoController _controller;
  late final bool _ownsController;
  GaoBody? _velocityDragBody;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ??
        GaoController(isModelScreen: widget.isModelScreen);
    _controller.attach(this);
    _controller.addListener(_onNotify);
  }

  void _onNotify() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onNotify);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  GaoMvt _buildMvt(Size canvas) {
    final scene = _controller.model.scene;
    return GaoMvt.fromZoom(
      defaultZoomScale: scene.defaultZoomScale,
      zoomLevel: scene.zoomLevel,
      gridCenter: scene.gridCenter,
      stageSize: canvas,
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = ColoredBox(
      color: GaoColors.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _playArea()),
          _rightColumn(),
        ],
      ),
    );

    if (widget.embedded) return body;
    return Scaffold(
      backgroundColor: GaoColors.background,
      body: SafeArea(child: body),
    );
  }

  Widget _playArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final mvt = _buildMvt(size);
        _controller.updateViewContext(mvt: mvt, canvasSize: size);
        final scene = _controller.model.scene;
        final model = _controller.model;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: GaoGridPainter(
                  mvt: mvt,
                  gridSpacing: scene.gridSpacing,
                  gridCenter: scene.gridCenter,
                  visible: model.showGrid,
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: GaoPathPainter(
                  bodies: scene.bodies,
                  mvt: mvt,
                  visible: model.showPath,
                ),
              ),
            ),
            Positioned.fill(
              child: GaoBodiesLayer(
                bodies: scene.bodies,
                mvt: mvt,
                showMass: model.showMass,
                onDragStart: _controller.dragBodyStart,
                onDragUpdate: (body, delta) {
                  final view = mvt.modelToView(body.position) + delta;
                  _controller.dragBody(body, mvt.viewToModel(view));
                },
                onDragEnd: _controller.dragBodyEnd,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: GaoBodyLabelsPainter(
                    bodies: scene.bodies,
                    mvt: mvt,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: GaoVectorsPainter(
                    bodies: scene.bodies,
                    mvt: mvt,
                    forceScale: scene.forceScale,
                    velocityVectorScale: scene.velocityVectorScale,
                    showForce: model.showGravityForce,
                    showVelocity: model.showVelocity,
                  ),
                ),
              ),
            ),
            if (model.showVelocity)
              ..._velocityHandles(mvt, scene.bodies, scene.velocityVectorScale),
            if (model.showMeasuringTapeFlag && model.showMeasuringTape)
              Positioned.fill(
                child: GaoMeasuringTape(controller: _controller, mvt: mvt),
              ),
            Positioned(
              left: 8,
              top: 8,
              child: ZoomControl(controller: _controller),
            ),
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: ReturnObjectsButton(controller: _controller),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GaoTimeControl(controller: _controller),
                  const SizedBox(width: 16),
                  TimeCounter(controller: _controller),
                ],
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: KratosResetAllButton(
                onPressed: _controller.resetAll,
                radius: 20.5,
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _velocityHandles(
    GaoMvt mvt,
    List<GaoBody> bodies,
    double velocityScale,
  ) {
    const grab = 28.0;
    final tips = velocityTips(
      bodies: bodies,
      mvt: mvt,
      velocityVectorScale: velocityScale,
    );
    return [
      for (final tip in tips)
        Positioned(
          left: tip.tipView.dx - grab / 2,
          top: tip.tipView.dy - grab / 2,
          width: grab,
          height: grab,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (_) {
              _velocityDragBody = tip.body;
              _controller.dragVelocityStart(tip.body);
            },
            onPanUpdate: (d) {
              final body = _velocityDragBody ?? tip.body;
              final tipView = mvt.modelToView(
                    body.position + body.velocity * velocityScale,
                  ) +
                  d.delta;
              _controller.dragVelocity(body, mvt.viewToModel(tipView));
            },
            onPanEnd: (_) {
              final body = _velocityDragBody ?? tip.body;
              _controller.dragVelocityEnd(body);
              _velocityDragBody = null;
            },
          ),
        ),
    ];
  }

  Widget _rightColumn() {
    return Container(
      width: 240,
      margin: const EdgeInsets.fromLTRB(0, 8, 8, 8),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: GaoColors.controlPanelStroke),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SceneSelectionControls(controller: _controller),
                    const SizedBox(height: 12),
                    CheckboxPanel(controller: _controller),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: GaoColors.controlPanelStroke),
            ),
            child: MassControlPanel(controller: _controller),
          ),
        ],
      ),
    );
  }
}
