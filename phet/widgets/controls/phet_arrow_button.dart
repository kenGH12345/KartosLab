/// PhET Arrow Button — chevron-style step button for number controls.
library;

import 'package:flutter/material.dart';
import '../theme/phet_theme.dart';

class PhetArrowButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool left;

  const PhetArrowButton({
    super.key,
    this.onPressed,
    this.left = false,
  });

  const PhetArrowButton.left({super.key, this.onPressed}) : left = true;
  const PhetArrowButton.right({super.key, this.onPressed}) : left = false;

  @override
  Widget build(BuildContext context) {
    final theme = PhetTheme.of(context);
    final isInteractive = onPressed != null;

    return IconButton(
      icon: Icon(left ? Icons.chevron_left : Icons.chevron_right, size: 20),
      onPressed: isInteractive ? onPressed : null,
      iconSize: 20,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      padding: EdgeInsets.zero,
      color: isInteractive ? theme.buttonPrimary : theme.textSecondary,
    );
  }
}
