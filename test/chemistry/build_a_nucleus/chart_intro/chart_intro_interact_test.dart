import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/ban_constants.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/controller/chart_intro_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/render/mini_atom_render.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/render/nuclide_chart_render.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/render/shell_nucleus_render.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/widgets/chart_intro_interact_view.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';

void main() {
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    repo = NuclideRepository(
      NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  });

  Future<ChartIntroController> pumpView(WidgetTester tester) async {
    final c = ChartIntroController(repository: repo);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChartIntroInteractView(controller: c, tickOnClock: false),
        ),
      ),
    );
    return c;
  }

  Future<void> tapKey(WidgetTester tester, Key key) async {
    final f = find.byKey(key);
    await tester.ensureVisible(f);
    await tester.tap(f);
    await tester.pump();
  }

  testWidgets('点质子 +：读数 / 元素 / 壳层 / 图 / mini-atom 同步', (tester) async {
    final c = await pumpView(tester);
    expect(find.text('质子: 0'), findsOneWidget);
    expect(find.byKey(const ValueKey('chart_intro_element')), findsNothing);

    await tapKey(tester, const ValueKey('chart_intro_add_proton'));

    expect(find.text('质子: 1'), findsOneWidget);
    expect(find.text('Hydrogen - 1'), findsOneWidget);
    expect(c.state.protonCount, 1);
    expect(c.state.currentCell!.y, 1);
    expect(c.state.currentCell!.x, 0);
    expect(ShellNucleusRender.from(c.state).protonColumn.nucleons, hasLength(1));
    expect(MiniAtomRender.from(c.state, repo).nucleons, hasLength(1));
    expect(
      NuclideChartRender.from(c.state, repo).currentSymbol,
      'H',
    );
    c.dispose();
  });

  testWidgets('空核：减号禁用；加中子后可减', (tester) async {
    final c = await pumpView(tester);
    expect(
      tester.widget<IconButton>(
        find.byKey(const ValueKey('chart_intro_remove_proton')),
      ).onPressed,
      isNull,
    );
    expect(
      tester.widget<IconButton>(
        find.byKey(const ValueKey('chart_intro_remove_neutron')),
      ).onPressed,
      isNull,
    );

    await tapKey(tester, const ValueKey('chart_intro_add_neutron'));
    expect(find.text('中子: 1'), findsOneWidget);
    expect(
      tester.widget<IconButton>(
        find.byKey(const ValueKey('chart_intro_remove_neutron')),
      ).onPressed,
      isNotNull,
    );

    await tapKey(tester, const ValueKey('chart_intro_remove_neutron'));
    expect(find.text('中子: 0'), findsOneWidget);
    c.dispose();
  });

  testWidgets('核素图点击不改 State', (tester) async {
    final c = await pumpView(tester);
    await tapKey(tester, const ValueKey('chart_intro_add_proton'));
    await tester.tap(
      find.byKey(const ValueKey('chart_intro_chart')),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(c.state.protonCount, 1);
    expect(c.state.neutronCount, 0);
    c.dispose();
  });

  testWidgets('Reset 清计数并恢复空核渲染', (tester) async {
    final c = await pumpView(tester);
    await tapKey(tester, const ValueKey('chart_intro_add_proton'));
    await tapKey(tester, const ValueKey('chart_intro_add_neutron'));
    expect(find.text('质子: 1'), findsOneWidget);

    await tapKey(tester, const ValueKey('chart_intro_reset'));
    expect(find.text('质子: 0'), findsOneWidget);
    expect(find.text('中子: 0'), findsOneWidget);
    expect(find.byKey(const ValueKey('chart_intro_element')), findsNothing);
    expect(c.state.isEmptyNucleus, isTrue);
    expect(MiniAtomRender.from(c.state, repo).showEmptyCircle, isTrue);
    c.dispose();
  });

  testWidgets('不存在核素：does not form，箭头全禁，图无当前格', (tester) async {
    final c = await pumpView(tester);
    await tapKey(tester, const ValueKey('chart_intro_add_neutron'));
    await tapKey(tester, const ValueKey('chart_intro_add_neutron'));

    expect(find.text('2 neutrons does not form'), findsOneWidget);
    expect(c.state.isShowingInvalidNuclide, isTrue);
    expect(c.state.currentCell, isNull);
    expect(
      NuclideChartRender.from(c.state, repo).currentExists,
      isFalse,
    );
    expect(
      tester.widget<IconButton>(
        find.byKey(const ValueKey('chart_intro_add_proton')),
      ).onPressed,
      isNull,
    );
    expect(
      tester.widget<IconButton>(
        find.byKey(const ValueKey('chart_intro_add_neutron')),
      ).onPressed,
      isNull,
    );
    c.dispose();
  });

  testWidgets('质子加到上限 10 后 + 禁用', (tester) async {
    final c = await pumpView(tester);
    for (var i = 0; i < BanConstants.chartMaxProtons; i++) {
      await tapKey(tester, const ValueKey('chart_intro_add_proton'));
      if (c.state.canAddNeutron) {
        await tapKey(tester, const ValueKey('chart_intro_add_neutron'));
      }
    }
    expect(c.state.protonCount, BanConstants.chartMaxProtons);
    expect(
      tester.widget<IconButton>(
        find.byKey(const ValueKey('chart_intro_add_proton')),
      ).onPressed,
      isNull,
    );
    c.dispose();
  });
}
