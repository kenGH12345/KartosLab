import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/chart_intro_state.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/widgets/chart_intro_symbol_view.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/widgets/mini_atom_view.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/widgets/nuclide_chart_view.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/widgets/periodic_table_view.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/widgets/shell_nucleus_view.dart';
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

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: Center(child: child)),
        ),
      ),
    );
  }

  testWidgets('空核：三块静态视图都能泵出', (tester) async {
    final s = ChartIntroState(repository: repo);
    await pump(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniAtomView.fromState(s, repo),
          ShellNucleusView.fromState(s),
          NuclideChartView.fromState(s, repo),
          PeriodicTableAndSymbolView.fromState(s, repo.table.elements),
          const NuclideChartLegend(),
        ],
      ),
    );
    expect(find.byType(MiniAtomView), findsOneWidget);
    expect(find.byType(ShellNucleusView), findsOneWidget);
    expect(find.byType(NuclideChartView), findsOneWidget);
    expect(find.byType(PeriodicTableView), findsOneWidget);
    expect(find.text('Stable'), findsOneWidget);
  });

  testWidgets('He-4：壳层与图随状态更新且 IgnorePointer', (tester) async {
    final s = ChartIntroState(repository: repo);
    s.addProton();
    s.addProton();
    s.addNeutron();
    s.addNeutron();
    await pump(tester, ShellNucleusView.fromState(s));
    expect(find.byType(IgnorePointer), findsWidgets);
    expect(s.miniAtom.interactive, isFalse);
  });
}
