import '../../ba_shared_constants.dart';
import '../ba_enums.dart';
import '../ba_mass.dart';
import '../ba_vector2.dart';
import '../plank.dart';
import 'balance_game_challenge.dart';
import 'challenge_factory.dart';

/// Source: `js/game/model/BalanceGameModel.ts` — independent of BalanceModel.
class BalanceGameModel {
  BalanceGameModel({
    List<BalanceGameChallenge> Function(int level)? challengeSetFactory,
  }) : _challengeSetFactory = challengeSetFactory ??
            SourceFaithfulChallengeFactory.generateChallengeSet {
    plank = Plank(
      position: const BaVector2(0, BaGeometry.plankHeight),
      pivotPoint: const BaVector2(0, BaGeometry.fulcrumHeight),
      columnStateGetter: () => columnState,
      userControlledMassesGetter: () => userControlledMasses,
    );
    plank.onColumnStateChanged(columnState);
    bestScores = List<int>.filled(BaGameConstants.maxLevels, 0);
    bestTimes = List<double?>.filled(BaGameConstants.maxLevels, null);
  }

  final List<BalanceGameChallenge> Function(int level) _challengeSetFactory;

  late final Plank plank;
  ColumnState columnState = ColumnState.doubleColumns;

  final List<BaMass> fixedMasses = [];
  final List<BaMass> movableMasses = [];
  final List<BaMass> userControlledMasses = [];

  bool timerEnabled = false;
  int level = 0; // zero-based
  int challengeIndex = 0;
  int score = 0;
  BaGameState gameState = BaGameState.choosingLevel;
  double elapsedTime = 0;
  late List<int> bestScores;
  late List<double?> bestTimes;
  bool newBestTime = false;

  List<BalanceGameChallenge> challengeList = [];
  int incorrectGuessesOnCurrentChallenge = 0;

  PositionIndicatorChoice positionMarkerState = PositionIndicatorChoice.none;

  void step(double dt) {
    plank.step(dt);
    for (final m in movableMasses) {
      m.step(dt);
    }
    for (final m in fixedMasses) {
      m.step(dt);
    }
  }

  void reset() {
    timerEnabled = false;
    level = 0;
    challengeIndex = 0;
    score = 0;
    gameState = BaGameState.choosingLevel;
    columnState = ColumnState.doubleColumns;
    plank.onColumnStateChanged(columnState);
    elapsedTime = 0;
    bestScores = List<int>.filled(BaGameConstants.maxLevels, 0);
    bestTimes = List<double?>.filled(BaGameConstants.maxLevels, null);
    positionMarkerState = PositionIndicatorChoice.none;
    incorrectGuessesOnCurrentChallenge = 0;
    challengeList = [];
    plank.removeAllMasses();
    fixedMasses.clear();
    movableMasses.clear();
    userControlledMasses.clear();
  }

  void startLevel(int levelIndex) {
    plank.removeAllMasses();
    level = levelIndex;
    score = 0;
    challengeIndex = 0;
    elapsedTime = 0;
    challengeList = _challengeSetFactory(levelIndex);
    setChallenge(challengeList[0], challengeList[0].initialColumnState);
    gameState = BaGameState.presentingInteractiveChallenge;
    newBestTime = false;
    incorrectGuessesOnCurrentChallenge = 0;
  }

  void setChallenge(BalanceGameChallenge challenge, ColumnState columns) {
    plank.removeAllMasses();
    userControlledMasses.clear();
    columnState = ColumnState.doubleColumns;
    plank.onColumnStateChanged(columnState);

    fixedMasses.clear();
    movableMasses.clear();

    for (final pair in challenge.fixedMassDistancePairs) {
      fixedMasses.add(pair.mass);
      plank.addMassToSurfaceAt(pair.mass, pair.distance);
    }

    for (final mass in challenge.movableMasses) {
      const initialPosition = BaVector2(3, 0);
      mass.position = initialPosition;
      movableMasses.add(mass);
    }

    columnState = columns;
    plank.onColumnStateChanged(columnState);
  }

  BalanceGameChallenge? getCurrentChallenge() {
    if (challengeList.isEmpty || challengeIndex >= challengeList.length) {
      return null;
    }
    return challengeList[challengeIndex];
  }

  int getChallengeCurrentPointValue() =>
      BaGameConstants.maxPointsPerProblem - incorrectGuessesOnCurrentChallenge;

  void beginDragMovable(BaMass mass) {
    mass.userControlled = true;
    if (!userControlledMasses.contains(mass)) {
      userControlledMasses.add(mass);
    }
    if (mass.onPlank) {
      plank.removeMassFromSurface(mass);
    }
  }

