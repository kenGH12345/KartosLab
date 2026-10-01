/// PhET Icon Button — icon-only styled button.
library;

import 'package:flutter/material.dart';
import '../theme/phet_theme.dart';

class PhetIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool enabled;
  final double size;
  final String? tooltip;

  const PhetIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.enabled = true,
    this.size = 28,
    this.tooltip,
  });

  @override
  State<PhetIconButton> createState() => _PhetIconButtonState();
}

class _PhetIconButtonState extends State<PhetIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = PhetTheme.of(context);
    final isInteractive = widget.enabled && widget.onPressed != null;

    return Tooltip(
      message: widget.tooltip ?? '',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: isInteractive ? widget.onPressed : null,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _hover && isInteractive
                  ? theme.buttonPrimary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(theme.buttonRadius),
            ),
            child: Icon(
              widget.icon,
              size: widget.size,
              color: isInteractive ? theme.buttonPrimary : theme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
