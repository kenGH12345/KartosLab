/// PhET Label — a label with value/unit display (e.g. "Voltage: 1.5 V").
library;

import 'package:flutter/material.dart';
import '../theme/phet_theme.dart';

class PhetLabel extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final bool onDark;

  const PhetLabel({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PhetTheme.of(context);
    final fg = onDark ? theme.textOnDark : theme.textPrimary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: TextStyle(fontSize: 12, color: fg)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: onDark ? Colors.white12 : Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: onDark ? Colors.white24 : theme.buttonBorder),
          ),
          child: Text(
            unit != null ? '$value $unit' : value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: onDark ? theme.textOnDark : theme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
