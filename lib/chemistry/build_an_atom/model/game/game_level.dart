/// One game level — PhET `GameLevel`.
library;

import 'dart:math';

import '../../constants/baa_constants.dart';
import 'challenge_descriptor.dart';
import 'challenge_descriptor_set_factory.dart';

/// Level with challenge descriptors and best score / time.
class GameLevel {
  GameLevel({
    required this.levelNumber,
    required Random random,
  }) : levelIndex = levelNumber - 1 {
    regenerateChallenges(random);
  }

  /// 1-based level number.
  final int levelNumber;

  /// 0-based index into pools / type tables.
  final int levelIndex;

  List<ChallengeDescriptor> challengeDescriptors = const [];

  int bestScore = 0;

  /// Best time in whole seconds for the highest score; 0 means unset.
  int bestTimeSeconds = 0;

  bool isNewBestTime = false;

  int get perfectScore =>
      BAAConstants.challengesPerLevel * BAAConstants.pointsFirstAttempt;

  bool isPerfectScore(int score) => score >= perfectScore;

  void regenerateChallenges(Random random) {
    challengeDescriptors = ChallengeDescriptorSetFactory.createSet(
      levelIndex: levelIndex,
      random: random,
    );
  }

  void startLevel() {
    isNewBestTime = false;
  }

  bool isLastChallenge(int challengeNumber1Based) =>
      challengeNumber1Based >= challengeDescriptors.length;

  /// Update best score / time at end of level (PhET `GameLevel.endLevel`).
  void endLevel({
    required int score,
    required int timeSeconds,
    required bool timerEnabled,
  }) {
    if (score > bestScore) {
      bestTimeSeconds = 0;
    }

    if (timerEnabled) {
      isNewBestTime = _updateScoreAndBestTime(score, timeSeconds);
    } else {
      if (score > bestScore) {
        bestScore = score;
      }
    }
  }

  /// vegas `GameUtils.updateScoreAndBestTime`.
  bool _updateScoreAndBestTime(int score, int time) {
    var newBest = false;
    if (score > bestScore) {
      bestScore = score;
      bestTimeSeconds = time;
      newBest = true;
    } else if (bestTimeSeconds == 0 ||
        (score == bestScore && time < bestTimeSeconds)) {
      bestTimeSeconds = time;
      newBest = true;
    }
    return newBest;
  }

  void reset() {
    bestScore = 0;
    bestTimeSeconds = 0;
    isNewBestTime = false;
  }
}
