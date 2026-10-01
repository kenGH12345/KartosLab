/// PhET vegas `GameAudioPlayer` wiring for BCE Game.
///
/// Source triggers:
/// - check simplified → correctAnswer
/// - check otherwise → wrongAnswer
/// - level complete perfect → gameOverPerfectScore
/// - level complete imperfect → gameOverImperfectScore
///
/// **Asset status**: vegas/tambo sound files are not present in the local tree
/// (network clone blocked). Methods are no-ops so call sites stay correct;
/// documented as P2 — source asset unavailable (not Material substitution).
class GameAudioPlayer {
  const GameAudioPlayer();

  void correctAnswer() {}
  void wrongAnswer() {}
  void gameOverPerfectScore() {}
  void gameOverImperfectScore() {}

  void dispose() {}
}
