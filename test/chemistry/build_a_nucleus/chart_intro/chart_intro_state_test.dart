import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/ban_constants.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/chart_intro_state.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/energy_level.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/populated_cells.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/shell_model_nucleus.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/nucleon.dart';

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
        expect(s.addPair(), isTrue,
            reason: 'addPair at ${s.protonCount},${s.neutronCount}');
      } else if (s.protonCount < p) {
        expect(s.addProton(), isNotNull,
            reason: 'addProton at ${s.protonCount},${s.neutronCount}');
      } else {
        expect(s.addNeutron(), isNotNull,
            reason: 'addNeutron at ${s.protonCount},${s.neutronCount}');
      }
    }
  }

  group('proton / neutron', () {
    test('初始 0p0n', () {
      final s = newState();
      expect(s.protonCount, 0);
      expect(s.neutronCount, 0);
      expect(s.massNumber, 0);
      expect(s.isEmptyNucleus, isTrue);
    });

    test('+1 / -1', () {
      final s = newState();
      expect(s.addProton(), isNotNull);
      expect(s.protonCount, 1);
      expect(s.addNeutron(), isNotNull);
      expect(s.neutronCount, 1);
      expect(s.removeProton(), isTrue);
      expect(s.protonCount, 0);
      expect(s.removeNeutron(), isTrue);
      expect(s.neutronCount, 0);
    });

    test('下限 0：空核不能减', () {
      final s = newState();
      expect(s.removeProton(), isFalse);
      expect(s.removeNeutron(), isFalse);
      expect(s.protonCount, 0);
      expect(s.neutronCount, 0);
    });

    test('质子上限 10', () {
      final s = newState();
      buildUp(s, BanConstants.chartMaxProtons, 5);
      expect(s.protonCount, 10);
      expect(s.canAddProton, isFalse);
      expect(s.addProton(), isNull);
      expect(s.protonCount, 10);
    });

    test('中子上限 12', () {
      final s = newState();
      buildUp(s, 4, BanConstants.chartMaxNeutrons);
      expect(s.neutronCount, 12);
      expect(s.canAddNeutron, isFalse);
      expect(s.addNeutron(), isNull);
      expect(s.neutronCount, 12);
    });

    test('箭头 enable：0p0n 可加不可减', () {
      final s = newState();
      expect(s.canAddProton, isTrue);
      expect(s.canAddNeutron, isTrue);
      expect(s.canRemoveProton, isFalse);
      expect(s.canRemoveNeutron, isFalse);
    });

    test('上箭头允许越界 1 个进入不存在态，之后全部禁用', () {
      final s = newState();
      expect(s.addNeutron(), isNotNull); // (0,1) 自由中子
      expect(s.canAddNeutron, isTrue);
      expect(s.addNeutron(), isNotNull); // (0,2) 不存在
      expect(s.isShowingInvalidNuclide, isTrue);
      expect(s.canAddProton, isFalse);
      expect(s.canAddNeutron, isFalse);
      expect(s.addNeutron(), isNull);
    });
  });

  group('Nuclide lookup', () {
    test('有效组合 H-1：存在、稳定、元素与质量数', () {
      final s = newState();
      s.addProton();
      expect(s.nuclideExists, isTrue);
      expect(s.isStable, isTrue);
      expect(s.elementSymbol, 'H');
      expect(s.elementName, 'Hydrogen');
      expect(s.massNumber, 1);
    });

    test('无效组合 (0,2)：不存在，元素仍按质子', () {
      final s = newState();
      s.addNeutron();
      s.addNeutron();
      expect(s.nuclideExists, isFalse);
      expect(s.isShowingInvalidNuclide, isTrue);
      expect(s.elementSymbol, '-');
      expect(s.massNumber, 2);
    });

    test('元素随质子变化：H → He', () {
      final s = newState();
      buildUp(s, 2, 2);
      expect(s.elementSymbol, 'He');
      expect(s.elementName, 'Helium');
      expect(s.massNumber, 4);
      expect(s.nuclideExists, isTrue);
    });

    test('不复制核素表：查表走 Repository', () {
      final s = newState();
      buildUp(s, 6, 6);
      expect(s.elementSymbol, repo.elementSymbol(6));
      expect(s.nuclideExists, repo.doesExist(6, 6));
      expect(s.isStable, repo.isStable(6, 6));
    });
  });

  group('Chart', () {
    test('X = neutron，Y = proton', () {
      final cell = PopulatedCells.cellAt(2, 2)!;
      expect(cell.x, 2);
      expect(cell.y, 2);
      expect(cell.neutronNumber, cell.x);
      expect(cell.protonNumber, cell.y);
    });

    test('populated / empty', () {
      expect(PopulatedCells.isPopulated(1, 0), isTrue); // H-1
      expect(PopulatedCells.isPopulated(0, 0), isFalse); // 空核不画格
      expect(PopulatedCells.isPopulated(2, 2), isTrue); // He-4
      expect(PopulatedCells.isPopulated(1, 8), isFalse);
    });

    test('当前 cell 随 p/n 更新', () {
      final s = newState();
      expect(s.currentCell, isNull);
      expect(s.currentCellPopulated, isFalse);
      s.addProton();
      expect(s.currentCell, isNotNull);
      expect(s.currentCell!.x, 0);
      expect(s.currentCell!.y, 1);
      s.addNeutron();
      expect(s.currentCell!.x, 1);
      expect(s.currentCell!.y, 1);
      for (var i = 0; i < 5; i++) {
        expect(s.addNeutron(), isNotNull);
      }
      expect(s.protonCount, 1);
      expect(s.neutronCount, 6);
      expect(s.currentCellPopulated, isTrue); // p=1 行含 n=6
      expect(s.addNeutron(), isNotNull); // (1,7) 不在 POPULATED_CELLS
      expect(s.currentCell, isNull);
    });
  });

  group('Shell', () {
    test('三层座位始终存在', () {
      final shell = ShellModelNucleus();
      expect(shell.levelCount, 3);
      expect(shell.seatsOf(NucleonType.proton).length, 3);
      expect(shell.seatsOf(NucleonType.neutron).length, 3);
      expect(
        shell.seatsOf(NucleonType.proton).map((r) => r.length).toList(),
        [2, 6, 6],
      );
    });

    test('初始空座', () {
      final shell = ShellModelNucleus();
      expect(shell.protonCount, 0);
      expect(shell.neutronCount, 0);
      expect(shell.protonFillLevel, EnergyLevel.n0);
      for (final row in shell.seatsOf(NucleonType.proton)) {
        expect(row.every((seat) => seat.isEmpty), isTrue);
      }
    });

    test('p/n 更新填座：n0 居中 x=2,3', () {
      final shell = ShellModelNucleus();
      shell.add(NucleonType.proton);
      expect(shell.protons.single.yPosition, 0);
      expect(shell.protons.single.xPosition, 2);
      expect(shell.protons.single.bound, isFalse);
      shell.add(NucleonType.proton);
      expect(shell.protons.last.xPosition, 3);
      expect(shell.protons.every((n) => n.yPosition == 0), isTrue);
    });

    test('第 3 个质子上 n1，n0 绑定', () {
      final shell = ShellModelNucleus();
      for (var i = 0; i < 3; i++) {
        shell.add(NucleonType.proton);
      }
      expect(shell.protonFillLevel, EnergyLevel.n1);
      expect(shell.protons.where((n) => n.yPosition == 0).every((n) => n.bound),
          isTrue);
      expect(shell.protons.last.yPosition, 1);
      expect(shell.protons.last.bound, isFalse);
    });

    test('边界：10 质子占到 n2，12 中子占到 n2', () {
      final shell = ShellModelNucleus();
      for (var i = 0; i < 10; i++) {
        expect(shell.add(NucleonType.proton), isNotNull);
      }
      expect(shell.protonCount, 10);
      expect(shell.protonFillLevel, EnergyLevel.n2);
      expect(shell.protons.where((n) => n.yPosition == 2).length, 2);
      for (var i = 0; i < 12; i++) {
        expect(shell.add(NucleonType.neutron), isNotNull);
      }
      expect(shell.neutronCount, 12);
      expect(shell.neutrons.where((n) => n.yPosition == 2).length, 4);
    });

    test('removeLast 取最高层最右', () {
      final shell = ShellModelNucleus();
      for (var i = 0; i < 3; i++) {
        shell.add(NucleonType.proton);
      }
      final last = shell.getLastInShell(NucleonType.proton)!;
      expect(last.yPosition, 1);
      shell.removeLast(NucleonType.proton);
      expect(shell.protonCount, 2);
      expect(shell.protons.every((n) => n.yPosition == 0), isTrue);
      expect(shell.protons.every((n) => !n.bound), isTrue);
    });
  });

  group('Reset', () {
    test('修改 → reset → 初始状态', () {
      final s = newState();
      buildUp(s, 2, 2);
      s.selectedChart = ChartIntroChartType.zoom;
      s.reset();
      expect(s.protonCount, 0);
      expect(s.neutronCount, 0);
      expect(s.selectedChart, ChartIntroChartType.partial);
      expect(s.currentCell, isNull);
      expect(s.miniAtom.protonCount, 0);
      expect(s.miniAtom.neutronCount, 0);
      expect(s.shell.protons, isEmpty);
    });
  });

  group('Mini-atom 派生', () {
    test('与壳层计数相同，不可交互，无第二粒子列表', () {
      final s = newState();
      buildUp(s, 2, 1);
      expect(s.miniAtom.protonCount, s.protonCount);
      expect(s.miniAtom.neutronCount, s.neutronCount);
      expect(s.miniAtom.massNumber, 3);
      expect(s.miniAtom.interactive, isFalse);
    });
  });

  group('生命周期', () {
    test('无 listener；dispose 后不再更新', () {
      final s = newState();
      s.addProton();
      s.dispose();
      expect(s.isDisposed, isTrue);
      expect(s.addProton(), isNull);
      expect(s.addNeutron(), isNull);
      expect(s.removeProton(), isFalse);
      expect(s.reset, returnsNormally);
      expect(s.protonCount, 1);
    });
  });
}
