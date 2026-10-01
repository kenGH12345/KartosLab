import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_chemical_equations/equations/equations_model.dart';
import 'package:kratos/balancing_chemical_equations/equations/equations_screen.dart';
import 'package:kratos/balancing_chemical_equations/bce_constants.dart';
import 'package:kratos/balancing_chemical_equations/game/bce_reward_node.dart';
import 'package:kratos/balancing_chemical_equations/game/game_model.dart';
import 'package:kratos/balancing_chemical_equations/game/game_screen.dart';
import 'package:kratos/balancing_chemical_equations/game/game_state.dart';
import 'package:kratos/balancing_chemical_equations/intro/intro_model.dart';
import 'package:kratos/balancing_chemical_equations/intro/intro_screen.dart';
import 'package:kratos/balancing_chemical_equations/model/view_mode.dart';
import 'package:kratos/balancing_chemical_equations/views/balance_scales_node.dart';
import 'package:kratos/balancing_chemical_equations/views/bar_charts_node.dart';
import 'package:kratos/balancing_chemical_equations/views/bce_molecule_node.dart';
import 'package:kratos/balancing_chemical_equations/views/particles_node.dart';
import 'package:kratos/balancing_chemical_equations/views/view_combo_box.dart';
import 'package:kratos/balancing_chemical_equations/model/bce_molecule.dart';

Future<void> _pump768(WidgetTester tester, Widget child) async {
  await tester.binding.setSurfaceSize(const Size(900, 600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 768, height: 504, child: child),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('Visual QA — Intro', () {
    testWidgets('default Particles at 768×504', (tester) async {
      final m = IntroModel();
      addTearDown(m.dispose);
      await _pump768(tester, IntroScreen(model: m));
      expect(find.byType(ParticlesNode), findsOneWidget);
      expect(find.byType(ViewComboBox), findsOneWidget);
      expect(find.text('Make Ammonia'), findsOneWidget);
    });

    testWidgets('each Intro equation + view modes', (tester) async {
      final m = IntroModel();
      addTearDown(m.dispose);
      await _pump768(tester, IntroScreen(model: m));
      for (final id in [
        'intro.makeAmmonia',
        'intro.separateWater',
        'intro.combustMethane',
      ]) {
        m.selectById(id);
        await tester.pump();
        expect(m.selectedId, id);
      }
      m.setViewMode(ViewMode.balanceScales);
      await tester.pump();
      expect(find.byType(BalanceScalesNode), findsOneWidget);
      m.setViewMode(ViewMode.barCharts);
      await tester.pump();
      expect(find.byType(BarChartsNode), findsOneWidget);
      m.setViewMode(ViewMode.none);
      await tester.pump();
      expect(find.byType(ParticlesNode), findsNothing);
    });
  });

  group('Visual QA — Equations', () {
    testWidgets('default synthesis chrome', (tester) async {
      final m = EquationsModel();
      addTearDown(m.dispose);
      await _pump768(tester, EquationsScreen(model: m));
      expect(find.text('Synthesis'), findsOneWidget);
      expect(find.byType(ParticlesNode), findsOneWidget);
    });

    testWidgets('balanced feedback appears', (tester) async {
      final m = EquationsModel();
      addTearDown(m.dispose);
      await _pump768(tester, EquationsScreen(model: m));
      m.selectedEquation.balance();
      await tester.pump();
      expect(find.text('Balanced'), findsOneWidget);
      expect(find.text('Simplified'), findsOneWidget);
    });
  });

  group('Visual QA — Game', () {
    testWidgets('level selection + play + reward on perfect', (tester) async {
      final m = GameModel(random: Random(99));
      addTearDown(m.dispose);
      await _pump768(tester, GameScreen(model: m));
      expect(find.text('Choose Your Level!'), findsOneWidget);

      m.selectLevel(m.levels.first);
      await tester.pump();
      expect(find.text('Check'), findsOneWidget);

      for (var i = 0; i < 5; i++) {
        m.challenge.balance();
        m.check();
        await tester.pump();
        m.next();
        await tester.pump();
      }
      expect(m.gameState, GameState.levelCompleted);
      expect(m.isPerfectScore(), isTrue);
      expect(find.byType(BceRewardNode), findsOneWidget);
      expect(find.text('Perfect Score!'), findsOneWidget);
    });
  });

  group('Molecule geometry', () {
    test('nitroglycerin-aligned H2O / NH3 layouts non-empty', () {
      final h2o = BceMoleculeNode.layoutsFor(BceMolecule.h2o);
      expect(h2o.length, 3);
      final nh3 = BceMoleculeNode.layoutsFor(BceMolecule.nh3);
      expect(nh3.length, 4);
      // N should be present (largest atom among NH3)
      expect(nh3.any((a) => a.element.symbol == 'N'), isTrue);
      // Atom diameter must match nitroglycerin/RPL (no *100 blow-up → blue "blocks")
      final n = nh3.firstWhere((a) => a.element.symbol == 'N');
      expect(n.diameter, lessThan(40), reason: 'N diameter ~18px, not ~1800');
      expect(n.diameter, greaterThan(10));
      final nh3Size = BceMoleculeNode.layoutSize(
        BceMolecule.nh3,
        scale: BceConstants.particlesScaleFactor,
      );
      expect(nh3Size.width, lessThan(80));
      expect(nh3Size.height, lessThan(80));
    });

    test('Intro + Equations molecules have layouts', () {
      final ids = [
        BceMolecule.n2,
        BceMolecule.h2,
        BceMolecule.nh3,
        BceMolecule.h2o,
        BceMolecule.o2,
        BceMolecule.ch4,
        BceMolecule.co2,
        BceMolecule.c,
        BceMolecule.co,
        BceMolecule.n2o5,
        BceMolecule.p2o5,
        BceMolecule.c2h5Oh,
      ];
      for (final m in ids) {
        expect(BceMoleculeNode.layoutsFor(m), isNotEmpty, reason: m.id);
      }
    });
  });

  group('Cross-screen lifecycle', () {
    testWidgets('Intro → Equations → Game → dispose without leak', (tester) async {
      final intro = IntroModel();
      final equations = EquationsModel();
      final game = GameModel(random: Random(1));

      await _pump768(tester, IntroScreen(model: intro));
      await tester.pump();
      await _pump768(tester, EquationsScreen(model: equations));
      await tester.pump();
      await _pump768(tester, GameScreen(model: game));
      game.selectLevel(game.levels.first);
      await tester.pump();
      game.startOver();
      await tester.pump();
      game.selectLevel(game.levels.first);
      await tester.pump();
      game.startOver();
      await tester.pump();

      // Re-enter Intro
      await _pump768(tester, IntroScreen(model: intro));
      await tester.pump();

      intro.dispose();
      equations.dispose();
      game.dispose();
      // No pending timers from disposed GameTimer / Reward
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('Game enter/exit/re-enter does not duplicate reward ticker',
        (tester) async {
      final m = GameModel(random: Random(2));
      addTearDown(m.dispose);
      for (var cycle = 0; cycle < 3; cycle++) {
        await _pump768(tester, GameScreen(model: m));
        m.selectLevel(m.levels[2]);
        await tester.pump();
        for (var i = 0; i < 5; i++) {
          m.challenge.balance();
          m.check();
          m.next();
        }
        await tester.pump();
        expect(m.gameState, GameState.levelCompleted);
        // Reward present then leave
        expect(find.byType(BceRewardNode), findsOneWidget);
        m.startOver();
        await tester.pump();
        expect(find.byType(BceRewardNode), findsNothing);
      }
    });
  });
}
