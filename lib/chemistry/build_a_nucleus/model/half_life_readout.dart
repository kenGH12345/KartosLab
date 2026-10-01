/// 半衰期读数条的纯数据格式。
///
/// 只消费 [HalfLifeNumberLineReading]，不查表、不解读哨兵。
/// 对标 `HalfLifeNumberLineNode.halfLifeDisplayNode` + `ScientificNotationNode`。
library;

import 'half_life_number_line.dart';

/// `halfLifeDisplayNode` 一帧要画的内容。
class HalfLifeReadoutContent {
  const HalfLifeReadoutContent({
    required this.kind,
    this.mantissa,
    this.exponent,
  });

  final HalfLifeReadoutKind kind;

  /// 仅 [HalfLifeReadoutKind.seconds]。
  final String? mantissa;

  /// 仅 [HalfLifeReadoutKind.seconds] 且指数非 0 时有值。
  /// `showZeroExponent: false` → 指数 0 只显示尾数。[已确认]
  final String? exponent;

  /// [已确认] `halfLifeColon` = "Half-life:"
  static const String label = 'Half-life:';

  /// [已确认] `unknown` = "Unknown"
  static const String unknown = 'Unknown';

  /// [已确认] `s` = "s"（科学计数后的单位，不是轴下方的 "seconds"）
  static const String unit = 's';

  /// InfinityNode 是 Path，不是字符。[已确认]
  /// 本阶段用 ∞ 作为可读占位，不做像素级 ∞ 路径。[推测 visual]
  static const String infinityGlyph = '∞';

  /// [已确认] ScientificNotationNode 默认 `mantissaDecimalPlaces: 1`
  static const int mantissaDecimalPlaces = 1;

  /// [已确认] timesTenNode.string = `'x 10'`（字母 x，不是 ×）
  static const String timesTen = 'x 10';

  bool get showUnknown => kind == HalfLifeReadoutKind.unknown;
  bool get showInfinity => kind == HalfLifeReadoutKind.infinity;
  bool get showSeconds => kind == HalfLifeReadoutKind.seconds;
  bool get showTimesTen => showSeconds && exponent != null;

  factory HalfLifeReadoutContent.fromReading(HalfLifeNumberLineReading reading) {
    switch (reading.readoutKind) {
      case HalfLifeReadoutKind.none:
        return const HalfLifeReadoutContent(kind: HalfLifeReadoutKind.none);
      case HalfLifeReadoutKind.unknown:
        return const HalfLifeReadoutContent(kind: HalfLifeReadoutKind.unknown);
      case HalfLifeReadoutKind.infinity:
        return const HalfLifeReadoutContent(kind: HalfLifeReadoutKind.infinity);
      case HalfLifeReadoutKind.seconds:
        final seconds = reading.halfLifeSeconds;
        if (seconds == null) {
          return const HalfLifeReadoutContent(kind: HalfLifeReadoutKind.none);
        }
        final notation = toScientificNotation(seconds);
        return HalfLifeReadoutContent(
          kind: HalfLifeReadoutKind.seconds,
          mantissa: notation.mantissa,
          exponent: notation.exponent,
        );
    }
  }

  /// 对标 `ScientificNotationNode.toScientificNotation`（exponent 由
  /// `Number.toExponential` 计算）+ `update()` 的零指数折叠。
  ///
  /// 返回的 [exponent] 为 null 表示只显示尾数（指数为 0）。
  static ({String mantissa, String? exponent}) toScientificNotation(
    double value,
  ) {
    // [已确认] `value.toExponential(mantissaDecimalPlaces)`
    final exponentialString =
        value.toStringAsExponential(mantissaDecimalPlaces);
    final tokens = exponentialString.toLowerCase().split('e');
    final mantissa = tokens[0];
    var exp = tokens[1];
    if (exp.startsWith('+')) {
      exp = exp.substring(1);
    }
    // [已确认] showZeroExponent: false → 'M x 10^0' 显示为 'M'
    if (exp == '0') {
      return (mantissa: mantissa, exponent: null);
    }
    return (mantissa: mantissa, exponent: exp);
  }

  /// 单行测试用。上标在 Widget 里画，这里用 `10^n`。[已确认 语义；^ 是文本折中]
  String get captionLine {
    switch (kind) {
      case HalfLifeReadoutKind.none:
        return label;
      case HalfLifeReadoutKind.unknown:
        return '$label $unknown';
      case HalfLifeReadoutKind.infinity:
        return '$label $infinityGlyph';
      case HalfLifeReadoutKind.seconds:
        if (showTimesTen) {
          return '$label $mantissa $timesTen^$exponent $unit';
        }
        return '$label $mantissa $unit';
    }
  }
}
