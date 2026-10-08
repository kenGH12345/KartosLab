import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_constants.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_math.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_view_properties.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/my_solution_model.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/abs_log_slider.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/my_solution_controller.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/my_solution_screen.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/intro_controller.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/chemistry/acid_base_solutions/abs_strings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('My Solution construct', () {
    testWidgets('builds layout 768×504 without Water', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      final controller = MySolutionController(random: Random(1));
      await tester.pumpWidget(
        MaterialApp(home: AbsMySolutionScreen(controller: controller)),
      );
      await tester.pump();
      expect(find.byType(AbsMySolutionScreen), findsOneWidget);
      expect(find.byType(KratosResetAllButton), findsOneWidget);
      expect(find.text('Solution'), findsOneWidget);
      expect(find.text('Views'), findsOneWidget);
      expect(find.text(AbsStrings.acid), findsOneWidget);
      expect(find.text(AbsStrings.base), findsOneWidget);
      expect(find.text(AbsStrings.weak), findsOneWidget);
      expect(find.text(AbsStrings.strong), findsOneWidget);
      expect(find.text(AbsStrings.waterH2O), findsNothing);
      expect(find.byType(AbsLogSlider), findsWidgets);
      controller.dispose();
    });

    test('controller uses MySolutionModel not IntroModel', () {
      final c = MySolutionController(random: Random(1));
      expect(c.model, isA<MySolutionModel>());
      expect(c.model.solutions.length, 4);
      expect(c.model.solution, same(c.model.weakAcid));
      expect(c.model.isAcid, isTrue);
      expect(c.model.isWeak, isTrue);
      expect(c.model.concentration, 1e-2);
      expect(c.model.strength, 1e-7);
      c.dispose();
    });

    test('Intro and My Solution models are independent instances', () {
      final intro = IntroController(random: Random(2));
      final mine = MySolutionController(random: Random(3));
      intro.selectSolution(intro.model.strongAcid);
      expect(mine.model.solution, same(mine.model.weakAcid));
      expect(mine.model.pH, isNot(intro.model.pH));
      intro.dispose();
      mine.dispose();
    });
  });

  group('LogSlider mapping', () {
    test('logToLinear / linearToLog round-trip concentration defaults', () {
      const c = 1e-2;
      final linear = AbsMath.logToLinear(c);
      expect(linear, closeTo(-2, 1e-12));
      expect(AbsMath.linearToLog(linear), closeTo(c, 1e-12));
    });

    test('strength range maps to linear [-10, 2]', () {
      expect(
        AbsMath.logToLinear(AbsConstants.weakStrengthRange.min),
        closeTo(-10, 1e-12),
      );
      expect(
        AbsMath.logToLinear(AbsConstants.weakStrengthRange.max),
        closeTo(2, 1e-12),
      );
      expect(
        AbsMath.linearToLog(-7),
        closeTo(1e-7, 1e-12),
      );
    });

    test('concentration range maps to linear [-3, 0]', () {
      expect(
        AbsMath.logToLinear(AbsConstants.concentrationRange.min),
        closeTo(-3, 1e-12),
      );
      expect(
        AbsMath.logToLinear(AbsConstants.concentrationRange.max),
        closeTo(0, 1e-12),
      );
    });
  });

  group('Acid/Base × Weak/Strong matrix', () {
    test('1 Strong Acid low C', () {
      final c = MySolutionController(random: Random(10));
      c.setIsWeak(false);
      c.setIsAcid(true);
      c.setConcentration(1e-3);
      expect(c.model.solution, same(c.model.strongAcid));
      expect(c.model.pH, closeTo(3, 1e-9));
      c.dispose();
    });

    test('2 Strong Acid high C', () {
      final c = MySolutionController(random: Random(11));
      c.setIsWeak(false);
      c.setIsAcid(true);
      c.setConcentration(1);
      expect(c.model.solution, same(c.model.strongAcid));
      expect(c.model.pH, closeTo(0, 1e-9));
      c.dispose();
    });

    test('3 Weak Acid low C low Ka', () {
      final c = MySolutionController(random: Random(12));
      c.setIsAcid(true);
      c.setIsWeak(true);
      c.setConcentration(1e-3);
      c.setStrength(1e-10);
      expect(c.model.solution, same(c.model.weakAcid));
      expect(c.model.pH, greaterThan(3));
      expect(c.model.pH, lessThan(7));
      c.dispose();
    });

    test('4 Weak Acid high C high Ka', () {
      final c = MySolutionController(random: Random(13));
      c.setIsAcid(true);
      c.setIsWeak(true);
      c.setConcentration(1);
      c.setStrength(1e2);
      expect(c.model.solution, same(c.model.weakAcid));
      expect(c.model.pH, lessThan(1));
      c.dispose();
    });

    test('5 Strong Base low C', () {
      final c = MySolutionController(random: Random(14));
      c.setIsAcid(false);
      c.setIsWeak(false);
      c.setConcentration(1e-3);
      expect(c.model.solution, same(c.model.strongBase));
      expect(c.model.pH, closeTo(11, 1e-9));
      c.dispose();
    });

    test('6 Strong Base high C', () {
      final c = MySolutionController(random: Random(15));
      c.setIsAcid(false);
      c.setIsWeak(false);
      c.setConcentration(1);
      expect(c.model.solution, same(c.model.strongBase));
      expect(c.model.pH, closeTo(14, 1e-9));
      c.dispose();
    });

    test('7 Weak Base low C low Kb', () {
      final c = MySolutionController(random: Random(16));
      c.setIsAcid(false);
      c.setIsWeak(true);
      c.setConcentration(1e-3);
      c.setStrength(1e-10);
      expect(c.model.solution, same(c.model.weakBase));
      expect(c.model.pH, greaterThan(7));
      expect(c.model.pH, lessThan(11));
      c.dispose();
    });

    test('8 Weak Base high C high Kb', () {
      final c = MySolutionController(random: Random(17));
      c.setIsAcid(false);
      c.setIsWeak(true);
      c.setConcentration(1);
      c.setStrength(1e2);
      expect(c.model.solution, same(c.model.weakBase));
      expect(c.model.pH, greaterThan(13));
      c.dispose();
    });

    test('Acid ↔ Base switches solution class and pH', () {
      final c = MySolutionController(random: Random(18));
      c.setIsWeak(false);
      c.setIsAcid(true);
      c.setConcentration(0.01);
      final acidPh = c.model.pH;
      c.setIsAcid(false);
      expect(c.model.solution, same(c.model.strongBase));
      expect(c.model.pH, isNot(acidPh));
      expect(c.model.pH, closeTo(12, 1e-9));
      c.dispose();
    });

    test('Weak ↔ Strong switches solution class', () {
      final c = MySolutionController(random: Random(19));
      expect(c.model.solution, same(c.model.weakAcid));
      final weakPh = c.model.pH;
      c.setIsWeak(false);
      expect(c.model.solution, same(c.model.strongAcid));
      expect(c.model.pH, isNot(weakPh));
      expect(c.model.pH, closeTo(2, 1e-9));
      c.dispose();
    });
  });

  group('Concentration / Strength controls', () {
    test('concentration low → high updates pH and particles', () {
      final c = MySolutionController(random: Random(20));
      c.setIsWeak(false);
      final before = List.of(c.particles);
      c.setConcentration(1e-3);
      expect(c.model.pH, closeTo(3, 1e-9));
      final mid = List.of(c.particles);
      expect(identical(c.particles, before), isFalse);
      c.setConcentration(1);
      expect(c.model.pH, closeTo(0, 1e-9));
      expect(identical(c.particles, mid), isFalse);
      c.dispose();
    });

    test('strength low → high updates weak acid pH', () {
      final c = MySolutionController(random: Random(21));
      c.setStrength(1e-10);
      final lowPh = c.model.pH;
      c.setStrength(1e2);
      expect(c.model.pH, lessThan(lowPh));
      c.dispose();
    });

    test('nudgeConcentration ±0.001 with 3-decimal fixed', () {
      final c = MySolutionController(random: Random(22));
      expect(c.model.concentration, 0.01);
      c.nudgeConcentration(1);
      expect(c.model.concentration, closeTo(0.011, 1e-12));
      c.nudgeConcentration(-1);
      expect(c.model.concentration, closeTo(0.01, 1e-12));
      c.dispose();
    });

    test('strong hides strength effect on class but keeps strength value', () {
      final c = MySolutionController(random: Random(23));
      c.setStrength(1e-3);
      c.setIsWeak(false);
      expect(c.model.solution, same(c.model.strongAcid));
      expect(c.model.strength, 1e-3);
      // Strong acid strength is constant marker, not synced from model.strength
      expect(c.model.strongAcid.strength, AbsConstants.strongStrength);
      c.dispose();
    });
  });

  group('Particle lifecycle', () {
    test('notify rebuild does not regenerate particles', () {
      final c = MySolutionController(random: Random(42));
      final a = List.of(c.particles);
      c.notifyModelChanged();
      final b = c.particles;
      expect(a.length, b.length);
      for (var i = 0; i < a.length; i++) {
        expect(a[i].position, b[i].position);
        expect(a[i].key, b[i].key);
      }
      c.dispose();
    });

    test('view mode change keeps particle positions', () {
      final c = MySolutionController(random: Random(43));
      final snap = c.particles;
      c.setViewMode(AbsViewMode.graph);
      c.setViewMode(AbsViewMode.hideViews);
      c.setViewMode(AbsViewMode.particles);
      expect(identical(c.particles, snap), isTrue);
      c.dispose();
    });

    test('chemistry change regenerates population', () {
      final c = MySolutionController(random: Random(44));
      final before = c.particles;
      c.setConcentration(1);
      expect(identical(c.particles, before), isFalse);
      c.dispose();
    });
  });

  group('Tools', () {
    test('pH meter reads model pH when dipped', () {
      final c = MySolutionController(random: Random(30));
      expect(c.model.pHMeter.displayedPH, isNull);
      c.setIsWeak(false);
      c.model.pHMeter.position = Offset(
        c.model.pHMeter.position.dx,
        c.model.beaker.top + 20,
      );
      expect(c.model.pHMeter.displayedPH, closeTo(2, 1e-9));
      c.dispose();
    });

    test('pH paper floats at 250 px/s', () {
      final c = MySolutionController(random: Random(31));
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
      c.dispose();
    });

    test('conductivity dipped strong acid > 0', () {
      final c = MySolutionController(random: Random(32));
      c.setIsWeak(false);
      final t = c.model.conductivityTester;
      final y = c.model.beaker.top + 25;
      t.positiveProbePosition = Offset(t.positiveProbePosition.dx, y);
      t.negativeProbePosition = Offset(t.negativeProbePosition.dx, y);
      expect(t.brightness, greaterThan(0));
      c.dispose();
    });

    test('tool state isolated from Intro', () {
      final intro = IntroController(random: Random(33));
      final mine = MySolutionController(random: Random(34));
      intro.setToolMode(AbsToolMode.pHPaper);
      intro.model.pHMeter.position = Offset(
        intro.model.pHMeter.position.dx,
        intro.model.beaker.top + 30,
      );
      expect(mine.viewProperties.toolMode, AbsToolMode.pHMeter);
      expect(mine.model.pHMeter.isInSolution, isFalse);
      intro.dispose();
      mine.dispose();
    });
  });

  group('Views / Reset / Lifecycle', () {
    test('view modes cycle', () {
      final c = MySolutionController(random: Random(40));
      c.setViewMode(AbsViewMode.graph);
      expect(c.viewProperties.viewMode, AbsViewMode.graph);
      c.setViewMode(AbsViewMode.hideViews);
      expect(c.viewProperties.viewMode, AbsViewMode.hideViews);
      c.setViewMode(AbsViewMode.particles);
      expect(c.viewProperties.viewMode, AbsViewMode.particles);
      c.dispose();
    });

    test('resetAll restores My Solution defaults', () {
      final c = MySolutionController(random: Random(41));
      c.setIsAcid(false);
      c.setIsWeak(false);
      c.setConcentration(1);
      c.setStrength(1e-3);
      c.setViewMode(AbsViewMode.graph);
      c.setToolMode(AbsToolMode.conductivityTester);
      c.model.pHMeter.position = Offset(
        c.model.pHMeter.position.dx,
        c.model.beaker.top + 40,
      );
      c.resetAll();
      expect(c.model.isAcid, isTrue);
      expect(c.model.isWeak, isTrue);
      expect(c.model.concentration, 1e-2);
      expect(c.model.strength, 1e-7);
      expect(c.model.solution, same(c.model.weakAcid));
      expect(c.viewProperties.viewMode, AbsViewMode.particles);
      expect(c.viewProperties.toolMode, AbsToolMode.pHMeter);
      expect(c.model.pHMeter.isInSolution, isFalse);
      c.dispose();
    });

    test('reset stress ×10 random states', () {
      final c = MySolutionController(random: Random(50));
      final rnd = Random(99);
      for (var i = 0; i < 10; i++) {
        c.setIsAcid(rnd.nextBool());
        c.setIsWeak(rnd.nextBool());
        c.setConcentration(
          AbsMath.linearToLog(-3 + rnd.nextDouble() * 3),
        );
        c.setStrength(
          AbsMath.linearToLog(-10 + rnd.nextDouble() * 12),
        );
        c.setViewMode(
          AbsViewMode.values[rnd.nextInt(AbsViewMode.values.length)],
        );
        c.setToolMode(
          [
            AbsToolMode.pHMeter,
            AbsToolMode.pHPaper,
            AbsToolMode.conductivityTester,
          ][rnd.nextInt(3)],
        );
        c.resetAll();
        expect(c.model.isAcid, isTrue);
        expect(c.model.isWeak, isTrue);
        expect(c.model.concentration, 1e-2);
        expect(c.model.strength, 1e-7);
        expect(c.model.solution, same(c.model.weakAcid));
        expect(c.viewProperties.viewMode, AbsViewMode.particles);
        expect(c.viewProperties.toolMode, AbsToolMode.pHMeter);
      }
      c.dispose();
    });

    testWidgets('enter interact leave re-enter thrice', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      for (var i = 0; i < 3; i++) {
        final c = MySolutionController(random: Random(100 + i));
        await tester.pumpWidget(
          MaterialApp(home: AbsMySolutionScreen(controller: c)),
        );
        await tester.pump();
        c.setIsWeak(false);
        c.setConcentration(0.1);
        expect(c.model.solution, same(c.model.strongAcid));
        await tester.tap(find.byType(KratosResetAllButton));
        await tester.pump();
        expect(c.model.solution, same(c.model.weakAcid));
        expect(c.model.concentration, 1e-2);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        c.dispose();
      }
    });
  });

  group('Combined chemistry chain', () {
    test('solution → H3O → pH → particles stay model-driven', () {
      final c = MySolutionController(random: Random(60));
      c.setIsAcid(true);
      c.setIsWeak(true);
      c.setConcentration(0.01);
      c.setStrength(1e-7);
      final h3o = c.model.solution.getH3OConcentration();
      expect(c.model.pH, AbsMath.pHFromH3O(h3o));
      expect(c.particles, isNotEmpty);
      c.dispose();
    });
  });
}
