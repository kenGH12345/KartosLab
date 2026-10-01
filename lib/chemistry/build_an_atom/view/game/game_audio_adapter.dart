/// Game audio hooks — vegas `GameAudioPlayer` semantics without forged assets.
library;

/// Events that PhET plays via shared vegas/tambo sounds.
enum GameAudioEvent {
  correctAnswer,
  wrongAnswer,
  gameOverPerfectScore,
  gameOverImperfectScore,
}

/// Adapter: wire to shared audio when available; no-op otherwise (P2).
class GameAudioAdapter {
  GameAudioAdapter({this.onEvent});

  /// Optional sink for tests / future shared player.
  final void Function(GameAudioEvent event)? onEvent;

  final List<GameAudioEvent> history = <GameAudioEvent>[];

  void play(GameAudioEvent event) {
    history.add(event);
    onEvent?.call(event);
  }

  void correctAnswer() => play(GameAudioEvent.correctAnswer);
  void wrongAnswer() => play(GameAudioEvent.wrongAnswer);
  void gameOverPerfect() => play(GameAudioEvent.gameOverPerfectScore);
  void gameOverImperfect() => play(GameAudioEvent.gameOverImperfectScore);

  void clearHistory() => history.clear();
}
