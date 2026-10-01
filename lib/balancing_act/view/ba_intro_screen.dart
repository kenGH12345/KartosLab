import 'package:kratos/balancing_act/model/ba_enums.dart';
import 'package:kratos/balancing_act/view/ba_intro_controller.dart';
import 'package:kratos/balancing_act/view/ba_viewport.dart';
import 'package:kratos/balancing_act/view/painters/ba_position_painters.dart';
import 'package:kratos/balancing_act/view/painters/ba_scene_painters.dart';
import 'package:kratos/balancing_act/view/widgets/ba_column_switch.dart';
import 'package:kratos/balancing_act/view/widgets/ba_control_panels.dart';
import 'package:kratos/balancing_act/view/widgets/ba_mass_node.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/balancing_act/ba_shared_constants.dart';
import 'package:flutter/material.dart';

/// Balancing Act 鈥?Intro Screen only (no Lab / Game / Home).
class BaIntroScreen extends StatefulWidget {
  const BaIntroScreen({super.key, this.controller});

  /// Optional external controller (tests). Owns lifecycle if null.
  final BaIntroController? controller;

  @override
  State<BaIntroScreen> createState() => _BaIntroScreenState();
}

class _BaIntroScreenState extends State<BaIntroScreen>
    with TickerProviderStateMixin {
  late final BaIntroController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? BaIntroController();
    _controller.attach(this);
    _controller.addListener(_onTick);
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    // Pause clock while this view is off-stage to avoid ticks into disposed trees.
    if (_controller.clock.isRunning) {
      _controller.clock.pause();
    }
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaViewport(
      layoutKey: const Key('ba_intro_viewport'),
      child: _BaIntroStage(controller: _controller),
    );
  }
}

class _BaIntroStage extends StatelessWidget {
  const _BaIntroStage({required this.controller});

  final BaIntroController controller;
  static final GlobalKey _stageKey = GlobalKey(debugLabel: 'ba_intro_stage');

  @override
  Widget build(BuildContext context) {
    final model = controller.model;
    final vp = controller.viewProperties;
    final mvt = controller.mvt;
    final plank = model.plank;

    return SizedBox(
      key: _stageKey,
      width: BaSharedConstants.layoutWidth,
      height: BaSharedConstants.layoutHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background + fulcrum + columns + plank
          Positioned.fill(
            child: CustomPaint(
              painter: BaBalanceScenePainter(
                mvt: mvt,
                plank: plank,
                columnState: model.columnState,
              ),
            ),
          ),

          // Marks 鈥?PositionMarkerSetNode
          if (vp.positionMarkerState == PositionIndicatorChoice.marks)
            Positioned.fill(
              child: CustomPaint(
                painter: BaPositionMarksPainter(mvt: mvt, plank: plank),
              ),
            ),

          // Rulers 鈥?RotatingRulerNode
          if (vp.positionMarkerState == PositionIndicatorChoice.rulers)
            Positioned.fill(
              child: CustomPaint(
                painter: BaRotatingRulerPainter(mvt: mvt, plank: plank),
              ),
            ),

          // Level indicator
          Positioned.fill(
            child: CustomPaint(
              painter: BaLevelIndicatorPainter(
                mvt: mvt,
                plank: plank,
                visible: vp.levelIndicatorVisible,
              ),
            ),
          ),

          // Force vectors
          Positioned.fill(
            child: CustomPaint(
              painter: BaForceVectorsPainter(
                mvt: mvt,
                plank: plank,
                visible: vp.forceVectorsFromObjectsVisible,
              ),
            ),
          ),

          // Masses (front)
          ...model.massList.map(
            (mass) => BaMassNode(
              key: ValueKey(identityHashCode(mass)),
              mass: mass,
              mvt: mvt,
              showLabel: vp.massLabelsVisible,
              stageKey: _stageKey,
              onDragStart: (p) => controller.beginDrag(mass, p),
              onDragUpdate: controller.updateDrag,
              onDragEnd: controller.endDrag,
            ),
          ),

          // Column switch 鈥?model (0, -0.5)
          Positioned(
            left: mvt.modelToViewX(0) - 90,
            top: mvt.modelToViewY(-0.5) - 24,
            child: BaColumnSwitch(
              supportsOn: model.supportsEnabled,
              onChanged: controller.setSupportsEnabled,
            ),
          ),

          // Control panels top-right
          Positioned(
            right: 10,
            top: 5,
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                BaShowPanel(
                  massLabels: vp.massLabelsVisible,
                  forces: vp.forceVectorsFromObjectsVisible,
                  level: vp.levelIndicatorVisible,
                  onMassLabels: controller.setMassLabelsVisible,
                  onForces: controller.setForcesVisible,
                  onLevel: controller.setLevelVisible,
                ),
                const SizedBox(height: 5),
                BaPositionPanel(
                  value: vp.positionMarkerState,
                  onChanged: controller.setPositionChoice,
                ),
              ],
            ),
          ),

          // Reset All 鈥?bottom right
          Positioned(
            right: 10,
            bottom: 10,
            child: KratosResetAllButton(
              key: const Key('ba_intro_reset_all'),
              radius: 20.5 * BaSharedConstants.resetAllButtonScale,
              onPressed: controller.resetAll,
            ),
          ),
        ],
      ),
    );
  }
}
