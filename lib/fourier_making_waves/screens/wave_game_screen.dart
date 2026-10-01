import 'package:flutter/material.dart';

import '../controller/wave_game_controller.dart';
import '../fmw_colors.dart';
import '../fmw_constants.dart';
import '../fmw_strings.dart';
import '../render/fmw_render_builder.dart';
import '../widgets/fmw_chart_panel.dart';
import '../widgets/fmw_page_shell.dart';
import '../widgets/wave_game_level_select.dart';

class WaveGameScreen extends StatelessWidget {
  const WaveGameScreen({
    super.key,
    required this.controller,
    this.embedded = false,
  });

  final WaveGameController controller;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final body = Material(
      color: FmwColors.waveGameScreenBackground,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          if (controller.isLevelSelect) {
            return FmwPageShell(
              backgroundColor: FmwColors.waveGameScreenBackground,
              child: WaveGameLevelSelect(
                levels: controller.model.levels,
                onSelect: controller.selectLevel,
              ),
            );
          }

          final level = controller.selectedLevel!;
          final data = FmwRenderBuilder.fromWaveGame(controller)!;

          return FmwPageShell(
            backgroundColor: FmwColors.waveGameScreenBackground,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                FmwConstants.screenViewXMargin,
                FmwConstants.screenViewYMargin,
                FmwConstants.screenViewXMargin,
                8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FmwChartPanel(
                            title: FmwStrings.amplitudes,
                            bars: data.bars,
                            barsYMin: data.amplitudesYMin,
                            barsYMax: data.amplitudesYMax,
                          ),
                          const SizedBox(height: 8),
                          FmwChartPanel(
                            title: FmwStrings.harmonics,
                            chart: data.harmonicsChart,
                          ),
                          const SizedBox(height: 8),
                          FmwChartPanel(
                            title: FmwStrings.sum,
                            chart: data.sumChart,
                          ),
                          if (data.isSolved && data.isMatched)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                FmwStrings.matched,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  WaveGameLevelControls(
                    level: level,
                    lastCheckCorrect: controller.lastCheckCorrect,
                    onAmplitude: (pair) =>
                        controller.setGuessAmplitude(pair.$1, pair.$2),
                    onAmplitudeControls:
                        controller.setNumberOfAmplitudeControls,
                    onCheckAnswer: controller.checkAnswer,
                    onShowAnswer: controller.showAnswer,
                    onNewWaveform: controller.newWaveform,
                    onErase: controller.eraseAmplitudes,
                    onBack: controller.backToLevels,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text(FmwStrings.tabWaveGame)),
      body: body,
    );
  }
}
