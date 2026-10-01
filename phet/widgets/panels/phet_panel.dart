/// PhET Panel — a styled container for grouping controls.
///
/// Provides the characteristic PhET light-blue rounded panel with border
/// and shadow.
library;

import 'package:flutter/material.dart';
import '../theme/phet_theme.dart';

class PhetPanel extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final double? width;
  final double? padding;
  final bool onDark;

  const PhetPanel({
    super.key,
    this.title,
    required this.children,
    this.width,
    this.padding = 12,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PhetTheme.of(context);
    return Container(
      width: width,
      padding: EdgeInsets.all(padding!),
      decoration: BoxDecoration(
        color: onDark ? theme.panelBackground.withValues(alpha: 0.95) : theme.panelBackground.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(theme.panelRadius),
        border: Border.all(color: theme.panelBorder, width: theme.borderWidth),
        boxShadow: [
          BoxShadow(
            color: theme.panelShadow,
            blurRadius: theme.shadowBlur,
            offset: theme.shadowOffset,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: onDark ? theme.textOnDark : theme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
          ],
          ...children,
        ],
      ),
    );
  }
}
