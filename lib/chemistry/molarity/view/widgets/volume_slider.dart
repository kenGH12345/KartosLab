import 'package:flutter/material.dart';

import '../../config/molarity_scenario.dart';
import 'compact_slider.dart';

/// 体积滑块（窄格紧凑版 · 对齐蓝本 VerticalSliderNode 的语义）。
class VolumeSlider extends StatelessWidget {
  const VolumeSlider({
    super.key,
    required this.value,
    required this.range,
    required this.onChanged,
    this.accent = const Color(0xFF0E7490),
  });

  final double value;
  final ParamRange range;
  final ValueChanged<double> onChanged;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final divisions = range.step != null && range.step! > 0
        ? ((range.max - range.min) / range.step!).round()
        : null;
    return CompactSlider(
      label: '体积(${range.unit ?? ''})',
      icon: '🧴 ',
      value: value,
      min: range.min,
      max: range.max,
      divisions: divisions,
      valueText: value.toStringAsFixed(2),
      accent: accent,
      onChanged: onChanged,
    );
  }
}
