/// Chart Intro 核壳层能级常量。
///
/// 对标 `js/chart-intro/model/EnergyLevelType.ts`。
/// 只描述「哪一层、能坐几个、允许的 x 座」，不含像素。
///
/// n=2 真实壳模型容量为 12，本屏 Hollywood 为 6。
/// [已确认] EnergyLevelType.N_TWO + doc/model.md Hollywood
library;

/// 一层能级。[已确认] EnergyLevelType.N_ZERO / N_ONE / N_TWO
enum EnergyLevel {
  n0(yPosition: 0, capacity: 2, allowedX: [2, 3]),
  n1(yPosition: 1, capacity: 6, allowedX: [0, 1, 2, 3, 4, 5]),
  n2(yPosition: 2, capacity: 6, allowedX: [0, 1, 2, 3, 4, 5]);

  const EnergyLevel({
    required this.yPosition,
    required this.capacity,
    required this.allowedX,
  });

  /// 能级行号（0 最低）。[已确认] EnergyLevelType.yPosition
  final int yPosition;

  /// 本层座位数。[已确认] EnergyLevelType.capacity（n2 为 Hollywood 6）
  final int capacity;

  /// 本层允许的模型 x（0–5）。[已确认] ShellModelNucleus.ALLOWED_PARTICLE_POSITIONS
  final List<int> allowedX;

  static const List<EnergyLevel> levels = [n0, n1, n2];

  static const int n0Capacity = 2;
  static const int n1Capacity = 6;
  static const int n2Capacity = 6;

  /// 该种类已入核下标（0-based）落在哪一层。
  /// [已确认] EnergyLevelType.getForIndex
  static EnergyLevel forIndex(int index) {
    var remainder = index;
    for (final level in levels) {
      remainder -= level.capacity;
      if (remainder < 0) return level;
    }
    return n2;
  }

  /// 该种类已入核数量对应的「填充到哪一层」（绑定判定用）。
  /// [已确认] ShellModelNucleus.createLevelPropertyListener
  static EnergyLevel fillLevelForCount(int count) {
    if (count > n0Capacity + n1Capacity) return n2;
    if (count > n0Capacity) return n1;
    return n0;
  }
}
