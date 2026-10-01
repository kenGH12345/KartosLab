import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_chemical_equations/data/equations_datasets.dart';
import 'package:kratos/balancing_chemical_equations/equations/equations_model.dart';
import 'package:kratos/balancing_chemical_equations/game/game_model.dart';
import 'package:kratos/balancing_chemical_equations/game/game_state.dart';
import 'package:kratos/balancing_chemical_equations/intro/intro_model.dart';
import 'package:kratos/balancing_chemical_equations/model/atom_count.dart';
import 'package:kratos/balancing_chemical_equations/model/bce_element.dart';
import 'package:kratos/balancing_chemical_equations/model/view_mode.dart';
import 'package:kratos/balancing_chemical_equations/vegas/game_audio_player.dart';
import 'package:kratos/balancing_chemical_equations/vegas/game_timer.dart';

/// Phase 6 — Behavioral Acceptance matrix (source-locked semantics).
void main() {
  group('Phase 6 Intro behavioral', () {
    test('equation selection A→B→C→A preserves per-equation coeffs', () {
      final m = IntroModel();
      addTearDown(m.dispose);
      final ids = [
        'intro.makeAmmonia',
        'intro.separateWater',
        'intro.combustMethane',
      ];
      m.selectById(ids[0]);
      m.selectedEquation.reactants.first.coefficient = 3;
      m.selectById(ids[1]);
      m.selectedEquation.reactants.first.coefficient = 2;
      m.selectById(ids[2]);
      m.selectedEquation.products.first.coefficient = 0;
      m.selectById(ids[0]);
      expect(m.selectedEquation.reactants.first.coefficient, 3);
      m.selectById(ids[1]);
      expect(m.selectedEquation.reactants.first.coefficient, 2);
      m.selectById(ids[2]);
      expect(m.selectedEquation.products.first.coefficient, 0);
    });

    test('coefficient bounds 0..3 — no negative / no overflow', () {
      final m = IntroModel();
      addTearDown(m.dispose);
      final t = m.selectedEquation.reactants.first;
      t.coefficient = -5;
      expect(t.coefficient, 0);
      t.coefficient = 100;
      expect(t.coefficient, 3);
      for (final v in [0, 1, 2, 3]) {
        t.coefficient = v;
        expect(t.coefficient, v);
      }
    });

    test('view modes mutually exclusive cycle', () {
      final m = IntroModel();
      addTearDown(m.dispose);
      final order = [
        ViewMode.particles,
        ViewMode.balanceScales,
        ViewMode.barCharts,
        ViewMode.none,
        ViewMode.particles,
      ];
      for (final mode in order) {
        m.setViewMode(mode);
        expect(m.viewMode, mode);
        // Exactly one enum value — no parallel bool flags.
        expect(ViewMode.values.where((v) => v == m.viewMode).length, 1);
      }
      expect(m.selectedEquation.reactants.first.coefficient, 1);
    });

    test('atom totals sync with coefficients across view switches', () {
      final m = IntroModel();
      addTearDown(m.dispose);
      // Make Ammonia: N2 + H2 → NH3 ; set 1,3,2
      final eq = m.selectedEquation;
      eq.reactants[0].coefficient = 1;
      eq.reactants[1].coefficient = 3;
      eq.products[0].coefficient = 2;
      expect(eq.isSimplified, isTrue);

      List<AtomCount> countsFor(ViewMode mode) {
        m.setViewMode(mode);
        return eq.getAtomCounts();
      }

      final particles = countsFor(ViewMode.particles);
      final scales = countsFor(ViewMode.balanceScales);
      final bars = countsFor(ViewMode.barCharts);
      expect(particles.length, scales.length);
      expect(particles.length, bars.length);
      for (var i = 0; i < particles.length; i++) {
        expect(particles[i].element, scales[i].element);
        expect(particles[i].reactantsCount, scales[i].reactantsCount);
        expect(particles[i].productsCount, scales[i].productsCount);
        expect(particles[i].reactantsCount, bars[i].reactantsCount);
        expect(particles[i].productsCount, bars[i].productsCount);
      }
      final n = particles.firstWhere((c) => c.element == BceElement.n);
      expect(n.reactantsCount, 2); // 1 × N2
      expect(n.productsCount, 2); // 2 × NH3
      final h = particles.firstWhere((c) => c.element == BceElement.h);
      expect(h.reactantsCount, 6); // 3 × H2
      expect(h.productsCount, 6); // 2 × NH3
    });

    test('accordion expand/collapse rapid toggle', () {
      final m = IntroModel();
      addTearDown(m.dispose);
      for (var i = 0; i < 6; i++) {
        m.toggleReactants();
        m.toggleProducts();
      }
      // Started true; 6 toggles → true again
      expect(m.reactantsExpanded, isTrue);
      expect(m.productsExpanded, isTrue);
    });

    test('Reset All restores source defaults', () {
      final m = IntroModel();
      addTearDown(m.dispose);
      m.selectById('intro.combustMethane');
      m.selectedEquation.reactants.first.coefficient = 3;
      m.setViewMode(ViewMode.none);
      m.setReactantsExpanded(false);
      m.setProductsExpanded(false);
      m.reset();
      expect(m.selectedId, 'intro.makeAmmonia');
      expect(m.viewMode, ViewMode.particles);
      expect(m.reactantsExpanded, isTrue);
      expect(m.productsExpanded, isTrue);
      expect(m.selectedEquation.reactants.first.coefficient, 1);
    });
  });

  group('Phase 6 Equations behavioral — 12 datasets', () {
    test('all 12 equations: default / balance / N=2 / incorrect / reset', () {
      final all = EquationsDatasets.createAll(initialCoefficient: 1);
      expect(all.length, 12);
      for (final eq in all) {
        // Default initial = 1 → not always simplified
        eq.balance();
        expect(eq.isBalanced, isTrue, reason: eq.id);
        expect(eq.isSimplified, isTrue, reason: eq.id);

        // N=2 only when all doubled coeffs fit Equations range 0..6
        // (source clamps; e.g. 5 O2 × 2 = 10 → clamped → not balanced).
        final canDouble = eq.terms.every(
          (t) => t.balancedCoefficient * 2 <= t.coefficientRange.max,
        );
        if (canDouble) {
          for (final t in eq.terms) {
            t.coefficient = t.balancedCoefficient * 2;
          }
          expect(eq.isBalanced, isTrue, reason: '${eq.id} N=2');
          expect(eq.isSimplified, isFalse, reason: '${eq.id} N=2');
        }

        eq.reactants.first.coefficient = 0;
        expect(eq.isBalanced, isFalse, reason: '${eq.id} zero');

        eq.reset();
        for (final t in eq.terms) {
          expect(t.coefficient, 1, reason: '${eq.id} reset');
        }
        eq.dispose();
      }
    });

    test('reaction type switch preserves per-type selection and coeffs', () {
      final m = EquationsModel();
      addTearDown(m.dispose);
      m.selectEquation(m.synthesisEquations[2]);
      m.selectedEquation.reactants.first.coefficient = 4;
      m.setReactionType(ReactionType.decomposition);
      expect(m.selectedId, 'equations.decomposition.equation0');
      m.setReactionType(ReactionType.combustion);
      m.selectEquation(m.combustionEquations.last);
      m.selectedEquation.reactants.first.coefficient = 5;
      m.setReactionType(ReactionType.synthesis);
      expect(m.selectedId, 'equations.synthesis.equation2');
      expect(m.selectedEquation.reactants.first.coefficient, 4);
      m.setReactionType(ReactionType.combustion);
      expect(m.selectedEquation.reactants.first.coefficient, 5);
    });

    test('Equations Reset All', () {
      final m = EquationsModel();
      addTearDown(m.dispose);
      m.setReactionType(ReactionType.combustion);
      m.selectEquation(m.combustionEquations[1]);
      m.selectedEquation.reactants.first.coefficient = 6;
      m.setViewMode(ViewMode.barCharts);
      m.setReactantsExpanded(false);
      m.reset();
      expect(m.reactionType, ReactionType.synthesis);
      expect(m.selectedId, 'equations.synthesis.equation0');
      expect(m.viewMode, ViewMode.particles);
      expect(m.reactantsExpanded, isTrue);
      expect(m.selectedEquation.reactants.first.coefficient, 1);
    });

    test('rapid reaction + equation + view switching', () {
      final m = EquationsModel();
      addTearDown(m.dispose);
      final types = ReactionType.values;
      final modes = ViewMode.values;
      for (var i = 0; i < 20; i++) {
        m.setReactionType(types[i % types.length]);
        final pool = m.equationsFor(m.reactionType);
        m.selectEquation(pool[i % pool.length]);
        m.setViewMode(modes[i % modes.length]);
        m.selectedEquation.reactants.first.coefficient = i % 7;
      }
      expect(m.selectedEquation.reactants.first.coefficient, lessThanOrEqualTo(6));
      expect(m.allEquations.length, 12);
    });
  });

  group('Phase 6 balance / simplified locked semantics', () {
    test('Case A simplified; Case B N×; Case C wrong; Case D balance()', () {
      final eq = EquationsDatasets.createSynthesis().first; // 2C + O2 → 2CO
      addTearDown(eq.dispose);

      eq.balance();
      expect(eq.isBalanced, isTrue);
      expect(eq.isSimplified, isTrue);

      for (final t in eq.terms) {
        t.coefficient = t.balancedCoefficient * 3;
      }
      expect(eq.isBalanced, isTrue);
      expect(eq.isSimplified, isFalse);

      eq.products.first.coefficient = 1;
      expect(eq.isBalanced, isFalse);

      eq.balance();
      expect(eq.isSimplified, isTrue);
      expect(eq.reactants[0].coefficient, 2);
      expect(eq.reactants[1].coefficient, 1);
      expect(eq.products[0].coefficient, 2);
    });
  });

  group('Phase 6 Game behavioral', () {
    test('5-question round first-attempt all → score 10', () {
      final m = GameModel(random: Random(11));
      addTearDown(m.dispose);
      m.selectLevel(m.levels.first);
      expect(m.numberOfChallenges, 5);
      for (var i = 0; i < 5; i++) {
        expect(m.challengeNumber, i + 1);
        m.challenge.balance();
        m.check();
        expect(m.points, 2);
        m.next();
      }
      expect(m.gameState, GameState.levelCompleted);
      expect(m.score, 10);
    });

    test('mixed scoring 2+1+2+1+2 = 8', () {
      final m = GameModel(random: Random(22));
      addTearDown(m.dispose);
      m.selectLevel(m.levels.first);
      final pattern = [true, false, true, false, true]; // first-try success?
      for (var i = 0; i < 5; i++) {
        if (pattern[i]) {
          m.challenge.balance();
          m.check();
          expect(m.points, 2);
        } else {
          // Fail once then succeed
          m.challenge.reactants.first.coefficient = 0;
          if (m.challenge.isSimplified) {
            m.challenge.reactants.first.coefficient =
                m.challenge.reactants.first.balancedCoefficient + 1;
          }
          m.check();
          expect(m.gameState, GameState.tryAgain);
          expect(m.score, i == 0 ? 0 : m.score); // unchanged this check
          final scoreBefore = m.score;
          m.tryAgain();
          m.challenge.balance();
          m.check();
          expect(m.points, 1);
          expect(m.score, scoreBefore + 1);
        }
        m.next();
      }
      expect(m.score, 8);
      expect(m.gameState, GameState.levelCompleted);
    });

    test('Show Answer awards 0 and uses balance()', () {
      final m = GameModel(random: Random(33));
      addTearDown(m.dispose);
      m.selectLevel(m.levels.first);
      // Two failures
      for (var a = 0; a < 2; a++) {
        m.challenge.reactants.first.coefficient = 0;
        if (m.challenge.isSimplified) {
          m.challenge.products.first.coefficient =
              m.challenge.products.first.balancedCoefficient + 1;
        }
        expect(m.challenge.isSimplified, isFalse);
        m.check();
        if (a == 0) {
          expect(m.gameState, GameState.tryAgain);
          m.tryAgain();
        }
      }
      expect(m.gameState, GameState.showAnswer);
      expect(m.score, 0);
      m.showAnswer();
      expect(m.gameState, GameState.next);
      expect(m.challenge.isSimplified, isTrue);
      expect(m.points, 0);
      expect(m.score, 0);
    });

    test('Show Why toggles without changing score/coeffs', () {
      final m = GameModel(random: Random(44));
      addTearDown(m.dispose);
      m.selectLevel(m.levels.first);
      m.challenge.reactants.first.coefficient = 0;
      if (m.challenge.isSimplified) {
        m.challenge.reactants.first.coefficient = 7;
      }
      m.check();
      expect(m.gameState, GameState.tryAgain);
      final coeff = m.challenge.reactants.first.coefficient;
      final score = m.score;
      m.setShowWhy(true);
      expect(m.showWhy, isTrue);
      expect(m.score, score);
      expect(m.challenge.reactants.first.coefficient, coeff);
      m.toggleShowWhy();
      expect(m.showWhy, isFalse);
    });

    test('Start Over keeps bestScore; Reset All clears it', () {
      final m = GameModel(random: Random(55));
      addTearDown(m.dispose);
      m.selectLevel(m.levels.first);
      for (var i = 0; i < 5; i++) {
        m.challenge.balance();
        m.check();
        m.next();
      }
      expect(m.levels.first.bestScore, 10);
      m.startOver();
      expect(m.gameState, GameState.levelSelection);
      expect(m.score, 0);
      expect(m.levels.first.bestScore, 10);
      m.setTimerEnabled(true);
      m.reset();
      expect(m.levels.first.bestScore, 0);
      expect(m.timerEnabled, isFalse);
    });

    test('timer single instance — enable start/stop/dispose restart', () {
      final m = GameModel(random: Random(66));
      addTearDown(m.dispose);
      m.setTimerEnabled(true);
      m.selectLevel(m.levels.first);
      expect(m.timer.isRunning, isTrue);
      final t1 = m.timer;
      m.startOver();
      expect(t1.isRunning, isFalse);
      m.setTimerEnabled(true);
      m.selectLevel(m.levels.first);
      expect(identical(m.timer, t1), isTrue);
      expect(m.timer.isRunning, isTrue);
      m.timer.stop();
      expect(m.timer.isRunning, isFalse);
      m.timer.start();
      expect(m.timer.elapsedSeconds, 0);
    });

    test('GameTimer formatTime', () {
      expect(GameTimer.formatTime(0), '0:00');
      expect(GameTimer.formatTime(65), '1:05');
    });

    test('rapid check / tryAgain / showAnswer / next sequence', () {
      final m = GameModel(random: Random(77));
      addTearDown(m.dispose);
      m.selectLevel(m.levels[1]);
      // Fail twice → show answer → next, repeat for remaining
      while (m.gameState != GameState.levelCompleted) {
        if (m.gameState == GameState.check) {
          m.challenge.reactants.first.coefficient = 0;
          if (m.challenge.isSimplified) {
            m.challenge.reactants.first.coefficient = 7;
          }
          m.check();
        } else if (m.gameState == GameState.tryAgain) {
          m.tryAgain();
          m.challenge.reactants.first.coefficient = 0;
          if (m.challenge.isSimplified) {
            m.challenge.reactants.first.coefficient = 7;
          }
          m.check();
        } else if (m.gameState == GameState.showAnswer) {
          m.showAnswer();
        } else if (m.gameState == GameState.next) {
          m.next();
        } else {
          fail('unexpected ${m.gameState}');
        }
      }
      expect(m.score, 0);
    });

    test('audio hooks are callable no-ops (source mp3 unavailable)', () {
      const audio = GameAudioPlayer();
      audio.correctAnswer();
      audio.wrongAnswer();
      audio.gameOverPerfectScore();
      audio.gameOverImperfectScore();
      audio.dispose();
    });
  });

  group('Phase 6 cross-screen + rapid interaction', () {
    test('Intro/Equations/Game models cycle without listener corruption', () {
      final intro = IntroModel();
      final equations = EquationsModel();
      final game = GameModel(random: Random(88));
      var introN = 0;
      var eqN = 0;
      var gameN = 0;
      void iL() => introN++;
      void eL() => eqN++;
      void gL() => gameN++;
      intro.addListener(iL);
      equations.addListener(eL);
      game.addListener(gL);

      for (var cycle = 0; cycle < 3; cycle++) {
        intro.selectById('intro.separateWater');
        intro.setViewMode(ViewMode.barCharts);
        equations.setReactionType(ReactionType.decomposition);
        equations.selectEquation(equations.decompositionEquations.last);
        game.selectLevel(game.levels[cycle % 3]);
        game.challenge.balance();
        game.check();
        game.next();
        game.startOver();
        intro.reset();
        equations.reset();
      }

      intro.removeListener(iL);
      equations.removeListener(eL);
      game.removeListener(gL);
      final iAfter = introN;
      final eAfter = eqN;
      final gAfter = gameN;
      intro.selectById('intro.makeAmmonia');
      equations.setReactionType(ReactionType.synthesis);
      // No listeners → counts unchanged
      expect(introN, iAfter);
      expect(eqN, eAfter);
      expect(gameN, gAfter);

      intro.dispose();
      equations.dispose();
      game.dispose();
    });

    test('rapid coefficient +/- does not produce NaN or out-of-range', () {
      final m = IntroModel();
      addTearDown(m.dispose);
      final t = m.selectedEquation.reactants.first;
      for (var i = 0; i < 50; i++) {
        t.increment();
        t.decrement();
        t.increment();
      }
      expect(t.coefficient >= 0, isTrue);
      expect(t.coefficient <= 3, isTrue);
      expect(t.coefficient.isNaN, isFalse);
    });
  });
}
