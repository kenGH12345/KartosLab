import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_particle.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/answer_atom.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_state.dart';
import 'package:kratos/chemistry/build_an_atom/model/number_atom.dart';
import 'package:kratos/chemistry/build_an_atom/screens/atom_screen.dart';
import 'package:kratos/chemistry/build_an_atom/screens/build_an_atom_home.dart';
import 'package:kratos/chemistry/build_an_atom/screens/game_screen.dart';
import 'package:kratos/chemistry/build_an_atom/screens/symbol_screen.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/main.dart';
import 'package:kratos/screens/home_screen.dart';

/// PHASE 9 — Android runtime gate (formal Home + required touch paths).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const KratosApp());
    await tester.pumpAndSettle();
  }

  Future<void> openBaa(WidgetTester tester) async {
    final card = find.text(BuildAnAtomHome.title);
    await tester.ensureVisible(card);
    await tester.pump();
    await tester.tap(card);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> backHome(WidgetTester tester) async {
    final back = find.byType(BackButton);
    if (back.evaluate().isNotEmpty) {
      await tester.tap(back);
    } else {
      await tester.pageBack();
    }
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> pumpDesign(WidgetTester tester, Widget home) async {
    await tester.binding.setSurfaceSize(
      const Size(BAAConstants.designWidth, BAAConstants.designHeight + 56),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(BAAConstants.designWidth, BAAConstants.designHeight + 56),
            devicePixelRatio: 1,
            textScaler: TextScaler.linear(1),
          ),
          child: home,
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('1+10 Home entry / back / re-entry', (tester) async {
    await pumpApp(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('化学'), findsOneWidget);
    expect(find.text('原子结构'), findsOneWidget);
    expect(find.text(BuildAnAtomHome.title), findsOneWidget);
    expect(find.text('构建原子 (QA)'), findsNothing);

    await openBaa(tester);
    expect(find.byType(BuildAnAtomHome), findsOneWidget);
    expect(find.byType(BuildAnAtomAtomScreen), findsOneWidget);

    await tester.tap(find.text(BuildAnAtomHome.symbolTabLabel));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(BuildAnAtomSymbolScreen), findsOneWidget);

    await tester.tap(find.text(BuildAnAtomHome.gameTabLabel));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(BuildAnAtomGameScreen), findsOneWidget);

    await tester.tap(find.text(BuildAnAtomHome.atomTabLabel));
    await tester.pump(const Duration(milliseconds: 400));

    await backHome(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    await openBaa(tester);
    expect(find.byType(BuildAnAtomAtomScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('2 Atom particle drag capture/return', (tester) async {
    final m = BAAModel();
    await pumpDesign(tester, BuildAnAtomAtomScreen(model: m));
    final p = m.bucketFor(BaaParticleType.proton).particles.first;
    m.beginDrag(p, modelX: 0, modelY: -40);
    m.updateDrag(p, 0, 0);
    m.endDrag(p, 0, 0);
    await tester.pump();
    expect(m.atom.protonCount, 1);

    final inAtom = m.atom.protons.first;
    m.beginDrag(inAtom, modelX: inAtom.x, modelY: inAtom.y);
    m.updateDrag(inAtom, 200, 200);
    m.endDrag(inAtom, 200, 200);
    await tester.pump();
    expect(m.atom.protonCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('3 Symbol ion / isotope / reset', (tester) async {
    final m = BAAModel()..setAtomConfiguration(const NumberAtom(6, 6, 5));
    await pumpDesign(tester, BuildAnAtomSymbolScreen(model: m));
    expect(m.atom.protonCount, 6);
    expect(m.atom.electronCount, 5);
    await tester.tap(find.byType(KratosResetAllButton));
    await tester.pump();
    expect(m.atom.protonCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('4–9 Game Level1 / Timer / Retry / ShowAnswer / Reset / StartOver',
      (tester) async {
    final g = GameModel(randomSeed: 902);
    await pumpDesign(tester, BuildAnAtomGameScreen(model: g));

    // Timer OFF visible then ON
    expect(find.textContaining('Timer'), findsWidgets);
    await tester.tap(find.textContaining('Timer').first);
    await tester.pump();
    expect(g.timerEnabled, isTrue);

    await tester.tap(find.text('Periodic Table'));
    await tester.pump();
    expect(g.gameState, GameState.presentingChallenge);
    expect(g.timer.isRunning, isTrue);

    // Retry path: wrong → Try Again → correct (+1)
    g.check(const AnswerAtom(0, 0, 0));
    await tester.pump();
    expect(g.gameState, GameState.tryAgain);
    await tester.tap(find.text('Try Again'));
    await tester.pump();
    final c = g.correctAnswer!;
    g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
    await tester.pump();
    expect(g.score, 1);

    if (find.text('Next').evaluate().isNotEmpty) {
      await tester.tap(find.text('Next'));
      await tester.pump();
    }

    // Show Answer path
    g.check(const AnswerAtom(0, 0, 0));
    await tester.pump();
    if (g.gameState == GameState.tryAgain) {
      await tester.tap(find.text('Try Again'));
      await tester.pump();
      g.check(const AnswerAtom(0, 0, 0));
      await tester.pump();
    }
    expect(g.gameState, GameState.attemptsExhausted);
    expect(find.text('Show Answer'), findsOneWidget);
    await tester.tap(find.text('Show Answer'));
    await tester.pump();

    // Start Over → level selection; Reset clears timer preference
    expect(g.score, greaterThan(0));
    g.startOver();
    await tester.pump();
    expect(g.gameState, GameState.levelSelection);
    expect(g.score, 0);

    g.setTimerEnabled(true);
    g.reset();
    await tester.pump();
    expect(g.timerEnabled, isFalse);
    expect(g.gameState, GameState.levelSelection);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rapid Home entry/exit ×5', (tester) async {
    await pumpApp(tester);
    for (var i = 0; i < 5; i++) {
      await openBaa(tester);
      expect(find.byType(BuildAnAtomHome), findsOneWidget);
      await backHome(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
}
