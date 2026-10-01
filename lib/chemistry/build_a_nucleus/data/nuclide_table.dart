/// 核素数据表：对应 `assets/data/nuclide_table.json`
/// （结构约束见 `schemas/nuclide_table.schema.json`）。
///
/// 数据来源：PhET shred 仓库 AtomData.ts / AtomNameUtils.ts（Relational ENSDF 2022），
/// 由 `scripts/extract_nuclide_data.mjs` 生成。
///
/// 本文件只做结构化持有，查询语义在 `NuclideRepository`。
library;

class ElementInfo {
  const ElementInfo({required this.z, required this.symbol, required this.name});

  /// 原子序数（质子数）。0 为「无元素」占位。
  final int z;

  /// 元素符号；z = 0 时为 '-'。
  final String symbol;

  /// 首字母大写的英文名；z = 0 时为空串。本地化不在数据表内解决。
  final String name;

  factory ElementInfo.fromJson(Map<String, dynamic> json) => ElementInfo(
        z: json['z'] as int,
        symbol: json['symbol'] as String,
        name: json['name'] as String,
      );
}

class NuclideTable {
  const NuclideTable({
    required this.version,
    required this.elements,
    required this.stableNeutrons,
    required this.halfLives,
    required this.decays,
    required this.electronCloudRadii,
  });

  final String version;

  /// 下标 = 质子数 Z。
  final List<ElementInfo> elements;

  /// 下标 = 质子数 Z，值为稳定同位素的中子数列表。
  /// 同构于 shred `stableElementTable`。
  final List<List<int>> stableNeutrons;

  /// Z → N → 半衰期秒数；值为 null 表示「存在但半衰期未知」；
  /// 键不存在表示「无该核素数据」。同构于 shred `HalfLifeConstants`。
  final Map<int, Map<int, double?>> halfLives;

  /// Z → N → （ENSDF 衰变串 → 分支比 %）；值为 null 表示「存在但衰变模式未知」。
  /// 同构于 shred `DECAYS_INFO_TABLE`。内层 Map 保持 JSON 键序
  /// （原项目的「同类型取首个非 null」规则依赖该顺序）。
  final Map<int, Map<int, Map<String, double?>?>> decays;

  /// 电子数（= 中性原子的 Z）→ 电子云半径（PhET 视觉数据）。
  final Map<int, double> electronCloudRadii;

  factory NuclideTable.fromJson(Map<String, dynamic> json) {
    Map<int, double?> parseHalfLifeRow(Map<String, dynamic> row) => row.map(
          (k, v) => MapEntry(int.parse(k), (v as num?)?.toDouble()),
        );

    Map<String, double?>? parseDecayEntry(dynamic entry) {
      if (entry == null) return null;
      // 保持插入序：Dart jsonDecode 产出 LinkedHashMap，map() 同样保序。
      return (entry as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num?)?.toDouble()));
    }

    return NuclideTable(
      version: json['version'] as String,
      elements: [
        for (final e in json['elements'] as List<dynamic>)
          ElementInfo.fromJson(e as Map<String, dynamic>),
      ],
      stableNeutrons: [
        for (final list in json['stableNeutrons'] as List<dynamic>)
          (list as List<dynamic>).cast<int>(),
      ],
      halfLives: (json['halfLives'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(
          int.parse(k),
          parseHalfLifeRow(v as Map<String, dynamic>),
        ),
      ),
      decays: (json['decays'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(
          int.parse(k),
          (v as Map<String, dynamic>)
              .map((n, entry) => MapEntry(int.parse(n), parseDecayEntry(entry))),
        ),
      ),
      electronCloudRadii:
          (json['electronCloudRadii'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(int.parse(k), (v as num).toDouble()),
      ),
    );
  }
}
