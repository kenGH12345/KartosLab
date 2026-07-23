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
    // 吸附到最近的 step 整数倍：先除到"第几档"再乘回来
    final displayValue = step != null
        ? (value / step!).roundToDouble() * step!
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
///
/// 使用 StatefulWidget 管理 TextEditingController 生命周期，避免每次 build
/// 新建 controller 导致光标被吞、IME 输入被中断的问题。
class PhetSliderField extends StatefulWidget {
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
  State<PhetSliderField> createState() => _PhetSliderFieldState();
}

class _PhetSliderFieldState extends State<PhetSliderField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(1));
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant PhetSliderField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部 value 变化时，仅在用户未编辑（未获焦）时同步到输入框，避免打断用户输入
    if (widget.value != oldWidget.value && !_focusNode.hasFocus) {
      final newText = widget.value.toStringAsFixed(1);
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PhetSlider(
          label: widget.label,
          unit: widget.unit,
          min: widget.min,
          max: widget.max,
          value: widget.value,
          onChanged: widget.onChanged,
          step: widget.step,
          enabled: widget.enabled,
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: 28,
          width: 80,
          child: TextField(
            enabled: widget.enabled,
            controller: _controller,
            focusNode: _focusNode,
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
              if (d != null) widget.onChanged(d.clamp(widget.min, widget.max));
            },
          ),
        ),
      ],
    );
  }
}
