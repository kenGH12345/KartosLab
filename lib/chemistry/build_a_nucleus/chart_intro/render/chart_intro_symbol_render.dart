/// Chart Intro 同位素符号盒快照。对标 shred `SymbolNode`（无电荷）。
///
/// 字段全部透传，本类不算 A、不算 Z、不查 [NuclideRepository]。
/// 符号只从已有 [ElementInfo] 读取。
library;

import '../../data/nuclide_table.dart';

class ChartIntroSymbolRender {
  const ChartIntroSymbolRender({
    required this.symbol,
    required this.protonCount,
    required this.massNumber,
  });

  /// 三字段均已算好后写入。[elementSymbol] 必须来自 ElementInfo。
  /// 空核时 ElementInfo[0].symbol 已是 `'-'`，与
  /// `SymbolNode` `protonCount > 0 ? symbol : '-'` 一致。[已确认]
  factory ChartIntroSymbolRender.from({
    required int protonCount,
    required int massNumber,
    required String elementSymbol,
  }) {
    return ChartIntroSymbolRender(
      symbol: elementSymbol,
      protonCount: protonCount,
      massNumber: massNumber,
    );
  }

  /// 只读 [elements][protonCount].symbol + 已有 A / Z。
  factory ChartIntroSymbolRender.fromCounts({
    required int protonCount,
    required int massNumber,
    required List<ElementInfo> elements,
  }) {
    return ChartIntroSymbolRender(
      symbol: _symbolAt(protonCount, elements),
      protonCount: protonCount,
      massNumber: massNumber,
    );
  }

  /// 盒中央字母。Z=0 为 `-`（来自 ElementInfo，不是本类改写）。
  final String symbol;

  /// Z。直接使用壳层质子数。[已确认] `SymbolNode(protonCountProperty, …)`
  final int protonCount;

  /// A。直接使用已有 massNumber。[已确认] `SymbolNode(…, massNumberProperty)`
  /// massNumber 在 State 里已是 p+n；这里不再加一遍。
  final int massNumber;

  /// 与 [massNumber] 同一值，不另算。
  int get a => massNumber;

  /// 与 [protonCount] 同一值，不另算。
  int get z => protonCount;

  /// Chart Intro 未传 `chargeProperty`。[已确认] `PeriodicTableAndIsotopeSymbol`
  static const bool showsCharge = false;

  static String _symbolAt(int z, List<ElementInfo> elements) {
    if (z < 0 || z >= elements.length) return '';
    return elements[z].symbol;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartIntroSymbolRender &&
          symbol == other.symbol &&
          protonCount == other.protonCount &&
          massNumber == other.massNumber;

  @override
  int get hashCode => Object.hash(symbol, protonCount, massNumber);
}
