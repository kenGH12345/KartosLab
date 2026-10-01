import 'package:flutter/material.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

import '../../domain/detector_mode.dart';
import '../common/qwi_panel.dart';
import '../experiment/experiment_barrier.dart';
import '../experiment/experiment_controller.dart';
import '../experiment/experiment_controls.dart';
import '../experiment/experiment_detector.dart';
import '../experiment/experiment_graph.dart';
import '../experiment/experiment_overhead.dart';
import '../experiment/experiment_ruler.dart';
import '../experiment/experiment_snapshots.dart';
import '../experiment/experiment_source.dart';
import 'experiment_layout_spec.dart';
import 'qwi_layout_primitives.dart';

/// Places existing Experiment components according to [ExperimentLayoutSpec].
///
/// Paint order ≈ PhET `ExperimentScreenView` addChild order (LAYOUT_SPEC §10).
class ExperimentLayoutComposer extends StatelessWidget {
  const ExperimentLayoutComposer({
    super.key,
    required this.controller,
    this.spec,
  });

  final ExperimentController controller;
  final ExperimentLayoutSpec? spec;

  @override
  Widget build(BuildContext context) {
    final layout = spec ?? ExperimentLayoutSpec.resolve();
    return SizedBox(
      width: layout.canvas.width,
      height: layout.canvas.height,
      child: Material(
        color: Colors.white,
        child: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'Arial', fontSize: 11, color: Colors.black87, height: 1.1),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              activeTrackColor: const Color(0xFF5BA3E0),
              inactiveTrackColor: const Color(0xFFCCCCCC),
              thumbColor: const Color(0xFF337AB7),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1 OVERHEAD
                ExperimentOverheadView(controller: controller),
                ExperimentSourceView(controller: controller),

                // 2 SLIT_COLUMN panel (below front-facing row)
                Positioned(
                  left: layout.slitPanel.left,
                  top: layout.slitPanel.top,
                  width: layout.slitPanel.width,
                  height: layout.slitPanel.height,
                  child: QwiPanel(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: layout.slitPanel.width - 24,
                        child: ExperimentSlitControls(controller: controller),
                      ),
                    ),
                  ),
                ),

                // 4 SOURCE_CONTROL_PANEL — before front-facing displays so the
                // inevitable ~30px X-overlap with the slit does not hide slits
                // (PhET paints source later; Flutter prioritizes slit visibility).
                Positioned(
                  left: layout.sourcePanel.left,
                  top: layout.sourcePanel.top,
                  width: layout.sourcePanel.width,
                  child: QwiPanel(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: ExperimentSourceControls(controller: controller),
                  ),
                ),

                // Front-facing displays (slit then detector) above source/slit panels
                ExperimentBarrierView(controller: controller),
                ExperimentDetectorView(controller: controller),
                Positioned(
                  left: layout.snapshotColumn.left,
                  top: layout.snapshotColumn.top + 8,
                  width: layout.snapshotColumn.width,
                  height: layout.snapshotColumn.height - 8,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: ExperimentSnapshotIconColumn(controller: controller),
                  ),
                ),
                Positioned(
                  left: layout.detector.left,
                  top: layout.screenControls.top,
                  width: layout.detector.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: ExperimentDetectorControls(controller: controller),
                      ),
                      SizedBox(height: layout.stackGap),
                      ExperimentGraphAccordion(controller: controller),
                      // Must follow accordion height (collapse/expand) — not an absolute
                      // Spec Y that sits inside the expanded chart.
                      SizedBox(height: ExperimentLayoutConstants.rulerUnderGraphGap),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: layout.rulerCheckbox.width,
                          height: layout.rulerCheckbox.height,
                          child: ExperimentRulerCheckbox(controller: controller),
                        ),
                      ),
                    ],
                  ),
                ),

                // 5 SCENE_RADIO_BUTTON_GROUP
                Positioned(
                  left: layout.sceneRadios.left,
                  top: layout.sceneRadios.top,
                  width: layout.sceneRadios.width,
                  child: ExperimentParticleSelector(controller: controller),
                ),

                // 6–9 BOTTOM_TOOL_ROW
                _centerY(
                  layout.timeControls.left,
                  layout.bottomToolsCenterY,
                  ExperimentTimeControls(controller: controller),
                ),
                _centerY(
                  layout.eraser.left,
                  layout.bottomToolsCenterY,
                  _ClearScreenButton(controller: controller),
                ),
                Positioned(
                  right: QwiSpacing.margin,
                  bottom: QwiSpacing.margin,
                  child: KratosResetAllButton(
                    key: const Key('qwi_reset_all'),
                    onPressed: controller.reset,
                    radius: ExperimentLayoutConstants.resetRadius,
                  ),
                ),

                // 10 overlays
                ExperimentRulerView(controller: controller),
                ExperimentSnapshotPanel(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _centerY(double left, double centerY, Widget child) => Positioned(
        left: left,
        top: centerY - 20,
        height: 40,
        child: Align(alignment: Alignment.centerLeft, child: child),
      );
}

class _ClearScreenButton extends StatelessWidget {
  const _ClearScreenButton({required this.controller});

  final ExperimentController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.scene.detectionMode != DetectorMode.hits) {
      return const SizedBox.shrink();
    }
    return Material(
      color: const Color(0xFFFFE066),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        key: const Key('qwi_clear_screen'),
        onTap: controller.clearScreen,
        child: const SizedBox(
          width: ExperimentLayoutConstants.eraserWidth,
          height: ExperimentLayoutConstants.eraserHeight,
          child: Center(
            child: CustomPaint(size: Size(18, 12), painter: _EraserIconPainter()),
          ),
        ),
      ),
    );
  }
}

class _EraserIconPainter extends CustomPainter {
  const _EraserIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(2, size.height * 0.6)
      ..lineTo(size.width * 0.45, 2)
      ..lineTo(size.width - 2, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height - 2)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFE57373));
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
