/// 半衰期数轴的数据 / 映射（无 Canvas / Widget / Paint）。
///
/// 逐函数对标 `HalfLifeNumberLineNode.ts`：
/// - 模型坐标 = 秒的 **log10**（`Utils.log10`），不是 ln
/// - ChartTransform.modelXRange = [START_EXPONENT, END_EXPONENT] = [-24, 24]
/// - 特殊值 0 / -1 / 10^24 是 DecayModel 的 **显示哨兵**，不是普通半衰期
///
/// 数据流：`NuclideRepository → State.halfLifeNumber (+ isStable) → 本类`
/// 不查核素表、不重算半衰期。
library;

import 'dart:math' as math;

import '../ban_constants.dart';
import 'build_a_nucleus_state.dart';

/// 读数种类。对标 `halfLifeDisplayNode` 三个互斥子节点
/// （infinity / Unknown / scientific+s）以及「全隐」。
enum HalfLifeReadoutKind {
  /// 不存在 / 空核：标签仍在，无数、无 Unknown、无 ∞。[已确认]
  none,

  /// halfLifeNumber === -1。[已确认]
  unknown,

  /// isStable：InfinityNode。[已确认]
  infinity,

  /// 不稳定且有秒数（含超右端钉住指针但仍显示真值）。[已确认]
  seconds,
}

/// 某一核素状态下，数轴需要的全部显示量。
class HalfLifeNumberLineReading {
  const HalfLifeNumberLineReading({
    required this.readoutKind,
    required this.halfLifeSeconds,
    required this.pointerExponent,
    required this.pointerVisible,
    required this.pointerPointsRight,
  });

  final HalfLifeReadoutKind readoutKind;

  /// 已知秒数时的真值（超范围仍保留）。其余种类为 null。
  final double? halfLifeSeconds;

  /// ChartTransform 模型 X：秒的 log10，范围名义上 [-24, 24]。
  /// unknown / nonexistent 为 **0**（轴中央，1 秒处），不是左端。[已确认]
  final double pointerExponent;

  /// nonexistent / unknown 隐藏箭头。[已确认]
  final bool pointerVisible;

  /// 稳定，或指针被钉在 10^24：箭头水平向右；否则竖直向下。[已确认]
  final bool pointerPointsRight;

  /// 0 = 左端 10^-24，1 = 右端 10^24。可越出 [0,1]（左端无 clamp）。
  double get normalizedPosition {
    const start = BanConstants.halfLifeNumberLineStartExponent;
    const end = BanConstants.halfLifeNumberLineEndExponent;
    return (pointerExponent - start) / (end - start);
  }

  @override
  bool operator ==(Object other) =>
      other is HalfLifeNumberLineReading &&
      readoutKind == other.readoutKind &&
      halfLifeSeconds == other.halfLifeSeconds &&
      pointerExponent == other.pointerExponent &&
      pointerVisible == other.pointerVisible &&
      pointerPointsRight == other.pointerPointsRight;

  @override
  int get hashCode => Object.hash(
        readoutKind,
        halfLifeSeconds,
        pointerExponent,
        pointerVisible,
        pointerPointsRight,
      );
}

/// 数轴几何与映射。全部静态；无内部缓存（核素切换 = 对当前 State 再求一次）。
class HalfLifeNumberLine {
  const HalfLifeNumberLine._();

  static const int startExponent = BanConstants.halfLifeNumberLineStartExponent;
  static const int endExponent = BanConstants.halfLifeNumberLineEndExponent;
  static const int tickSpacing = BanConstants.halfLifeNumberLineTickSpacing;

  /// 右端对应的秒数 10^24。对标 JS `Math.pow(10, END)`（IEEE double）。
  /// 必须用 `10.0`：Dart `pow(10, 24)` 走整数幂会溢出 int64。[已确认 原版是浮点幂]
  static double get maxSeconds => math.pow(10.0, endExponent).toDouble();

  /// 轴下方单位文案。[已确认] strings.seconds = "seconds"
  static const String unitsLabel = 'seconds';

  /// 刻度指数。spacing=3 且 ±24 可被 3 整除 → 含两端。
  /// bamboo TickMarkSet 是否从 range.min 起 [推测：与 spacing 对齐故两端都会出现]。
  static List<int> tickExponents() {
    final ticks = <int>[];
    for (var e = startExponent; e <= endExponent; e += tickSpacing) {
      ticks.add(e);
    }
    return ticks;
  }

  /// 刻度标签的 **数据** 形态。原版 0 → 文本 "1"，其余为 10 的上标。
  /// 上标绘制属 1G-3B。[已确认] createExponentialLabel
  static String tickLabel(int exponent) => exponent == 0 ? '1' : '10^$exponent';

  /// 对标 `logScaleNumberToLinearScaleNumber`。
  ///
  /// - `halfLifeNumber === 0` → **0**（不是 log(0)，也不是左端 -24）
  /// - 其余 → log10(seconds)
  ///
  /// 底数 10 [已确认] 方法名 `Utils.log10`。Dart 用 `log(x)/ln10` 同一数学定义；
  /// 与 JS 逐 bit 是否相同 [待确认：ulp，测试用 closeTo]。
  static double logScaleNumberToLinearScaleNumber(double halfLifeNumber) {
    if (halfLifeNumber == 0) return 0;
    return math.log(halfLifeNumber) / math.ln10;
  }

  /// 只读 State：半衰期哨兵 + 稳定性（原版 NumberLine 同时监听这两个 Property）。
  static HalfLifeNumberLineReading fromState(BuildANucleusState state) =>
      fromValues(
        halfLifeNumber: state.halfLifeNumber,
        isStable: state.isStable,
      );

  /// 纯函数入口。不读核素表。
  static HalfLifeNumberLineReading fromValues({
    required double halfLifeNumber,
    required bool isStable,
  }) {
    // [已确认] halfLifeNumberProperty.link：先 isStable，再 0 / -1 / 其余
    if (isStable) {
      return HalfLifeNumberLineReading(
        readoutKind: HalfLifeReadoutKind.infinity,
        halfLifeSeconds: null,
        pointerExponent: endExponent.toDouble(),
        pointerVisible: true,
        pointerPointsRight: true,
      );
    }
    if (halfLifeNumber == BanConstants.nonexistentHalfLife) {
      return HalfLifeNumberLineReading(
        readoutKind: HalfLifeReadoutKind.none,
        halfLifeSeconds: null,
        // moveHalfLifePointerSet(0) → logScale(0) = 0
        pointerExponent: 0,
        pointerVisible: false,
        pointerPointsRight: false,
      );
    }
    if (halfLifeNumber == BanConstants.unknownHalfLife) {
      return HalfLifeNumberLineReading(
        readoutKind: HalfLifeReadoutKind.unknown,
        halfLifeSeconds: null,
        // [已确认] 显式 moveHalfLifePointerSet(0)，不把 -1 送进 log10
        pointerExponent: 0,
        pointerVisible: false,
        pointerPointsRight: false,
      );
    }

    final pegged = halfLifeNumber > maxSeconds;
    final pointerSeconds = pegged ? maxSeconds : halfLifeNumber;
    final exponent = logScaleNumberToLinearScaleNumber(pointerSeconds);
    return HalfLifeNumberLineReading(
      readoutKind: HalfLifeReadoutKind.seconds,
      halfLifeSeconds: halfLifeNumber,
      pointerExponent: exponent,
      pointerVisible: true,
      pointerPointsRight: pointerSeconds == maxSeconds,
    );
  }
}
