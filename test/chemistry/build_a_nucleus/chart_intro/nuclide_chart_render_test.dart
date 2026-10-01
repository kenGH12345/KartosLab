import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/chart_intro/chart_intro_visuals.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/chart_intro_state.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/populated_cells.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/render/nuclide_chart_render.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/decay_type.dart';
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

  ChartIntroState newState() => ChartIntroState(repository: repo);

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

  NuclideChartRender renderOf(ChartIntroState s) =>
      NuclideChartRender.from(s, repo);

  group('坐标', () {
    test('X = neutron，Y = proton；Y 翻转后 p 大者在上', () {
      final s = newState();
      final r = renderOf(s);
      expect(r.cellTopLeft(10, 0).dy, 0);
      expect(r.cellTopLeft(0, 0).dy, 10 * r.cellSize);
      expect(r.cellTopLeft(0, 5).dx, 5 * r.cellSize);
      expect(r.cellCenter(1, 0).dx, r.cellSize / 2);
    });

    test('格子边长 18，无额外间距', () {
      final r = renderOf(newState());
      expect(r.cellSize, ChartIntroVisuals.partialCellSize);
      expect(
        r.cellTopLeft(1, 1) - r.cellTopLeft(1, 0),
        Offset(r.cellSize, 0),
      );
    });
  });

  group('稀疏格子', () {
    test('cells 与 POPULATED_CELLS 一一对应，0p0n 无格', () {
      final r = renderOf(newState());
      expect(r.cells.length, PopulatedCells.allCells.length);
      expect(
        r.cells.any((c) => c.protonNumber == 0 && c.neutronNumber == 0),
        isFalse,
      );
      expect(PopulatedCells.isPopulated(0, 0), isFalse);
    });

    test('空白格不进入 cells', () {
      final r = renderOf(newState());
      expect(
        r.cells.any((c) => c.protonNumber == 1 && c.neutronNumber == 8),
        isFalse,
      );
    });

    test('当前 cell 随 p/n 更新；不存在则无标签', () {
      final s = newState();
      var r = renderOf(s);
      expect(r.currentExists, isFalse);
      expect(r.currentSymbol, '');
      expect(r.currentCellVisual, isNull);

      s.addProton();
      r = renderOf(s);
      expect(r.currentExists, isTrue);
      expect(r.currentSymbol, 'H');
      expect(r.currentCellVisual, isNotNull);
      expect(r.currentCellVisual!.x, 0);
      expect(r.currentCellVisual!.y, 1);
    });
  });

  group('颜色', () {
    test('H-1 稳定 = stable 深蓝', () {
      final s = newState();
      s.addProton();
      final cell = renderOf(s).currentCellVisual!;
      expect(cell.kind, ChartCellKind.stable);
      expect(cell.color, ChartIntroVisuals.stable);
      expect(cell.decayType, isNull);
    });

    test('He-4 稳定', () {
      final s = newState();
      buildUp(s, 2, 2);
      expect(renderOf(s).currentCellVisual!.kind, ChartCellKind.stable);
    });

    test('格子色 = availableDecays.first，不另建表', () {
      final s = newState();
      buildUp(s, 4, 4); // Be-8
      final cell = renderOf(s).currentCellVisual!;
      final first = repo.availableDecays(4, 4).first;
      expect(cell.decayType, first.type);
      expect(
        cell.color,
        ChartIntroVisuals.colorForDecay(first.type, isStable: false),
      );
      expect(first.type, NucleusDecayType.alphaDecay);
      expect(cell.color, ChartIntroVisuals.alpha);
    });

    test('稳定标签白字，α 标签黑字', () {
      final s = newState();
      s.addProton();
      expect(renderOf(s).currentLabelFill, const Color(0xFFFFFFFF));
      buildUp(s, 4, 4);
      expect(renderOf(s).currentLabelFill, const Color(0xFF000000));
    });
  });

  group('POPULATED_CELLS vs doesExist', () {
    test('0–10p × 0–12n 内 doesExist 但不在白名单的格子', () {
      final missing = <(int, int)>[];
      for (var p = 0; p <= 10; p++) {
        for (var n = 0; n <= 12; n++) {
          if (repo.doesExist(p, n) && !PopulatedCells.isPopulated(p, n)) {
            missing.add((p, n));
          }
        }
      }
      // 记录事实，不猜。0p0n 不存在故不会出现。
      expect(missing, isEmpty,
          reason: '存在但不在 POPULATED_CELLS：$missing');
    });
  });
}
