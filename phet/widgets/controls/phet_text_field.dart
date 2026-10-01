/// PhET Text Field — styled text input.
library;

import 'package:flutter/material.dart';
import '../theme/phet_theme.dart';

class PhetTextField extends StatelessWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final bool enabled;

  const PhetTextField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.hintText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PhetTheme.of(context);
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: theme.buttonBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: theme.buttonBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: theme.buttonPrimary, width: 2),
        ),
      ),
      style: TextStyle(fontSize: 13, color: theme.textPrimary),
    );
  }
}
