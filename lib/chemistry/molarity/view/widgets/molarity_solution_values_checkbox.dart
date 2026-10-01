import 'package:flutter/material.dart';

/// Source `solutionValuesCheckbox` — "Solution Values" / 显示数值.
class MolaritySolutionValuesCheckbox extends StatelessWidget {
  const MolaritySolutionValuesCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '显示数值',
      checked: value,
      child: InkWell(
        onTap: () => onChanged(!value),
        // Source expands touchArea vertically.
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: value,
                  onChanged: (v) => onChanged(v ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '显示数值',
                style: TextStyle(fontSize: 22, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
