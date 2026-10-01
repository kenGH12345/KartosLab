/// PhET Radio Button — styled radio button group.
library;

import 'package:flutter/material.dart';
import '../theme/phet_theme.dart';

class PhetRadioButton<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final String label;
  final ValueChanged<T?>? onChanged;

  const PhetRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.label,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PhetTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<T>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: theme.radioButtonActive,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(label, style: TextStyle(fontSize: 12, color: theme.textPrimary)),
      ],
    );
  }
}

/// A horizontal row of radio buttons for quick DC/AC-style toggles.
class PhetRadioGroup<T> extends StatelessWidget {
  final List<T> options;
  final List<String> labels;
  final T groupValue;
  final ValueChanged<T?>? onChanged;

  const PhetRadioGroup({
    super.key,
    required this.options,
    required this.labels,
    required this.groupValue,
    this.onChanged,
  }) : assert(options.length == labels.length);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: List.generate(options.length, (i) {
        return PhetRadioButton<T>(
          value: options[i],
          groupValue: groupValue,
          label: labels[i],
          onChanged: onChanged,
        );
      }),
    );
  }
}
