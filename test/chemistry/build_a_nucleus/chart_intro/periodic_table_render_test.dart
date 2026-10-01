import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/chart_intro/chart_intro_visuals.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/chart_intro_state.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/periodic_table_layout.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/periodic_table_reading.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/render/chart_intro_symbol_render.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/render/periodic_table_panel_geometry.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/render/periodic_table_render.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/widgets/chart_intro_symbol_view.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/widgets/periodic_table_view.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/nucleon.dart';

void main() {
  late final NuclideTable table;
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    table = NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    repo = NuclideRepository(table);
  });

  PeriodicTableReading reading(int protonCount) => PeriodicTableReading.from(
        protonCount: protonCount,
        elements: table.elements,
      );

  PeriodicTableRender renderOf(int protonCount) =>
      PeriodicTableRender.from(reading(protonCount));

  ChartIntroSymbolRender symbolOf(int p, int n) =>
      ChartIntroSymbolRender.fromCounts(
        protonCount: p,
        massNumber: p + n,
        elements: table.elements,
      );

  group('Geometry', () {
    test('第一周期：仅 H、He，中间空白不画格', () {
      final r = renderOf(0);
      final row = r.cellsInRow(0).toList();
      expect(row, hasLength(2));
      expect(row.map((c) => c.column), [0, 17]);
      expect(r.cellAtGrid(1, 0), isNull);
      expect(r.cellAtGrid(8, 0), isNull);
      expect(r.cellAtGrid(16, 0), isNull);
    });

    test('第二周期：8 格，Li–Ne', () {
      final r = renderOf(0);
      final row = r.cellsInRow(1).toList();
      expect(row, hasLength(8));
      expect(row.map((c) => c.column), [0, 1, 12, 13, 14, 15, 16, 17]);
      expect(r.cellAtGrid(2, 1), isNull);
    });

    test('第七周期：满 18 族', () {
      final r = renderOf(0);
      expect(r.cellsInRow(6), hasLength(18));
    });

    test('第 18 族：He 到 Og 共 7 格', () {
      final r = renderOf(0);
      final col = r.cellsInColumn(17).toList();
      expect(col, hasLength(7));
      expect(col.map((c) => c.symbol), ['He', 'Ne', 'Ar', 'Kr', 'Xe', 'Rn', 'Og']);
    });

    test('H / He / C / Ne / Fe / Og 像素矩形', () {
      const s = ChartIntroVisuals.periodicTableCellSize;
      final r = renderOf(0);

      expect(r.cellAtAtomicNumber(1)!.rect, const Rect.fromLTWH(0, 0, s, s));
      expect(r.cellAtAtomicNumber(2)!.rect, const Rect.fromLTWH(17 * s, 0, s, s));
      expect(
        r.cellAtAtomicNumber(6)!.rect,
        const Rect.fromLTWH(13 * s, s, s, s),
      );
      expect(
        r.cellAtAtomicNumber(10)!.rect,
        const Rect.fromLTWH(17 * s, s, s, s),
      );
      expect(
        r.cellAtAtomicNumber(26)!.rect,
        const Rect.fromLTWH(7 * s, 3 * s, s, s),
      );
      expect(
        r.cellAtAtomicNumber(118)!.rect,
        const Rect.fromLTWH(17 * s, 6 * s, s, s),
      );
    });
  });

  group('Highlight', () {
    test('0p0n → 无高亮', () {
      final r = renderOf(0);
      expect(r.highlightedAtomicNumber, isNull);
      expect(r.highlightedCell, isNull);
      expect(r.cells.where((c) => c.highlighted), isEmpty);
    });

    test('1p → H', () {
      final r = renderOf(1);
      expect(r.highlightedCell!.symbol, 'H');
      expect(r.highlightedCell!.atomicNumber, 1);
    });

    test('2p → He', () {
      expect(renderOf(2).highlightedCell!.symbol, 'He');
    });

    test('6p → C', () {
      expect(renderOf(6).highlightedCell!.symbol, 'C');
    });

    test('10p → Ne', () {
      expect(renderOf(10).highlightedCell!.symbol, 'Ne');
    });

    test('10p + 任意 neutron → 仍是 Ne', () {
      final s = ChartIntroState(repository: repo);
      for (var i = 0; i < 10; i++) {
        expect(s.addImmediately(NucleonType.proton), isNotNull);
      }
      s.addImmediately(NucleonType.neutron);
      s.addImmediately(NucleonType.neutron);
      expect(s.protonCount, 10);
      expect(s.neutronCount, 2);
      expect(s.periodicTableHighlightZ, 10);
      expect(renderOf(s.protonCount).highlightedCell!.symbol, 'Ne');
    });

    test('2p0n 不存在仍高亮 He', () {
      final s = ChartIntroState(repository: repo);
      s.addProton();
      s.addProton();
      expect(s.protonCount, 2);
      expect(s.neutronCount, 0);
      expect(s.nuclideExists, isFalse);
      expect(s.periodicTableHighlightZ, 2);
      final r = renderOf(s.protonCount);
      expect(r.highlightedCell!.symbol, 'He');
      expect(r.cells.where((c) => c.highlighted), hasLength(1));
    });

    test('高亮只改对应 cell 的填色 / 标签，其它格仍是 disabled 白', () {
      final r = renderOf(6);
      final c = r.highlightedCell!;
      expect(c.fill, ChartIntroVisuals.periodicTableHighlightFill);
      expect(c.stroke, ChartIntroVisuals.periodicTableHighlightStroke);
      expect(c.labelColor, ChartIntroVisuals.periodicTableHighlightLabel);
      expect(c.labelWeight, FontWeight.bold);

      final fe = r.cellAtAtomicNumber(26)!;
      expect(fe.highlighted, isFalse);
      expect(fe.fill, ChartIntroVisuals.periodicTableDisabledFill);
      expect(fe.labelColor, ChartIntroVisuals.periodicTableLabel);
      expect(fe.labelWeight, FontWeight.normal);
    });
  });

  group('Render', () {
    test('90 格存在；镧锕空白不画格', () {
      final r = renderOf(0);
      expect(r.cells, hasLength(90));
      expect(r.cellAtAtomicNumber(58), isNull);
      expect(r.cellAtAtomicNumber(71), isNull);
      expect(r.cellAtAtomicNumber(90), isNull);
      expect(r.cellAtAtomicNumber(103), isNull);
      expect(r.cellAtAtomicNumber(57), isNotNull);
      expect(r.cellAtAtomicNumber(72), isNotNull);
    });

    test('Z>10 仍画（Fe / Og），不是「不显示」', () {
      final r = renderOf(10);
      expect(r.cellAtAtomicNumber(26)!.symbol, 'Fe');
      expect(r.cellAtAtomicNumber(118)!.symbol, 'Og');
      expect(r.cellAtAtomicNumber(26)!.highlighted, isFalse);
    });

    test('符号来自 ElementInfo', () {
      final r = renderOf(0);
      expect(r.cellAtAtomicNumber(1)!.symbol, 'H');
      expect(r.cellAtAtomicNumber(2)!.symbol, 'He');
      expect(r.cellAtAtomicNumber(6)!.symbol, 'C');
      expect(r.cellAtAtomicNumber(10)!.symbol, 'Ne');
      expect(r.cellAtAtomicNumber(26)!.symbol, 'Fe');
      expect(r.cellAtAtomicNumber(118)!.symbol, 'Og');
    });

    test('无额外 cell gap', () {
      expect(ChartIntroVisuals.periodicTableCellGap, 0);
      final r = renderOf(0);
      final h = r.cellAtAtomicNumber(1)!;
      expect(h.rect.left, 0);
      expect(h.rect.width, ChartIntroVisuals.periodicTableCellSize);
    });

    test('符号盒：空核为 -；2p0n 仍是 He', () {
      expect(symbolOf(0, 0).symbol, '-');
      expect(symbolOf(0, 0).protonCount, 0);
      expect(symbolOf(0, 0).massNumber, 0);

      expect(symbolOf(2, 0).symbol, 'He');
      expect(symbolOf(2, 0).massNumber, 2);
      expect(symbolOf(10, 12).symbol, 'Ne');
      expect(symbolOf(10, 12).massNumber, 22);
    });

    test('面板叠层：符号对准第 8 列中心', () {
      final table = PeriodicTablePanelGeometry.tablePaintedSize;
      expect(
        PeriodicTablePanelGeometry.symbolCenterX,
        (7.5 / PeriodicTableLayout.columnCount) * table.width,
      );
      expect(PeriodicTablePanelGeometry.tableLeft, 0);
      expect(PeriodicTablePanelGeometry.symbolTop, 0);
      expect(
        PeriodicTablePanelGeometry.tableTop,
        PeriodicTablePanelGeometry.symbolPaintedSize.height -
            (table.height / 7) * 2.5,
      );
    });
  });

  group('Widget', () {
    Future<void> pump(WidgetTester tester, Widget child) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: Center(child: child)),
          ),
        ),
      );
    }

    testWidgets('周期表与符号盒可泵出且 IgnorePointer', (tester) async {
      final s = ChartIntroState(repository: repo);
      s.addProton();
      s.addProton();
      await pump(
        tester,
        PeriodicTableAndSymbolView.fromState(s, table.elements),
      );
      expect(find.byType(PeriodicTableView), findsOneWidget);
      expect(find.byType(ChartIntroSymbolView), findsOneWidget);
      expect(find.byType(IgnorePointer), findsWidgets);
    });

    testWidgets('空核：表在、无高亮', (tester) async {
      final s = ChartIntroState(repository: repo);
      await pump(
        tester,
        PeriodicTableView.fromReading(reading(s.protonCount)),
      );
      final view = tester.widget<PeriodicTableView>(
        find.byType(PeriodicTableView),
      );
      expect(view.render.cells, hasLength(90));
      expect(view.render.highlightedCell, isNull);
    });
  });
}
