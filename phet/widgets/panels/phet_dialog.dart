/// PhET Dialog — a styled modal dialog.
library;

import 'package:flutter/material.dart';
import '../theme/phet_theme.dart';
import '../controls/phet_button.dart';

class PhetDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String? confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const PhetDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmLabel,
    this.cancelLabel,
    this.onConfirm,
    this.onCancel,
  });

  /// Convenience method to show as a modal dialog.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required Widget content,
    String? confirmLabel,
    String? cancelLabel,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => PhetDialog(
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = PhetTheme.of(context);
    return AlertDialog(
      title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textPrimary)),
      content: content,
      backgroundColor: theme.panelBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(theme.panelRadius),
        side: BorderSide(color: theme.panelBorder, width: theme.borderWidth),
      ),
      actions: [
        if (cancelLabel != null)
          PhetButton(label: cancelLabel!, onPressed: onCancel ?? () => Navigator.of(context).pop()),
        if (confirmLabel != null)
          PhetButton(label: confirmLabel!, onPressed: onConfirm ?? () => Navigator.of(context).pop()),
      ],
    );
  }
}
