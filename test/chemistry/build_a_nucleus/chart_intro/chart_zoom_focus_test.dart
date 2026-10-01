import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/ban_constants.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/chart_intro_visuals.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/controller/chart_intro_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/chart_intro_state.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/render/chart_focus_memory.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/render/chart_viewport.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/render/nuclide_chart_render.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/widgets/nuclide_chart_view.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/screens/chart_intro_screen.dart';

void main() {
  late final NuclideTable table;
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    table = NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    repo = NuclideRepository(table);
  });

  void buildUp(ChartIntroState s, int p, int n) {
    while (s.protonCount < p || s.neutronCount < n) {
      if (s.protonCount < p && s.neutronCount < n) {
        expect(s.addPair(), isTrue);
      } else if (s.protonCount < p) {
        expect(s.addProton(), isNotNull);
      } else {
        expect(s.addNeutron(), isNotNull);
      }
    }
  }

  group('取证锁死', () {
    test('Zoom 是 mode，不是 scale；默认 partial', () {
      final s = ChartIntroState(repository: repo);
      expect(s.selectedChart, ChartIntroChartType.partial);
      expect(ChartIntroChartType.values, [
        ChartIntroChartType.partial,
        ChartIntroChartType.zoom,
      ]);
    });

    test('Focused 不是 boolean，是 5×5 窗', () {
      expect(BanConstants.zoomInChartSquareLength, 5);
      expect(ChartIntroVisuals.focusedCellSize, 10);
      expect(ChartIntroVisuals.zoomCellSize, 30);
      expect(ChartIntroVisuals.partialCellSize, 18);
    });
  });

  group('Current nuclide 联动', () {
    test('1p0n → current cell 是 H-1', () {
      final s = ChartIntroState(repository: repo);
      s.addProton();
      expect(s.nuclideExists, isTrue);
      final r = NuclideChartRender.from(s, repo);
      expect(r.currentExists, isTrue);
      expect(r.currentCellVisual!.protonNumber, 1);
      expect(r.currentCellVisual!.neutronNumber, 0);
      expect(r.currentSymbol, 'H');
    });

    test('6p6n → focus / zoom 窗对准 (6,6)', () {
      final s = ChartIntroState(repository: repo);
      buildUp(s, 6, 6);
      expect(s.nuclideExists, isTrue);
      final mem = ChartFocusMemory()
        ..sync(
          protonCount: s.protonCount,
          neutronCount: s.neutronCount,
          exists: s.nuclideExists,
        );
      expect(mem.proton, 6);
      expect(mem.neutron, 6);

      final vp = ChartViewport.from(
        mem,
        cellSize: ChartIntroVisuals.zoomCellSize,
      );
      expect(vp.focusProton, 6);
      expect(vp.focusNeutron, 6);
      expect(vp.zoomCenterProton, 6);
      expect(vp.zoomCenterNeutron, 6);
      expect(vp.clipLocal.contains(Offset(
        6.5 * ChartIntroVisuals.zoomCellSize,
        (10 - 6 + 0.5) * ChartIntroVisuals.zoomCellSize,
      )), isTrue);
    });

    test('6p8n → focus 更新（C-14 存在）', () {
      final s = ChartIntroState(repository: repo);
      buildUp(s, 6, 6);
      final mem = ChartFocusMemory()
        ..sync(
          protonCount: 6,
          neutronCount: 6,
          exists: true,
        );
      s.addNeutron();
      s.addNeutron();
      expect(s.protonCount, 6);
      expect(s.neutronCount, 8);
      expect(s.nuclideExists, isTrue);
      mem.sync(
        protonCount: s.protonCount,
        neutronCount: s.neutronCount,
        exists: s.nuclideExists,
      );
      expect(mem.proton, 6);
      expect(mem.neutron, 8);
    });

    test('无效核素：focus 保持上一格', () {
      final s = ChartIntroState(repository: repo);
      s.addProton();
      final mem = ChartFocusMemory()
        ..sync(
          protonCount: 1,
          neutronCount: 0,
          exists: true,
        );
      s.addProton();
      expect(s.nuclideExists, isFalse);
      mem.sync(
        protonCount: s.protonCount,
        neutronCount: s.neutronCount,
        exists: s.nuclideExists,
      );
      expect(mem.proton, 1);
      expect(mem.neutron, 0);
    });
  });

  group('Zoom clip / Focused 变淡', () {
    test('1p0n zoom 中心夹紧到 (p=2,n=2)，窗仍盖住 H-1', () {
      final mem = ChartFocusMemory()
        ..sync(protonCount: 1, neutronCount: 0, exists: true);
      final vp = ChartViewport.from(mem, cellSize: 30);
      expect(vp.zoomCenterProton, 2);
      expect(vp.zoomCenterNeutron, 2);
      expect(vp.clipLocal.left, 0);
      expect(
        vp.clipLocal.width,
        BanConstants.zoomInChartSquareLength * 30,
      );
    });

    test('Focused：窗外格子 opacity 0.65', () {
      final s = ChartIntroState(repository: repo);
      buildUp(s, 6, 6);
      final mem = ChartFocusMemory()
        ..sync(protonCount: 6, neutronCount: 6, exists: true);
      final r = NuclideChartRender.from(
        s,
        repo,
        presentation: NuclideChartPresentation.focused,
        focus: mem,
      );
      ChartCellVisual cell(int p, int n) => r.cells.firstWhere(
            (c) => c.protonNumber == p && c.neutronNumber == n,
          );
      expect(cell(6, 6).opacity, 1);
      expect(cell(1, 0).opacity, ChartIntroVisuals.focusedDimOpacity);
    });

    test('Partial 不 clip、不 dim、cellSize 18', () {
      final r = NuclideChartRender.from(
        ChartIntroState(repository: repo)..addProton(),
        repo,
      );
      expect(r.presentation, NuclideChartPresentation.partial);
      expect(r.cellSize, 18);
      expect(r.viewport, isNull);
      expect(r.showAxes, isTrue);
      expect(r.cells.every((c) => c.opacity == 1), isTrue);
    });
  });

  group('Controller', () {
    test('selectChart + Reset 回 partial；focus 记忆保留', () {
      final c = ChartIntroController(repository: repo);
      expect(c.chartFocus.proton, 0);
      expect(c.chartFocus.initialized, isTrue);

      c.addProton();
      expect(c.chartFocus.proton, 1);
      expect(c.chartFocus.neutron, 0);

      c.selectChart(ChartIntroChartType.zoom);
      expect(c.state.selectedChart, ChartIntroChartType.zoom);

      c.reset();
      expect(c.state.selectedChart, ChartIntroChartType.partial);
      expect(c.state.protonCount, 0);
      expect(c.chartFocus.proton, 1);
      expect(c.chartFocus.neutron, 0);
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

    testWidgets('默认 Partial；切 Zoom 出现两张图；Reset 回 Partial', (tester) async {
      final c = ChartIntroController(repository: repo);
      await pumpScreen(tester, c);
      expect(find.byType(ChartIntroChartPanel), findsOneWidget);
      expect(find.byType(NuclideChartView), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('chart_intro_chart_zoom')));
      await tester.pump();
      expect(c.state.selectedChart, ChartIntroChartType.zoom);
      expect(find.byType(NuclideChartView), findsNWidgets(2));

      await tester.tap(find.byKey(const ValueKey('chart_intro_reset')));
      await tester.pump();
      expect(c.state.selectedChart, ChartIntroChartType.partial);
      expect(find.byType(NuclideChartView), findsOneWidget);
      expect(find.byKey(const ValueKey('chart_intro_full_chart')), findsOneWidget);
      expect(find.text('Decay'), findsNothing);
      c.dispose();
    });
  });
}
