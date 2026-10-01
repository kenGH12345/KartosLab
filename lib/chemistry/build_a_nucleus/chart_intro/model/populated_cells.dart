/// Chart Intro 核素图稀疏白名单。
///
/// 对标 `BANModel.POPULATED_CELLS`：行下标 = 质子数，行内数字 = 画出的中子数。
/// 不是 11×13 满格，也不是 `doesExist` 的全集（是否一致见分析文档 [待确认]）。
///
/// 坐标约定 [已确认 NuclideChartNode / getChartTransform]：
/// - X = 中子数
/// - Y = 质子数
library;

/// 一个核素图格子的数据坐标（无像素）。
class ChartCellRef {
  const ChartCellRef({required this.protonNumber, required this.neutronNumber});

  final int protonNumber;
  final int neutronNumber;

  /// 图上 X。[已确认] modelToViewX(neutronNumber)
  int get x => neutronNumber;

  /// 图上 Y。[已确认] 竖直 spacing 的 protonNumber
  int get y => protonNumber;
}

class PopulatedCells {
  const PopulatedCells._();

  /// [已确认] BANModel.POPULATED_CELLS
  static const List<List<int>> rows = [
    [1, 4, 6],
    [0, 1, 2, 3, 4, 5, 6],
    [1, 2, 3, 4, 5, 6, 7, 8],
    [1, 2, 3, 4, 5, 6, 7, 8, 9],
    [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    [3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    [3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    [4, 5, 6, 7, 8, 9, 10, 11, 12],
    [5, 6, 7, 8, 9, 10, 11, 12],
  ];

  static int get maxProton => rows.length - 1;

  static bool isPopulated(int protonNumber, int neutronNumber) {
    if (protonNumber < 0 || protonNumber >= rows.length) return false;
    return rows[protonNumber].contains(neutronNumber);
  }

  /// 当前 (p,n) 对应的格子；不在白名单则 null。
  static ChartCellRef? cellAt(int protonNumber, int neutronNumber) =>
      isPopulated(protonNumber, neutronNumber)
          ? ChartCellRef(
              protonNumber: protonNumber, neutronNumber: neutronNumber)
          : null;

  static List<ChartCellRef> get allCells => [
        for (var p = 0; p < rows.length; p++)
          for (final n in rows[p])
            ChartCellRef(protonNumber: p, neutronNumber: n),
      ];
}
