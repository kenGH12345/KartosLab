import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/chart_intro/controller/chart_intro_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/chart_intro_state.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/painters/chart_intro_symbol_painter.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/render/chart_intro_symbol_render.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/widgets/chart_intro_symbol_view.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/nucleon.dart';
import 'package:kratos/chemistry/build_a_nucleus/screens/chart_intro_screen.dart';

void main() {
  late final NuclideTable table;
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    table = NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    repo = NuclideRepository(table);
  });

  ChartIntroSymbolRender fromState(ChartIntroState s) =>
      ChartIntroSymbolRender.fromCounts(
        protonCount: s.protonCount,
        massNumber: s.massNumber,
        elements: table.elements,
      );

  group('A / Z 语义', () {
    test('A 用传入的 massNumber，Render 不再加 p+n', () {
      final r = ChartIntroSymbolRender.from(
        protonCount: 1,
        massNumber: 99,
        elementSymbol: table.elements[1].symbol,
      );
      expect(r.a, 99);
      expect(r.massNumber, 99);
      expect(r.z, 1);
      expect(r.protonCount, 1);
      expect(r.symbol, 'H');
    });

    test('fromCounts：符号只读 ElementInfo，不经 Repository', () {
      final r = ChartIntroSymbolRender.fromCounts(
        protonCount: 6,
        massNumber: 14,
        elements: table.elements,
      );
      expect(r.symbol, table.elements[6].symbol);
      expect(r.symbol, 'C');
      expect(r.a, 14);
      expect(r.z, 6);
    });

    test('Chart Intro 无 charge', () {
      expect(ChartIntroSymbolRender.showsCharge, isFalse);
    });
  });

  group('状态 → 符号盒', () {
    test('0p0n：符号 -，A=0，Z=0', () {
      final s = ChartIntroState(repository: repo);
      final r = fromState(s);
      expect(s.massNumber, 0);
      expect(r.symbol, table.elements[0].symbol);
      expect(r.symbol, '-');
      expect(r.a, 0);
      expect(r.z, 0);
    });

    test('0p + 中子：符号仍是 -，A 随中子变，Z=0', () {
      final s = ChartIntroState(repository: repo);
      s.addImmediately(NucleonType.neutron);
      s.addImmediately(NucleonType.neutron);
      expect(s.nuclideExists, isFalse);
      final r = fromState(s);
      expect(r.symbol, '-');
      expect(r.z, 0);
      expect(r.a, s.massNumber);
      expect(r.a, 2);
    });

    test('1p → H；再加中子 A 增加、符号仍是 H', () {
      final s = ChartIntroState(repository: repo);
      s.addProton();
      expect(fromState(s).symbol, 'H');
      expect(fromState(s).a, 1);
      expect(fromState(s).z, 1);

      s.addNeutron();
      expect(fromState(s).symbol, 'H');
      expect(fromState(s).a, s.massNumber);
      expect(fromState(s).a, 2);
      expect(fromState(s).z, 1);
    });

    test('2p0n 不存在仍显示 He，A=2，Z=2', () {
      final s = ChartIntroState(repository: repo);
      s.addProton();
      s.addProton();
      expect(s.nuclideExists, isFalse);
      final r = fromState(s);
      expect(r.symbol, 'He');
      expect(r.a, 2);
      expect(r.z, 2);
    });

    test('10p + 任意 n：符号 Ne，A = p+n（来自 State.massNumber）', () {
      final s = ChartIntroState(repository: repo);
      for (var i = 0; i < 10; i++) {
        s.addImmediately(NucleonType.proton);
      }
      s.addImmediately(NucleonType.neutron);
      s.addImmediately(NucleonType.neutron);
      final r = fromState(s);
      expect(r.symbol, 'Ne');
      expect(r.z, 10);
      expect(r.a, s.massNumber);
      expect(r.a, 12);
    });

    test('Reset 后回到 - / 0 / 0', () {
      final s = ChartIntroState(repository: repo);
      s.addProton();
      s.addNeutron();
      s.reset();
      final r = fromState(s);
      expect(r.symbol, '-');
      expect(r.a, 0);
      expect(r.z, 0);
    });
  });

  group('Painter', () {
    test('shouldRepaint 只看 A / Z / 符号值', () {
      final a = ChartIntroSymbolRender.fromCounts(
        protonCount: 1,
        massNumber: 1,
        elements: table.elements,
      );
      final same = ChartIntroSymbolRender.fromCounts(
        protonCount: 1,
        massNumber: 1,
        elements: table.elements,
      );
      final changed = ChartIntroSymbolRender.fromCounts(
        protonCount: 1,
        massNumber: 2,
        elements: table.elements,
      );
      final p = ChartIntroSymbolPainter(render: a);
      expect(p.shouldRepaint(ChartIntroSymbolPainter(render: same)), isFalse);
      expect(p.shouldRepaint(ChartIntroSymbolPainter(render: changed)), isTrue);
    });
  });

  group('Screen 联动', () {
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

    ChartIntroSymbolRender box(WidgetTester tester) =>
        tester.widget<ChartIntroSymbolView>(
          find.byKey(const ValueKey('chart_intro_isotope_symbol')),
        ).render;

    testWidgets('0p0n 起：+p / +n 即时更新；Reset 恢复', (tester) async {
      final c = ChartIntroController(repository: repo);
      await pumpScreen(tester, c);

      expect(box(tester).symbol, '-');
      expect(box(tester).a, 0);
      expect(box(tester).z, 0);

      await tester.tap(find.byKey(const ValueKey('chart_intro_add_proton')));
      await tester.pump();
      expect(box(tester).symbol, 'H');
      expect(box(tester).z, 1);
      expect(box(tester).a, 1);

      await tester.tap(find.byKey(const ValueKey('chart_intro_add_neutron')));
      await tester.pump();
      expect(box(tester).symbol, 'H');
      expect(box(tester).z, 1);
      expect(box(tester).a, 2);

      await tester.tap(find.byKey(const ValueKey('chart_intro_reset')));
      await tester.pump();
      expect(box(tester).symbol, '-');
      expect(box(tester).a, 0);
      expect(box(tester).z, 0);

      await tester.tap(find.byKey(const ValueKey('chart_intro_add_proton')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('chart_intro_add_proton')));
      await tester.pump();
      expect(c.state.protonCount, 2);
      expect(c.state.neutronCount, 0);
      expect(c.state.nuclideExists, isFalse);
      expect(box(tester).symbol, 'He');
      expect(box(tester).z, 2);
      expect(box(tester).a, 2);
      c.dispose();
    });
  });
}
