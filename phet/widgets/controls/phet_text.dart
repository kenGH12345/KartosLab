/// PhET Text — styled text widget with consistent defaults.
library;

import 'package:flutter/material.dart';
import '../theme/phet_theme.dart';

class PhetText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final bool onDark;

  const PhetText(
    this.text, {
    super.key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PhetTheme.of(context);
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize ?? 13,
        fontWeight: fontWeight,
        color: color ?? (onDark ? theme.textOnDark : theme.textPrimary),
      ),
    );
  }
}
