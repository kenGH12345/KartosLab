/// 核素查询仓库：对标 shred `AtomInfoUtils` 与 build-a-nucleus
/// `getAvailableDecaysAndPercents` 的查询语义。
///
/// 所有判定均为查表，无物理推演；数据见 [NuclideTable]。
library;

import 'decay_type.dart';
import 'nuclide_table.dart';

/// 半衰期查询结果。
///
/// 对应 shred `AtomInfoUtils.getNuclideHalfLife` 的三种返回：
/// - 无数据条目（原项目返回 null）→ [hasEntry] = false
/// - 有条目但半衰期未知（原项目条目为 null，返回 -1）→ [hasEntry] = true, [seconds] = null
/// - 有数值 → [hasEntry] = true, [seconds] = 秒数
class HalfLifeInfo {
  const HalfLifeInfo({required this.hasEntry, required this.seconds});

  final bool hasEntry;
  final double? seconds;
}

/// 一条可用衰变分支：衰变类型 + 分支比（%）。
/// [percent] 为 null 表示该衰变存在但分支比未知。
class DecayBranch {
  const DecayBranch(this.type, this.percent);

  final NucleusDecayType type;
  final double? percent;
}

class NuclideRepository {
  const NuclideRepository(this.table);

  final NuclideTable table;

  /// 是否稳定核素。对标 `AtomInfoUtils.isStable`。
  bool isStable(int protons, int neutrons) =>
      protons >= 0 &&
      protons < table.stableNeutrons.length &&
      table.stableNeutrons[protons].contains(neutrons);

  /// 半衰期查询。对标 `AtomInfoUtils.getNuclideHalfLife`。
  HalfLifeInfo halfLife(int protons, int neutrons) {
    final row = table.halfLives[protons];
    if (row == null || !row.containsKey(neutrons)) {
      return const HalfLifeInfo(hasEntry: false, seconds: null);
    }
    return HalfLifeInfo(hasEntry: true, seconds: row[neutrons]);
  }

  /// 核素是否存在（地球上有观测）。
  /// 对标 `AtomInfoUtils.doesExist`：稳定 或 有半衰期条目。
  bool doesExist(int protons, int neutrons) =>
      isStable(protons, neutrons) || halfLife(protons, neutrons).hasEntry;

  /// 以下 6 个邻位存在性判定对标 `AtomInfoUtils.doesNext/Previous*`。
  /// 原实现为 `getNuclideHalfLife(...) !== null || isStable(...)`，
  /// 即「有半衰期条目（含未知）或稳定」，与 doesExist 等价。

  bool doesNextIsotopeExist(int protons, int neutrons) =>
      doesExist(protons, neutrons + 1);

  bool doesPreviousIsotopeExist(int protons, int neutrons) =>
      doesExist(protons, neutrons - 1);

  bool doesNextIsotoneExist(int protons, int neutrons) =>
      doesExist(protons + 1, neutrons);

  bool doesPreviousIsotoneExist(int protons, int neutrons) =>
      doesExist(protons - 1, neutrons);

  bool doesNextNuclideExist(int protons, int neutrons) =>
      doesExist(protons + 1, neutrons + 1);

  bool doesPreviousNuclideExist(int protons, int neutrons) =>
      doesExist(protons - 1, neutrons - 1);

  /// 当前核素的可用衰变分支，按分支比降序、未知（null）排最后。
  ///
  /// 合并两段原项目逻辑：
  /// 1. shred `AtomInfoUtils.getAvailableDecaysAndPercents`：
  ///    ENSDF 键映射 + 「同类型已有非 null 条目则跳过」；
  /// 2. build-a-nucleus `getAvailableDecaysAndPercents`：排序
  ///    （JS `Array.prototype.sort` 为稳定排序，此处用下标 Tie-break 复现）。
  ///
  /// 核素不存在 / 稳定 / 衰变模式未知（条目为 null）时返回空列表。
  List<DecayBranch> availableDecays(int protons, int neutrons) {
    final entry = table.decays[protons]?[neutrons];
    if (entry == null) return const [];

    final branches = <DecayBranch>[];
    for (final e in entry.entries) {
      final type = NucleusDecayType.fromEnsdfKey(e.key);
      if (type == null) continue; // 原项目忽略的 ENSDF 键
      final blocked =
          branches.any((b) => b.type == type && b.percent != null);
      if (!blocked) branches.add(DecayBranch(type, e.value));
    }

    // 稳定排序：percent 降序，null 排最后；并列保持数据表原始顺序。
    final indexed = <(int, DecayBranch)>[
      for (var i = 0; i < branches.length; i++) (i, branches[i]),
    ];
    indexed.sort((a, b) {
      final ap = a.$2.percent;
      final bp = b.$2.percent;
      if (ap == null && bp == null) return a.$1.compareTo(b.$1);
      if (ap == null) return 1;
      if (bp == null) return -1;
      final byPercent = bp.compareTo(ap);
      return byPercent != 0 ? byPercent : a.$1.compareTo(b.$1);
    });
    return [for (final e in indexed) e.$2];
  }

  /// 元素符号（z = 0 返回 '-'）。对标 `AtomNameUtils.getSymbol`。
  String elementSymbol(int protons) =>
      (protons >= 0 && protons < table.elements.length)
          ? table.elements[protons].symbol
          : '-';

  /// 元素英文名（z = 0 返回 ''）。对标 `AtomNameUtils.getName`。
  String elementName(int protons) =>
      (protons >= 0 && protons < table.elements.length)
          ? table.elements[protons].name
          : '';

  /// 电子云半径。对标 `AtomInfoUtils.getAtomicRadius`（按电子数索引）。
  double? electronCloudRadius(int electrons) => table.electronCloudRadii[electrons];
}
