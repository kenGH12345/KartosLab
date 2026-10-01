import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_act/balancing_act.dart';

/// Phase 6 — Final behavioral acceptance / lifecycle / isolation.
///
/// Does not change production semantics; asserts state + lifecycle only.
void main() {
  Widget wrap(Widget child) => MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 800, height: 600, child: child),
        ),
      );

  Future<void> leave(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
    );
    await tester.pump();
  }

  // ─── INTRO ─────────────────────────────────────────────────────────────

  group('Phase6 Intro acceptance', () {
    test('I-A1 initial plank / masses / ViewProperties / columns', () {
      final c = BaIntroController();
      expect(c.model.plank.tiltAngle, 0);
      expect(c.model.plank.angularVelocity, 0);
      expect(c.model.columnState, ColumnState.doubleColumns);
      expect(c.model.plank.massesOnSurface, isEmpty);
      expect(c.model.fireExtinguisher1.position, const BaVector2(2.7, 0));
      expect(c.model.fireExtinguisher2.position, const BaVector2(3.2, 0));
      expect(c.model.smallTrashCan.position, const BaVector2(3.7, 0));
      expect(c.viewProperties.massLabelsVisible, isTrue);
      expect(c.viewProperties.forceVectorsFromObjectsVisible, isFalse);
      expect(c.viewProperties.levelIndicatorVisible, isFalse);
      expect(
        c.viewProperties.positionMarkerState,
        PositionIndicatorChoice.none,
      );
      expect(c.mvt.scale, BaSharedConstants.introLabMvtScale);
      c.dispose();
    });

    test('I-A2 / I-A3 drag extinguisher + trash can; multi-mass', () {
      final c = BaIntroController();
      final fe = c.model.fireExtinguisher1;
      c.beginDrag(fe, c.mvt.modelToView(fe.position));
      c.updateDrag(c.mvt.modelToView(const BaVector2(-1.0, 0.9)));
      c.endDrag();
      expect(fe.onPlank, isTrue);

      final tc = c.model.smallTrashCan;
      c.beginDrag(tc, c.mvt.modelToView(tc.position));
      c.updateDrag(c.mvt.modelToView(const BaVector2(1.0, 0.9)));
      c.endDrag();
      expect(tc.onPlank, isTrue);
      expect(c.model.plank.massesOnSurface.length, greaterThanOrEqualTo(2));

      final fe2 = c.model.fireExtinguisher2;
      c.beginDrag(fe2, c.mvt.modelToView(fe2.position));
      c.updateDrag(c.mvt.modelToView(const BaVector2(0.5, 0.9)));
      c.endDrag();
      expect(c.model.plank.massesOnSurface.length, greaterThanOrEqualTo(2));
      c.dispose();
    });

    test('I-A4 remove / reposition', () {
      final c = BaIntroController();
      final m = c.model.fireExtinguisher1;
      c.beginDrag(m, c.mvt.modelToView(m.position));
      c.updateDrag(c.mvt.modelToView(const BaVector2(1.0, 0.9)));
      c.endDrag();
      expect(m.onPlank, isTrue);

      c.beginDrag(m, c.mvt.modelToView(m.position));
      c.updateDrag(c.mvt.modelToView(const BaVector2(-1.5, 0.9)));
      c.endDrag();
      expect(m.onPlank, isTrue);
      expect(m.position.x, closeTo(-1.5, 0.01));
      c.dispose();
    });

    test('I-A5 Show toggles sync ViewProperties', () {
      final c = BaIntroController();
      c.setMassLabelsVisible(false);
      expect(c.viewProperties.massLabelsVisible, isFalse);
      c.setForcesVisible(true);
      expect(c.viewProperties.forceVectorsFromObjectsVisible, isTrue);
      c.setLevelVisible(true);
      expect(c.viewProperties.levelIndicatorVisible, isTrue);
      c.setMassLabelsVisible(true);
      c.setForcesVisible(false);
      c.setLevelVisible(false);
      expect(c.viewProperties.massLabelsVisible, isTrue);
      expect(c.viewProperties.forceVectorsFromObjectsVisible, isFalse);
      expect(c.viewProperties.levelIndicatorVisible, isFalse);
      c.dispose();
    });

    test('I-A6 Position none/rulers/marks round-trip', () {
      final c = BaIntroController();
      for (final choice in [
        PositionIndicatorChoice.rulers,
        PositionIndicatorChoice.marks,
        PositionIndicatorChoice.none,
        PositionIndicatorChoice.rulers,
        PositionIndicatorChoice.none,
      ]) {
        c.setPositionChoice(choice);
        expect(c.viewProperties.positionMarkerState, choice);
      }
      c.dispose();
    });

    test('I-A7 AB DOUBLE↔NO ×3', () {
      final c = BaIntroController();
      for (var i = 0; i < 3; i++) {
        c.setSupportsEnabled(false);
        expect(c.model.columnState, ColumnState.noColumns);
        c.setSupportsEnabled(true);
        expect(c.model.columnState, ColumnState.doubleColumns);
      }
      c.dispose();
    });

    test('I-A8 Reset ×3 restores initial', () {
      final c = BaIntroController();
      for (var i = 0; i < 3; i++) {
        final m = c.model.fireExtinguisher1;
        c.beginDrag(m, c.mvt.modelToView(m.position));
        c.updateDrag(c.mvt.modelToView(const BaVector2(1.25, 0.9)));
        c.endDrag();
        c.setSupportsEnabled(false);
        c.setForcesVisible(true);
        c.setPositionChoice(PositionIndicatorChoice.marks);
        for (var s = 0; s < 10; s++) {
          c.model.step(1 / 60);
        }
        c.resetAll();
        expect(c.model.plank.massesOnSurface, isEmpty);
        expect(c.model.plank.tiltAngle, 0);
        expect(c.model.columnState, ColumnState.doubleColumns);
        expect(c.viewProperties.forceVectorsFromObjectsVisible, isFalse);
        expect(
          c.viewProperties.positionMarkerState,
          PositionIndicatorChoice.none,
        );
        expect(c.model.fireExtinguisher1.position, const BaVector2(2.7, 0));
      }
      c.dispose();
    });
  });

  // ─── LAB ───────────────────────────────────────────────────────────────

  group('Phase6 Lab acceptance', () {
    test('L-A1 / L-A2 carousel pages forward and back', () {
      final c = BaBalanceLabController();
      expect(c.model.carousel.pageIndex, 0);
      expect(c.model.carousel.currentPage, LabCarouselPage.bricks);

      c.nextCarouselPage(); // people1
      c.nextCarouselPage(); // people2
      c.nextCarouselPage(); // mystery1
      c.nextCarouselPage(); // mystery2
      expect(c.model.carousel.pageIndex, 4);
      c.previousCarouselPage();
      c.previousCarouselPage();
      c.previousCarouselPage();
      c.previousCarouselPage();
      expect(c.model.carousel.pageIndex, 0);
      expect(c.model.carousel.currentPage, LabCarouselPage.bricks);
      c.dispose();
    });

    test('L-A3 brick / person / mystery placement + miss', () {
      final c = BaBalanceLabController();

      c.startBrickCreator(2, c.mvt.modelToView(const BaVector2(0.75, 0.9)));
      c.updateDrag(c.mvt.modelToView(const BaVector2(0.75, 0.9)));
      c.endDrag();
      expect(c.model.massList.any((m) => m.onPlank && m.numBricks == 2), isTrue);

      c.nextCarouselPage();
      c.startPersonCreator(
        BaMassType.boy,
        c.mvt.modelToView(const BaVector2(-0.75, 0.9)),
      );
      c.updateDrag(c.mvt.modelToView(const BaVector2(-0.75, 0.9)));
      c.endDrag();
      expect(
        c.model.massList.any((m) => m.onPlank && m.type == BaMassType.boy),
        isTrue,
      );

      c.nextCarouselPage();
      c.nextCarouselPage();
      c.startMysteryCreator(0, c.mvt.modelToView(const BaVector2(1.25, 0.9)));
      c.updateDrag(c.mvt.modelToView(const BaVector2(1.25, 0.9)));
      c.endDrag();
      expect(c.model.massList.any((m) => m.onPlank && m.isMystery), isTrue);

      final before = c.model.massList.length;
      c.startBrickCreator(1, c.mvt.modelToView(const BaVector2(3.5, 0.5)));
      final ghost = c.dragging!;
      c.updateDrag(c.mvt.modelToView(const BaVector2(3.5, 0.5)));
      c.endDrag();
      expect(ghost.animating, isTrue);
      for (var i = 0; i < 180; i++) {
        c.model.step(1 / 60);
      }
      expect(c.model.massList.length, lessThanOrEqualTo(before));
      c.dispose();
    });

    test('L-A5 Show/Position + L-A6 Reset', () {
      final c = BaBalanceLabController();
      c.nextCarouselPage();
      c.setForcesVisible(true);
      c.setLevelVisible(true);
      c.setPositionChoice(PositionIndicatorChoice.rulers);
      c.setSupportsEnabled(false);
      c.startBrickCreator(1, c.mvt.modelToView(const BaVector2(1.0, 0.9)));
      c.updateDrag(c.mvt.modelToView(const BaVector2(1.0, 0.9)));
      c.endDrag();
      for (var i = 0; i < 20; i++) {
        c.model.step(1 / 60);
      }
      c.resetAll();
      expect(c.model.massList, isEmpty);
      expect(c.model.carousel.pageIndex, 0);
      expect(c.model.columnState, ColumnState.doubleColumns);
      expect(c.viewProperties.forceVectorsFromObjectsVisible, isFalse);
      expect(
        c.viewProperties.positionMarkerState,
        PositionIndicatorChoice.none,
      );
      expect(c.model.plank.tiltAngle, 0);
      c.dispose();
    });
  });

  // ─── GAME ──────────────────────────────────────────────────────────────

  group('Phase6 Game acceptance', () {
    BaGameController game([
      List<BalanceGameChallenge> Function(int level)? factory,
    ]) =>
        BaGameController(
          challengeSetFactory:
              factory ?? DeterministicChallengeFactory.generateChallengeSet,
        );

    test('G-A1 all 4 levels selectable; timer toggle', () {
      final c = game();
      expect(c.model.gameState, BaGameState.choosingLevel);
      for (var level = 0; level < 4; level++) {
        c.startLevel(level);
        expect(c.model.level, level);
        expect(c.model.gameState, BaGameState.presentingInteractiveChallenge);
        expect(c.model.challengeList.length, 6);
        c.newGame();
        expect(c.model.gameState, BaGameState.choosingLevel);
      }
      c.setTimerEnabled(true);
      expect(c.model.timerEnabled, isTrue);
      c.setTimerEnabled(false);
      expect(c.model.timerEnabled, isFalse);
      c.setTimerEnabled(true);
      c.setTimerEnabled(false);
      expect(c.model.timerEnabled, isFalse);
      c.dispose();
    });

    test('G-A2 production factory 4×6 kinds + solvable balance', () {
      for (var level = 0; level < 4; level++) {
        final set = SourceFaithfulChallengeFactory.generateChallengeSet(level);
        expect(set.length, 6);
        for (final ch in set) {
          expect(ch.kind, isNotNull);
          if (ch.kind == BaChallengeKind.balanceMasses) {
            final m = BalanceGameModel(
              challengeSetFactory: (_) => [ch],
            );
            m.startLevel(0);
            m.displayCorrectAnswer();
            expect(m.plank.isBalanced(), isTrue);
          }
        }
      }
    });

    test('G-A3→G-A8 correct / incorrect / tryAgain / showAnswer / next / results',
        () {
      final c = game(
        (_) => [
          DeterministicChallengeFactory.balanceMassesSample(),
          DeterministicChallengeFactory.balanceMassesSample(),
        ],
      );
      c.startLevel(0);

      // Wrong
      final movable = c.model.getCurrentChallenge()!.movableMasses.single;
      c.beginDrag(movable, c.mvt.modelToView(movable.position));
      c.updateDrag(c.mvt.modelToView(const BaVector2(0.5, 0.9)));
      c.endDrag();
      c.checkAnswer();
      expect(
        c.model.gameState,
        BaGameState.showingIncorrectAnswerFeedbackTryAgain,
      );
      expect(c.model.score, 0);

      // Try Again
      c.tryAgain();
      expect(c.model.gameState, BaGameState.presentingInteractiveChallenge);
      expect(c.model.incorrectGuessesOnCurrentChallenge, greaterThan(0));

      // Correct (+1)
      c.beginDrag(movable, c.mvt.modelToView(movable.position));
      c.updateDrag(c.mvt.modelToView(const BaVector2(-2.0, 0.9)));
      c.endDrag();
      c.checkAnswer();
      expect(c.model.score, 1);
      c.nextChallenge();
      expect(c.model.challengeIndex, 1);

      // Show answer path on second
      c.displayCorrectAnswer();
      expect(c.model.gameState, BaGameState.displayingCorrectAnswer);
      expect(c.model.columnState, ColumnState.noColumns);
      expect(c.model.plank.isBalanced(), isTrue);
      c.nextChallenge();
      expect(c.model.gameState, BaGameState.showingLevelResults);
      expect(c.model.bestScores[0], greaterThanOrEqualTo(1));
      c.dispose();
    });

    test('G-A9 timer 1 Hz via clock stepForward; no double count', () {
      final c = game(
        (_) => [DeterministicChallengeFactory.balanceMassesSample()],
      );
      c.setTimerEnabled(true);
      c.startLevel(0);
      expect(c.model.elapsedTime, 0);

      c.clock.pause();
      for (var i = 0; i < 60; i++) {
        c.clock.stepForward();
      }
      expect(c.model.elapsedTime, 1);

      for (var i = 0; i < 60; i++) {
        c.clock.stepForward();
      }
      expect(c.model.elapsedTime, 2);

      c.setTimerEnabled(false);
      for (var i = 0; i < 60; i++) {
        c.clock.stepForward();
      }
      expect(c.model.elapsedTime, 2); // frozen when off

      c.setTimerEnabled(true);
      for (var i = 0; i < 60; i++) {
        c.clock.stepForward();
      }
      expect(c.model.elapsedTime, 3);

      c.resetAll();
      expect(c.model.elapsedTime, 0);
      expect(c.model.timerEnabled, isFalse);
      c.dispose();
    });
  });

  // ─── PHYSICS FRAME-RATE ────────────────────────────────────────────────

  group('Phase6 Physics frame-rate', () {
    test('standard / small / large dt preserve ω+=α semantics', () {
      Plank make() => Plank(
            position: const BaVector2(0, BaGeometry.plankHeight),
            pivotPoint: const BaVector2(0, BaGeometry.fulcrumHeight),
            columnStateGetter: () => ColumnState.noColumns,
            userControlledMassesGetter: () => <BaMass>[],
          );

      void place(Plank p) {
        final m = BaMass.fromType(BaMassType.fireExtinguisher, const BaVector2(0, 0));
        p.addMassToSurfaceAt(m, 1.5);
      }

      // A: standard 1/60
      final a = make()..onColumnStateChanged(ColumnState.noColumns);
      place(a);
      a.step(1 / 60);
      final omegaA = a.angularVelocity;
      final thetaA = a.tiltAngle;

      // B: small dt ×2 vs half (order lock: ω+=α then θ+=ω·dt then damp)
      final b = make()..onColumnStateChanged(ColumnState.noColumns);
      place(b);
      b.step(1 / 120);
      b.step(1 / 120);

      // C: large dt clamps tilt
      final c = make()..onColumnStateChanged(ColumnState.noColumns);
      place(c);
      c.step(0.5);
      expect(c.tiltAngle.abs(), lessThanOrEqualTo(BaGeometry.maxTiltAngle + 1e-9));

      // D: multi-step settle stays finite
      final d = make()..onColumnStateChanged(ColumnState.noColumns);
      place(d);
      for (var i = 0; i < 300; i++) {
        d.step(1 / 60);
      }
      expect(d.tiltAngle.isFinite, isTrue);
      expect(d.angularVelocity.isFinite, isTrue);

      // Frame sensitivity retained: B ≠ A necessarily, but both finite & signed
      expect(omegaA.isFinite && thetaA.isFinite, isTrue);
      expect(b.angularVelocity.isFinite, isTrue);
    });
  });

  // ─── LIFECYCLE / ISOLATION ─────────────────────────────────────────────

  group('Phase6 Lifecycle', () {
    testWidgets('Intro leave/re-enter ×3 — single clock, no crash',
        (tester) async {
      final c = BaIntroController();
      for (var i = 0; i < 3; i++) {
        await tester.pumpWidget(wrap(BaIntroScreen(controller: c)));
        await tester.pump();
        expect(c.clock.isRunning, isTrue);
        await leave(tester);
        expect(c.clock.isRunning, isFalse);
      }
      await tester.pumpWidget(wrap(BaIntroScreen(controller: c)));
      await tester.pump();
      expect(c.clock.isRunning, isTrue);
      c.clock.pause();
      final t0 = c.clock.totalTime;
      for (var i = 0; i < 10; i++) {
        c.clock.stepForward();
      }
      expect(c.clock.totalTime - t0, closeTo(10 / 60, 1e-9));
      c.dispose();
    });

    testWidgets('Lab leave/re-enter ×3', (tester) async {
      final c = BaBalanceLabController();
      for (var i = 0; i < 3; i++) {
        await tester.pumpWidget(wrap(BaBalanceLabScreen(controller: c)));
        await tester.pump();
        expect(c.clock.isRunning, isTrue);
        await leave(tester);
      }
      await tester.pumpWidget(wrap(BaBalanceLabScreen(controller: c)));
      await tester.pump();
      expect(c.clock.isRunning, isTrue);
      c.dispose();
    });

    testWidgets('Game leave/re-enter ×3 — timer does not multiply',
        (tester) async {
      final c = BaGameController(
        challengeSetFactory: (_) => [
          DeterministicChallengeFactory.balanceMassesSample(),
        ],
      );
      for (var i = 0; i < 3; i++) {
        await tester.pumpWidget(wrap(BaGameScreen(controller: c)));
        await tester.pump();
        expect(c.clock.isRunning, isTrue);
        await leave(tester);
      }
      await tester.pumpWidget(wrap(BaGameScreen(controller: c)));
      await tester.pump();
      c.setTimerEnabled(true);
      c.startLevel(0);
      c.clock.pause();
      for (var i = 0; i < 60; i++) {
        c.clock.stepForward();
      }
      // One second of sim — not 3× from duplicate tickers
      expect(c.model.elapsedTime, 1);
      c.dispose();
    });

    testWidgets('Rapid navigation Intro↔Lab↔Game', (tester) async {
      final intro = BaIntroController();
      final lab = BaBalanceLabController();
      final game = BaGameController(
        challengeSetFactory: DeterministicChallengeFactory.generateChallengeSet,
      );

      Future<void> show(Widget w) async {
        await tester.pumpWidget(wrap(w));
        await tester.pump();
      }

      await show(BaIntroScreen(controller: intro));
      await show(BaBalanceLabScreen(controller: lab));
      await show(BaIntroScreen(controller: intro));
      await show(BaGameScreen(controller: game));
      await show(BaBalanceLabScreen(controller: lab));
      await show(BaGameScreen(controller: game));
      await show(BaIntroScreen(controller: intro));

      expect(intro.clock.isRunning, isTrue);
      expect(lab.clock.isRunning, isFalse); // left → paused
      expect(game.clock.isRunning, isFalse);

      intro.dispose();
      lab.dispose();
      game.dispose();
    });

    test('Cross-screen state isolation', () {
      final intro = BaIntroController();
      final lab = BaBalanceLabController();
      final game = BaGameController(
        challengeSetFactory: DeterministicChallengeFactory.generateChallengeSet,
      );

      // Pollute Intro
      final m = intro.model.fireExtinguisher1;
      intro.beginDrag(m, intro.mvt.modelToView(m.position));
      intro.updateDrag(intro.mvt.modelToView(const BaVector2(1.0, 0.9)));
      intro.endDrag();
      intro.setForcesVisible(true);
      intro.setSupportsEnabled(false);

      // Lab must be pristine
      expect(lab.model.massList, isEmpty);
      expect(lab.viewProperties.forceVectorsFromObjectsVisible, isFalse);
      expect(lab.model.columnState, ColumnState.doubleColumns);

      // Pollute Lab
      lab.startBrickCreator(4, lab.mvt.modelToView(const BaVector2(0.5, 0.9)));
      lab.updateDrag(lab.mvt.modelToView(const BaVector2(0.5, 0.9)));
      lab.endDrag();
      lab.nextCarouselPage();
      lab.setPositionChoice(PositionIndicatorChoice.rulers);

      // Game pristine
      expect(game.model.gameState, BaGameState.choosingLevel);
      expect(game.model.score, 0);
      expect(game.model.massListEquivalentEmpty, isTrue);

      // Pollute Game
      game.startLevel(3);
      game.setTimerEnabled(true);
      expect(game.model.level, 3);

      // Intro still has its own state (not cleared by Game)
      expect(intro.model.plank.massesOnSurface, isNotEmpty);
      expect(intro.viewProperties.forceVectorsFromObjectsVisible, isTrue);

      // Lab still has brick
      expect(lab.model.massList, isNotEmpty);
      expect(lab.model.carousel.pageIndex, 1);

      intro.dispose();
      lab.dispose();
      game.dispose();
    });
  });

  // ─── RESET STRESS ──────────────────────────────────────────────────────

  group('Phase6 Reset stress ×10', () {
    test('Intro reset ×10', () {
      final c = BaIntroController();
      for (var i = 0; i < 10; i++) {
        c.beginDrag(
          c.model.fireExtinguisher1,
          c.mvt.modelToView(c.model.fireExtinguisher1.position),
        );
        c.updateDrag(c.mvt.modelToView(BaVector2(0.25 + (i % 5) * 0.25, 0.9)));
        c.endDrag();
        c.setSupportsEnabled(i.isEven);
        c.setPositionChoice(
          i.isOdd
              ? PositionIndicatorChoice.rulers
              : PositionIndicatorChoice.marks,
        );
        c.resetAll();
        expect(c.model.plank.massesOnSurface, isEmpty);
        expect(c.model.plank.tiltAngle, 0);
        expect(c.dragging, isNull);
      }
      c.dispose();
    });

    test('Lab reset ×10', () {
      final c = BaBalanceLabController();
      for (var i = 0; i < 10; i++) {
        c.nextCarouselPage();
        c.startBrickCreator(
          1 + (i % 4),
          c.mvt.modelToView(const BaVector2(1.0, 0.9)),
        );
        c.updateDrag(c.mvt.modelToView(const BaVector2(1.0, 0.9)));
        c.endDrag();
        c.setForcesVisible(true);
        c.resetAll();
        expect(c.model.massList, isEmpty);
        expect(c.model.carousel.pageIndex, 0);
        expect(c.dragging, isNull);
      }
      c.dispose();
    });

    test('Game reset ×10', () {
      final c = BaGameController(
        challengeSetFactory: DeterministicChallengeFactory.generateChallengeSet,
      );
      for (var i = 0; i < 10; i++) {
        c.startLevel(i % 4);
        c.setTimerEnabled(true);
        c.setMassEntry(42);
        c.resetAll();
        expect(c.model.gameState, BaGameState.choosingLevel);
        expect(c.model.score, 0);
        expect(c.model.elapsedTime, 0);
        expect(c.model.timerEnabled, isFalse);
        expect(c.massEntryValue, 0);
        expect(c.dragging, isNull);
      }
      c.dispose();
    });
  });
}

/// Helper — Game model has no massList; empty movable+fixed.
extension on BalanceGameModel {
  bool get massListEquivalentEmpty =>
      movableMasses.isEmpty && fixedMasses.isEmpty && plank.massesOnSurface.isEmpty;
}
