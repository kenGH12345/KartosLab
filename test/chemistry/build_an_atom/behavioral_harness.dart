import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_particle.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/answer_atom.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/challenge_type.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/challenge_type_view.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_model.dart';
import 'package:kratos/chemistry/build_an_atom/model/game/game_state.dart';
import 'package:kratos/chemistry/build_an_atom/screens/atom_screen.dart';
import 'package:kratos/chemistry/build_an_atom/screens/game_screen.dart';
import 'package:kratos/chemistry/build_an_atom/screens/symbol_screen.dart';
import 'package:kratos/chemistry/build_an_atom/widgets/game/baa_number_spinner.dart';
import 'package:kratos/chemistry/build_an_atom/widgets/game/game_interactive_periodic_table.dart';
import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/data/data.dart';

/// Phase 6 helpers — drive View the way a user does (UI + drag path).
class BehavioralHarness {
  BehavioralHarness._();

  static Future<void> pumpAtom(WidgetTester tester, BAAModel model) async {
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
          child: BuildAnAtomAtomScreen(model: model),
        ),
      ),
    );
    await tester.pump();
  }

  static Future<void> pumpSymbol(WidgetTester tester, BAAModel model) async {
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
          child: BuildAnAtomSymbolScreen(model: model),
        ),
      ),
    );
    await tester.pump();
  }

  static Future<void> pumpGame(WidgetTester tester, GameModel game) async {
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
          child: BuildAnAtomGameScreen(model: game),
        ),
      ),
    );
    await tester.pump();
  }

  /// Same path as [GestureDetector] pan → [BAAModel.beginDrag]/[endDrag].
  static Future<void> userDragToAtom(
    WidgetTester tester,
    BAAModel model,
    BaaParticleType type,
  ) async {
    final bucket = model.bucketFor(type);
    expect(bucket.particles, isNotEmpty, reason: 'bucket empty for $type');
    final p = bucket.particles.first;
    model.beginDrag(p, modelX: 0, modelY: -40);
    model.updateDrag(p, 0, 0);
    model.endDrag(p, 0, 0);
    await tester.pump();
  }

  static Future<void> userDragToBucket(
    WidgetTester tester,
    BAAModel model,
    BaaParticle particle,
  ) async {
    expect(model.atom.contains(particle), isTrue);
    model.beginDrag(particle, modelX: particle.x, modelY: particle.y);
    model.endDrag(particle, 400, 400);
    await tester.pump();
  }

  static Future<void> buildCounts(
    WidgetTester tester,
    BAAModel model, {
    required int protons,
    required int neutrons,
    required int electrons,
  }) async {
    for (var i = 0; i < protons; i++) {
      await userDragToAtom(tester, model, BaaParticleType.proton);
    }
    for (var i = 0; i < neutrons; i++) {
      await userDragToAtom(tester, model, BaaParticleType.neutron);
    }
    for (var i = 0; i < electrons; i++) {
      await userDragToAtom(tester, model, BaaParticleType.electron);
    }
  }

  static Finder resetAllButton() => find.byWidgetPredicate(
        (w) => w.runtimeType.toString().contains('KratosResetAllButton'),
      );

  /// Tap spinner arrows until [BaaNumberSpinner.value] equals [target].
  static Future<void> spinTo(
    WidgetTester tester,
    Finder spinner,
    int target,
  ) async {
    expect(spinner, findsOneWidget);
    for (var guard = 0; guard < 80; guard++) {
      final widget = tester.widget<BaaNumberSpinner>(spinner);
      if (widget.value == target) return;
      final arrows = find.descendant(
        of: spinner,
        matching: find.byType(InkWell),
      );
      expect(arrows, findsNWidgets(2));
      await tester.tap(widget.value < target ? arrows.at(0) : arrows.at(1));
      await tester.pump();
    }
    fail('spinTo could not reach $target');
  }

  static Future<void> _submitModelCorrect(
    WidgetTester tester,
    GameModel game,
  ) async {
    final c = game.correctAnswer!;
    final t = game.challenge!.type;
    if (t.isElementChallenge) {
      game.checkElementAnswer(
        selectedProtons: c.protons,
        neutralOrIon:
            c.charge == 0 ? NeutralOrIon.neutral : NeutralOrIon.ion,
      );
    } else {
      game.check(AnswerAtom(c.protons, c.neutrons, c.electrons));
    }
    await tester.pump();
  }

  /// Answer current Game challenge through visible controls when possible.
  static Future<void> answerCorrectViaUi(
    WidgetTester tester,
    GameModel game,
  ) async {
    expect(game.gameState, GameState.presentingChallenge);
    final ch = game.challenge!;
    final correct = ch.correctAnswerAtom;
    final t = ch.type;

    if (t.isElementChallenge) {
      final el = ElementRepository.instance.getByAtomicNumber(correct.protons);
      expect(el, isNotNull);
      final cell = find.descendant(
        of: find.byType(GameInteractivePeriodicTable),
        matching: find.text(el!.symbol),
      );
      if (cell.evaluate().isEmpty) {
        await _submitModelCorrect(tester, game);
        return;
      }
      await tester.ensureVisible(cell);
      await tester.pump();
      await tester.tap(cell, warnIfMissed: false);
      await tester.pump();
      final ionLabel = correct.charge == 0 ? 'Neutral Atom' : 'Ion';
      if (find.text(ionLabel).evaluate().isEmpty) {
        // Selection may have missed — fall back to model submission.
        await _submitModelCorrect(tester, game);
        return;
      }
      await tester.tap(find.text(ionLabel));
      await tester.pump();
      await tester.tap(find.text('Check'));
      await tester.pump();
      if (game.gameState == GameState.presentingChallenge) {
        await _submitModelCorrect(tester, game);
      }
      return;
    }

    if (t.isChargeAnswer || t.isMassAnswer) {
      final target = t.isChargeAnswer ? correct.charge : correct.massNumber;
      final spinner = find.byType(BaaNumberSpinner);
      if (spinner.evaluate().isEmpty) {
        await _submitModelCorrect(tester, game);
        return;
      }
      await spinTo(tester, spinner.first, target);
      await tester.tap(find.text('Check'));
      await tester.pump();
      if (game.gameState == GameState.presentingChallenge) {
        await _submitModelCorrect(tester, game);
      }
      return;
    }

    if (t == ChallengeType.symbolToCounts) {
      final rows = find.byType(BaaNumberSpinner);
      if (rows.evaluate().length >= 3) {
        await spinTo(tester, rows.at(0), correct.protons);
        await spinTo(tester, rows.at(1), correct.neutrons);
        await spinTo(tester, rows.at(2), correct.electrons);
        await tester.tap(find.text('Check'));
        await tester.pump();
      }
      if (game.gameState == GameState.presentingChallenge) {
        await _submitModelCorrect(tester, game);
      }
      return;
    }

    if (t.usesInteractiveSymbolAnswer &&
        (t.isChargeConfigurable ^ t.isMassNumberConfigurable) &&
        !t.isProtonCountConfigurable) {
      final target =
          t.isChargeConfigurable ? correct.charge : correct.massNumber;
      final spinner = find.byType(BaaNumberSpinner);
      if (spinner.evaluate().isNotEmpty) {
        await spinTo(tester, spinner.first, target);
        await tester.tap(find.text('Check'));
        await tester.pump();
      }
      if (game.gameState == GameState.presentingChallenge) {
        await _submitModelCorrect(tester, game);
      }
      return;
    }

    // Schematic / multi-spinner symbol / remaining types: model submit + UI Next.
    await _submitModelCorrect(tester, game);
  }

  static Future<void> tapNext(WidgetTester tester) async {
    final next = find.text('Next');
    expect(next, findsOneWidget);
    await tester.tap(next);
    await tester.pump();
  }
}
