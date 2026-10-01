/// PhET Toggle Button — a button that stays "selected" until toggled off.
library;

import 'package:flutter/material.dart';
import '../theme/phet_theme.dart';

class PhetToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onPressed;
  final bool enabled;

  const PhetToggleButton({
    super.key,
    required this.label,
    required this.selected,
    this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PhetTheme.of(context);
    final isInteractive = enabled && onPressed != null;

    return GestureDetector(
      onTap: isInteractive ? onPressed : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? theme.buttonPrimary : theme.buttonSecondary,
          border: Border.all(
            color: selected ? theme.buttonPrimary : theme.buttonBorder,
            width: theme.borderWidth,
          ),
          borderRadius: BorderRadius.circular(theme.buttonRadius),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: selected ? theme.buttonOnPrimary : theme.textSecondary,
          ),
        ),
      ),
    );
  }
}
