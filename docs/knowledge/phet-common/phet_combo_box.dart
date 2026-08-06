import 'package:flutter/material.dart';

/// PhET 风格下拉选择——对应 Java ComboBoxNode。
///
/// 用法：
/// ```dart
/// PhetComboBox<String>(
///   label: '场景',
///   items: ['实验一', '实验二', '实验三'],
///   value: selectedScene,
///   onChanged: (v) => setState(...),
/// )
/// ```
class PhetComboBox<T> extends StatelessWidget {
  const PhetComboBox({
    super.key,
    this.label,
    required this.items,
    this.itemLabels,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.width = 160,
  });

  final String? label;
  final List<T> items;
  final List<String>? itemLabels;
  final T value;
  final ValueChanged<T> onChanged;
  final bool enabled;
  final double width;

  String _labelFor(T item, int index) {
    if (itemLabels != null && index < itemLabels!.length) return itemLabels![index];
    return item.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
          const SizedBox(height: 4),
        ],
        SizedBox(
          width: width,
          height: 32,
          child: DropdownButtonFormField<T>(
            value: value,
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
            items: List.generate(items.length, (i) {
              return DropdownMenuItem<T>(
                value: items[i],
                child: Text(_labelFor(items[i], i), style: const TextStyle(fontSize: 12)),
              );
            }),
            onChanged: enabled ? (v) { if (v != null) onChanged(v); } : null,
          ),
        ),
      ],
    );
  }
}
