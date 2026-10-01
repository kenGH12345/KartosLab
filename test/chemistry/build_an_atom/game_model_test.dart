import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/answer_atom.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_state.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/score_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/number_atom.dart';

void main() {
  group('GameModel scoring', () {
    test('first attempt correct → +2', () {
      final g = GameModel(randomSeed: 1);
      g.startLevel(1);
      final correct = g.correctAnswer!;
      g.check(AnswerAtom(correct.protons, correct.neutrons, correct.electrons));
      expect(g.score, 2);
      expect(g.gameState, GameState.solvedCorrectly);
    });

    test('second attempt correct → +1', () {
      final g = GameModel(randomSeed: 2);
      g.startLevel(1);
      final correct = g.correctAnswer!;
      g.check(const AnswerAtom(0, 0, 0)); // wrong
      expect(g.gameState, GameState.tryAgain);
      expect(g.score, 0);
      g.tryAgain();
      g.check(AnswerAtom(correct.protons, correct.neutrons, correct.electrons));
      expect(g.score, 1);
      expect(g.gameState, GameState.solvedCorrectly);
    });

    test('second attempt wrong → no score, attemptsExhausted', () {
      final g = GameModel(randomSeed: 3);
      g.startLevel(1);
      g.check(const AnswerAtom(0, 0, 0));
      g.tryAgain();
      g.check(const AnswerAtom(0, 0, 0));
      expect(g.score, 0);
      expect(g.gameState, GameState.attemptsExhausted);
    });

    test('perfect score path → 10 and reward flag', () {
      final g = GameModel(randomSeed: 99);
      g.startLevel(1);
      for (var i = 0; i < BAAConstants.challengesPerLevel; i++) {
        final correct = g.correctAnswer!;
        g.check(
          AnswerAtom(correct.protons, correct.neutrons, correct.electrons),
        );
        if (g.gameState == GameState.solvedCorrectly ||
            g.gameState == GameState.levelCompleted) {
          // After last challenge, endLevel already called; next() moves to completed
          if (i < BAAConstants.challengesPerLevel - 1) {
            g.next();
          } else {
            g.next();
          }
        }
      }
      expect(g.score, BAAConstants.maxPointsPerGameLevel);
      expect(g.shouldShowReward, isTrue);
      expect(g.starProgress.filledStars, 5);
    });

    test('star progress half star', () {
      final p = StarProgress(score: 1); // 1/10 → 0.5 stars
      expect(p.filledStars, 0);
      expect(p.hasHalfStar, isTrue);
      expect(p.remainder, closeTo(0.5, 1e-9));
    });
  });

  group('Reset vs StartOver', () {
    test('startOver keeps bestScore; reset clears it', () {
      final g = GameModel(randomSeed: 7);
      g.startLevel(1);
      // perfect one challenge then bail via startOver after scoring
      final correct = g.correctAnswer!;
      g.check(AnswerAtom(correct.protons, correct.neutrons, correct.electrons));
      // Force end-of-level bookkeeping by completing remaining as wrong then
      // manually set best via finishing level:
      while (g.challengeNumber < BAAConstants.challengesPerLevel) {
        g.next();
        final c = g.correctAnswer!;
        g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
      }
      g.next(); // levelCompleted
      expect(g.levels[0].bestScore, greaterThan(0));
      final best = g.levels[0].bestScore;
      final seedBefore = g.randomSeed;

      g.startOver();
      expect(g.gameState, GameState.levelSelection);
      expect(g.levels[0].bestScore, best);
      expect(g.randomSeed, seedBefore + 1);
      expect(g.score, 0);

      g.reset();
      expect(g.levels[0].bestScore, 0);
      expect(g.timerEnabled, isFalse);
      expect(g.gameState, GameState.levelSelection);
    });
  });

  group('Timer lifecycle', () {
    test('timer starts when enabled on level start', () {
      final g = GameModel(randomSeed: 5);
      g.setTimerEnabled(true);
      g.startLevel(2);
      expect(g.timer.isRunning, isTrue);
      g.step(1.0);
      expect(g.timer.elapsedSeconds, 1);
      // Exhaust level quickly
      for (var i = 0; i < BAAConstants.challengesPerLevel; i++) {
        final c = g.correctAnswer!;
        g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
        if (i < BAAConstants.challengesPerLevel - 1) g.next();
      }
      expect(g.timer.isRunning, isFalse);
    });

    test('timer off by default', () {
      final g = GameModel(randomSeed: 5);
      g.startLevel(1);
      expect(g.timerEnabled, isFalse);
      expect(g.timer.isRunning, isFalse);
    });
  });

  group('Element challenge submission', () {
    test('only Z + ion/neutral matter', () {
      final g = GameModel(randomSeed: 11);
      g.startLevel(1);
      // Force descriptor that is element type by scanning
      // Just use checkElementAnswer API against current correct answer.
      final correct = g.correctAnswer!;
      final ionOrNeutral =
          correct.charge == 0 ? NeutralOrIon.neutral : NeutralOrIon.ion;
      g.checkElementAnswer(
        selectedProtons: correct.protons,
        neutralOrIon: ionOrNeutral,
      );
      expect(g.score, 2);
    });
  });

  test('NumberAtom used in wrong answer path compiles', () {
    const a = NumberAtom(1, 0, 1);
    expect(a.charge, 0);
  });
}
