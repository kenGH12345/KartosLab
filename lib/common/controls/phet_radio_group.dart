import 'package:flutter/material.dart';

/// PhET 风格单选按钮组——对应 Java RadioButtonStripControlPanelNode。
///
/// 用法：
/// ```dart
/// PhetRadioGroup<String>(
///   label: '透镜类型',
///   items: ['凸透镜', '凹透镜'],
///   value: lensType,
///   onChanged: (v) => setState(...),
/// )
/// ```
class PhetRadioGroup<T> extends StatelessWidget {
  const PhetRadioGroup({
    super.key,
    this.label,
    required this.items,
    this.itemLabels,
    required this.value,
    required this.onChanged,
    this.direction = Axis.vertical,
    this.enabled = true,
  });

  final String? label;
  final List<T> items;
  final List<String>? itemLabels;
  final T value;
  final ValueChanged<T> onChanged;
  final Axis direction;
  final bool enabled;

  String _labelFor(T item, int index) {
    if (itemLabels != null && index < itemLabels!.length) return itemLabels![index];
    return item.toString();
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (label != null) {
      children.add(Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(label!, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
      ));
    }
    children.add(
      direction == Axis.vertical
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(items.length, (i) {
                return _buildItem(items[i], i);
              }),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(items.length, (i) {
                return Padding(
                  padding: EdgeInsets.only(left: i > 0 ? 8.0 : 0),
                  child: _buildItem(items[i], i),
                );
              }),
            ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildItem(T item, int index) {
    final label = _labelFor(item, index);
    final selected = item == value;
    return InkWell(
      onTap: enabled ? () => onChanged(item) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            size: 16,
            color: selected
                ? (enabled ? const Color(0xFF1177AA) : const Color(0xFF94A3B8))
                : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: enabled ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
