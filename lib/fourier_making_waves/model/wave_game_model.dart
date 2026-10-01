import 'dart:math' as math;

import '../fmw_constants.dart';
import '../solver/amplitudes_generator.dart';
import 'wave_game_level.dart';

/// Top-level Wave Game model. PhET `WaveGameModel.ts`
class WaveGameModel {
  WaveGameModel({math.Random? random})
      : rewardScore = FmwConstants.rewardScore {
    final rng = random ?? math.Random();
    levels = [
      WaveGameLevel(
        levelNumber: 1,
        defaultNumberOfAmplitudeControls: 2,
        amplitudesGenerator: AmplitudesGenerator(
          getNumberOfNonZeroHarmonics: () => 1,
          random: rng,
        ),
      ),
      WaveGameLevel(
        levelNumber: 2,
        defaultNumberOfAmplitudeControls: 3,
        amplitudesGenerator: AmplitudesGenerator(
          getNumberOfNonZeroHarmonics: () => 2,
          random: rng,
        ),
      ),
      WaveGameLevel(
        levelNumber: 3,
        defaultNumberOfAmplitudeControls: 5,
        amplitudesGenerator: AmplitudesGenerator(
          getNumberOfNonZeroHarmonics: () => 3,
          random: rng,
        ),
      ),
      WaveGameLevel(
        levelNumber: 4,
        defaultNumberOfAmplitudeControls: 6,
        amplitudesGenerator: AmplitudesGenerator(
          getNumberOfNonZeroHarmonics: () => 4,
          random: rng,
        ),
      ),
      WaveGameLevel(
        levelNumber: 5,
        defaultNumberOfAmplitudeControls: FmwConstants.maxHarmonics,
        getNumberOfNonZeroHarmonics: () =>
            5 + rng.nextInt(FmwConstants.maxHarmonics - 5 + 1),
        amplitudesGenerator: AmplitudesGenerator(
          getNumberOfNonZeroHarmonics: () =>
              5 + rng.nextInt(FmwConstants.maxHarmonics - 5 + 1),
          random: rng,
        ),
      ),
    ];
    assert(levels.length == FmwConstants.numberOfGameLevels);
  }

  final int rewardScore;
  late final List<WaveGameLevel> levels;

  /// Selected level, or null for level-selection UI.
  WaveGameLevel? selectedLevel;

  void selectLevel(int levelNumber) {
    assert(levelNumber >= 1 && levelNumber <= levels.length);
    selectedLevel = levels[levelNumber - 1];
  }

  void clearLevelSelection() {
    selectedLevel = null;
  }

  void reset() {
    for (final level in levels) {
      level.reset();
    }
    selectedLevel = null;
  }
}
