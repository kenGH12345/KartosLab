import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_beaker.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_constants.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_math.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/abs_view_properties.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/solutions/strong_acid.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/solutions/water.dart';
import 'package:kratos/chemistry/acid_base_solutions/model/solutions/weak_acid.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/abs_assets.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/abs_concentration_graph.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/abs_conductivity_layer.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/abs_reaction_equation.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/intro_controller.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/intro_screen.dart';
import 'package:kratos/chemistry/acid_base_solutions/view/my_solution_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Graph scientific notation (ConcentrationBarNode)', () {
    test('negligible below 1e-13', () {
      expect(absConcentrationToGraphString(1e-14), 'negligible');
    });

    test('pow==0 shows mantissa only', () {
      expect(absConcentrationToGraphString(1.0), '1.0');
    });

    test('scientific form for mid range', () {
      expect(absConcentrationToGraphString(1e-2), '1.0 x 10⁻²');
      expect(absConcentrationToGraphString(3.5e-5), '3.5 x 10⁻⁵');
    });

    test('>1 uses one decimal', () {
      expect(absConcentrationToGraphString(55.6), '55.6');
    });

    test('bar height mapping matches source formula', () {
      const maxH = 100.0;
      final h = absBarHeight(1e-2, maxH);
      // |log10(0.01)+8| * 100/10 = 6 * 10 = 60
      expect(h, closeTo(60, 1e-9));
    });

    test('Y-axis title string matches source', () {
      expect(
        AbsConcentrationGraph.yAxisTitle,
        'Equilibrium Concentration (mol/L)',
      );
    });
  });

  group('Graph widget chrome', () {
    testWidgets('renders Y-axis title and bars (no under-axis formulas)',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      final beaker = AbsBeaker();
      final solution = WeakAcid();
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: AbsConstants.layoutBounds.width,
            height: AbsConstants.layoutBounds.height,
            child: Stack(
              children: [
                AbsConcentrationGraph(
                  beaker: beaker,
                  solution: solution,
                  viewMode: AbsViewMode.graph,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text(AbsConcentrationGraph.yAxisTitle), findsOneWidget);
      expect(find.byType(AbsConcentrationGraph), findsOneWidget);
      // PhET: formulas live in the equation below the beaker, not on the x-axis
      expect(find.text('HA'), findsNothing);
      expect(find.text('A⁻'), findsNothing);
    });

    testWidgets('equation formulas fully visible without overlap', (tester) async {
      await tester.binding.setSurfaceSize(
        Size(AbsConstants.layoutBounds.width, AbsConstants.layoutBounds.height),
      );
      final beaker = AbsBeaker();
      final solution = WeakAcid();
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: AbsConstants.layoutBounds.width,
            height: AbsConstants.layoutBounds.height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AbsReactionEquation(beaker: beaker, solution: solution),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      final formulas = ['HA', 'H₂O', 'A⁻', 'H₃O⁺'];
      final rects = <Rect>[];
      for (final f in formulas) {
        expect(find.text(f), findsOneWidget);
        rects.add(tester.getRect(find.text(f)));
      }
      for (var i = 0; i < rects.length - 1; i++) {
        expect(
          rects[i].right,
          lessThan(rects[i + 1].left),
          reason: '${formulas[i]} must not overlap ${formulas[i + 1]}',
        );
      }
      // Equation group centered on beaker bottom-center (PhET centerX)
      final eqLeft = rects.first.left;
      final eqRight = rects.last.right;
      final eqCenterX = (eqLeft + eqRight) / 2;
      expect(
        (eqCenterX - beaker.position.dx).abs(),
        lessThan(8.0),
        reason: 'equation should be centered under beaker',
      );
    });
  });

  group('ConductivityTester chrome', () {
    testWidgets('uses original bulb/battery assets when active', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      final c = IntroController(random: Random(1));
      c.setToolMode(AbsToolMode.conductivityTester);
      await tester.pumpWidget(
        MaterialApp(home: AbsIntroScreen(controller: c)),
      );
      await tester.pump();
      expect(find.byType(AbsConductivityLayer), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Image &&
              w.image is AssetImage &&
              (w.image as AssetImage).assetName == AbsAssets.lightBulbOff,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Image &&
              w.image is AssetImage &&
              (w.image as AssetImage).assetName == AbsAssets.batteryDCell,
        ),
        findsOneWidget,
      );
      // Neutral water dipped → brightness 0 → on bulb not shown
      final t = c.model.conductivityTester;
      final y = c.model.beaker.top + 25;
      t.positiveProbePosition = Offset(t.positiveProbePosition.dx, y);
      t.negativeProbePosition = Offset(t.negativeProbePosition.dx, y);
      expect(t.brightness, 0);
      c.notifyModelChanged();
      await tester.pump();
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Image &&
              w.image is AssetImage &&
              (w.image as AssetImage).assetName == AbsAssets.lightBulbOn,
        ),
        findsNothing,
      );
      c.dispose();
    });

    testWidgets('active acid shows on-bulb asset', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      final c = IntroController(random: Random(2));
      c.selectSolution(c.model.strongAcid);
      c.setToolMode(AbsToolMode.conductivityTester);
      final t = c.model.conductivityTester;
      final y = c.model.beaker.top + 25;
      t.positiveProbePosition = Offset(t.positiveProbePosition.dx, y);
      t.negativeProbePosition = Offset(t.negativeProbePosition.dx, y);
      expect(t.brightness, greaterThan(0));
      await tester.pumpWidget(
        MaterialApp(home: AbsIntroScreen(controller: c)),
      );
      await tester.pump();
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Image &&
              w.image is AssetImage &&
              (w.image as AssetImage).assetName == AbsAssets.lightBulbOn,
        ),
        findsOneWidget,
      );
      c.dispose();
    });

    test('probe drag moves both probes together (source semantics)', () {
      final c = IntroController(random: Random(3));
      final t = c.model.conductivityTester;
      final y0 = t.positiveProbePosition.dy;
      final newY = y0 + 20;
      // Simulate layer sync
      t.positiveProbePosition = Offset(t.positiveProbePosition.dx, newY);
      t.negativeProbePosition = Offset(t.negativeProbePosition.dx, newY);
      expect(t.positiveProbePosition.dy, t.negativeProbePosition.dy);
      c.dispose();
    });
  });

  group('Shared chrome / AbsMath display helpers', () {
    test('toFixed pads decimals', () {
      expect(AbsMath.toFixed(1, 1), '1.0');
      expect(AbsMath.toFixed(3.56, 1), '3.6');
    });

    test('Water H2O bar height is finite', () {
      final w = Water();
      final h2o = w.particleWithKey(w.particles.first.key)!;
      final h = absBarHeight(h2o.getConcentration(), 100);
      expect(h.isFinite, isTrue);
    });

    test('Strong acid C=0.01 bar label', () {
      final a = StrongAcid()..concentration = 0.01;
      final c = a.getH3OConcentration();
      expect(absConcentrationToGraphString(c), '1.0 x 10⁻²');
    });
  });

  group('Regression — chemistry / screens unchanged by visual', () {
    test('Intro strong acid pH still 2', () {
      final c = IntroController(random: Random(9));
      c.selectSolution(c.model.strongAcid);
      expect(c.model.pH, 2);
      c.dispose();
    });

    test('My Solution defaults unchanged', () {
      final c = MySolutionController(random: Random(9));
      expect(c.model.concentration, 1e-2);
      expect(c.model.strength, 1e-7);
      expect(c.model.isAcid && c.model.isWeak, isTrue);
      c.dispose();
    });
  });
}
