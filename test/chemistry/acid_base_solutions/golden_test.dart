import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_constants.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_view_properties.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/intro_controller.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/intro_screen.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/my_solution_controller.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/my_solution_screen.dart';

/// Phase 4 goldens — fixed 768×504 viewport, seeded particles.
///
/// Particle positions are deterministic via [Random] seed (not production
/// semantics change). Structure: beaker, controls, tools, graph chrome.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpAbs(
    WidgetTester tester,
    Widget child,
  ) async {
    await tester.binding.setSurfaceSize(
      Size(
        AbsConstants.layoutBounds.width,
        AbsConstants.layoutBounds.height,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox(
            width: AbsConstants.layoutBounds.width,
            height: AbsConstants.layoutBounds.height,
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(768, 504),
                devicePixelRatio: 1,
                textScaler: TextScaler.linear(1),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
  }

  group('Intro goldens', () {
    testWidgets('intro_initial', (tester) async {
      final c = IntroController(random: Random(1));
      addTearDown(c.dispose);
      await pumpAbs(tester, AbsIntroScreen(controller: c));
      await expectLater(
        find.byType(AbsIntroScreen),
        matchesGoldenFile('goldens/intro_initial.png'),
      );
    });

    testWidgets('intro_strong_acid', (tester) async {
      final c = IntroController(random: Random(1));
      addTearDown(c.dispose);
      c.selectSolution(c.model.strongAcid);
      await pumpAbs(tester, AbsIntroScreen(controller: c));
      await expectLater(
        find.byType(AbsIntroScreen),
        matchesGoldenFile('goldens/intro_strong_acid.png'),
      );
    });

    testWidgets('intro_weak_acid', (tester) async {
      final c = IntroController(random: Random(1));
      addTearDown(c.dispose);
      c.selectSolution(c.model.weakAcid);
      await pumpAbs(tester, AbsIntroScreen(controller: c));
      await expectLater(
        find.byType(AbsIntroScreen),
        matchesGoldenFile('goldens/intro_weak_acid.png'),
      );
    });

    testWidgets('intro_strong_base', (tester) async {
      final c = IntroController(random: Random(1));
      addTearDown(c.dispose);
      c.selectSolution(c.model.strongBase);
      await pumpAbs(tester, AbsIntroScreen(controller: c));
      await expectLater(
        find.byType(AbsIntroScreen),
        matchesGoldenFile('goldens/intro_strong_base.png'),
      );
    });

    testWidgets('intro_weak_base', (tester) async {
      final c = IntroController(random: Random(1));
      addTearDown(c.dispose);
      c.selectSolution(c.model.weakBase);
      await pumpAbs(tester, AbsIntroScreen(controller: c));
      await expectLater(
        find.byType(AbsIntroScreen),
        matchesGoldenFile('goldens/intro_weak_base.png'),
      );
    });

    testWidgets('intro_graph', (tester) async {
      final c = IntroController(random: Random(1));
      addTearDown(c.dispose);
      c.selectSolution(c.model.weakAcid);
      c.setViewMode(AbsViewMode.graph);
      await pumpAbs(tester, AbsIntroScreen(controller: c));
      await expectLater(
        find.byType(AbsIntroScreen),
        matchesGoldenFile('goldens/intro_graph.png'),
      );
    });

    testWidgets('intro_conductivity_active', (tester) async {
      final c = IntroController(random: Random(1));
      addTearDown(c.dispose);
      c.selectSolution(c.model.strongAcid);
      c.setToolMode(AbsToolMode.conductivityTester);
      final t = c.model.conductivityTester;
      final y = c.model.beaker.top + 25;
      t.positiveProbePosition = Offset(t.positiveProbePosition.dx, y);
      t.negativeProbePosition = Offset(t.negativeProbePosition.dx, y);
      await pumpAbs(tester, AbsIntroScreen(controller: c));
      await expectLater(
        find.byType(AbsIntroScreen),
        matchesGoldenFile('goldens/intro_conductivity_active.png'),
      );
    });
  });

  group('My Solution goldens', () {
    testWidgets('mysol_initial_weak_acid', (tester) async {
      final c = MySolutionController(random: Random(1));
      addTearDown(c.dispose);
      await pumpAbs(tester, AbsMySolutionScreen(controller: c));
      await expectLater(
        find.byType(AbsMySolutionScreen),
        matchesGoldenFile('goldens/mysol_initial_weak_acid.png'),
      );
    });

    testWidgets('mysol_strong_acid', (tester) async {
      final c = MySolutionController(random: Random(1));
      addTearDown(c.dispose);
      c.setIsWeak(false);
      c.setIsAcid(true);
      await pumpAbs(tester, AbsMySolutionScreen(controller: c));
      await expectLater(
        find.byType(AbsMySolutionScreen),
        matchesGoldenFile('goldens/mysol_strong_acid.png'),
      );
    });

    testWidgets('mysol_strong_base', (tester) async {
      final c = MySolutionController(random: Random(1));
      addTearDown(c.dispose);
      c.setIsAcid(false);
      c.setIsWeak(false);
      await pumpAbs(tester, AbsMySolutionScreen(controller: c));
      await expectLater(
        find.byType(AbsMySolutionScreen),
        matchesGoldenFile('goldens/mysol_strong_base.png'),
      );
    });

    testWidgets('mysol_weak_base', (tester) async {
      final c = MySolutionController(random: Random(1));
      addTearDown(c.dispose);
      c.setIsAcid(false);
      c.setIsWeak(true);
      await pumpAbs(tester, AbsMySolutionScreen(controller: c));
      await expectLater(
        find.byType(AbsMySolutionScreen),
        matchesGoldenFile('goldens/mysol_weak_base.png'),
      );
    });

    testWidgets('mysol_high_concentration', (tester) async {
      final c = MySolutionController(random: Random(1));
      addTearDown(c.dispose);
      c.setConcentration(1);
      await pumpAbs(tester, AbsMySolutionScreen(controller: c));
      await expectLater(
        find.byType(AbsMySolutionScreen),
        matchesGoldenFile('goldens/mysol_high_concentration.png'),
      );
    });

    testWidgets('mysol_graph', (tester) async {
      final c = MySolutionController(random: Random(1));
      addTearDown(c.dispose);
      c.setViewMode(AbsViewMode.graph);
      await pumpAbs(tester, AbsMySolutionScreen(controller: c));
      await expectLater(
        find.byType(AbsMySolutionScreen),
        matchesGoldenFile('goldens/mysol_graph.png'),
      );
    });
  });
}
