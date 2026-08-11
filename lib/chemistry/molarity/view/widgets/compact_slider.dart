import 'package:flutter/material.dart';

/// 窄格紧凑滑块：label 行 Flexible+ellipsis 防溢出 + 值文本。
///
/// 模式照抄 sound sim 的 `_compactSlider`（sound 为第 1 用户 · 本组件为第 2 用户，
/// 按 3-Time Rule 应在第 3 用户前上抽到 `lib/common/controls/` —— 已登记 notes.md）。
class CompactSlider extends StatelessWidget {
  const CompactSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.valueText,
    required this.onChanged,
    this.icon,
    this.divisions,
    this.accent = const Color(0xFF0891B2),
  });

  final String label;
  final String? icon;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String valueText;
  final Color accent;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // FittedBox scaleDown：窄格永不溢出（超宽整体缩放）
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${icon ?? ''}$label',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A))),
              const SizedBox(width: 4),
              Text(valueText,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800, color: accent)),
            ],
          ),
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          activeColor: accent,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
