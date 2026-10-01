/// PhET Checkbox — styled checkbox with label.
library;

import 'package:flutter/material.dart';
import '../theme/phet_theme.dart';

class PhetCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final bool enabled;

  const PhetCheckbox({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PhetTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeColor: theme.checkboxActive,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        Flexible(
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: theme.textPrimary),
          ),
        ),
      ],
    );
  }
}
