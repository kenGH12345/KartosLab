/// PhET `GameState.ts` — game state machine values.
enum GameState {
  levelSelection,
  check,
  tryAgain,
  showAnswer,
  next,
  levelCompleted,
}

/// Source `isValidGameStateTransition`.
bool isValidGameStateTransition(GameState from, GameState to) {
  if (to == GameState.levelSelection) return true;
  switch (from) {
    case GameState.levelSelection:
      return to == GameState.check;
    case GameState.check:
      return to == GameState.next ||
          to == GameState.tryAgain ||
          to == GameState.showAnswer ||
          to == GameState.check ||
          to == GameState.levelCompleted;
    case GameState.tryAgain:
      return to == GameState.check;
    case GameState.showAnswer:
      return to == GameState.next;
    case GameState.next:
      return to == GameState.check || to == GameState.levelCompleted;
    case GameState.levelCompleted:
      return false;
  }
}
