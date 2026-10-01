import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/reactants_products_and_leftovers/model/game_model.dart';
import 'package:kratos/reactants_products_and_leftovers/rpal_strings.dart';
import 'package:kratos/reactants_products_and_leftovers/view/game_controller.dart';
import 'package:kratos/reactants_products_and_leftovers/view/game_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Game settings shows Choose Your Level and 3 levels',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GameScreen()),
      ),
    );
    expect(find.text(RpalStrings.chooseYourLevel), findsOneWidget);
    expect(find.text(RpalStrings.levelN(1)), findsOneWidget);
    expect(find.text(RpalStrings.levelN(2)), findsOneWidget);
    expect(find.text(RpalStrings.levelN(3)), findsOneWidget);
    expect(find.text(RpalStrings.showAll), findsOneWidget);
  });

  testWidgets('selecting Level 1 enters play with Check', (tester) async {
    final controller = GameController(model: GameModel(random: Random(5)));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GameScreen(controller: controller)),
      ),
    );
    await tester.tap(find.text(RpalStrings.levelN(1)));
    await tester.pumpAndSettle();

    expect(find.text(RpalStrings.check), findsOneWidget);
    expect(find.text(RpalStrings.startOver), findsOneWidget);
    expect(find.textContaining('Score'), findsOneWidget);
    expect(find.text(RpalStrings.challengeProgress(1, 5)), findsOneWidget);
  });

  testWidgets('reset from settings restores defaults', (tester) async {
    final controller = GameController(model: GameModel(random: Random(2)));
    controller.setTimerEnabled(true);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GameScreen(controller: controller)),
      ),
    );
    controller.reset();
    await tester.pump();
    expect(controller.model.timerEnabled, isFalse);
    expect(find.text(RpalStrings.chooseYourLevel), findsOneWidget);
  });
}
