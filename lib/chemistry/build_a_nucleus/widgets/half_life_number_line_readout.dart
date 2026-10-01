/// 半衰期数轴上方的读数条：`Half-life:` + Unknown / ∞ / 科学计数+s。
///
/// 只读 [HalfLifeNumberLineReading]。立即切换，不跟 pointer 动画。
library;

import 'package:flutter/material.dart';

import '../model/half_life_number_line.dart';
import '../model/half_life_readout.dart';
import '../painters/half_life_number_line_painter.dart';

class HalfLifeNumberLineReadout extends StatelessWidget {
  const HalfLifeNumberLineReadout({super.key, required this.reading});

  final HalfLifeNumberLineReading reading;

  static const double fontSize = HalfLifeNumberLineMetrics.readoutFontSize;

  @override
  Widget build(BuildContext context) {
    final content = HalfLifeReadoutContent.fromReading(reading);
    const style = TextStyle(
      fontSize: fontSize,
      color: Color(0xFF000000),
      height: 1,
    );
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        key: const ValueKey('ban_half_life_readout'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            HalfLifeReadoutContent.label,
            key: ValueKey('ban_half_life_readout_label'),
            style: style,
          ),
          if (content.showUnknown) ...[
            const SizedBox(width: 8),
            const Text(
              HalfLifeReadoutContent.unknown,
              key: ValueKey('ban_half_life_readout_unknown'),
              style: style,
            ),
          ],
          if (content.showInfinity) ...[
            const SizedBox(width: 8),
            const Text(
              HalfLifeReadoutContent.infinityGlyph,
              key: ValueKey('ban_half_life_readout_infinity'),
              style: style,
            ),
          ],
          if (content.showSeconds) ...[
            const SizedBox(width: 8),
            _SecondsValue(content: content, style: style),
          ],
        ],
      ),
    );
  }
}

class _SecondsValue extends StatelessWidget {
  const _SecondsValue({required this.content, required this.style});

  final HalfLifeReadoutContent content;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final exponent = content.exponent;
    return Row(
      key: const ValueKey('ban_half_life_readout_seconds'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          content.mantissa ?? '',
          key: const ValueKey('ban_half_life_readout_mantissa'),
          style: style,
        ),
        if (exponent != null) ...[
          const Text(' ', style: TextStyle(fontSize: HalfLifeNumberLineReadout.fontSize, height: 1)),
          Text(
            HalfLifeReadoutContent.timesTen,
            key: const ValueKey('ban_half_life_readout_times_ten'),
            style: style,
          ),
          Transform.translate(
            offset: const Offset(2, 0),
            child: Text(
              exponent,
              key: const ValueKey('ban_half_life_readout_exponent'),
              style: style.copyWith(
                fontSize: HalfLifeNumberLineReadout.fontSize *
                    HalfLifeNumberLineMetrics.readoutExponentScale,
              ),
            ),
          ),
        ],
        const SizedBox(width: 10),
        Text(
          HalfLifeReadoutContent.unit,
          key: const ValueKey('ban_half_life_readout_unit'),
          style: style,
        ),
      ],
    );
  }
}
