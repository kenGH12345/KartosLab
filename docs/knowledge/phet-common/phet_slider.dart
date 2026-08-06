import 'package:flutter/material.dart';

/// PhET 风格滑动条——min/max 区间内拖拽取 value。
///
/// 用法：
/// ```dart
/// PhetSlider(
///   label: '焦距', unit: 'cm',
///   min: 5, max: 50, step: 1, value: f,
///   onChanged: (v) => setState(...),
/// )
/// ```
class PhetSlider extends StatelessWidget {
  const PhetSlider({
    super.key,
    required this.label,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    this.unit,
    this.step,
    this.enabled = true,
    this.tickLabels,
    this.direction = Axis.horizontal,
    this.trackThickness = 6.0,
    this.trackLength = 200.0,
    this.trackColor,
    this.knobColor,
  });

  final String label;
  final String? unit;
  final double min;
  final double max;
  final double value;
  final ValueChanged<double> onChanged;
  final double? step;
  final bool enabled;
  final Map<double, String>? tickLabels;
  final Axis direction;
  final double trackThickness;
  final double trackLength;
  final Color? trackColor;
  final Color? knobColor;

  @override
  Widget build(BuildContext context) {
    final displayValue = step != null
        ? (value / step! * step!).roundToDouble() / (1 / step!)
        : value;
    final valueStr = displayValue.toStringAsFixed(
      step != null && step! >= 1 ? 0 : 1,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
            const Spacer(),
            Text.rich(
              TextSpan(
                text: valueStr,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                children: [
                  if (unit != null)
                    TextSpan(
                      text: ' $unit',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Color(0xFF64748B)),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        direction == Axis.horizontal
            ? Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: step != null ? ((max - min) ~/ step!) : null,
                activeColor: knobColor ?? const Color(0xFF1177AA),
                inactiveColor: trackColor ?? const Color(0xFFCBD5E1),
                onChanged: enabled ? (v) => onChanged(v) : null,
              )
            : SizedBox(
                height: trackLength,
                child: RotatedBox(
                  quarterTurns: -1,
                  child: Slider(
                    value: value.clamp(min, max),
                    min: min,
                    max: max,
                    divisions: step != null ? ((max - min) ~/ step!) : null,
                    activeColor: knobColor ?? const Color(0xFF1177AA),
                    inactiveColor: trackColor ?? const Color(0xFFCBD5E1),
                    onChanged: enabled ? (v) => onChanged(v) : null,
                  ),
                ),
              ),
      ],
    );
  }
}

/// 滑动条 + 数值输入框组合（精确输入模式）。
class PhetSliderField extends StatelessWidget {
  const PhetSliderField({
    super.key,
    required this.label,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    this.unit,
    this.step,
    this.enabled = true,
    this.format = '0.0',
  });

  final String label;
  final String? unit;
  final double min;
  final double max;
  final double value;
  final ValueChanged<double> onChanged;
  final double? step;
  final bool enabled;
  final String format;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PhetSlider(
          label: label,
          unit: unit,
          min: min,
          max: max,
          value: value,
          onChanged: onChanged,
          step: step,
          enabled: enabled,
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: 28,
          width: 80,
          child: TextField(
            enabled: enabled,
            controller: TextEditingController(text: value.toStringAsFixed(1)),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              isDense: true,
            ),
            onSubmitted: (v) {
              final d = double.tryParse(v);
              if (d != null) onChanged(d.clamp(min, max));
            },
          ),
        ),
      ],
    );
  }
}
