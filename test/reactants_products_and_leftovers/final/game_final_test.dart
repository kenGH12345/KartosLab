import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/reactants_products_and_leftovers/model/box_type.dart';
import 'package:kratos/reactants_products_and_leftovers/model/challenge.dart';
import 'package:kratos/reactants_products_and_leftovers/model/challenge_factory.dart';
import 'package:kratos/reactants_products_and_leftovers/model/game_enums.dart';
import 'package:kratos/reactants_products_and_leftovers/model/game_model.dart';
import 'package:kratos/reactants_products_and_leftovers/model/reaction_factory.dart';
import 'package:kratos/reactants_products_and_leftovers/rpal_constants.dart';

void main() {
  group('Game Final QA — pools', () {
    test('39 / 21 / 18 reaction pools', () {
      expect(ReactionFactory.level1Pool.length, 39);
      expect(ReactionFactory.level2Pool.length, 21);
      expect(ReactionFactory.level3Pool.length, 18);
      expect(
        ReactionFactory.level1Pool.length,
        ReactionFactory.level2Pool.length + ReactionFactory.level3Pool.length,
      );
    });

    test('interactive boxes Before / After / After', () {
      expect(ChallengeFactory.interactiveBoxes, [
        BoxType.before,
        BoxType.after,
        BoxType.after,
      ]);
    });
  });

  group('Game Final QA — zero-product guaranteed', () {
    test('many seeds always yield exactly one zero-product per level', () {
      for (var level = 0; level < 3; level++) {
        for (var seed = 0; seed < 40; seed++) {
          final challenges = ChallengeFactory.createChallenges(
            level,
            RpalConstants.quantityMax,
            random: Random(seed),
          );
          expect(challenges.length, 5);
          final zeros = challenges.where((c) {
            return c.reaction.products.every((p) => p.quantity == 0);
          }).length;
          expect(zeros, 1, reason: 'level=$level seed=$seed');
        }
      }
    });
  });

  group('Game Final QA — full level loops', () {
    for (final level in [0, 1, 2]) {
      test('Level ${level + 1}: perfect run → Results score 10', () {
        final model = GameModel(random: Random(100 + level));
        model.play(level);
        expect(model.gamePhase, GamePhase.play);
        expect(model.challenges.length, 5);
        expect(
          model.challenge!.interactiveBox,
          ChallengeFactory.interactiveBoxes[level],
        );

        for (var i = 0; i < 5; i++) {
          expect(model.challengeNumber, i + 1);
          expect(model.playState, PlayState.firstCheck);
          final challenge = model.challenge!;
          challenge.showAnswer();
          expect(challenge.isCorrect(), isTrue);
          expect(model.checkEnabled, isTrue);
          model.check();
          expect(model.playState, PlayState.next);
          expect(challenge.points, 2);
          model.next();
        }

        expect(model.gamePhase, GamePhase.results);
        expect(model.score, 10);
        expect(model.isPerfectScore(), isTrue);
        expect(model.bestScores[level], 10);
      });
    }
  });

  group('Game Final QA — guess / score / controls', () {
    test('incorrect → Try Again → edit → Check +1', () {
      final model = GameModel(random: Random(3));
      model.play(0);
      final challenge = model.challenge!;
      final guess = challenge.guess;

      guess.reactants[0].quantity = 1;
      if (challenge.isCorrect()) {
        guess.reactants[0].quantity = 2;
      }
      expect(challenge.isCorrect(), isFalse);
      model.check();
      expect(model.playState, PlayState.tryAgain);
      expect(model.score, 0);

      model.tryAgain();
      expect(model.playState, PlayState.secondCheck);

      challenge.showAnswer();
      model.check();
      expect(model.playState, PlayState.next);
      expect(model.score, 1);
      expect(challenge.points, 1);
    });

    test('Show Answer awards 0 and does not grant full score', () {
      final model = GameModel(random: Random(11));
      model.play(1);
      final challenge = model.challenge!;
      challenge.guess.products[0].quantity = 1;
      if (challenge.isCorrect()) {
        challenge.guess.products[0].quantity = 2;
      }
      model.check();
      expect(model.playState, PlayState.tryAgain);
      model.tryAgain();
      if (challenge.isCorrect()) {
        challenge.guess.products[0].quantity =
            (challenge.guess.products[0].quantity + 1)
                .clamp(0, RpalConstants.quantityMax);
      }
      model.check();
      expect(model.playState, PlayState.showAnswer);
      model.showAnswer();
      expect(model.playState, PlayState.next);
      expect(model.score, 0);
      expect(challenge.points, 0);
      expect(challenge.isCorrect(), isTrue);
    });

    test('check disabled when all guessable quantities are zero', () {
      final model = GameModel(random: Random(4));
      model.play(0);
      expect(model.checkEnabled, isFalse);
      model.challenge!.guess.reactants[0].quantity = 1;
      expect(model.checkEnabled, isTrue);
    });

    test('Next clears previous interactive state for new challenge', () {
      final model = GameModel(random: Random(8));
      model.play(0);
      final first = model.challenge!;
      first.showAnswer();
      model.check();
      model.next();
      final second = model.challenge!;
      expect(identical(first, second), isFalse);
      expect(model.playState, PlayState.firstCheck);
      expect(second.points, 0);
      if (second.interactiveBox == BoxType.before) {
        expect(second.guess.reactants.every((r) => r.quantity == 0), isTrue);
      } else {
        expect(second.guess.products.every((p) => p.quantity == 0), isTrue);
        expect(second.guess.leftovers.every((l) => l.quantity == 0), isTrue);
      }
    });

    test('zero-product challenge solvable via GameGuess/showAnswer', () {
      final model = GameModel(random: Random(0));
      model.play(0);
      Challenge? zero;
      while (model.gamePhase == GamePhase.play) {
        final c = model.challenge!;
        if (c.reaction.products.every((p) => p.quantity == 0)) {
          zero = c;
          break;
        }
        c.showAnswer();
        model.check();
        model.next();
      }
      expect(zero, isNotNull);
      zero!.showAnswer();
      expect(zero.isCorrect(), isTrue);
      expect(zero.reaction.products.every((p) => p.quantity == 0), isTrue);
    });
  });

  group('Game Final QA — level isolation', () {
    test('finishing level A then playing level B does not inherit score', () {
      final model = GameModel(random: Random(21));
      model.play(0);
      for (var i = 0; i < 5; i++) {
        model.challenge!.showAnswer();
        model.check();
        model.next();
      }
      expect(model.score, 10);
      expect(model.gamePhase, GamePhase.results);

      model.settings();
      model.play(2);
      expect(model.score, 0);
      expect(model.challengeNumber, 1);
      expect(model.playState, PlayState.firstCheck);
      expect(model.level, 2);
      expect(model.bestScores[0], 10);
      expect(model.bestScores[2], 0);
    });
  });
}
