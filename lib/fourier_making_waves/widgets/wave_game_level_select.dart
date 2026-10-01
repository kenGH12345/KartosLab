import 'package:flutter/material.dart';

import '../fmw_colors.dart';
import '../fmw_constants.dart';
import '../fmw_strings.dart';
import '../model/wave_game_level.dart';
import 'amplitude_slider_row.dart';

/// Level selection grid for Wave Game.
class WaveGameLevelSelect extends StatelessWidget {
  const WaveGameLevelSelect({
    super.key,
    required this.levels,
    required this.onSelect,
  });

  final List<WaveGameLevel> levels;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              FmwStrings.selectLevel,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                for (final level in levels)
                  _LevelButton(
                    levelNumber: level.levelNumber,
                    score: level.score,
                    onTap: () => onSelect(level.levelNumber),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelButton extends StatelessWidget {
  const _LevelButton({
    required this.levelNumber,
    required this.score,
    required this.onTap,
  });

  final int levelNumber;
  final int score;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FmwColors.levelSelectionButtonFill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 120,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                FmwStrings.levelLabel(levelNumber),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                FmwStrings.scoreLabel(score),
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// In-level Wave Game controls (sliders + check/show/new/erase/back).
class WaveGameLevelControls extends StatelessWidget {
  const WaveGameLevelControls({
    super.key,
    required this.level,
    required this.lastCheckCorrect,
    required this.onAmplitude,
    required this.onAmplitudeControls,
    required this.onCheckAnswer,
    required this.onShowAnswer,
    required this.onNewWaveform,
    required this.onErase,
    required this.onBack,
  });

  final WaveGameLevel level;
  final bool? lastCheckCorrect;
  final ValueChanged<(int order, double value)> onAmplitude;
  final ValueChanged<int> onAmplitudeControls;
  final VoidCallback onCheckAnswer;
  final VoidCallback onShowAnswer;
  final VoidCallback onNewWaveform;
  final VoidCallback onErase;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final n = level.numberOfAmplitudeControls;
    final values = [
      for (var i = 0; i < n; i++) level.guessSeries.amplitudes[i],
    ];

    return Container(
      width: 300,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: FmwColors.panelFill,
        border: Border.all(color: FmwColors.panelStroke),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${FmwStrings.levelLabel(level.levelNumber)} · ${FmwStrings.scoreLabel(level.score)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (lastCheckCorrect != null) ...[
              const SizedBox(height: 6),
              Text(
                lastCheckCorrect!
                    ? FmwStrings.matched
                    : FmwStrings.tryAgain,
                style: TextStyle(
                  color: lastCheckCorrect! ? Colors.green.shade700 : Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(FmwStrings.amplitudeControls),
            Row(
              children: [
                IconButton(
                  onPressed: n > level.amplitudeControlsMin
                      ? () => onAmplitudeControls(n - 1)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: Text('$n', textAlign: TextAlign.center),
                ),
                IconButton(
                  onPressed: n < level.amplitudeControlsMax
                      ? () => onAmplitudeControls(n + 1)
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            AmplitudeSliderRow(
              values: values,
              step: FmwConstants.waveGameAmplitudeStep,
              enabled: !level.isSolved,
              onChanged: onAmplitude,
              height: 160,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                FilledButton(
                  onPressed: level.isSolved ? null : onCheckAnswer,
                  child: Text(FmwStrings.checkAnswer),
                ),
                OutlinedButton(
                  onPressed: level.isSolved ? null : onShowAnswer,
                  child: Text(FmwStrings.showAnswer),
                ),
                OutlinedButton(
                  onPressed: onNewWaveform,
                  child: Text(FmwStrings.newWaveform),
                ),
                OutlinedButton(
                  onPressed: level.isSolved ? null : onErase,
                  child: Text(FmwStrings.erase),
                ),
                TextButton(
                  onPressed: onBack,
                  child: Text(FmwStrings.backToLevels),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
