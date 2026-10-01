import 'package:flutter/material.dart';

/// PhET nitroglycerin element colors used by Real Molecules (CPK-style).
Color elementColor(String? symbol) {
  switch (symbol) {
    case 'H':
      return const Color(0xFFFFFFFF);
    case 'B':
      return const Color(0xFFFFAA77);
    case 'C':
      return const Color(0xFFB2B2B2);
    case 'N':
      return const Color(0xFF0000FF);
    case 'O':
      return const Color(0xFFFF5500); // RED_COLORBLIND
    case 'F':
      return const Color(0xFFF5FF24);
    case 'P':
      return const Color(0xFFFF9A00);
    case 'S':
      return const Color(0xFFD4B53B);
    case 'Cl':
      return const Color(0xFF88F215);
    case 'Br':
      return const Color(0xFFBE1E14);
    case 'Xe':
      return const Color(0xFF429EB0);
    case 'Be':
      return const Color(0xFFC2FF5F);
    default:
      return const Color(0xFFCCCCCC);
  }
}

/// `ChemUtils.toSubscript` for formulas like `H2O` → `H₂O`.
String toSubscriptFormula(String formula) {
  const map = {
    '0': '₀',
    '1': '₁',
    '2': '₂',
    '3': '₃',
    '4': '₄',
    '5': '₅',
    '6': '₆',
    '7': '₇',
    '8': '₈',
    '9': '₉',
  };
  final buffer = StringBuffer();
  for (final rune in formula.runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(map[ch] ?? ch);
  }
  return buffer.toString();
}
