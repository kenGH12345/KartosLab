import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/chart_intro/chart_intro_visuals.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/controller/chart_intro_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/chart_intro_state.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/widgets/full_chart_dialog.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/screens/chart_intro_screen.dart';

void main() {
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    repo = NuclideRepository(
      NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  });

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

  test('静态资源存在，不是运行时画图', () {
    expect(File(ChartIntroVisuals.fullChartAsset).existsSync(), isTrue);
    expect(ChartIntroVisuals.fullChartImageMaxWidth, 481.5);
    expect(ChartIntroVisuals.fullChartSourceWidth, 1948);
    expect(ChartIntroVisuals.fullChartSourceHeight, 1367);
  });

  testWidgets('按钮始终在；打开不改 selectedChart / focus / 当前核素', (tester) async {
    final c = ChartIntroController(repository: repo);
    c.addProton();
    c.selectChart(ChartIntroChartType.zoom);
    await pumpScreen(tester, c);

    expect(find.byKey(const ValueKey('chart_intro_full_chart')), findsOneWidget);
    expect(c.state.selectedChart, ChartIntroChartType.zoom);
    expect(c.state.protonCount, 1);
    expect(c.chartFocus.proton, 1);

    await tester.ensureVisible(find.byKey(const ValueKey('chart_intro_full_chart')));
    await tester.tap(find.byKey(const ValueKey('chart_intro_full_chart')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('chart_intro_full_chart_dialog')), findsOneWidget);
    expect(find.byKey(const ValueKey('chart_intro_full_chart_image')), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsNothing);
    expect(c.state.selectedChart, ChartIntroChartType.zoom);
    expect(c.state.protonCount, 1);
    expect(c.chartFocus.proton, 1);

    c.reset();
    await tester.pump();
    expect(find.byKey(const ValueKey('chart_intro_full_chart_dialog')), findsOneWidget);
    expect(c.state.selectedChart, ChartIntroChartType.partial);

    await tester.tap(find.byKey(const ValueKey('chart_intro_full_chart_close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('chart_intro_full_chart_dialog')), findsNothing);
    c.dispose();
  });

  testWidgets('点遮罩关闭', (tester) async {
    final c = ChartIntroController(repository: repo);
    await pumpScreen(tester, c);
    await tester.ensureVisible(find.byKey(const ValueKey('chart_intro_full_chart')));
    await tester.tap(find.byKey(const ValueKey('chart_intro_full_chart')));
    await tester.pumpAndSettle();
    expect(find.byType(FullChartDialog), findsOneWidget);

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.byType(FullChartDialog), findsNothing);
    expect(c.state.selectedChart, ChartIntroChartType.partial);
    c.dispose();
  });
}
