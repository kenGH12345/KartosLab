/// Chart Intro 周期表座位（无像素、无 Painter）。
///
/// 对标 shred `PeriodicTableNode.POPULATED_CELLS` 与造格循环。
/// 符号 / 名称不在本文件；单一事实来源仍是 [ElementInfo] 表。
library;

/// 主表上一格：原子序 + 网格列/行。列 0–17，行 0–6。
class PeriodicTableSeat {
  const PeriodicTableSeat({
    required this.atomicNumber,
    required this.column,
    required this.row,
  });

  /// Z。[已确认] `PeriodicTableCell.atomicNumber`
  final int atomicNumber;

  /// 网格 x。[已确认] `populatedCellsInRow[j]`
  final int column;

  /// 网格 y。[已确认] `POPULATED_CELLS` 行下标
  final int row;
}

class PeriodicTableLayout {
  const PeriodicTableLayout._();

  /// [已确认] PeriodicTableNode `MAX_PROTON_COUNT = 118`
  static const int maxProtonCount = 118;

  /// [已确认] 主表 18 列
  static const int columnCount = 18;

  /// [已确认] `POPULATED_CELLS.length === 7`（无独立 f 区行）
  static const int rowCount = 7;

  /// Chart Intro 能点亮的最大 Z。[已确认] `CHART_MAX_NUMBER_OF_PROTONS = 10`
  static const int chartIntroMaxAtomicNumber = 10;

  /// 每行有格子的列号。
  /// [已确认] shred `PeriodicTableNode.POPULATED_CELLS`
  static const List<List<int>> populatedColumns = [
    [0, 17],
    [0, 1, 12, 13, 14, 15, 16, 17],
    [0, 1, 12, 13, 14, 15, 16, 17],
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
  ];

  /// 主表全部座位（90 格）。镧系 58–71、锕系 90–103 被跳过。
  /// [已确认] 造格后 `if (protonCount === 58) protonCount = 72` /
  /// `if (protonCount === 90) protonCount = 104`
  static final List<PeriodicTableSeat> seats = _buildSeats();

  static List<PeriodicTableSeat> _buildSeats() {
    final out = <PeriodicTableSeat>[];
    var z = 1;
    for (var row = 0; row < populatedColumns.length; row++) {
      for (final column in populatedColumns[row]) {
        out.add(PeriodicTableSeat(
          atomicNumber: z,
          column: column,
          row: row,
        ));
        z++;
        if (z == 58) z = 72;
        if (z == 90) z = 104;
      }
    }
    return List.unmodifiable(out);
  }

  static PeriodicTableSeat? seatForAtomicNumber(int z) {
    for (final s in seats) {
      if (s.atomicNumber == z) return s;
    }
    return null;
  }

  /// 该 Z 是否画在主表上（镧/锕系为 false）。
  static bool isShown(int z) => seatForAtomicNumber(z) != null;

  /// 高亮原子序。0 → 无高亮。
  /// [已确认] `if (protonCount !== 0)` 才 `cells[protonCountToElementIndex]`
  /// 不查核素是否存在。
  static int? highlightAtomicNumber(int protonCount) {
    if (protonCount == 0) return null;
    return protonCount;
  }
}
