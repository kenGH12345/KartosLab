/// Source: `js/common/model/ColumnState.ts`
enum ColumnState {
  doubleColumns,
  singleColumn,
  noColumns,
}

/// Source: `js/common/model/PositionIndicatorChoice.ts`
enum PositionIndicatorChoice {
  none,
  rulers,
  marks,
}

/// Source: `js/game/model/TiltPredictionState.ts`
enum TiltPredictionState {
  tiltDownOnLeftSide,
  stayBalanced,
  tiltDownOnRightSide,
  none,
}

/// Source: `BalanceGameModel` GameState string union.
enum BaGameState {
  choosingLevel,
  presentingInteractiveChallenge,
  showingCorrectAnswerFeedback,
  showingIncorrectAnswerFeedbackTryAgain,
  showingIncorrectAnswerFeedbackMoveOn,
  displayingCorrectAnswer,
  showingLevelResults,
}
