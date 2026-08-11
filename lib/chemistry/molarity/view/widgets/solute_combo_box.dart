import 'package:flutter/material.dart';

import '../../../../common/controls/kratos_combo_box.dart';
import '../../model/molarity_state.dart';
import '../../model/solute.dart';

/// 溶质选择下拉（包装 L0 KratosComboBox · 对齐蓝本 SoluteControlNode）。
class SoluteComboBox extends StatelessWidget {
  const SoluteComboBox({
    super.key,
    required this.state,
    required this.onSelected,
    this.width = 160,
    this.compact = false,
  });

  final bool compact;

  final MolarityState state;
  final ValueChanged<Solute> onSelected;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Theme(
      // 窄格下拉：缩小 arrow icon 防 1px 级溢出
      data: Theme.of(context).copyWith(
          iconTheme: const IconThemeData(size: 14, color: Color(0xFF64748B))),
      child: KratosComboBox<Solute>(
        label: compact ? null : '溶质',
        items: state.solutes,
        itemLabels: state.solutes.map((s) => s.name).toList(growable: false),
        value: state.solution.solute,
        width: width,
        onChanged: onSelected,
      ),
    );
  }
}
