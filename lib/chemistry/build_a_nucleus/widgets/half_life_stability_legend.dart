/// 数轴下方「less stable / more stable」。纯视觉常量，不读 Reading。
///
/// [已确认] HalfLifeInformationNode：始终添加，无 visible 绑定。
library;

import 'package:flutter/material.dart';

/// [已确认] lessStable / moreStable 英文字符串
class HalfLifeStabilityLegend extends StatelessWidget {
  const HalfLifeStabilityLegend({super.key});

  static const String lessStable = '较不稳定';
  static const String moreStable = '较稳定';

  static const double _fontSize = 14;
  static const double _arrowLength = 30;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: _fontSize, color: Color(0xFF000000));
    return Row(
      key: const ValueKey('ban_half_life_stability_legend'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _StableArrow(pointingLeft: true),
            const SizedBox(width: 5),
            const Text(
              lessStable,
              key: ValueKey('ban_half_life_less_stable'),
              style: style,
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              moreStable,
              key: ValueKey('ban_half_life_more_stable'),
              style: style,
            ),
            const SizedBox(width: 5),
            const _StableArrow(pointingLeft: false),
          ],
        ),
      ],
    );
  }
}

/// [已确认] ArrowNode length 30, headWidth 6, tailWidth 1；未覆盖 fill → 黑
class _StableArrow extends StatelessWidget {
  const _StableArrow({required this.pointingLeft});

  final bool pointingLeft;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(HalfLifeStabilityLegend._arrowLength, 8),
      painter: _HArrowPainter(pointingLeft: pointingLeft),
    );
  }
}

class _HArrowPainter extends CustomPainter {
  _HArrowPainter({required this.pointingLeft});

  final bool pointingLeft;

  @override
  void paint(Canvas canvas, Size size) {
    const headH = 10.0;
    const headW = 6.0;
    const tailW = 1.0;
    final y = size.height / 2;
    final tipX = pointingLeft ? 0.0 : size.width;
    final tailX = pointingLeft ? size.width : 0.0;
    final dir = pointingLeft ? -1.0 : 1.0;
    final neckX = tipX - dir * headH;
    final path = Path()
      ..moveTo(tailX, y - tailW / 2)
      ..lineTo(neckX, y - tailW / 2)
      ..lineTo(neckX, y - headW / 2)
      ..lineTo(tipX, y)
      ..lineTo(neckX, y + headW / 2)
      ..lineTo(neckX, y + tailW / 2)
      ..lineTo(tailX, y + tailW / 2)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF000000));
  }

  @override
  bool shouldRepaint(covariant _HArrowPainter oldDelegate) =>
      oldDelegate.pointingLeft != pointingLeft;
}
