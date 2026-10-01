import 'package:flutter/material.dart';
import 'package:kratos/balancing_act/ba_shared_constants.dart';
import 'package:kratos/balancing_act/model/ba_enums.dart';
import 'package:kratos/balancing_act/view/ba_balance_lab_controller.dart';
import 'package:kratos/balancing_act/view/ba_viewport.dart';
import 'package:kratos/balancing_act/view/painters/ba_position_painters.dart';
import 'package:kratos/balancing_act/view/painters/ba_scene_painters.dart';
import 'package:kratos/balancing_act/view/widgets/ba_column_switch.dart';
import 'package:kratos/balancing_act/view/widgets/ba_control_panels.dart';
import 'package:kratos/balancing_act/view/widgets/ba_mass_carousel.dart';
import 'package:kratos/balancing_act/view/widgets/ba_mass_node.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

/// Balancing Act — Balance Lab Screen only (no Game / Home).
class BaBalanceLabScreen extends StatefulWidget {
  const BaBalanceLabScreen({super.key, this.controller});

  final BaBalanceLabController? controller;

  @override
  State<BaBalanceLabScreen> createState() => _BaBalanceLabScreenState();
}

class _BaBalanceLabScreenState extends State<BaBalanceLabScreen>
    with TickerProviderStateMixin {
  late final BaBalanceLabController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? BaBalanceLabController();
    _controller.attach(this);
    _controller.addListener(_onTick);
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
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
      layoutKey: const Key('ba_lab_viewport'),
      child: _BaLabStage(controller: _controller),
    );
  }
}

class _BaLabStage extends StatelessWidget {
  const _BaLabStage({required this.controller});

  final BaBalanceLabController controller;
  static final GlobalKey _stageKey = GlobalKey(debugLabel: 'ba_lab_stage');

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
          Positioned.fill(
            child: CustomPaint(
              painter: BaBalanceScenePainter(
                mvt: mvt,
                plank: plank,
                columnState: model.columnState,
              ),
            ),
          ),
          if (vp.positionMarkerState == PositionIndicatorChoice.marks)
            Positioned.fill(
              child: CustomPaint(
                painter: BaPositionMarksPainter(mvt: mvt, plank: plank),
              ),
            ),
          if (vp.positionMarkerState == PositionIndicatorChoice.rulers)
            Positioned.fill(
              child: CustomPaint(
                painter: BaRotatingRulerPainter(mvt: mvt, plank: plank),
              ),
            ),
          Positioned.fill(
            child: CustomPaint(
              painter: BaLevelIndicatorPainter(
                mvt: mvt,
                plank: plank,
                visible: vp.levelIndicatorVisible,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: BaForceVectorsPainter(
                mvt: mvt,
                plank: plank,
                visible: vp.forceVectorsFromObjectsVisible,
              ),
            ),
          ),
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
          Positioned(
            left: mvt.modelToViewX(0) - 90,
            top: mvt.modelToViewY(-0.5) - 24,
            child: BaColumnSwitch(
              supportsOn: model.supportsEnabled,
              onChanged: controller.setSupportsEnabled,
            ),
          ),
          Positioned(
            right: 10,
            top: 5,
            width: 220,
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
                const SizedBox(height: 5),
                BaMassCarousel(
                  carousel: model.carousel,
                  stageKey: _stageKey,
                  onPrev: controller.previousCarouselPage,
                  onNext: controller.nextCarouselPage,
                  onCreateBrick: controller.startBrickCreator,
                  onCreatePerson: controller.startPersonCreator,
                  onCreateMystery: controller.startMysteryCreator,
                  onDragUpdate: controller.updateDrag,
                  onDragEnd: controller.endDrag,
                ),
              ],
            ),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: KratosResetAllButton(
              key: const Key('ba_lab_reset_all'),
              radius: 20.5 * BaSharedConstants.resetAllButtonScale,
              onPressed: controller.resetAll,
            ),
          ),
        ],
      ),
    );
  }
}
