import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_act/balancing_act.dart';

void main() {
  group('Game dataset schema', () {
    test('4 levels x 6 challenges kinds match source switch', () {
      expect(BaGameLevelDataset.levelCount, 4);
      expect(BaGameLevelDataset.challengesPerLevel, 6);
      for (var level = 0; level < 4; level++) {
        final kinds = BaGameLevelDataset.challengeKindsForLevel(level);
        expect(kinds.length, 6);
        final set = DeterministicChallengeFactory.generateChallengeSet(level);
        expect(set.length, 6);
        for (var i = 0; i < 6; i++) {
          expect(set[i].kind, kinds[i]);
        }
      }
    });

    test('scoring constants from BalanceGameModel.ts', () {
      expect(BaGameConstants.maxPointsPerProblem, 2);
      expect(BaGameConstants.challengesPerProblemSet, 6);
      expect(BaGameConstants.maxScorePerGame, 12);
      expect(BaGameConstants.defaultMaxAttemptsAllowed, 2);
    });
  });

  group('Game answer semantics', () {
    test('Balance Me: correct first try earns 2', () {
      final game = BalanceGameModel(
        challengeSetFactory: (_) => [
          DeterministicChallengeFactory.balanceMassesSample(),
        ],
      );
      game.startLevel(0);
      final challenge = game.getCurrentChallenge()!;
      final movable = challenge.movableMasses.single;
      game.beginDragMovable(movable);
      game.dragMovableTo(movable, const BaVector2(-2.0, 0.9));
      expect(game.endDragMovable(movable), isTrue);
      game.checkAnswer();
      expect(game.gameState, BaGameState.showingCorrectAnswerFeedback);
      expect(game.score, 2);
    });

    test('Balance Me: wrong then correct earns 1', () {
      final game = BalanceGameModel(
        challengeSetFactory: (_) => [
          DeterministicChallengeFactory.balanceMassesSample(),
        ],
      );
      game.startLevel(0);
      final movable = game.getCurrentChallenge()!.movableMasses.single;
      game.beginDragMovable(movable);
      game.dragMovableTo(movable, const BaVector2(0.5, 0.9));
      game.endDragMovable(movable);
      game.checkAnswer();
      expect(
        game.gameState,
        BaGameState.showingIncorrectAnswerFeedbackTryAgain,
      );
      expect(game.score, 0);

      game.tryAgain();
      game.beginDragMovable(movable);
      game.dragMovableTo(movable, const BaVector2(-2.0, 0.9));
      game.endDragMovable(movable);
      game.checkAnswer();
      expect(game.score, 1);
    });

    test('Mass deduction compares total fixed mass', () {
      final game = BalanceGameModel(
        challengeSetFactory: (_) => [
          DeterministicChallengeFactory.massDeductionSample(),
        ],
      );
      game.startLevel(0);
      expect(game.getTotalFixedMassValue(), 15);
      game.checkAnswer(mass: 15);
      expect(game.gameState, BaGameState.showingCorrectAnswerFeedback);
      expect(game.score, 2);

      game.reset();
      game.startLevel(0);
      game.checkAnswer(mass: 10);
      expect(
        game.gameState,
        BaGameState.showingIncorrectAnswerFeedbackTryAgain,
      );
    });

    test('Tilt prediction uses getTorqueDueToMasses sign', () {
      final game = BalanceGameModel(
        challengeSetFactory: (_) => [
          DeterministicChallengeFactory.tiltPredictionSample(),
        ],
      );
      game.startLevel(0);
      expect(
        game.getTipDirection(),
        TiltPredictionState.tiltDownOnRightSide,
      );
      game.checkAnswer(
        tiltPrediction: TiltPredictionState.tiltDownOnRightSide,
      );
      expect(game.score, 2);
    });
  });

  group('Game progression', () {
    test('nextChallenge through level then results', () {
      final game = BalanceGameModel(
        challengeSetFactory: DeterministicChallengeFactory.generateChallengeSet,
      );
      game.startLevel(0);
      expect(game.challengeList.length, 6);
      expect(game.gameState, BaGameState.presentingInteractiveChallenge);

      for (var i = 0; i < 6; i++) {
        final c = game.getCurrentChallenge()!;
        if (c.kind == BaChallengeKind.massDeduction) {
          game.checkAnswer(mass: game.getTotalFixedMassValue());
        } else if (c.kind == BaChallengeKind.tiltPrediction) {
          game.checkAnswer(tiltPrediction: game.getTipDirection());
        } else {
          final movable = c.movableMasses.single;
          final sol = c.balancedConfiguration.single.distance;
          game.beginDragMovable(movable);
          game.dragMovableTo(movable, BaVector2(sol, 0.9));
          game.endDragMovable(movable);
          game.checkAnswer();
        }
        expect(game.gameState, BaGameState.showingCorrectAnswerFeedback);
        game.nextChallenge();
      }
      expect(game.gameState, BaGameState.showingLevelResults);
      expect(game.score, 12);
      expect(game.bestScores[0], 12);
    });

    test('newGame returns to choosingLevel', () {
      final game = BalanceGameModel(
        challengeSetFactory: DeterministicChallengeFactory.generateChallengeSet,
      );
      game.startLevel(1);
      game.newGame();
      expect(game.gameState, BaGameState.choosingLevel);
    });

    test('displayCorrectAnswer places solution', () {
      final game = BalanceGameModel(
        challengeSetFactory: (_) => [
          DeterministicChallengeFactory.balanceMassesSample(),
        ],
      );
      game.startLevel(0);
      game.displayCorrectAnswer();
      expect(game.gameState, BaGameState.displayingCorrectAnswer);
      expect(game.plank.isBalanced(), isTrue);
    });

    test('Game reset clears scores and times', () {
      final game = BalanceGameModel(
        challengeSetFactory: DeterministicChallengeFactory.generateChallengeSet,
      );
      game.startLevel(0);
      game.score = 5;
      game.bestScores[0] = 5;
      game.elapsedTime = 30;
      game.reset();
      expect(game.score, 0);
      expect(game.bestScores[0], 0);
      expect(game.elapsedTime, 0);
      expect(game.gameState, BaGameState.choosingLevel);
    });
  });
}
