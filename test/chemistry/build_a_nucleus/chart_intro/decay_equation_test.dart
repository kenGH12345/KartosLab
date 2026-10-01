import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/chart_intro/controller/chart_intro_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/chart_intro_decay_spec.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/chart_intro_state.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/render/decay_equation_render.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/widgets/chart_intro_decay_controls.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/widgets/decay_equation_view.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/decay_type.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/nucleon.dart';
import 'package:kratos/chemistry/build_a_nucleus/screens/chart_intro_screen.dart';

void main() {
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    repo = NuclideRepository(
      NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  });

  DecayEquationRender eq(ChartIntroState s) =>
      DecayEquationRender.from(s, repo);

  void seed(ChartIntroState s, int p, int n) {
    for (var i = 0; i < p; i++) {
      expect(s.addImmediately(NucleonType.proton), isNotNull);
    }
    for (var i = 0; i < n; i++) {
      expect(s.addImmediately(NucleonType.neutron), isNotNull);
    }
  }

  group('Equation 数据', () {
    test('0p0n / 2p0n：无格 → hidden，不可 decay', () {
      final s = ChartIntroState(repository: repo);
      expect(eq(s).kind, DecayEquationKind.hidden);
      expect(eq(s).canDecay, isFalse);
      expect(eq(s).showsEquation, isFalse);

      seed(s, 2, 0);
      expect(s.nuclideExists, isFalse);
      expect(eq(s).kind, DecayEquationKind.hidden);
    });

    test('1p0n H-1：Stable，无发射物', () {
      final s = ChartIntroState(repository: repo);
      seed(s, 1, 0);
      final r = eq(s);
      expect(r.kind, DecayEquationKind.stable);
      expect(r.canDecay, isFalse);
      expect(r.percentText, isNull);
      expect(r.parent!.symbol, 'H');
      expect(r.parent!.massNumber, 1);
      expect(r.emitted, isNull);
    });

    test('4p4n Be-8：一条 α 方程 parent → daughter + α', () {
      final s = ChartIntroState(repository: repo);
      seed(s, 4, 4);
      final first = repo.availableDecays(4, 4).first;
      expect(first.type, NucleusDecayType.alphaDecay);
      final r = eq(s);
      expect(r.kind, DecayEquationKind.decay);
      expect(r.decayType, NucleusDecayType.alphaDecay);
      expect(r.parent!.symbol, 'Be');
      expect(r.parent!.protonNumber, 4);
      expect(r.parent!.massNumber, 8);
      expect(r.daughter!.symbol, 'He');
      expect(r.daughter!.protonNumber, 2);
      expect(r.daughter!.massNumber, 4);
      expect(r.emitted!.symbol, 'α');
      expect(r.emitted!.protonNumber, 2);
      expect(r.emitted!.massNumber, 4);
      expect(r.percentText, isNotNull);
    });

    test('6p8n C-14：β−，daughter Z+1', () {
      final s = ChartIntroState(repository: repo);
      seed(s, 6, 8);
      expect(s.nuclideExists, isTrue);
      final r = eq(s);
      expect(r.decayType, NucleusDecayType.betaMinusDecay);
      expect(r.parent!.symbol, 'C');
      expect(r.daughter!.protonNumber, 7);
      expect(r.daughter!.massNumber, 14);
      expect(r.emitted!.symbol, 'β');
      expect(r.emitted!.protonNumber, ChartIntroDecaySpec.betaMinus.protonNumber);
    });

    test('只取 availableDecays.first，不建第二条方程', () {
      final s = ChartIntroState(repository: repo);
      seed(s, 4, 4);
      expect(repo.availableDecays(4, 4), isNotEmpty);
      expect(eq(s).decayType, repo.availableDecays(4, 4).first.type);
    });
  });

  group('Decay 控制', () {
    test('H-1 不能按；Be-8 能按；衰变后壳层/图变成 He-4', () {
      final c = ChartIntroController(repository: repo);
      c.state.addImmediately(NucleonType.proton);
      expect(c.canDecay, isFalse);

      c.reset();
      for (var i = 0; i < 4; i++) {
        c.state.addImmediately(NucleonType.proton);
        c.state.addImmediately(NucleonType.neutron);
      }
      expect(c.canDecay, isTrue);
      expect(c.decay(), isTrue);
      expect(c.state.protonCount, 2);
      expect(c.state.neutronCount, 2);
      expect(c.state.elementSymbol, 'He');
      expect(c.decayEquation.kind, DecayEquationKind.stable);
      expect(c.canUndoDecay, isTrue);
      c.undoDecay();
      expect(c.state.protonCount, 4);
      expect(c.state.neutronCount, 4);
      expect(c.canUndoDecay, isFalse);
      c.dispose();
    });

    test('Reset 清方程回到 hidden，Undo 消失', () {
      final c = ChartIntroController(repository: repo);
      for (var i = 0; i < 4; i++) {
        c.state.addImmediately(NucleonType.proton);
        c.state.addImmediately(NucleonType.neutron);
      }
      c.decay();
      c.reset();
      expect(c.decayEquation.kind, DecayEquationKind.hidden);
      expect(c.canUndoDecay, isFalse);
      expect(c.state.selectedChart, ChartIntroChartType.partial);
      c.dispose();
    });
  });

  group('Screen', () {
    Future<void> pumpScreen(
      WidgetTester tester,
      ChartIntroController c,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: ChartIntroScreen(controller: c, tickOnClock: false),
        ),
      );
      await tester.pump();
    }

    testWidgets('Partial 无方程；Zoom 才出现；方程不可点；无五键', (tester) async {
      final c = ChartIntroController(repository: repo);
      await pumpScreen(tester, c);
      expect(find.byType(DecayEquationView), findsNothing);
      expect(find.byType(ChartIntroDecayControls), findsNothing);

      await tester.tap(find.byKey(const ValueKey('chart_intro_chart_zoom')));
      await tester.pump();
      expect(find.byType(DecayEquationView), findsOneWidget);
      expect(find.byType(ChartIntroDecayControls), findsOneWidget);
      expect(find.byKey(const ValueKey('chart_intro_decay_button')), findsOneWidget);
      expect(find.byType(IgnorePointer), findsWidgets);
      expect(find.text('α 衰变'), findsNothing);
      expect(find.text('β- 衰变'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('chart_intro_chart_partial')));
      await tester.pump();
      expect(find.byType(DecayEquationView), findsNothing);
      c.dispose();
    });
  });
}
