import 'package:flutter/material.dart';

/// scenery-phet `PhetFont` — Arial then sans-serif (PhET default).
class BaaPhetFont {
  BaaPhetFont._();

  static TextStyle of(
    double size, {
    Color color = const Color(0xFF000000),
    FontWeight fontWeight = FontWeight.normal,
    double height = 1.0,
  }) {
    return TextStyle(
      fontFamily: 'Arial',
      fontFamilyFallback: const ['Helvetica', 'sans-serif'],
      fontSize: size,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }
}
