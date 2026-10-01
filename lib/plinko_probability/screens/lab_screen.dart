import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_reset_all_button.dart';
import '../controller/intro_controller.dart';
import '../controller/lab_controller.dart';
import '../model/plinko_common_model.dart';
import '../painters/balls_painter.dart';
import '../painters/board_painter.dart';
import '../painters/histogram_painter.dart';
import '../painters/hopper_painter.dart';
import '../painters/peg_raster.dart';
import '../painters/pegs_painter.dart';
import '../painters/trajectory_path_painter.dart';
import '../plinko_colors.dart';
import '../transform/plinko_mvt.dart';
import '../widgets/lab_controls.dart';
import '../widgets/lab_right_panel_layout.dart';
import '../widgets/play_panels.dart';
import '../widgets/plinko_chrome_buttons.dart';

/// Lab screen — layout from LabScreenView / CommonView.
class LabScreen extends StatelessWidget {
  const LabScreen({super.key, required this.controller});

  final LabController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!PegRaster.isReady) {
          return FutureBuilder<void>(
            future: PegRaster.ensureLoaded(),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const ColoredBox(color: PlinkoColors.background);
              }
              return _buildBody();
            },
          );
        }
        return _buildBody();
      },
    );
  }

  Widget _buildBody() {
        final m = controller.model;
        final vp = controller.viewProperties;
        final showBalls = m.hopperMode == HopperMode.ball;

        return ColoredBox(
          color: PlinkoColors.background,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              final mvt = PlinkoMvt.fromCanvasSize(size);
              final s = mvt.layoutScale;
              final rightPad = size.width -
                  (mvt.layoutOriginX +
                      (PlinkoMvt.layoutWidth - PlinkoMvt.panelRightPadding) *
                          s);
              final panelW = 220 * s;
              // PegControls owns its width (=220 layout × s); Column stretch uses panelW.

              final hopperCx = mvt.viewBoardLeft + mvt.viewBoardWidth / 2;
              final bottomWidth =
                  45 * s * 11 / (5 + math.min(6, m.numberOfRows));
              final hopperRight = hopperCx + bottomWidth / 2 + 12 * s;

              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: BoardPainter(mvt: mvt)),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: HistogramPainter(
                        histogram: m.histogram,
                        mvt: mvt,
                        mode: vp.histogramMode == HistogramDisplayMode.cylinder
                            ? HistogramDisplayMode.counter
                            : vp.histogramMode,
                        showIdeal: vp.isTheoreticalHistogramVisible,
                        idealNormalized:
                            m.getNormalizedBinomialDistribution(),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: PegsPainter(
                        board: m.galtonBoard,
                        mvt: mvt,
                        probability: m.probability,
                        rotatePegs: true,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: HopperPainter(
                        mvt: mvt,
                        numberOfRows: m.numberOfRows,
                      ),
                    ),
                  ),
                  if (m.hopperMode == HopperMode.path)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: TrajectoryPathPainter(
                          balls: m.balls,
                          mvt: mvt,
                        ),
                      ),
                    ),
                  if (showBalls)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: BallsPainter(
                          balls: m.balls,
                          mvt: mvt,
                          showCollected: true,
                        ),
                      ),
                    ),
                  Positioned(
                    left: hopperRight + 47 * s,
                    top: mvt.viewBoardTop -
                        (28 + 3 + 10) * s,
                    child: HopperModeControl(controller: controller),
                  ),
                  Positioned(
                    top: mvt.layoutOriginY + 10 * s,
                    right: rightPad,
                    child: SizedBox(
                      width: panelW,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LabPlayPanel(controller: controller, layoutScale: s),
                          SizedBox(
                              height:
                                  LabRightPanelLayout.panelVerticalSpacing * s),
                          PegControls(controller: controller, layoutScale: s),
                          SizedBox(
                              height:
                                  LabRightPanelLayout.panelVerticalSpacing * s),
                          StatisticsAccordionBox(
                            controller: controller,
                            layoutScale: s,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: mvt.layoutOriginX + 40 * s,
                    bottom: size.height -
                        (mvt.layoutOriginY + (PlinkoMvt.layoutHeight - 55) * s) +
                        16 * s +
                        110 * s,
                    child: HistogramModeControl(
                      mode: vp.histogramMode == HistogramDisplayMode.cylinder
                          ? HistogramDisplayMode.counter
                          : vp.histogramMode,
                      modes: const [
                        HistogramDisplayMode.counter,
                        HistogramDisplayMode.fraction,
                      ],
                      onChanged: controller.setHistogramMode,
                    ),
                  ),
                  Positioned(
                    left: mvt.layoutOriginX + 40 * s,
                    bottom: size.height -
                        (mvt.layoutOriginY + (PlinkoMvt.layoutHeight - 55) * s),
                    child: PlinkoEraserButton(onPressed: controller.erase),
                  ),
                  Positioned(
                    right: rightPad,
                    bottom: size.height -
                        (mvt.layoutOriginY + (PlinkoMvt.layoutHeight - 10) * s),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PlinkoSoundToggle(
                          enabled: vp.isSoundEnabled,
                          onPressed: controller.toggleSound,
                        ),
                        const SizedBox(width: 20),
                        KratosResetAllButton(
                          onPressed: controller.resetAll,
                          radius: 20.5,
                        ),
                      ],
                    ),
                  ),
                  if (m.isBallCapReached)
                    Center(
                      child: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Out of Balls!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
  }
}