  void dragMovableTo(BaMass mass, BaVector2 position) {
    if (!mass.userControlled) return;
    mass.position = position;
  }

  bool endDragMovable(BaMass mass) {
    mass.userControlled = false;
    userControlledMasses.remove(mass);
    if (!plank.addMassToSurface(mass)) {
      mass.position = const BaVector2(3, 0);
      return false;
    }
    return true;
  }

  /// Source: `checkAnswer(mass?, tiltPrediction?)`
  void checkAnswer({double? mass, TiltPredictionState? tiltPrediction}) {
    final challenge = getCurrentChallenge();
    if (challenge == null) return;

    if (challenge.kind == BaChallengeKind.balanceMasses) {
      columnState = ColumnState.noColumns;
      plank.onColumnStateChanged(columnState);
      _handleProposedAnswer(plank.isBalanced());
    } else if (challenge.kind == BaChallengeKind.tiltPrediction) {
      final torque = plank.getTorqueDueToMasses();
      final correct = (tiltPrediction ==
                  TiltPredictionState.tiltDownOnLeftSide &&
              torque > 0) ||
          (tiltPrediction == TiltPredictionState.tiltDownOnRightSide &&
              torque < 0) ||
          (tiltPrediction == TiltPredictionState.stayBalanced && torque == 0);
      if (correct) {
        columnState = ColumnState.noColumns;
        plank.onColumnStateChanged(columnState);
      }
      _handleProposedAnswer(correct);
    } else if (challenge.kind == BaChallengeKind.massDeduction) {
      _handleProposedAnswer(mass == getTotalFixedMassValue());
    }
  }

  void _handleProposedAnswer(bool answerIsCorrect) {
    if (answerIsCorrect) {
      gameState = BaGameState.showingCorrectAnswerFeedback;
      final pointsEarned = incorrectGuessesOnCurrentChallenge == 0
          ? BaGameConstants.maxPointsPerProblem
          : BaGameConstants.maxPointsPerProblem -
              incorrectGuessesOnCurrentChallenge;
      score += pointsEarned;
    } else {
      incorrectGuessesOnCurrentChallenge++;
      final maxAttempts = getCurrentChallenge()!.maxAttemptsAllowed;
      if (incorrectGuessesOnCurrentChallenge < maxAttempts) {
        gameState = BaGameState.showingIncorrectAnswerFeedbackTryAgain;
      } else {
        gameState = BaGameState.showingIncorrectAnswerFeedbackMoveOn;
      }
    }
  }

  void newGame() {
    gameState = BaGameState.choosingLevel;
    incorrectGuessesOnCurrentChallenge = 0;
  }

  void nextChallenge() {
    challengeIndex++;
    incorrectGuessesOnCurrentChallenge = 0;
    if (challengeIndex < challengeList.length) {
      final c = getCurrentChallenge()!;
      setChallenge(c, c.initialColumnState);
      gameState = BaGameState.presentingInteractiveChallenge;
    } else {
      final lvl = level;
      if (score == BaGameConstants.maxScorePerGame) {
        if (bestTimes[lvl] == null || elapsedTime < bestTimes[lvl]!) {
          newBestTime = bestTimes[lvl] != null;
          bestTimes[lvl] = elapsedTime;
        }
      }
      if (score > bestScores[lvl]) {
        bestScores[lvl] = score;
      }
      gameState = BaGameState.showingLevelResults;
    }
  }

  void tryAgain() {
    columnState = getCurrentChallenge()!.initialColumnState;
    plank.onColumnStateChanged(columnState);
    gameState = BaGameState.presentingInteractiveChallenge;
  }

  void displayCorrectAnswer() {
    final current = getCurrentChallenge()!;
    setChallenge(current, ColumnState.noColumns);
    for (final pair in current.balancedConfiguration) {
      plank.addMassToSurfaceAt(pair.mass, pair.distance);
    }
    gameState = BaGameState.displayingCorrectAnswer;
  }

  TiltPredictionState getTipDirection() {
    final torque = plank.getTorqueDueToMasses();
    if (torque < 0) return TiltPredictionState.tiltDownOnRightSide;
    if (torque > 0) return TiltPredictionState.tiltDownOnLeftSide;
    return TiltPredictionState.stayBalanced;
  }

  double getTotalFixedMassValue() {
    var total = 0.0;
    for (final pair in getCurrentChallenge()!.fixedMassDistancePairs) {
      total += pair.mass.massValue;
    }
    return total;
  }

  void tickTimerOneSecond() {
    if (timerEnabled) {
      elapsedTime += 1;
    }
  }
}
