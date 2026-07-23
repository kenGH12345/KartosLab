import 'package:flutter/material.dart';

/// PhET 风格数值输入框——对应 Java GraphControlTextBox。
///
/// 用于"精确输入数值"场景。
class PhetNumberField extends StatelessWidget {
  const PhetNumberField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.unit,
    this.min,
    this.max,
    this.format = '0.00',
    this.enabled = true,
  });

  final String label;
  final String? unit;
  final double value;
  final double? min;
  final double? max;
  final ValueChanged<double> onChanged;
  final String format;
  final bool enabled;

  static String _format(double v, String fmt) {
    final dot = fmt.indexOf('.');
    if (dot < 0) return v.toStringAsFixed(0);
    final decimals = fmt.length - dot - 1;
    return v.toStringAsFixed(decimals);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
        const SizedBox(height: 2),
        SizedBox(
          height: 28,
          width: 100,
          child: TextField(
            enabled: enabled,
            controller: TextEditingController(text: _format(value, format)),
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, fontFamily: 'monospace', color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              isDense: true,
              suffixText: unit,
              suffixStyle: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
            onSubmitted: (v) {
              final d = double.tryParse(v);
              if (d == null) return;
              double clamped = d;
              if (min != null) clamped = clamped.clamp(min!, double.infinity);
              if (max != null) clamped = clamped.clamp(double.negativeInfinity, max!);
              onChanged(clamped);
            },
          ),
        ),
      ],
    );
  }
}
