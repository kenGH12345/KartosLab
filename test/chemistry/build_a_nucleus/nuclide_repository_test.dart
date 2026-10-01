import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/data/decay_type.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';

/// 逻辑测试：内联迷你数据表（与现有 scenario 测试同风格，不依赖 assets）。
///
/// 语义对照：shred `AtomInfoUtils` + build-a-nucleus `getAvailableDecaysAndPercents`。
void main() {
  group('NuclideTable.fromJson', () {
    test('完整解析各分区', () {
      final table = NuclideTable.fromJson(_miniJson());
      expect(table.version, 'test');
      expect(table.elements[1].symbol, 'H');
      expect(table.elements[1].name, 'Hydrogen');
      expect(table.stableNeutrons[1], [0, 1]);
      expect(table.halfLives[1]![2], 388781328.0);
      expect(table.halfLives[1]![3], isNull); // 条目存在但半衰期未知
      expect(table.decays[1]![2], {'B-': 100.0});
      expect(table.decays[0]![4], isNull); // 存在但衰变模式未知
      expect(table.electronCloudRadii[1], greaterThan(0));
    });
  });

  group('NuclideRepository（迷你表）', () {
    final repo = NuclideRepository(NuclideTable.fromJson(_miniJson()));

    test('isStable 查稳定表', () {
      expect(repo.isStable(1, 0), isTrue); // H-1
      expect(repo.isStable(1, 1), isTrue); // H-2
      expect(repo.isStable(1, 2), isFalse); // H-3
      expect(repo.isStable(0, 1), isFalse); // 自由中子不稳定
    });

    test('halfLife 三态：有值 / 未知 / 无条目', () {
      expect(repo.halfLife(1, 2).seconds, 388781328.0);
      expect(repo.halfLife(1, 3).hasEntry, isTrue);
      expect(repo.halfLife(1, 3).seconds, isNull);
      expect(repo.halfLife(9, 9).hasEntry, isFalse);
    });

    test('doesExist = 稳定 或 有半衰期条目', () {
      expect(repo.doesExist(1, 0), isTrue); // 稳定
      expect(repo.doesExist(1, 2), isTrue); // 有半衰期
      expect(repo.doesExist(1, 3), isTrue); // 半衰期未知但有条目
      expect(repo.doesExist(0, 0), isFalse); // 空核不存在
      expect(repo.doesExist(9, 9), isFalse);
    });

    test('邻位存在性判定', () {
      // 迷你表：Z=1 行有 N=2,3 条目；稳定表 Z=1 有 N=0,1
      expect(repo.doesNextIsotopeExist(1, 1), isTrue); // (1,2) 存在
      expect(repo.doesPreviousIsotopeExist(1, 1), isTrue); // (1,0) 稳定
      expect(repo.doesNextIsotoneExist(1, 0), isFalse); // (2,0) 无数据
      expect(repo.doesNextNuclideExist(0, 0), isTrue); // (1,1) 稳定
    });

    test('衰变映射：ENSDF 键 → 5 种类型', () {
      expect(repo.availableDecays(1, 2).single.type,
          NucleusDecayType.betaMinusDecay); // B-
      expect(repo.availableDecays(1, 3).single.type,
          NucleusDecayType.neutronEmission); // N
    });

    test('衰变映射：同类型已有非 null 条目则跳过后续键', () {
      // (2,2): {'EC+B+': 50, 'B+': 30} → 只保留首个 betaPlus
      final branches = repo.availableDecays(2, 2);
      expect(branches, hasLength(1));
      expect(branches.single.type, NucleusDecayType.betaPlusDecay);
      expect(branches.single.percent, 50.0);
    });

    test('衰变映射：同类型 null 条目不阻塞后续非 null 条目', () {
      // (2,3): {'EC': null, 'B+': 30} → 两个 betaPlus，排序后 30 在前
      final branches = repo.availableDecays(2, 3);
      expect(branches, hasLength(2));
      expect(branches[0].percent, 30.0);
      expect(branches[1].percent, isNull);
    });

    test('衰变映射：原项目忽略的 ENSDF 键不产生分支', () {
      // (3,1): {'B-N': 16, '2B-': 5} → 空
      expect(repo.availableDecays(3, 1), isEmpty);
    });

    test('衰变排序：分支比降序、null 最后、并列保持原顺序（稳定排序）', () {
      // (3,2): {'N': 20, 'A': 80, 'P': null}
      final branches = repo.availableDecays(3, 2);
      expect(branches.map((b) => b.type), [
        NucleusDecayType.alphaDecay,
        NucleusDecayType.neutronEmission,
        NucleusDecayType.protonEmission,
      ]);
      // (4,2): {'2P': 100, 'A': 100} → 并列保持表内顺序（Be-6 真实数据同构）
      expect(
        repo.availableDecays(4, 2).map((b) => b.type),
        [NucleusDecayType.protonEmission, NucleusDecayType.alphaDecay],
      );
    });

    test('衰变模式未知（条目为 null）返回空列表', () {
      expect(repo.availableDecays(0, 4), isEmpty);
    });

    test('元素符号与名称，含越界保护', () {
      expect(repo.elementSymbol(1), 'H');
      expect(repo.elementName(1), 'Hydrogen');
      expect(repo.elementSymbol(0), '-');
      expect(repo.elementName(0), '');
      expect(repo.elementSymbol(999), '-');
    });
  });

  group('真实数据锚点（assets/data/nuclide_table.json）', () {
    late final NuclideRepository repo;

    setUpAll(() {
      // flutter_test 在包根目录运行，直接读文件即可验证生成产物。
      final jsonStr =
          File('assets/data/nuclide_table.json').readAsStringSync();
      repo = NuclideRepository(
        NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
      );
    });

    test('锚点：H-3 / C-14 / 自由中子 / Be-6 / Pu-240 半衰期', () {
      expect(repo.halfLife(1, 2).seconds, 388781328.0); // H-3 ≈ 12.3 年
      expect(repo.halfLife(6, 8).seconds, 1.79874e11); // C-14 ≈ 5700 年
      expect(repo.halfLife(0, 1).seconds, 613.9); // 自由中子
      expect(repo.halfLife(4, 2).seconds, 4.95911e-21); // Be-6
      expect(repo.halfLife(94, 146).seconds, 2.07045e11); // Pu-240（Decay 屏上限）
    });

    test('锚点：稳定性', () {
      expect(repo.isStable(6, 6), isTrue); // C-12
      expect(repo.isStable(6, 7), isTrue); // C-13
      expect(repo.isStable(6, 8), isFalse); // C-14
      expect(repo.isStable(2, 2), isTrue); // He-4
    });

    test('锚点：存在性', () {
      expect(repo.doesExist(0, 0), isFalse); // 空核（视图层特例，非数据层）
      expect(repo.doesExist(0, 1), isTrue); // 自由中子
      expect(repo.doesExist(2, 3), isTrue); // He-5
      expect(repo.doesExist(94, 146), isTrue); // Pu-240
    });

    test('锚点：衰变分支', () {
      // H-3 → β- 100%
      expect(repo.availableDecays(1, 2).single.type,
          NucleusDecayType.betaMinusDecay);
      // Be-6 → 2P 100 + A 100（原版 Hollywood 特例的数据来源）
      expect(
        repo.availableDecays(4, 2).map((b) => b.type),
        [NucleusDecayType.protonEmission, NucleusDecayType.alphaDecay],
      );
      // 自由中子 → β- 100%
      expect(repo.availableDecays(0, 1).single.type,
          NucleusDecayType.betaMinusDecay);
      // 稳定核素无衰变
      expect(repo.availableDecays(6, 6), isEmpty);
    });

    test('锚点：元素表与电子云半径', () {
      expect(repo.elementSymbol(26), 'Fe');
      expect(repo.elementName(26), 'Iron');
      expect(repo.elementSymbol(94), 'Pu');
      expect(repo.electronCloudRadius(6), isNotNull);
      expect(repo.electronCloudRadius(6)!, greaterThan(0));
    });
  });
}

Map<String, dynamic> _miniJson() => {
      'version': 'test',
      'source': {
        'description': 'mini',
        'files': ['https://example.com'],
        'retrievedAt': '2026-08-28',
        'license': 'test',
      },
      'elements': [
        {'z': 0, 'symbol': '-', 'name': ''},
        {'z': 1, 'symbol': 'H', 'name': 'Hydrogen'},
      ],
      'stableNeutrons': [
        <int>[],
        [0, 1],
      ],
      'halfLives': {
        '0': {'1': 613.9, '4': 1.75476e-22},
        '1': {'2': 388781328, '3': null},
      },
      'decays': {
        '0': {
          '1': {'B-': 100},
          '4': null,
        },
        '1': {
          '2': {'B-': 100},
          '3': {'N': 100},
        },
        '2': {
          '2': {'EC+B+': 50, 'B+': 30},
          '3': {'EC': null, 'B+': 30},
        },
        '3': {
          '1': {'B-N': 16, '2B-': 5},
          '2': {'N': 20, 'A': 80, 'P': null},
        },
        '4': {
          '2': {'2P': 100, 'A': 100},
        },
      },
      'electronCloudRadii': {'0': 10.0, '1': 53.0},
    };
