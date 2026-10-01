import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_constants.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_view_properties.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/intro_model.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/intro_controller.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/intro_screen.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Intro screen construct', () {
    testWidgets('builds layout 768×504 scene', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      final controller = IntroController(random: Random(1));
      await tester.pumpWidget(
        MaterialApp(home: AbsIntroScreen(controller: controller)),
      );
      await tester.pump();
      expect(find.byType(AbsIntroScreen), findsOneWidget);
      expect(find.byType(KratosResetAllButton), findsOneWidget);
      expect(find.text('Solution'), findsOneWidget);
      expect(find.text('Views'), findsOneWidget);
      expect(find.text('Water (H₂O)'), findsOneWidget);
      controller.dispose();
    });

    test('controller uses IntroModel not MySolution', () {
      final c = IntroController(random: Random(1));
      expect(c.model, isA<IntroModel>());
      expect(c.model.solutions.length, 5);
      expect(c.model.solution, same(c.model.water));
      c.dispose();
    });
  });

  group('Preset switching', () {
    test('selecting Strong Acid updates model pH and particles', () {
      final c = IntroController(random: Random(7));
      final before = List.of(c.particles);
      c.selectSolution(c.model.strongAcid);
      expect(c.model.solution, same(c.model.strongAcid));
      expect(c.model.pH, 2);
      expect(identical(c.particles, before), isFalse);
      expect(c.particles, isNotEmpty);
      c.dispose();
    });

    test('all five presets switch', () {
      final c = IntroController(random: Random(3));
      for (final s in c.model.solutions) {
        c.selectSolution(s);
        expect(c.model.solution, same(s));
        expect(c.model.pH, inInclusiveRange(0, 14));
      }
      c.dispose();
    });
  });

  group('Views / Tools', () {
    test('view modes cycle without regenerating particles', () {
      final c = IntroController(random: Random(11));
      c.selectSolution(c.model.weakAcid);
      final snap = c.particles;
      c.setViewMode(AbsViewMode.graph);
      c.setViewMode(AbsViewMode.hideViews);
      c.setViewMode(AbsViewMode.particles);
      expect(identical(c.particles, snap), isTrue);
      c.dispose();
    });

    test('tool modes exclude none from UI path', () {
      final c = IntroController(random: Random(2));
      c.setToolMode(AbsToolMode.pHPaper);
      expect(c.viewProperties.toolMode, AbsToolMode.pHPaper);
      c.setToolMode(AbsToolMode.conductivityTester);
      expect(c.viewProperties.toolMode, AbsToolMode.conductivityTester);
      c.setToolMode(AbsToolMode.pHMeter);
      expect(c.viewProperties.toolMode, AbsToolMode.pHMeter);
      c.dispose();
    });
  });

  group('Particle lifecycle', () {
    test('rebuild notify does not teleport particles', () {
      final c = IntroController(random: Random(42));
      final a = List.of(c.particles);
      c.notifyModelChanged();
      final b = c.particles;
      expect(identical(a, b) || _samePositions(a, b), isTrue);
      expect(a.length, b.length);
      for (var i = 0; i < a.length; i++) {
        expect(a[i].position, b[i].position);
        expect(a[i].key, b[i].key);
      }
      c.dispose();
    });

    test('solution change regenerates population', () {
      final c = IntroController(random: Random(5));
      final waterCount = c.particles.length;
      c.selectSolution(c.model.strongAcid);
      expect(c.particles.length, isNot(waterCount));
      c.dispose();
    });
  });

  group('Tools integration', () {
    test('pH meter blank until dipped; then shows model pH', () {
      final c = IntroController(random: Random(9));
      expect(c.model.pHMeter.displayedPH, isNull);
      c.model.pHMeter.position = Offset(
        c.model.pHMeter.position.dx,
        c.model.beaker.top + 20,
      );
      expect(c.model.pHMeter.displayedPH, 7);
      c.selectSolution(c.model.strongAcid);
      c.model.pHMeter.position = Offset(
        c.model.pHMeter.position.dx,
        c.model.beaker.top + 20,
      );
      expect(c.model.pHMeter.displayedPH, 2);
      c.dispose();
    });

    test('conductivity water dipped → 0; strong acid dipped → >0', () {
      final c = IntroController(random: Random(8));
      final t = c.model.conductivityTester;
      final y = c.model.beaker.top + 25;
      t.positiveProbePosition = Offset(t.positiveProbePosition.dx, y);
      t.negativeProbePosition = Offset(t.negativeProbePosition.dx, y);
      expect(t.brightness, 0);
      c.selectSolution(c.model.strongAcid);
      t.positiveProbePosition = Offset(t.positiveProbePosition.dx, y);
      t.negativeProbePosition = Offset(t.negativeProbePosition.dx, y);
      expect(t.brightness, greaterThan(0));
      c.dispose();
    });

    test('pH paper step floats at 250 px/s when released', () {
      final c = IntroController(random: Random(4));
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
  });

  group('Reset / lifecycle', () {
    test('resetAll restores Intro defaults and view props', () {
      final c = IntroController(random: Random(6));
      c.selectSolution(c.model.weakBase);
      c.setViewMode(AbsViewMode.graph);
      c.setToolMode(AbsToolMode.pHPaper);
      c.model.pHMeter.position = Offset(
        c.model.pHMeter.position.dx,
        c.model.beaker.top + 40,
      );
      c.resetAll();
      expect(c.model.solution, same(c.model.water));
      expect(c.viewProperties.viewMode, AbsViewMode.particles);
      expect(c.viewProperties.toolMode, AbsToolMode.pHMeter);
      expect(c.model.pHMeter.isInSolution, isFalse);
      expect(c.particles, isNotEmpty);
      c.dispose();
    });

    testWidgets('enter interact leave re-enter thrice', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      for (var i = 0; i < 3; i++) {
        final c = IntroController(random: Random(100 + i));
        await tester.pumpWidget(
          MaterialApp(home: AbsIntroScreen(controller: c)),
        );
        await tester.pump();
        await tester.tap(find.text('Strong Acid (HA)'));
        await tester.pump();
        expect(c.model.solution, same(c.model.strongAcid));
        await tester.tap(find.byType(KratosResetAllButton));
        await tester.pump();
        expect(c.model.solution, same(c.model.water));
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        c.dispose();
      }
    });
  });

  group('Layout constants', () {
    test('layoutBounds remain 768×504', () {
      expect(AbsConstants.layoutBounds, const Size(768, 504));
    });
  });
}

bool _samePositions(List a, List b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i].position != b[i].position) return false;
  }
  return true;
}
