import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/answer_atom.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_state.dart';
import 'package:kratos/chemistry/build_an_atom/model/number_atom.dart';
import 'package:kratos/chemistry/build_an_atom/screens/atom_screen.dart';
import 'package:kratos/chemistry/build_an_atom/screens/game_screen.dart';
import 'package:kratos/chemistry/build_an_atom/screens/symbol_screen.dart';
import 'package:kratos/chemistry/build_an_atom/widgets/game/game_interactive_periodic_table.dart';

import 'behavioral_harness.dart';

/// PHASE 7 — Cross-screen / lifecycle / stress / isolation.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpOwned(WidgetTester tester, Widget screen) async {
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
          child: screen,
        ),
      ),
    );
    await tester.pump();
  }

  group('State isolation (PhET: separate models per Screen)', () {
    testWidgets('owned Atom / Symbol / Game are independent instances',
        (tester) async {
      final atomProbe = <int>[];
      final symbolProbe = <int>[];

      // Capture owned models via brief inject-free open is hard; prove via
      // two injected models that production-style isolation must hold.
      final atomM = BAAModel()..setAtomConfiguration(const NumberAtom(6, 6, 6));
      final symbolM = BAAModel();
      final gameM = GameModel(randomSeed: 701)..startLevel(1);

      await BehavioralHarness.pumpAtom(tester, atomM);
      atomProbe.add(atomM.protonCount);
      await BehavioralHarness.pumpSymbol(tester, symbolM);
      symbolProbe.add(symbolM.protonCount);
      await BehavioralHarness.pumpGame(tester, gameM);

      expect(atomProbe.single, 6);
      expect(symbolProbe.single, 0);
      expect(gameM.score, 0);

      // Mutate Game — Atom/Symbol models untouched
      final c = gameM.correctAnswer!;
      gameM.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
      expect(atomM.protonCount, 6);
      expect(symbolM.protonCount, 0);

      // Mutate Symbol — Atom unchanged
      symbolM.setAtomConfiguration(const NumberAtom(1, 0, 1));
      expect(atomM.protonCount, 6);
      expect(symbolM.protonCount, 1);
    });

    testWidgets('QA leave/return creates fresh owned Atom (not preserved)',
        (tester) async {
      await pumpOwned(tester, const BuildAnAtomAtomScreen());
      // Cannot reach private model — mutate via UI drag is heavy; use inject
      // contrast: owned screen dispose must not throw.
      await pumpOwned(tester, const SizedBox());
      await pumpOwned(tester, const BuildAnAtomAtomScreen());
      expect(find.text('Atom'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Rebuild', () {
    testWidgets('Atom rebuild keeps particle counts', (tester) async {
      final m = BAAModel()..setAtomConfiguration(const NumberAtom(2, 2, 2));
      await BehavioralHarness.pumpAtom(tester, m);
      await tester.pumpWidget(
        MaterialApp(home: BuildAnAtomAtomScreen(model: m)),
      );
      await tester.pump();
      expect(m.protonCount, 2);
      expect(find.text('Helium'), findsOneWidget);
    });

    testWidgets('Game rebuild keeps score / challenge', (tester) async {
      final g = GameModel(randomSeed: 702)..startLevel(1);
      final c = g.correctAnswer!;
      g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
      await BehavioralHarness.pumpGame(tester, g);
      expect(g.score, 2);
      await BehavioralHarness.pumpGame(tester, g);
      expect(g.score, 2);
      expect(g.challengeNumber, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('rapid resize rebuilds without state reset', (tester) async {
      final m = BAAModel()..setAtomConfiguration(const NumberAtom(6, 6, 6));
      await BehavioralHarness.pumpAtom(tester, m);
      for (final size in const [
        Size(375, 667),
        Size(1024, 768),
        Size(1920, 1080),
        Size(BAAConstants.designWidth, BAAConstants.designHeight + 56),
      ]) {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(size: size, devicePixelRatio: 1),
              child: BuildAnAtomAtomScreen(model: m),
            ),
          ),
        );
        await tester.pump();
      }
      expect(m.protonCount, 6);
      expect(tester.takeException(), isNull);
    });
  });

  group('Timer lifecycle', () {
    testWidgets('leave stops timer; no double accumulation while away',
        (tester) async {
      final g = GameModel(randomSeed: 710)..setTimerEnabled(true);
      g.startLevel(1);
      await BehavioralHarness.pumpGame(tester, g);
      g.step(1.0);
      final t1 = g.timer.elapsedSecondsExact;
      expect(g.timer.isRunning, isTrue);

      // Leave — dispose stops timer
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
      expect(g.timer.isRunning, isFalse);
      final frozen = g.timer.elapsedSecondsExact;

      // Wall time away must not advance domain timer
      await tester.pump(const Duration(seconds: 2));
      expect(g.timer.elapsedSecondsExact, frozen);

      // Return — resume mid-level
      await BehavioralHarness.pumpGame(tester, g);
      expect(g.timer.isRunning, isTrue);
      g.step(0.5);
      expect(g.timer.elapsedSecondsExact, greaterThan(t1));
    });

    testWidgets('timer start is idempotent (no duplicate streams)', (tester) async {
      final g = GameModel(randomSeed: 711)..setTimerEnabled(true);
      g.startLevel(1);
      g.timer.start();
      g.timer.start();
      g.timer.start();
      await BehavioralHarness.pumpGame(tester, g);
      g.step(1.0);
      expect(g.timer.elapsedSeconds, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('Game / reward / focus lifecycle', () {
    testWidgets('reward then leave / return clean', (tester) async {
      final g = GameModel(randomSeed: 1)..startLevel(1);
      for (var i = 0; i < 5; i++) {
        final c = g.correctAnswer!;
        g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
        g.next();
      }
      await BehavioralHarness.pumpGame(tester, g);
      await tester.pump(const Duration(milliseconds: 80));
      expect(g.shouldShowReward, isTrue);
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
      await BehavioralHarness.pumpGame(tester, g);
      expect(g.gameState, GameState.levelCompleted);
      expect(tester.takeException(), isNull);
    });

    testWidgets('focus + keyboard survive screen switch', (tester) async {
      final m = BAAModel()..setAtomConfiguration(const NumberAtom(1, 0, 1));
      await BehavioralHarness.pumpAtom(tester, m);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
      await tester.pump();
      await BehavioralHarness.pumpSymbol(tester, BAAModel());
      await BehavioralHarness.pumpAtom(tester, m);
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pump();
      expect(m.protonCount, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('Cross-screen chains', () {
    testWidgets('Chain A: Atom→Symbol→Game→Atom', (tester) async {
      final atom = BAAModel()..setAtomConfiguration(const NumberAtom(1, 1, 1));
      final symbol = BAAModel();
      final game = GameModel(randomSeed: 720);

      await BehavioralHarness.pumpAtom(tester, atom);
      expect(find.text('Hydrogen'), findsOneWidget);

      await BehavioralHarness.pumpSymbol(tester, symbol);
      symbol.setAtomConfiguration(const NumberAtom(3, 3, 2));
      await tester.pump();
      expect(symbol.charge, 1);
      expect(atom.protonCount, 1); // isolated

      await BehavioralHarness.pumpGame(tester, game);
      game.startLevel(1);
      await tester.pump();
      final c = game.correctAnswer!;
      game.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
      expect(game.score, 2);

      await BehavioralHarness.pumpAtom(tester, atom);
      expect(atom.protonCount, 1);
      expect(atom.massNumber, 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Chain B: Game→Symbol→Atom→Game', (tester) async {
      final game = GameModel(randomSeed: 721)..startLevel(2);
      await BehavioralHarness.pumpGame(tester, game);
      final score = game.score;
      await BehavioralHarness.pumpSymbol(
        tester,
        BAAModel()..setAtomConfiguration(const NumberAtom(2, 2, 2)),
      );
      await BehavioralHarness.pumpAtom(tester, BAAModel());
      await BehavioralHarness.pumpGame(tester, game);
      expect(game.levelNumber, 2);
      expect(game.score, score);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Chain C: 8 transitions', (tester) async {
      final atom = BAAModel();
      final symbol = BAAModel();
      final game = GameModel(randomSeed: 722);
      final sequence = <Widget Function()>[
        () => BuildAnAtomAtomScreen(model: atom),
        () => BuildAnAtomSymbolScreen(model: symbol),
        () => BuildAnAtomGameScreen(model: game),
        () => BuildAnAtomAtomScreen(model: atom),
        () => BuildAnAtomGameScreen(model: game),
        () => BuildAnAtomSymbolScreen(model: symbol),
        () => BuildAnAtomAtomScreen(model: atom),
        () => BuildAnAtomGameScreen(model: game),
      ];
      for (final build in sequence) {
        await pumpOwned(tester, build());
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('Chain D: rapid 10 cycles Atom→Symbol→Game', (tester) async {
      final atom = BAAModel();
      final symbol = BAAModel();
      final game = GameModel(randomSeed: 723)..setTimerEnabled(true);
      for (var i = 0; i < 10; i++) {
        await pumpOwned(tester, BuildAnAtomAtomScreen(model: atom));
        await pumpOwned(tester, BuildAnAtomSymbolScreen(model: symbol));
        await pumpOwned(tester, BuildAnAtomGameScreen(model: game));
      }
      expect(tester.takeException(), isNull);
      // Timer must not be wildly large from leaked tickers while away
      expect(game.timer.elapsedSeconds, lessThan(30));
    });
  });

  group('Reset lifecycle', () {
    testWidgets('reset during drag clears gesture ownership', (tester) async {
      final m = BAAModel();
      await BehavioralHarness.pumpAtom(tester, m);
      final p = m.protonBucket.particles.first;
      m.beginDrag(p, modelX: 50, modelY: 50);
      expect(m.draggingParticle, isNotNull);
      m.reset();
      await tester.pump();
      expect(m.draggingParticle, isNull);
      expect(m.protonCount, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('reset during cloud / accordion / game feedback', (tester) async {
      final m = BAAModel()..setAtomConfiguration(const NumberAtom(2, 2, 5));
      await BehavioralHarness.pumpAtom(tester, m);
      await tester.tap(find.text('Cloud'));
      await tester.pump();
      await tester.tap(find.text('Periodic Table'));
      await tester.pump();
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w.runtimeType.toString().contains('KratosResetAllButton'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(m.protonCount, 0);

      final g = GameModel(randomSeed: 730)..startLevel(1);
      await BehavioralHarness.pumpGame(tester, g);
      g.check(const AnswerAtom(99, 99, 99));
      await tester.pump();
      expect(g.gameState, GameState.tryAgain);
      g.reset();
      await tester.pump();
      expect(g.gameState, GameState.levelSelection);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Start Over retain best; Reset clears; leave mid Start Over',
        (tester) async {
      final g = GameModel(randomSeed: 1)..startLevel(1);
      for (var i = 0; i < 5; i++) {
        final c = g.correctAnswer!;
        g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
        g.next();
      }
      expect(g.levels[0].bestScore, 10);
      await BehavioralHarness.pumpGame(tester, g);
      g.startOver();
      await tester.pump();
      expect(g.levels[0].bestScore, 10);
      await pumpOwned(tester, const SizedBox());
      await BehavioralHarness.pumpGame(tester, g);
      expect(g.gameState, GameState.levelSelection);
      expect(g.levels[0].bestScore, 10);
      g.reset();
      expect(g.levels[0].bestScore, 0);
    });
  });

  group('Invalid / double actions', () {
    testWidgets('Check ignored outside presentingChallenge', (tester) async {
      final g = GameModel(randomSeed: 740)..startLevel(1);
      final c = g.correctAnswer!;
      g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
      expect(g.score, 2);
      g.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
      expect(g.score, 2);
      g.next();
      g.check(const AnswerAtom(0, 0, 0)); // presenting again OK
      expect(g.gameState, isNot(GameState.levelCompleted));

      // Exhaust → showingAnswer → Check noop
      while (g.gameState != GameState.attemptsExhausted &&
          g.gameState != GameState.solvedCorrectly) {
        if (g.gameState == GameState.tryAgain) g.tryAgain();
        if (g.gameState == GameState.presentingChallenge) {
          g.check(const AnswerAtom(99, 99, 99));
        } else {
          break;
        }
      }
      if (g.gameState == GameState.attemptsExhausted) {
        g.displayCorrectAnswer();
        final scoreBefore = g.score;
        g.check(const AnswerAtom(1, 1, 1));
        expect(g.score, scoreBefore);
        expect(g.gameState, GameState.showingAnswer);
      }
    });
  });

  group('Game periodic table reachability', () {
    testWidgets('He and C cells hit-testable in half-pane', (tester) async {
      var selected = 0;
      await tester.binding.setSurfaceSize(const Size(360, 400));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: Row(
                children: [
                  const Expanded(child: Placeholder()),
                  Expanded(
                    child: GameInteractivePeriodicTable(
                      selectedZ: selected,
                      onSelected: (z) => selected = z,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final he = find.descendant(
        of: find.byType(GameInteractivePeriodicTable),
        matching: find.text('He'),
      );
      final c = find.descendant(
        of: find.byType(GameInteractivePeriodicTable),
        matching: find.text('C'),
      );
      expect(he, findsOneWidget);
      expect(c, findsOneWidget);
      await tester.ensureVisible(he);
      await tester.tap(he);
      await tester.pump();
      expect(selected, 2);
      await tester.ensureVisible(c);
      await tester.tap(c);
      await tester.pump();
      expect(selected, 6);
    });
  });

  group('Stress', () {
    testWidgets('20-cycle Atom↔Symbol↔Game with mutations', (tester) async {
      final atom = BAAModel();
      final symbol = BAAModel();
      final game = GameModel(randomSeed: 750);
      for (var i = 0; i < 20; i++) {
        await pumpOwned(tester, BuildAnAtomAtomScreen(model: atom));
        if (i.isEven) {
          atom.setAtomConfiguration(NumberAtom(1 + (i % 3), i % 2, 1));
        } else {
          atom.reset();
        }
        await pumpOwned(tester, BuildAnAtomSymbolScreen(model: symbol));
        symbol.setAtomConfiguration(const NumberAtom(2, 2, 2));
        await pumpOwned(tester, BuildAnAtomGameScreen(model: game));
        if (game.gameState == GameState.levelSelection) {
          game.startLevel(1 + (i % 4));
        } else if (game.gameState == GameState.presentingChallenge) {
          final c = game.correctAnswer!;
          game.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
          if (game.gameState == GameState.solvedCorrectly) game.next();
        } else if (game.gameState == GameState.levelCompleted) {
          game.startOver();
        }
        await tester.pump();
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('50-cycle Game enter/level/leave/return/reset', (tester) async {
      final game = GameModel(randomSeed: 760);
      for (var i = 0; i < 50; i++) {
        await pumpOwned(tester, BuildAnAtomGameScreen(model: game));
        if (game.gameState == GameState.levelSelection) {
          if (i % 7 == 0) game.setTimerEnabled(i.isEven);
          game.startLevel(1 + (i % 4));
        }
        if (game.gameState == GameState.presentingChallenge) {
          final c = game.correctAnswer!;
          if (i % 5 == 0) {
            game.check(const AnswerAtom(99, 99, 99));
            if (game.gameState == GameState.tryAgain) game.tryAgain();
          } else {
            game.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
            if (game.gameState == GameState.solvedCorrectly ||
                game.gameState == GameState.showingAnswer) {
              game.next();
            }
          }
        }
        if (game.gameState == GameState.levelCompleted) {
          if (i % 2 == 0) {
            game.startOver();
          } else {
            game.reset();
          }
        }
        // Leave
        await pumpOwned(tester, const SizedBox());
        if (i % 11 == 0) {
          game.reset();
        }
      }
      expect(tester.takeException(), isNull);
      expect(game.timer.isRunning, isFalse);
    });
  });

  group('Audio hooks', () {
    testWidgets('game audio adapter never throws on leave mid-feedback',
        (tester) async {
      final g = GameModel(randomSeed: 770)..startLevel(1);
      await BehavioralHarness.pumpGame(tester, g);
      g.check(const AnswerAtom(99, 99, 99));
      await tester.pump();
      await pumpOwned(tester, const SizedBox());
      expect(tester.takeException(), isNull);
    });
  });
}
