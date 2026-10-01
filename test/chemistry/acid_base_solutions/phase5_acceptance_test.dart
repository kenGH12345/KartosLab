import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_constants.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_math.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_particle_field.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_view_properties.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/intro_model.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/my_solution_model.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/particle_count.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/particle_key.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/solutions/aqueous_solution.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/abs_concentration_graph.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/abs_reaction_equation.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/intro_controller.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/intro_screen.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/my_solution_controller.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/my_solution_screen.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

/// Phase 5 - Final Behavioral Acceptance (no production UI/chemistry changes).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Map<ParticleKey, int> countByKey(List<AbsParticleInstance> particles) {
    final m = <ParticleKey, int>{};
    for (final p in particles) {
      m[p.key] = (m[p.key] ?? 0) + 1;
    }
    return m;
  }

  Map<ParticleKey, int> expectedCounts(AqueousSolution s) {
    final m = <ParticleKey, int>{};
    for (final p in s.particles) {
      if (p.key == ParticleKey.h2o) continue;
      final n = absParticleCount(p.getConcentration());
      if (n > 0) m[p.key] = n;
    }
    return m;
  }

  void dipMeter(IntroController c) {
    c.model.pHMeter.position = Offset(
      c.model.pHMeter.position.dx,
      c.model.beaker.top + 20,
    );
  }

  void dipMeterMs(MySolutionController c) {
    c.model.pHMeter.position = Offset(
      c.model.pHMeter.position.dx,
      c.model.beaker.top + 20,
    );
  }

  void dipTester(dynamic model) {
    final t = model.conductivityTester;
    final y = model.beaker.top + 25;
    t.positiveProbePosition = Offset(t.positiveProbePosition.dx, y);
    t.negativeProbePosition = Offset(t.negativeProbePosition.dx, y);
  }

  group('Phase 5 Intro - solutions', () {
    test('I-1 Water oracle + particles + tools', () {
      final c = IntroController(random: Random(1));
      expect(c.model.solution, same(c.model.water));
      expect(c.model.pH, 7);
      expect(c.model.water.getH3OConcentration(), closeTo(1e-7, 1e-20));
      expect(c.model.water.getOHConcentration(), closeTo(1e-7, 1e-20));
      expect(countByKey(c.particles), expectedCounts(c.model.water));

      dipMeter(c);
      expect(c.model.pHMeter.displayedPH, 7);
      dipTester(c.model);
      expect(c.model.conductivityTester.brightness, 0);
      c.dispose();
    });

    test('I-2 Strong Acid concentrations 1e-3..1', () {
      final c = IntroController(random: Random(2));
      c.selectSolution(c.model.strongAcid);
      for (final conc in [1e-3, 1e-2, 1e-1, 1.0]) {
        c.model.strongAcid.concentration = conc;
        c.selectSolution(c.model.water);
        c.selectSolution(c.model.strongAcid);
        expect(c.model.pH, AbsMath.pHFromH3O(conc));
        expect(countByKey(c.particles), expectedCounts(c.model.strongAcid));
        dipMeter(c);
        expect(c.model.pHMeter.displayedPH, c.model.pH);
        dipTester(c.model);
        expect(c.model.conductivityTester.brightness, greaterThan(0));
      }
      c.dispose();
    });

    test('I-3 Weak Acid strength x concentration matrix', () {
      final c = IntroController(random: Random(3));
      c.selectSolution(c.model.weakAcid);
      for (final ka in [1e-10, 1e-7, 1e2]) {
        for (final conc in [1e-3, 1e-2, 1.0]) {
          c.model.weakAcid.strength = ka;
          c.model.weakAcid.concentration = conc;
          c.selectSolution(c.model.water);
          c.selectSolution(c.model.weakAcid);
          final h3o = c.model.weakAcid.getH3OConcentration();
          expect(c.model.pH, AbsMath.pHFromH3O(h3o));
          expect(countByKey(c.particles), expectedCounts(c.model.weakAcid));
          expect(c.model.pH, inInclusiveRange(0, 14));
        }
      }
      c.dispose();
    });

    test('I-4 Strong Base concentrations', () {
      final c = IntroController(random: Random(4));
      c.selectSolution(c.model.strongBase);
      for (final conc in [1e-3, 1e-2, 1.0]) {
        c.model.strongBase.concentration = conc;
        c.selectSolution(c.model.water);
        c.selectSolution(c.model.strongBase);
        expect(c.model.pH, greaterThan(7));
        expect(countByKey(c.particles), expectedCounts(c.model.strongBase));
        dipTester(c.model);
        expect(c.model.conductivityTester.brightness, greaterThan(0));
      }
      c.dispose();
    });

    test('I-5 Weak Base strength x concentration', () {
      final c = IntroController(random: Random(5));
      c.selectSolution(c.model.weakBase);
      for (final kb in [1e-10, 1e-7, 1e2]) {
        for (final conc in [1e-3, 1.0]) {
          c.model.weakBase.strength = kb;
          c.model.weakBase.concentration = conc;
          c.selectSolution(c.model.water);
          c.selectSolution(c.model.weakBase);
          expect(c.model.pH, greaterThan(7));
          expect(countByKey(c.particles), expectedCounts(c.model.weakBase));
        }
      }
      c.dispose();
    });
  });

  group('Phase 5 Intro - controls / tools', () {
    test('Views cycle without particle regen', () {
      final c = IntroController(random: Random(6));
      c.selectSolution(c.model.weakAcid);
      final snap = c.particles;
      c.setViewMode(AbsViewMode.graph);
      c.setViewMode(AbsViewMode.hideViews);
      c.setViewMode(AbsViewMode.particles);
      expect(identical(c.particles, snap), isTrue);
      expect(c.viewProperties.viewMode, AbsViewMode.particles);
      c.dispose();
    });

    test('pH meter tracks solution / concentration changes', () {
      final c = IntroController(random: Random(7));
      c.selectSolution(c.model.strongAcid);
      dipMeter(c);
      expect(c.model.pHMeter.displayedPH, 2);
      c.model.strongAcid.concentration = 1e-3;
      c.selectSolution(c.model.water);
      c.selectSolution(c.model.strongAcid);
      dipMeter(c);
      expect(c.model.pHMeter.displayedPH, 3);
      c.selectSolution(c.model.strongBase);
      dipMeter(c);
      expect(c.model.pHMeter.displayedPH, c.model.pH);
      c.dispose();
    });

    test('pH paper float 250 px/s then reset clears animation', () {
      final c = IntroController(random: Random(8));
      c.setToolMode(AbsToolMode.pHPaper);
      final paper = c.model.pHPaper;
      paper.position = Offset(
        c.model.beaker.position.dx,
        c.model.beaker.bottom - 5,
      );
      final y0 = paper.position.dy;
      c.paperPressed = false;
      c.step(0.1);
      expect(y0 - paper.position.dy, closeTo(25, 1e-6));
      c.resetAll();
      expect(c.model.pHPaper.animating, isFalse);
      expect(c.viewProperties.toolMode, AbsToolMode.pHMeter);
      c.setToolMode(AbsToolMode.pHPaper);
      paper.position = Offset(
        c.model.beaker.position.dx,
        c.model.beaker.bottom - 5,
      );
      final y1 = paper.position.dy;
      c.step(0.05);
      expect(y1 - paper.position.dy, closeTo(12.5, 1e-6));
      c.dispose();
    });

    test('conductivity acid/base >0, water neutral =0', () {
      final c = IntroController(random: Random(9));
      dipTester(c.model);
      expect(c.model.conductivityTester.brightness, 0);
      c.selectSolution(c.model.strongAcid);
      dipTester(c.model);
      expect(c.model.conductivityTester.brightness, greaterThan(0));
      c.selectSolution(c.model.strongBase);
      dipTester(c.model);
      expect(c.model.conductivityTester.brightness, greaterThan(0));
      c.selectSolution(c.model.water);
      dipTester(c.model);
      expect(c.model.conductivityTester.brightness, 0);
      c.dispose();
    });
  });

  group('Phase 5 Particles / Graph / Equation', () {
    test('P-A1 counts match for all five Intro solutions', () {
      final c = IntroController(random: Random(10));
      for (final s in c.model.solutions) {
        c.selectSolution(s);
        expect(countByKey(c.particles), expectedCounts(s));
      }
      c.dispose();
    });

    test('P-A2 species keys subset of solution particles (no H2O canvas)', () {
      final c = IntroController(random: Random(11));
      for (final s in c.model.solutions) {
        c.selectSolution(s);
        final allowed = s.particles.map((p) => p.key).toSet()
          ..remove(ParticleKey.h2o);
        for (final p in c.particles) {
          expect(allowed.contains(p.key), isTrue);
        }
      }
      c.dispose();
    });

    test('P-A3 rebuild notify keeps positions', () {
      final c = IntroController(random: Random(12));
      c.selectSolution(c.model.weakAcid);
      final a = List.of(c.particles);
      c.notifyModelChanged();
      c.notifyModelChanged();
      final b = c.particles;
      expect(a.length, b.length);
      for (var i = 0; i < a.length; i++) {
        expect(a[i].position, b[i].position);
        expect(a[i].key, b[i].key);
      }
      c.dispose();
    });

    test('P-A4 solution change regenerates population', () {
      final c = IntroController(random: Random(13));
      final water = List.of(c.particles);
      c.selectSolution(c.model.strongAcid);
      expect(identical(c.particles, water), isFalse);
      expect(countByKey(c.particles), isNot(countByKey(water)));
      c.dispose();
    });

    test('Graph values come from model concentrations', () {
      final c = IntroController(random: Random(14));
      c.selectSolution(c.model.strongAcid);
      final h3o = c.model.solution.getH3OConcentration();
      expect(absConcentrationToGraphString(h3o), isNotEmpty);
      expect(c.model.pH, AbsMath.pHFromH3O(h3o));
      c.dispose();
    });

    testWidgets('Equation labels for all five solutions', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      final c = IntroController(random: Random(15));
      for (final s in c.model.solutions) {
        c.selectSolution(s);
        await tester.pumpWidget(
          MaterialApp(home: AbsIntroScreen(controller: c)),
        );
        await tester.pump();
        expect(find.byType(AbsReactionEquation), findsOneWidget);
        if (s == c.model.water) {
          expect(find.textContaining('H'), findsWidgets);
        } else if (s == c.model.strongAcid || s == c.model.weakAcid) {
          expect(find.text('HA'), findsOneWidget);
        } else if (s == c.model.strongBase) {
          expect(find.text('MOH'), findsOneWidget);
        } else if (s == c.model.weakBase) {
          expect(find.text('B'), findsOneWidget);
        }
      }
      c.dispose();
    });
  });

  group('Phase 5 My Solution', () {
    test('MS-1 Acid/Base toggle x5 updates solution class', () {
      final c = MySolutionController(random: Random(20));
      for (var i = 0; i < 5; i++) {
        c.setIsAcid(false);
        expect(c.model.isAcid, isFalse);
        expect(
          c.model.solution,
          anyOf(same(c.model.weakBase), same(c.model.strongBase)),
        );
        expect(c.model.pH, greaterThan(7));
        c.setIsAcid(true);
        expect(c.model.isAcid, isTrue);
        expect(
          c.model.solution,
          anyOf(same(c.model.weakAcid), same(c.model.strongAcid)),
        );
        expect(c.model.pH, lessThan(7));
      }
      c.dispose();
    });

    test('MS-2 Weak/Strong for acid and base x3', () {
      final c = MySolutionController(random: Random(21));
      for (var i = 0; i < 3; i++) {
        c.setIsAcid(true);
        c.setIsWeak(false);
        expect(c.model.solution, same(c.model.strongAcid));
        c.setIsWeak(true);
        expect(c.model.solution, same(c.model.weakAcid));
        c.setIsAcid(false);
        c.setIsWeak(false);
        expect(c.model.solution, same(c.model.strongBase));
        c.setIsWeak(true);
        expect(c.model.solution, same(c.model.weakBase));
      }
      c.dispose();
    });

    test('MS-3 concentration min default max min', () {
      final c = MySolutionController(random: Random(22));
      c.setIsWeak(false);
      c.setConcentration(AbsConstants.concentrationRange.min);
      expect(c.model.pH, 3);
      c.setConcentration(AbsConstants.concentrationRange.defaultValue);
      expect(c.model.pH, 2);
      c.setConcentration(AbsConstants.concentrationRange.max);
      expect(c.model.pH, 0);
      c.setConcentration(AbsConstants.concentrationRange.min);
      expect(c.model.pH, 3);
      expect(countByKey(c.particles), expectedCounts(c.model.solution));
      c.dispose();
    });

    test('MS-4 strength min default max for weak acid/base', () {
      final c = MySolutionController(random: Random(23));
      c.setIsAcid(true);
      c.setIsWeak(true);
      c.setStrength(AbsConstants.weakStrengthRange.min);
      final low = c.model.pH;
      c.setStrength(AbsConstants.weakStrengthRange.defaultValue);
      final mid = c.model.pH;
      c.setStrength(AbsConstants.weakStrengthRange.max);
      final high = c.model.pH;
      expect(high, lessThan(mid));
      expect(mid, lessThanOrEqualTo(low));

      c.setIsAcid(false);
      c.setStrength(AbsConstants.weakStrengthRange.min);
      final bLow = c.model.pH;
      c.setStrength(AbsConstants.weakStrengthRange.max);
      expect(c.model.pH, greaterThan(bLow));
      c.dispose();
    });

    test('Combined state matrix renders and chemistry coherent', () {
      final c = MySolutionController(random: Random(24));
      final cases = <(bool, bool, double, double?)>[
        (true, true, 1e-3, 1e-10),
        (true, true, 1.0, 1e2),
        (false, true, 1e-3, 1e-10),
        (false, true, 1.0, 1e2),
        (true, false, 1e-3, null),
        (true, false, 1.0, null),
        (false, false, 1e-3, null),
        (false, false, 1.0, null),
      ];
      for (final row in cases) {
        final acid = row.$1;
        final weak = row.$2;
        final conc = row.$3;
        final strength = row.$4;
        c.setIsAcid(acid);
        c.setIsWeak(weak);
        c.setConcentration(conc);
        if (strength != null) c.setStrength(strength);
        expect(c.model.pH, inInclusiveRange(0, 14));
        expect(countByKey(c.particles), expectedCounts(c.model.solution));
        dipMeterMs(c);
        expect(c.model.pHMeter.displayedPH, c.model.pH);
        if (c.model.pH != 7) {
          dipTester(c.model);
          expect(c.model.conductivityTester.brightness, greaterThan(0));
        }
      }
      c.dispose();
    });
  });

  group('Phase 5 Cross-screen isolation', () {
    test('Model Isolation Intro != MySolution', () {
      final intro = IntroController(random: Random(30));
      final mine = MySolutionController(random: Random(31));
      expect(intro.model, isA<IntroModel>());
      expect(mine.model, isA<MySolutionModel>());
      expect(identical(intro.model, mine.model), isFalse);

      intro.selectSolution(intro.model.weakAcid);
      intro.model.weakAcid.concentration = 1;
      expect(mine.model.concentration, 1e-2);
      expect(mine.model.solution, same(mine.model.weakAcid));

      mine.setIsAcid(false);
      mine.setConcentration(1);
      expect(intro.model.solution, same(intro.model.weakAcid));
      intro.dispose();
      mine.dispose();
    });

    test('Tool Isolation each screen keeps own tool state', () {
      final intro = IntroController(random: Random(32));
      final mine = MySolutionController(random: Random(33));
      intro.setToolMode(AbsToolMode.pHPaper);
      dipMeter(intro);
      expect(intro.model.pHMeter.isInSolution, isTrue);

      expect(mine.viewProperties.toolMode, AbsToolMode.pHMeter);
      expect(mine.model.pHMeter.isInSolution, isFalse);

      mine.setToolMode(AbsToolMode.conductivityTester);
      dipTester(mine.model);
      expect(intro.viewProperties.toolMode, AbsToolMode.pHPaper);
      intro.dispose();
      mine.dispose();
    });

    testWidgets('Rapid navigation Intro MySolution x5', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      for (var i = 0; i < 5; i++) {
        final intro = IntroController(random: Random(40 + i));
        intro.selectSolution(intro.model.strongAcid);
        await tester.pumpWidget(
          MaterialApp(home: AbsIntroScreen(controller: intro)),
        );
        await tester.pump();
        expect(intro.model.solution, same(intro.model.strongAcid));
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        intro.dispose();

        final mine = MySolutionController(random: Random(50 + i));
        mine.setIsWeak(false);
        await tester.pumpWidget(
          MaterialApp(home: AbsMySolutionScreen(controller: mine)),
        );
        await tester.pump();
        expect(mine.model.solution, same(mine.model.strongAcid));
        expect(mine.model.concentration, 1e-2);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        mine.dispose();
      }
    });

    testWidgets('Lifecycle enter interact leave re-enter x5 per screen',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      for (var i = 0; i < 5; i++) {
        final intro = IntroController(random: Random(60 + i));
        await tester.pumpWidget(
          MaterialApp(home: AbsIntroScreen(controller: intro)),
        );
        await tester.pump();
        intro.selectSolution(intro.model.weakBase);
        intro.setViewMode(AbsViewMode.graph);
        await tester.tap(find.byType(KratosResetAllButton));
        await tester.pump();
        expect(intro.model.solution, same(intro.model.water));
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        intro.dispose();
      }
      for (var i = 0; i < 5; i++) {
        final mine = MySolutionController(random: Random(70 + i));
        await tester.pumpWidget(
          MaterialApp(home: AbsMySolutionScreen(controller: mine)),
        );
        await tester.pump();
        mine.setIsAcid(false);
        mine.setConcentration(0.1);
        await tester.tap(find.byType(KratosResetAllButton));
        await tester.pump();
        expect(mine.model.isAcid, isTrue);
        expect(mine.model.concentration, 1e-2);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        mine.dispose();
      }
    });
  });

  group('Phase 5 Reset stress x10', () {
    test('Intro reset stress', () {
      final c = IntroController(random: Random(80));
      final rnd = Random(81);
      final sols = c.model.solutions;
      for (var i = 0; i < 10; i++) {
        c.selectSolution(sols[rnd.nextInt(sols.length)]);
        c.setViewMode(AbsViewMode.values[rnd.nextInt(3)]);
        c.setToolMode(
          [
            AbsToolMode.pHMeter,
            AbsToolMode.pHPaper,
            AbsToolMode.conductivityTester,
          ][rnd.nextInt(3)],
        );
        dipMeter(c);
        c.resetAll();
        expect(c.model.solution, same(c.model.water));
        expect(c.model.pH, 7);
        expect(c.viewProperties.viewMode, AbsViewMode.particles);
        expect(c.viewProperties.toolMode, AbsToolMode.pHMeter);
        expect(c.model.pHMeter.isInSolution, isFalse);
        expect(c.particles, isNotEmpty);
        expect(countByKey(c.particles), expectedCounts(c.model.water));
      }
      c.dispose();
    });

    test('My Solution reset stress', () {
      final c = MySolutionController(random: Random(82));
      final rnd = Random(83);
      for (var i = 0; i < 10; i++) {
        c.setIsAcid(rnd.nextBool());
        c.setIsWeak(rnd.nextBool());
        c.setConcentration(AbsMath.linearToLog(-3 + rnd.nextDouble() * 3));
        c.setStrength(AbsMath.linearToLog(-10 + rnd.nextDouble() * 12));
        c.setViewMode(AbsViewMode.values[rnd.nextInt(3)]);
        c.setToolMode(
          [
            AbsToolMode.pHMeter,
            AbsToolMode.pHPaper,
            AbsToolMode.conductivityTester,
          ][rnd.nextInt(3)],
        );
        dipMeterMs(c);
        c.resetAll();
        expect(c.model.isAcid, isTrue);
        expect(c.model.isWeak, isTrue);
        expect(c.model.concentration, 1e-2);
        expect(c.model.strength, 1e-7);
        expect(c.model.solution, same(c.model.weakAcid));
        expect(c.viewProperties.viewMode, AbsViewMode.particles);
        expect(c.viewProperties.toolMode, AbsToolMode.pHMeter);
        expect(c.model.pHMeter.isInSolution, isFalse);
      }
      c.dispose();
    });
  });

  group('Phase 5 Rebuild / ticker', () {
    test('rebuild stress keeps same model identity and particle list', () {
      final c = IntroController(random: Random(90));
      final model = c.model;
      final snap = c.particles;
      for (var i = 0; i < 20; i++) {
        c.notifyModelChanged();
      }
      expect(identical(c.model, model), isTrue);
      expect(identical(c.particles, snap), isTrue);
      c.dispose();
    });

    test('paper step while pressed does not float', () {
      final c = IntroController(random: Random(91));
      final y = c.model.pHPaper.position.dy;
      c.paperPressed = true;
      c.step(0.2);
      expect(c.model.pHPaper.position.dy, y);
      c.dispose();
    });
  });
}
