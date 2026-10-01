import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/reactants_products_and_leftovers/model/box_type.dart';
import 'package:kratos/reactants_products_and_leftovers/model/challenge_factory.dart';
import 'package:kratos/reactants_products_and_leftovers/model/game_enums.dart';
import 'package:kratos/reactants_products_and_leftovers/model/game_model.dart';
import 'package:kratos/reactants_products_and_leftovers/model/reaction_factory.dart';
import 'package:kratos/reactants_products_and_leftovers/rpal_constants.dart';

void main() {
  group('ReactionFactory pools', () {
    test('level pools are 39 / 21 / 18', () {
      expect(ReactionFactory.level1Pool.length, 39);
      expect(ReactionFactory.level2Pool.length, 21);
      expect(ReactionFactory.level3Pool.length, 18);
      expect(ReactionFactory.pools.length, 3);
    });
  });

  group('ChallengeFactory', () {
    test('creates 5 challenges per level with seeded RNG', () {
      for (var level = 0; level < 3; level++) {
        final challenges = ChallengeFactory.createChallenges(
          level,
          RpalConstants.quantityMax,
          random: Random(42 + level),
        );
        expect(challenges.length, 5);
        expect(
          challenges.where((c) {
            return c.reaction.products.every((p) => p.quantity == 0);
          }).length,
          1,
        );
      }
    });

    test('level interactive boxes match source', () {
      expect(
        ChallengeFactory.interactiveBoxes,
        [BoxType.before, BoxType.after, BoxType.after],
      );
      final c0 = ChallengeFactory.createChallenges(0, 8, random: Random(1));
      final c1 = ChallengeFactory.createChallenges(1, 8, random: Random(1));
      final c2 = ChallengeFactory.createChallenges(2, 8, random: Random(1));
      expect(c0.every((c) => c.interactiveBox == BoxType.before), isTrue);
      expect(c1.every((c) => c.interactiveBox == BoxType.after), isTrue);
      expect(c2.every((c) => c.interactiveBox == BoxType.after), isTrue);
    });

    test('no duplicate reactions in a set', () {
      final challenges = ChallengeFactory.createChallenges(
        1,
        8,
        random: Random(7),
      );
      final keys = challenges.map((c) {
        final left = c.reaction.reactants.map((r) => r.symbol).join('+');
        final right = c.reaction.products.map((p) => p.symbol).join('+');
        return '$left=>$right';
      }).toSet();
      expect(keys.length, challenges.length);
    });
  });

  group('GameModel PlayState', () {
    late GameModel model;

    setUp(() {
      model = GameModel(random: Random(99));
    });

    test('initial is settings / none', () {
      expect(model.gamePhase, GamePhase.settings);
      expect(model.playState, PlayState.none);
      expect(model.score, 0);
    });

    test('play starts level with 5 challenges', () {
      model.play(0);
      expect(model.gamePhase, GamePhase.play);
      expect(model.playState, PlayState.firstCheck);
      expect(model.numberOfChallenges, 5);
      expect(model.challengeNumber, 1);
      expect(model.challenge, isNotNull);
      expect(model.level, 0);
    });

    test('level 1/2/3 each have 5 challenges', () {
      for (var level = 0; level < 3; level++) {
        final m = GameModel(random: Random(level + 3));
        m.play(level);
        expect(m.challenges.length, 5);
        expect(m.getPerfectScore(level), 10);
      }
    });

    test('correct first check awards 2 and goes NEXT', () {
      model.play(0);
      final challenge = model.challenge!;
      challenge.showAnswer(); // fill correct guess
      model.check();
      expect(model.playState, PlayState.next);
      expect(model.score, 2);
      expect(challenge.points, 2);
    });

    test('wrong then tryAgain then second check correct awards 1', () {
      model.play(0);
      final challenge = model.challenge!;
      // leave zeros / wrong — for BEFORE, need non-zero wrong guess
      if (challenge.interactiveBox == BoxType.before) {
        challenge.guess.reactants[0].quantity = 1;
        // ensure incorrect relative to answer
        if (challenge.isCorrect()) {
          challenge.guess.reactants[0].quantity =
              (challenge.reaction.reactants[0].quantity + 1)
                  .clamp(0, RpalConstants.quantityMax);
        }
      } else {
        challenge.guess.products[0].quantity = 1;
        if (challenge.isCorrect()) {
          challenge.guess.products[0].quantity =
              (challenge.reaction.products[0].quantity + 1)
                  .clamp(0, RpalConstants.quantityMax);
        }
      }
      expect(challenge.isCorrect(), isFalse);
      model.check();
      expect(model.playState, PlayState.tryAgain);

      model.tryAgain();
      expect(model.playState, PlayState.secondCheck);

      challenge.showAnswer();
      model.check();
      expect(model.playState, PlayState.next);
      expect(model.score, 1);
      expect(challenge.points, 1);
    });

    test('quantity edit on TRY_AGAIN goes to SECOND_CHECK', () {
      model.play(0);
      final challenge = model.challenge!;
      challenge.guess.reactants[0].quantity = 1;
      if (challenge.isCorrect()) {
        challenge.guess.reactants[0].quantity = 2;
      }
      model.check();
      expect(model.playState, PlayState.tryAgain);
      model.setGuessQuantity(challenge.guess.reactants[0], 3);
      expect(model.playState, PlayState.secondCheck);
    });

    test('show answer awards 0 and goes NEXT', () {
      model.play(0);
      final challenge = model.challenge!;
      challenge.guess.reactants[0].quantity = 1;
      if (challenge.isCorrect()) {
        challenge.guess.reactants[0].quantity = 2;
      }
      model.check(); // try again
      model.tryAgain();
      // wrong again
      if (challenge.isCorrect()) {
        challenge.guess.reactants[0].quantity =
            (challenge.guess.reactants[0].quantity + 1)
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

    test('next advances then finishes to results', () {
      model.play(1);
      for (var i = 0; i < 5; i++) {
        expect(model.gamePhase, GamePhase.play);
        expect(model.challengeNumber, i + 1);
        model.challenge!.showAnswer();
        model.check();
        expect(model.playState, PlayState.next);
        model.next();
      }
      expect(model.gamePhase, GamePhase.results);
      expect(model.score, 10);
      expect(model.isPerfectScore(), isTrue);
      expect(model.bestScores[1], 10);
    });

    test('settings returns to choose level', () {
      model.play(0);
      model.settings();
      expect(model.gamePhase, GamePhase.settings);
      expect(model.playState, PlayState.none);
    });

    test('reset clears score progress and bests', () {
      model.play(0);
      model.challenge!.showAnswer();
      model.check();
      model.next();
      model.reset();
      expect(model.gamePhase, GamePhase.settings);
      expect(model.score, 0);
      expect(model.challenge, isNull);
      expect(model.bestScores.every((s) => s == 0), isTrue);
      expect(model.timerEnabled, isFalse);
      expect(model.gameVisibility, GameVisibility.showAll);
    });

    test('visibility baked into challenges', () {
      model.setGameVisibility(GameVisibility.hideMolecules);
      model.play(0);
      expect(model.challenges.every((c) => !c.moleculesVisible), isTrue);
      expect(model.challenges.every((c) => c.numbersVisible), isTrue);
    });
  });
}
