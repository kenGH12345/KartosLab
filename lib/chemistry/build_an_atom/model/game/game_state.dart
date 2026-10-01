/// Game state machine values — PhET `GameModel.GameStateValues`.
library;

enum GameState {
  levelSelection,
  presentingChallenge,
  solvedCorrectly,
  tryAgain,
  attemptsExhausted,
  showingAnswer,
  levelCompleted,
}
