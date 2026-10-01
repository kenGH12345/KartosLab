import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_act/balancing_act.dart';

void main() {
  BaGameController gameController() => BaGameController(
        challengeSetFactory: DeterministicChallengeFactory.generateChallengeSet,
      );

  testWidgets('Game screen shows level select initially', (tester) async {
    final c = gameController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: BaGameScreen(controller: c),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('ba_game_viewport')), findsOneWidget);
    expect(find.text(BaStrings.selectLevel), findsOneWidget);
    expect(find.byKey(const Key('ba_game_level_0')), findsOneWidget);
    expect(c.model.gameState, BaGameState.choosingLevel);
    expect(c.mvt.scale, BaSharedConstants.gameMvtScale);
    c.dispose();
  });

  testWidgets('select level starts challenge', (tester) async {
    final c = gameController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: BaGameScreen(controller: c),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('ba_game_level_0')));
    await tester.pump();
    expect(c.model.gameState, BaGameState.presentingInteractiveChallenge);
    expect(find.byKey(const Key('ba_game_status_bar')), findsOneWidget);
    expect(find.byKey(const Key('ba_game_check')), findsOneWidget);
    c.dispose();
  });

  test('controller balance flow: place → check → next', () {
    final c = BaGameController(
      challengeSetFactory: (_) => [
        DeterministicChallengeFactory.balanceMassesSample(),
      ],
    );
    c.startLevel(0);
    final movable = c.model.getCurrentChallenge()!.movableMasses.single;
    c.beginDrag(movable, c.mvt.modelToView(movable.position));
    c.updateDrag(c.mvt.modelToView(const BaVector2(-2.0, 0.9)));
    c.endDrag();
    expect(movable.onPlank, isTrue);
    expect(c.canCheckAnswer, isTrue);
    c.checkAnswer();
    expect(c.model.gameState, BaGameState.showingCorrectAnswerFeedback);
    expect(c.model.score, 2);
    expect(c.audio.eventLog, contains('correctAnswer'));
    c.nextChallenge();
    expect(c.model.gameState, BaGameState.showingLevelResults);
    // Single challenge × 2 pts ≠ perfect 12 → imperfect
    expect(c.audio.eventLog, contains('gameOverImperfectScore'));
    c.dispose();
  });

  test('wrong → tryAgain → correct earns 1', () {
    final c = BaGameController(
      challengeSetFactory: (_) => [
        DeterministicChallengeFactory.balanceMassesSample(),
      ],
    );
    c.startLevel(0);
    final movable = c.model.getCurrentChallenge()!.movableMasses.single;
    c.beginDrag(movable, c.mvt.modelToView(movable.position));
    c.updateDrag(c.mvt.modelToView(const BaVector2(0.5, 0.9)));
    c.endDrag();
    c.checkAnswer();
    expect(
      c.model.gameState,
      BaGameState.showingIncorrectAnswerFeedbackTryAgain,
    );
    expect(c.audio.eventLog, contains('wrongAnswer'));
    c.tryAgain();
    expect(c.model.gameState, BaGameState.presentingInteractiveChallenge);
    c.beginDrag(movable, c.mvt.modelToView(movable.position));
    c.updateDrag(c.mvt.modelToView(const BaVector2(-2.0, 0.9)));
    c.endDrag();
    c.checkAnswer();
    expect(c.model.score, 1);
    c.dispose();
  });

  test('displayCorrectAnswer places solution', () {
    final c = BaGameController(
      challengeSetFactory: (_) => [
        DeterministicChallengeFactory.balanceMassesSample(),
      ],
    );
    c.startLevel(0);
    c.displayCorrectAnswer();
    expect(c.model.gameState, BaGameState.displayingCorrectAnswer);
    expect(c.model.plank.isBalanced(), isTrue);
    c.dispose();
  });

  test('mass deduction answer via entry', () {
    final c = BaGameController(
      challengeSetFactory: (_) => [
        DeterministicChallengeFactory.massDeductionSample(),
      ],
    );
    c.startLevel(0);
    c.setMassEntry(15);
    c.checkAnswer();
    expect(c.model.score, 2);
    c.dispose();
  });

  test('tilt prediction answer', () {
    final c = BaGameController(
      challengeSetFactory: (_) => [
        DeterministicChallengeFactory.tiltPredictionSample(),
      ],
    );
    c.startLevel(0);
    c.setTiltPrediction(TiltPredictionState.tiltDownOnRightSide);
    expect(c.canCheckAnswer, isTrue);
    c.checkAnswer();
    expect(c.model.score, 2);
    c.dispose();
  });

  testWidgets('tilt selector sits above plank (source bottom @ plankH+0.8)',
      (tester) async {
    final c = BaGameController(
      challengeSetFactory: (_) => [
        DeterministicChallengeFactory.tiltPredictionSample(),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 768,
            height: 504,
            child: BaGameScreen(controller: c),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('ba_game_level_0')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byKey(const Key('ba_game_tilt_selector')), findsOneWidget);
    final tiltBox =
        tester.getRect(find.byKey(const Key('ba_game_tilt_selector')));
    final expectedBottom = c.mvt.modelToViewY(BaGeometry.plankHeight + 0.8);
    // Bottom of selector aligns near source model Y (allow ±30px chrome pad).
    expect(tiltBox.bottom, closeTo(expectedBottom, 30));
    // Must not sit in the ground/button band (model Y ≤ 0).
    expect(tiltBox.bottom, lessThan(c.mvt.modelToViewY(0)));
    c.dispose();
  });

  testWidgets('mass entry sits under title, not at ground', (tester) async {
    final c = BaGameController(
      challengeSetFactory: (_) => [
        DeterministicChallengeFactory.massDeductionSample(),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 768,
            height: 504,
            child: BaGameScreen(controller: c),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('ba_game_level_0')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byKey(const Key('ba_game_mass_entry')), findsOneWidget);
    final entryTop =
        tester.getTopLeft(find.byKey(const Key('ba_game_mass_entry'))).dy;
    // Under title (~top 100), well above ground (model Y 0 ≈ 433).
    expect(entryTop, lessThan(200));
    expect(entryTop, lessThan(c.mvt.modelToViewY(0) - 100));
    c.dispose();
  });

  test('resetAll returns to choosingLevel', () {
    final c = gameController();
    c.startLevel(2);
    c.setTimerEnabled(true);
    c.resetAll();
    expect(c.model.gameState, BaGameState.choosingLevel);
    expect(c.model.score, 0);
    expect(c.model.timerEnabled, isFalse);
    c.dispose();
  });

  testWidgets('lifecycle leave/re-enter rebinds ticker', (tester) async {
    final c = gameController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: BaGameScreen(controller: c),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(c.clock.isRunning, isTrue);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
    );
    await tester.pump();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: BaGameScreen(controller: c),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(c.clock.isRunning, isTrue);
    c.model.step(1 / 60);
    c.dispose();
  });

  test('Game MVT scale is 115 with game origin', () {
    final c = gameController();
    expect(c.mvt.scale, 115);
    expect(c.mvt.originInView.dx, closeTo(768 * 0.45, 0.01));
    expect(c.mvt.originInView.dy, closeTo(504 * 0.86, 0.01));
    c.dispose();
  });

  test('audio hooks fire on level complete imperfect', () {
    final c = BaGameController(
      challengeSetFactory: (_) => [
        DeterministicChallengeFactory.balanceMassesSample(),
        DeterministicChallengeFactory.balanceMassesSample(),
      ],
    );
    c.startLevel(0);
    // Fail first challenge via show-answer path (0 points)
    c.model.incorrectGuessesOnCurrentChallenge = 2;
    c.model.gameState = BaGameState.showingIncorrectAnswerFeedbackMoveOn;
    c.displayCorrectAnswer();
    c.nextChallenge();
    // Score second challenge correctly (+2) → imperfect total
    final movable = c.model.getCurrentChallenge()!.movableMasses.single;
    c.beginDrag(movable, c.mvt.modelToView(movable.position));
    c.updateDrag(c.mvt.modelToView(const BaVector2(-2.0, 0.9)));
    c.endDrag();
    c.checkAnswer();
    expect(c.model.score, 2);
    c.nextChallenge();
    expect(c.model.gameState, BaGameState.showingLevelResults);
    expect(c.audio.eventLog, contains('gameOverImperfectScore'));
    c.dispose();
  });
}
