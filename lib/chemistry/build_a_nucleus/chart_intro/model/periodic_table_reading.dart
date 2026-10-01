/// 周期表只读快照：座位 + 符号/名（来自已有 [ElementInfo]）+ 高亮 Z。
///
/// 不查 [NuclideRepository]（存在性 / 衰变 / 半衰期）。
/// 不持有像素。Chart Intro `interactiveMax: 0`，本对象无 click 字段。
library;

import '../../data/nuclide_table.dart';
import 'periodic_table_layout.dart';

class PeriodicTableCellData {
  const PeriodicTableCellData({
    required this.atomicNumber,
    required this.column,
    required this.row,
    required this.symbol,
    required this.name,
  });

  final int atomicNumber;
  final int column;
  final int row;
  final String symbol;
  final String name;
}

class PeriodicTableReading {
  const PeriodicTableReading({
    required this.cells,
    required this.highlightedAtomicNumber,
  });

  /// [protonCount] 只决定高亮；[elements] 只提供符号/名（下标 = Z）。
  factory PeriodicTableReading.from({
    required int protonCount,
    required List<ElementInfo> elements,
  }) {
    return PeriodicTableReading(
      cells: [
        for (final seat in PeriodicTableLayout.seats)
          PeriodicTableCellData(
            atomicNumber: seat.atomicNumber,
            column: seat.column,
            row: seat.row,
            symbol: _field(elements, seat.atomicNumber, (e) => e.symbol),
            name: _field(elements, seat.atomicNumber, (e) => e.name),
          ),
      ],
      highlightedAtomicNumber:
          PeriodicTableLayout.highlightAtomicNumber(protonCount),
    );
  }

  final List<PeriodicTableCellData> cells;
  final int? highlightedAtomicNumber;

  PeriodicTableCellData? get highlightedCell {
    final z = highlightedAtomicNumber;
    if (z == null) return null;
    for (final c in cells) {
      if (c.atomicNumber == z) return c;
    }
    return null;
  }

  PeriodicTableCellData? cellAtAtomicNumber(int z) {
    for (final c in cells) {
      if (c.atomicNumber == z) return c;
    }
    return null;
  }

  static String _field(
    List<ElementInfo> elements,
    int z,
    String Function(ElementInfo) pick,
  ) {
    if (z < 0 || z >= elements.length) return '';
    return pick(elements[z]);
  }
}
