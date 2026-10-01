/// PhET vegas `GameUtils.updateScoreAndBestTime` (main / SHA-aligned semantics).
abstract final class GameUtils {
  /// Updates [bestScore] / [bestTime] from a finished game.
  /// Returns whether this run established a new best time (or new high score).
  static bool updateScoreAndBestTime({
    required int score,
    required int time,
    required void Function(int) setBestScore,
    required void Function(int) setBestTime,
    required int Function() getBestScore,
    required int Function() getBestTime,
  }) {
    var newBest = false;
    final bestScore = getBestScore();
    final bestTime = getBestTime();

    if (score > 0 && score > bestScore) {
      setBestScore(score);
      setBestTime(time);
      newBest = true;
    } else if (time != 0 &&
        score > 0 &&
        score == bestScore &&
        (bestTime == 0 || time < bestTime)) {
      setBestTime(time);
      newBest = true;
    }
    return newBest;
  }
}
