import 'package:flutter/material.dart';

import '../controls/phet_slider.dart';
import '../controls/phet_radio_group.dart';
import '../controls/phet_combo_box.dart';
import '../controls/phet_number_field.dart';

/// 将多个属性控件垂直排列的聚合容器——对应 Java 版右侧 ControlPanel。
///
/// 用法：
/// ```dart
/// PropertyControlPanel(
///   children: [
///     PhetSlider(label: '焦距', unit: 'cm', min: 5, max: 50, value: f, onChanged: ...),
///     PhetRadioGroup<String>(label: '类型', items: ['凸透镜', '凹透镜'], value: t, onChanged: ...),
///   ],
/// )
/// ```
class PropertyControlPanel extends StatelessWidget {
  const PropertyControlPanel({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(12),
    this.spacing = 16.0,
    this.showDivider = false,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) spaced.add(SizedBox(height: spacing));
      spaced.add(children[i]);
      if (showDivider && i < children.length - 1) {
        spaced.add(const SizedBox(height: 4));
        spaced.add(const Divider(height: 1, color: Color(0xFFE2E8F0)));
        spaced.add(const SizedBox(height: 4));
      }
    }
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: spaced,
      ),
    );
  }

  /// 从 scenario JSON 的 `params` 段自动生成控件列表（§C2 合规）。
  ///
  /// JSON 格式（optics_scenario.schema.json）：
  /// ```json
  /// {
  ///   "params": [
  ///     {"key": "focalLength", "label": "焦距", "unit": "cm",
  ///       "min": 5, "max": 50, "step": 1, "type": "slider"},
  ///     {"key": "lensType", "label": "透镜类型",
  ///       "options": ["convex", "concave"], "type": "radio"}
  ///   ]
  /// }
  /// ```
  static Widget fromScenarioParam(
    Map<String, dynamic> param,
    Map<String, double> currentValues,
    void Function(String key, dynamic value) onParamChanged,
  ) {
    final key = param['key'] as String;
    final label = param['label'] as String? ?? key;
    final unit = param['unit'] as String?;
    final type = param['type'] as String? ?? 'slider';

    switch (type) {
      case 'slider':
        final min = (param['min'] as num?)?.toDouble() ?? 0;
        final max = (param['max'] as num?)?.toDouble() ?? 100;
        final step = (param['step'] as num?)?.toDouble();
        return PhetSlider(
          label: label,
          unit: unit,
          min: min,
          max: max,
          step: step,
          value: currentValues[key] ?? min,
          onChanged: (v) => onParamChanged(key, v),
        );

      case 'radio':
        final options = (param['options'] as List?)?.cast<String>() ?? [];
        return PhetRadioGroup<String>(
          label: label,
          items: options,
          value: currentValues[key]?.toString() ?? options.first,
          onChanged: (v) => onParamChanged(key, v),
        );

      case 'combo':
        final options = (param['options'] as List?)?.cast<String>() ?? [];
        return PhetComboBox<String>(
          label: label,
          items: options,
          value: currentValues[key]?.toString() ?? options.first,
          onChanged: (v) => onParamChanged(key, v),
        );

      case 'number':
        final min = (param['min'] as num?)?.toDouble();
        final max = (param['max'] as num?)?.toDouble();
        return PhetNumberField(
          label: label,
          unit: unit,
          min: min,
          max: max,
          value: currentValues[key] ?? 0,
          onChanged: (v) => onParamChanged(key, v),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
