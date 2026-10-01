import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/reactants_products_and_leftovers/model/game_enums.dart';
import 'package:kratos/reactants_products_and_leftovers/model/game_model.dart';
import 'package:kratos/reactants_products_and_leftovers/rpal_strings.dart';
import 'package:kratos/reactants_products_and_leftovers/view/game_controller.dart';
import 'package:kratos/reactants_products_and_leftovers/view/game_screen.dart';
import 'package:kratos/reactants_products_and_leftovers/view/molecules_controller.dart';
import 'package:kratos/reactants_products_and_leftovers/view/molecules_screen.dart';
import 'package:kratos/reactants_products_and_leftovers/view/sandwiches_controller.dart';
import 'package:kratos/reactants_products_and_leftovers/view/sandwiches_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Reset Matrix', () {
    test('Sandwiches: recipe / quantity / accordion → Reset → defaults', () {
      final c = SandwichesController();
      c.selectRecipe(c.recipes[1]);
      c.setReactantQuantity(c.selected.bread, 8);
      c.setReactantQuantity(c.selected.meat, 3);
      c.toggleBeforeExpanded();
      c.toggleAfterExpanded();
      c.reset();
      expect(c.selected.name, RpalStrings.cheese);
      expect(c.selected.bread.quantity, 0);
      expect(c.selected.cheese.quantity, 0);
      expect(c.beforeExpanded, isTrue);
      expect(c.afterExpanded, isTrue);
      expect(c.recipes[1].bread.quantity, 0);
    });

    test('Molecules: reaction / quantity / accordion → Reset → defaults', () {
      final c = MoleculesController();
      c.selectReaction(c.reactions[2]);
      c.setReactantQuantity(c.selected.reactants[0], 8);
      c.toggleAfterExpanded();
      c.reset();
      expect(c.selected.name, RpalStrings.makeWater);
      expect(c.selected.reactants.every((r) => r.quantity == 0), isTrue);
      expect(c.reactions[2].reactants.every((r) => r.quantity == 0), isTrue);
      expect(c.beforeExpanded, isTrue);
      expect(c.afterExpanded, isTrue);
    });

    test('Game: level/progress/guess/feedback → Reset → settings defaults', () {
      final c = GameController(model: GameModel(random: Random(9)));
      c.setTimerEnabled(true);
      c.setGameVisibility(GameVisibility.hideNumbers);
      c.play(1);
      c.model.challenge!.showAnswer();
      c.check();
      c.next();
      expect(c.model.score, greaterThan(0));
      c.reset();
      expect(c.model.gamePhase, GamePhase.settings);
      expect(c.model.playState, PlayState.none);
      expect(c.model.score, 0);
      expect(c.model.challenge, isNull);
      expect(c.model.challengeNumber, 0);
      expect(c.model.timerEnabled, isFalse);
      expect(c.model.gameVisibility, GameVisibility.showAll);
      expect(c.model.bestScores.every((s) => s == 0), isTrue);
    });
  });

  group('Lifecycle create → interact → dispose → recreate', () {
    testWidgets('Sandwiches dispose + recreate is clean', (tester) async {
      final c1 = SandwichesController();
      c1.setReactantQuantity(c1.selected.bread, 5);
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SandwichesScreen(controller: c1))),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      c1.dispose();

      final c2 = SandwichesController();
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SandwichesScreen(controller: c2))),
      );
      await tester.pumpAndSettle();
      expect(c2.selected.bread.quantity, 0);
      expect(find.text(RpalStrings.cheese), findsWidgets);
      c2.dispose();
    });

    testWidgets('Molecules dispose + recreate is clean', (tester) async {
      final c1 = MoleculesController();
      c1.selectReaction(c1.reactions[1]);
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MoleculesScreen(controller: c1))),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      c1.dispose();

      final c2 = MoleculesController();
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MoleculesScreen(controller: c2))),
      );
      await tester.pumpAndSettle();
      expect(c2.selected.name, RpalStrings.makeWater);
      c2.dispose();
    });

    testWidgets('Game dispose + recreate is clean', (tester) async {
      final c1 = GameController(model: GameModel(random: Random(5)));
      c1.play(0);
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: GameScreen(controller: c1))),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      c1.dispose();

      final c2 = GameController(model: GameModel(random: Random(6)));
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: GameScreen(controller: c2))),
      );
      await tester.pumpAndSettle();
      expect(c2.model.gamePhase, GamePhase.settings);
      expect(find.text(RpalStrings.chooseYourLevel), findsOneWidget);
      c2.dispose();
    });

    test('Game timer stops on settings / reset (no leaked running timer)', () {
      final model = GameModel(random: Random(7));
      model.play(0);
      expect(model.timer.isRunning, isTrue);
      model.settings();
      expect(model.timer.isRunning, isFalse);
      model.play(0);
      expect(model.timer.isRunning, isTrue);
      model.reset();
      expect(model.timer.isRunning, isFalse);
      expect(model.timer.elapsed, Duration.zero);
    });
  });
}
