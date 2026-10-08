/// Decay 屏「Electron Cloud」开关。
///
/// 视图层布尔，不进 [BuildANucleusState]。
/// [已确认] `ShowElectronCloudCheckbox`：`BooleanProperty(true)`，
/// `link` 只改 `electronCloud.visible`；`reset()` 恢复默认 true。
library;

import 'package:flutter/material.dart';

import '../ban_constants.dart';

class ShowElectronCloudCheckbox extends StatelessWidget {
  const ShowElectronCloudCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    const electron = Color(BanConstants.electronColorValue);
    return Row(
      key: const ValueKey('ban_electron_cloud_checkbox'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          value: value,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
        const Text('电子云', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 5),
        // 图标半径原版 = 文字高度 × 0.82。[已确认]
        // 文字字号与 REGULAR_FONT(20) 未逐像素对齐 → [视觉待确认]
        CustomPaint(
          size: const Size(22, 22),
          painter: _ElectronCloudIconPainter(electron),
        ),
      ],
    );
  }
}

class _ElectronCloudIconPainter extends CustomPainter {
  const _ElectronCloudIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final c = Offset(r, r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
          stops: const [0.0, 0.9],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  @override
  bool shouldRepaint(covariant _ElectronCloudIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
