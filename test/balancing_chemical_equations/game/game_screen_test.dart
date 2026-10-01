import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_chemical_equations/game/game_model.dart';
import 'package:kratos/balancing_chemical_equations/game/game_screen.dart';
import 'package:kratos/balancing_chemical_equations/game/game_state.dart';
import 'package:kratos/balancing_chemical_equations/vegas/game_timer.dart';
import 'package:kratos/balancing_chemical_equations/vegas/game_utils.dart';
import 'package:kratos/balancing_chemical_equations/views/balance_scales_node.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

void main() {
  group('GameModel semantics', () {
    late GameModel model;

    setUp(() {
      model = GameModel(random: Random(42));
    });

    tearDown(() {
      model.dispose();
    });

    test('initial state is levelSelection', () {
      expect(model.gameState, GameState.levelSelection);
      expect(model.level, isNull);
      expect(model.score, 0);
      expect(model.levels.length, 3);
    });

    test('start level → 5 challenges, state check', () {
      model.selectLevel(model.levels.first);
      expect(model.gameState, GameState.check);
      expect(model.numberOfChallenges, 5);
      expect(model.challengeNumber, 1);
      expect(model.levelNumber, 1);
      expect(model.challenge.id, startsWith('game.level1.'));
    });

    test('level1 first challenge has no big molecule', () {
      model.selectLevel(model.levels.first);
      expect(model.challenge.hasBigMolecule, isFalse);
    });

    test('correct first attempt awards 2 points', () {
      model.selectLevel(model.levels.first);
      final eq = model.challenge;
      eq.balance(); // simplified
      model.check();
      expect(model.points, 2);
      expect(model.score, 2);
      expect(model.gameState, GameState.next);
      expect(model.feedbackVisible, isTrue);
    });

    test('incorrect then correct second attempt awards 1 point', () {
      model.selectLevel(model.levels.first);
      // Leave coeffs at initial (typically not simplified)
      // Force non-simplified by setting wrong coeffs
      for (final t in model.challenge.terms) {
        t.coefficient = 0;
      }
      model.challenge.reactants.first.coefficient = 1;
      expect(model.challenge.isSimplified, isFalse);
      model.check();
      expect(model.gameState, GameState.tryAgain);
      expect(model.score, 0);
      expect(model.attempts, 1);

      model.tryAgain();
      expect(model.gameState, GameState.check);
      model.challenge.balance();
      model.check();
      expect(model.points, 1);
      expect(model.score, 1);
      expect(model.gameState, GameState.next);
    });

    test('two failures → showAnswer; Show Answer scores 0 + balance()', () {
      model.selectLevel(model.levels.first);
      for (final t in model.challenge.terms) {
        t.coefficient = 1;
      }
      // Ensure not simplified (may accidentally be if balanced coeffs are all 1)
      if (model.challenge.isSimplified) {
        model.challenge.reactants.first.coefficient = 0;
      }
      model.check();
      expect(model.gameState, GameState.tryAgain);
      model.tryAgain();
      if (model.challenge.isSimplified) {
        model.challenge.reactants.first.coefficient = 0;
      }
      model.challenge.reactants.first.coefficient =
          model.challenge.reactants.first.coefficient == 0 ? 2 : 0;
      expect(model.challenge.isSimplified, isFalse);
      model.check();
      expect(model.gameState, GameState.showAnswer);
      expect(model.score, 0);

      model.showAnswer();
      expect(model.gameState, GameState.next);
      expect(model.challenge.isSimplified, isTrue);
      expect(model.points, 0);
      expect(model.score, 0);
      expect(model.nextButtonVisible, isTrue);
    });

    test('balanced not simplified does not award points', () {
      model.selectLevel(model.levels.first);
      final eq = model.challenge;
      // Set N=2 multiple of balanced coeffs
      for (final t in eq.terms) {
        t.coefficient = t.balancedCoefficient * 2;
      }
      expect(eq.isBalanced, isTrue);
      expect(eq.isSimplified, isFalse);
      model.check();
      expect(model.score, 0);
      expect(model.gameState, GameState.tryAgain);
    });

    test('next advances challenge identity and preserves score', () {
      model.selectLevel(model.levels.first);
      final firstId = model.challenge.id;
      model.challenge.balance();
      model.check();
      expect(model.score, 2);
      model.next();
      expect(model.challengeNumber, 2);
      expect(model.challenge.id, isNot(firstId));
      expect(model.score, 2);
      expect(model.attempts, 0);
      expect(model.gameState, GameState.check);
    });

    test('5 challenges → levelCompleted', () {
      model.selectLevel(model.levels.first);
      for (var i = 0; i < 5; i++) {
        expect(model.gameState, GameState.check);
        model.challenge.balance();
        model.check();
        expect(model.gameState, GameState.next);
        model.next();
      }
      expect(model.gameState, GameState.levelCompleted);
      expect(model.score, 10);
      expect(model.isPerfectScore(), isTrue);
      expect(model.levels.first.bestScore, 10);
    });

    test('Start Over preserves bestScore, clears current score', () {
      model.selectLevel(model.levels.first);
      model.challenge.balance();
      model.check();
      model.next();
      // finish remaining with show answer path quickly
      while (model.gameState != GameState.levelCompleted) {
        if (model.gameState == GameState.check) {
          model.challenge.balance();
          model.check();
        } else if (model.gameState == GameState.next) {
          model.next();
        } else if (model.gameState == GameState.tryAgain) {
          model.tryAgain();
        } else if (model.gameState == GameState.showAnswer) {
          model.showAnswer();
        }
      }
      final best = model.levels.first.bestScore;
      expect(best, greaterThan(0));
      model.startOver();
      expect(model.gameState, GameState.levelSelection);
      expect(model.score, 0);
      expect(model.levels.first.bestScore, best);
      expect(model.timerEnabled, isFalse);
    });

    test('Reset All clears bestScore; Start Over does not', () {
      model.selectLevel(model.levels.first);
      for (var i = 0; i < 5; i++) {
        model.challenge.balance();
        model.check();
        model.next();
      }
      expect(model.levels.first.bestScore, 10);
      model.startOver();
      expect(model.levels.first.bestScore, 10);
      model.reset();
      expect(model.levels.first.bestScore, 0);
      expect(model.timerEnabled, isFalse);
    });

    test('view mode particles only — no View combo required', () {
      model.selectLevel(model.levels.first);
      expect(model.gameState, GameState.check);
      // Game has no ViewMode property; particles always shown in play view.
      expect(model.reactantsExpanded, isTrue);
    });
  });

  group('vegas helpers', () {
    test('GameTimer formatTime', () {
      expect(GameTimer.formatTime(65), '1:05');
      expect(GameTimer.formatTime(3601), '1:00:01');
    });

    test('GameUtils updateScoreAndBestTime', () {
      var bestScore = 0;
      var bestTime = 0;
      final isNew = GameUtils.updateScoreAndBestTime(
        score: 10,
        time: 42,
        setBestScore: (v) => bestScore = v,
        setBestTime: (v) => bestTime = v,
        getBestScore: () => bestScore,
        getBestTime: () => bestTime,
      );
      expect(isNew, isTrue);
      expect(bestScore, 10);
      expect(bestTime, 42);
    });
  });

  group('GameScreen widget', () {
    Future<void> pumpGame(WidgetTester tester, GameModel model) async {
      await tester.binding.setSurfaceSize(const Size(900, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 768,
                height: 504,
                child: GameScreen(model: model),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('level selection chrome', (tester) async {
      final model = GameModel(random: Random(1));
      addTearDown(model.dispose);
      await pumpGame(tester, model);
      expect(find.text('Choose Your Level!'), findsOneWidget);
      expect(find.byType(KratosResetAllButton), findsOneWidget);
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('select level enters play with Check', (tester) async {
      final model = GameModel(random: Random(1));
      addTearDown(model.dispose);
      await pumpGame(tester, model);
      model.selectLevel(model.levels.first);
      await tester.pump();
      expect(find.text('Check'), findsOneWidget);
      expect(find.textContaining('Challenge 1 of 5'), findsOneWidget);
      expect(find.text('Start Over'), findsOneWidget);
    });

    testWidgets('Show Why reveals conservation visualization', (tester) async {
      final model = GameModel(random: Random(7));
      addTearDown(model.dispose);
      await pumpGame(tester, model);
      model.selectLevel(model.levels.first);
      await tester.pump();
      // Fail check
      for (final t in model.challenge.terms) {
        t.coefficient = 0;
      }
      model.challenge.reactants.first.coefficient = 1;
      model.check();
      await tester.pump();
      expect(find.text('Not balanced'), findsOneWidget);
      expect(find.text('Show Why'), findsOneWidget);
      await tester.tap(find.text('Show Why'));
      await tester.pump();
      expect(model.showWhy, isTrue);
      expect(find.byType(BalanceScalesNode), findsOneWidget);
    });

    testWidgets('Start Over returns to level selection', (tester) async {
      final model = GameModel(random: Random(3));
      addTearDown(model.dispose);
      await pumpGame(tester, model);
      model.selectLevel(model.levels[1]);
      await tester.pump();
      await tester.tap(find.text('Start Over'));
      await tester.pump();
      expect(model.gameState, GameState.levelSelection);
      expect(find.text('Choose Your Level!'), findsOneWidget);
    });
  });
}
