import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_reset_all_button.dart';
import '../controller/intro_controller.dart';
import '../painters/balls_painter.dart';
import '../painters/board_painter.dart';
import '../painters/cylinders_painter.dart';
import '../painters/histogram_painter.dart';
import '../painters/hopper_painter.dart';
import '../painters/peg_raster.dart';
import '../painters/pegs_painter.dart';
import '../plinko_colors.dart';
import '../transform/plinko_mvt.dart';
import '../widgets/play_panels.dart';
import '../widgets/plinko_chrome_buttons.dart';

/// Intro screen — layout coords from PhET IntroScreenView / CommonView.
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key, required this.controller});

  final IntroController controller;

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
    final showCylinders = vp.histogramMode == HistogramDisplayMode.cylinder;

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

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: BoardPainter(mvt: mvt)),
              ),
              if (showCylinders)
                Positioned.fill(
                  child: CustomPaint(
                    painter: CylindersPainter(
                      cylinderInfo: m.cylinderInfo,
                      mvt: mvt,
                      numberOfRows: m.numberOfRows,
                      backOnly: true,
                    ),
                  ),
                ),
              Positioned.fill(
                child: CustomPaint(
                  painter: PegsPainter(
                    board: m.galtonBoard,
                    mvt: mvt,
                    probability: m.probability,
                    rotatePegs: false,
                  ),
                ),
              ),
              if (!showCylinders)
                Positioned.fill(
                  child: CustomPaint(
                    painter: HistogramPainter(
                      histogram: m.histogram,
                      mvt: mvt,
                      mode: HistogramDisplayMode.counter,
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
              Positioned.fill(
                child: CustomPaint(
                  painter: BallsPainter(
                    balls: m.balls,
                    mvt: mvt,
                    showCollected: showCylinders,
                  ),
                ),
              ),
              if (showCylinders)
                Positioned.fill(
                  child: CustomPaint(
                    painter: CylindersPainter(
                      cylinderInfo: m.cylinderInfo,
                      mvt: mvt,
                      numberOfRows: m.numberOfRows,
                      frontOnly: true,
                    ),
                  ),
                ),
              Positioned(
                top: mvt.layoutOriginY + 10 * s,
                right: rightPad,
                child: IntroPlayPanel(controller: controller),
              ),
              Positioned(
                top: mvt.layoutOriginY + 360 * s,
                right: rightPad,
                child: SizedBox(
                  width: 220 * s.clamp(0.85, 1.4),
                  child: NumberBallsDisplay(
                    n: m.histogram.landedBallsNumber,
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
                  mode: vp.histogramMode,
                  modes: const [
                    HistogramDisplayMode.counter,
                    HistogramDisplayMode.cylinder,
                  ],
                  onChanged: controller.setHistogramMode,
                ),
              ),
              Positioned(
                left: mvt.layoutOriginX + 40 * s,
                bottom:
                    size.height - (mvt.layoutOriginY + (PlinkoMvt.layoutHeight - 55) * s),
                child: PlinkoEraserButton(onPressed: controller.erase),
              ),
              Positioned(
                right: rightPad,
                bottom:
                    size.height - (mvt.layoutOriginY + (PlinkoMvt.layoutHeight - 10) * s),
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
            ],
          );
        },
      ),
    );
  }
}
