import 'package:flutter/material.dart';
import 'chart_series.dart';

/// 一组图表的命名集合（如 "Motion：Position+Velocity"）。
class GraphSuite {
  final String label;
  final List<ChartSeries> series;

  const GraphSuite({required this.label, required this.series});
}

/// 图表组选择器（RadioButton 风格切换）。
class GraphSuiteSelector extends StatelessWidget {
  const GraphSuiteSelector({
    super.key,
    required this.suites,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<GraphSuite> suites;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: List.generate(suites.length, (i) {
        final s = suites[i];
        return ChoiceChip(
          label: Text(s.label, style: const TextStyle(fontSize: 11)),
          selected: i == selectedIndex,
          onSelected: (_) => onChanged(i),
          selectedColor: const Color(0xFF1177AA).withAlpha(30),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }),
    );
  }
}
