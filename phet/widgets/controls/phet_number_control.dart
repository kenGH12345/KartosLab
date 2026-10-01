/// PhET Number Control — a label + value display + chevron stepper combo
/// (used for loops, particle count, etc.).
library;

import 'package:flutter/material.dart';
import '../theme/phet_theme.dart';
import 'phet_arrow_button.dart';

class PhetNumberControl extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int>? onChanged;

  const PhetNumberControl({
    super.key,
    required this.label,
    required this.value,
    this.min = 1,
    this.max = 99,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PhetTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: theme.textPrimary)),
        Row(
          children: [
            PhetArrowButton.left(
              onPressed: value > min ? () => onChanged?.call(value - 1) : null,
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                '$value',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.textPrimary),
              ),
            ),
            PhetArrowButton.right(
              onPressed: value < max ? () => onChanged?.call(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}
