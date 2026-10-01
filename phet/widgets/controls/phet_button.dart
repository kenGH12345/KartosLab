/// PhET Button — a styled push button consistent with PhET UI conventions.
library;

import 'package:flutter/material.dart';
import '../theme/phet_theme.dart';

class PhetButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool selected;
  final IconData? icon;
  final double? width;

  const PhetButton({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.selected = false,
    this.icon,
    this.width,
  });

  @override
  State<PhetButton> createState() => _PhetButtonState();
}

class _PhetButtonState extends State<PhetButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = PhetTheme.of(context);
    final isInteractive = widget.enabled && widget.onPressed != null;

    Color bg;
    Color fg;
    if (!isInteractive) {
      bg = theme.buttonSecondary.withValues(alpha: 0.5);
      fg = theme.textSecondary;
    } else if (widget.selected) {
      bg = theme.buttonPrimary;
      fg = theme.buttonOnPrimary;
    } else if (_pressed) {
      bg = theme.buttonPrimary.withValues(alpha: 0.8);
      fg = theme.buttonOnPrimary;
    } else if (_hover) {
      bg = theme.buttonPrimary.withValues(alpha: 0.9);
      fg = theme.buttonOnPrimary;
    } else {
      bg = theme.buttonSecondary;
      fg = theme.textPrimary;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: isInteractive ? widget.onPressed : null,
        child: Container(
          width: widget.width,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(theme.buttonRadius),
            border: Border.all(
              color: widget.selected ? theme.buttonPrimary : theme.buttonBorder,
              width: theme.borderWidth,
            ),
            boxShadow: isInteractive
                ? [BoxShadow(color: theme.panelShadow, blurRadius: 4, offset: const Offset(1, 2))]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
