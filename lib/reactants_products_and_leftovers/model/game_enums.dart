/// Game phase — `GamePhase.ts`.
enum GamePhase { settings, play, results }

/// Play button state machine — `PlayState.ts`.
enum PlayState {
  firstCheck,
  tryAgain,
  secondCheck,
  showAnswer,
  next,
  none,
}

extension PlayStateX on PlayState {
  bool get isInteractive =>
      this == PlayState.firstCheck ||
      this == PlayState.tryAgain ||
      this == PlayState.secondCheck;
}

/// Challenge visibility — `GameVisibility.ts`.
enum GameVisibility { showAll, hideMolecules, hideNumbers }
