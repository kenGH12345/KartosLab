import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/ban_constants.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/chart_intro_state.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/periodic_table_layout.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/periodic_table_reading.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';

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

  test('主表 90 格：7×18 骨架，无独立镧/锕行', () {
    expect(PeriodicTableLayout.rowCount, 7);
    expect(PeriodicTableLayout.columnCount, 18);
    expect(PeriodicTableLayout.seats, hasLength(90));
    expect(PeriodicTableLayout.isShown(58), isFalse);
    expect(PeriodicTableLayout.isShown(71), isFalse);
    expect(PeriodicTableLayout.isShown(90), isFalse);
    expect(PeriodicTableLayout.isShown(103), isFalse);
    expect(PeriodicTableLayout.isShown(57), isTrue);
    expect(PeriodicTableLayout.isShown(72), isTrue);
    expect(PeriodicTableLayout.isShown(89), isTrue);
    expect(PeriodicTableLayout.isShown(104), isTrue);
  });

  test('H / He / C / Fe / Ne / Og 行列', () {
    final h = PeriodicTableLayout.seatForAtomicNumber(1)!;
    expect(h.row, 0);
    expect(h.column, 0);

    final he = PeriodicTableLayout.seatForAtomicNumber(2)!;
    expect(he.row, 0);
    expect(he.column, 17);

    final c = PeriodicTableLayout.seatForAtomicNumber(6)!;
    expect(c.row, 1);
    expect(c.column, 13);

    final fe = PeriodicTableLayout.seatForAtomicNumber(26)!;
    expect(fe.row, 3);
    expect(fe.column, 7);

    final ne = PeriodicTableLayout.seatForAtomicNumber(10)!;
    expect(ne.row, 1);
    expect(ne.column, 17);
    expect(ne.atomicNumber, BanConstants.chartMaxProtons);

    final og = PeriodicTableLayout.seatForAtomicNumber(118)!;
    expect(og.row, 6);
    expect(og.column, 17);
  });

  test('符号/名来自 ElementInfo，不经核素存在性', () {
    final r = reading(0);
    expect(r.cellAtAtomicNumber(1)!.symbol, 'H');
    expect(r.cellAtAtomicNumber(1)!.name, 'Hydrogen');
    expect(r.cellAtAtomicNumber(2)!.symbol, 'He');
    expect(r.cellAtAtomicNumber(6)!.symbol, 'C');
    expect(r.cellAtAtomicNumber(26)!.symbol, 'Fe');
    expect(r.cellAtAtomicNumber(10)!.symbol, 'Ne');
    expect(r.cellAtAtomicNumber(118)!.symbol, 'Og');
    expect(r.cellAtAtomicNumber(58), isNull);
  });

  test('空核：无高亮', () {
    final r = reading(0);
    expect(r.highlightedAtomicNumber, isNull);
    expect(r.highlightedCell, isNull);
  });

  test('ChartIntroState：质子数 → 高亮 Z；无效核素仍高亮该元素', () {
    final s = ChartIntroState(repository: repo);
    expect(s.periodicTableHighlightZ, isNull);

    s.addProton();
    expect(s.protonCount, 1);
    expect(s.periodicTableHighlightZ, 1);
    expect(reading(s.protonCount).highlightedCell!.symbol, 'H');

    s.addProton();
    expect(s.protonCount, 2);
    expect(s.nuclideExists, isFalse);
    expect(s.periodicTableHighlightZ, 2);
    expect(reading(s.protonCount).highlightedCell!.symbol, 'He');
  });

  test('Reset：高亮清除', () {
    final s = ChartIntroState(repository: repo);
    s.addProton();
    s.reset();
    expect(s.periodicTableHighlightZ, isNull);
    expect(reading(s.protonCount).highlightedAtomicNumber, isNull);
  });

  test('Chart Intro 可点亮上限为 Ne（Z=10），表上仍有 Fe', () {
    expect(PeriodicTableLayout.chartIntroMaxAtomicNumber, 10);
    expect(PeriodicTableLayout.seatForAtomicNumber(26), isNotNull);
    expect(PeriodicTableLayout.seatForAtomicNumber(11), isNotNull);
  });
}
