import 'package:flutter/material.dart';

import 'color_range.dart';
import 'solute.dart';

/// Canonical 9-solute catalog from `MolarityModel.js` constructor.
///
/// Physics fields (C_sat, colors) are source-exact.
/// [displayName] may be localized; [formula] matches PhET symbols / Drink mix string.
///
/// `molar mass`: NOT USED in source — intentionally absent.
/// `particlesPerMole`: global [MolarityConstants.particlesPerMole], not per solute.
class MolaritySoluteCatalog {
  MolaritySoluteCatalog._();

  static const Color _red = Color(0xFFFF0000);
  static const Color _yellow = Color(0xFFFFFF00);
  static const Color _black = Color(0xFF000000);

  /// Source order — do not reorder.
  static List<Solute> createCanonical({
    List<String>? displayNames,
  }) {
    final names = displayNames ?? const [
      'Drink mix',
      'Cobalt(II) nitrate',
      'Cobalt chloride',
      'Potassium dichromate',
      'Gold(III) chloride',
      'Potassium chromate',
      'Nickel(II) chloride',
      'Copper sulfate',
      'Potassium permanganate',
    ];
    assert(names.length == 9);

    return [
      Solute(
        name: names[0],
        formula: 'Drink mix',
        saturatedConcentration: 5.95,
        solutionColor: const ColorRange(
          min: Color(0xFFFFE1E1), // (255,225,225)
          max: _red,
        ),
        particleColor: _red,
      ),
      Solute(
        name: names[1],
        formula: 'Co(NO\u2083)\u2082',
        saturatedConcentration: 5.65,
        solutionColor: const ColorRange(
          min: Color(0xFFFFE1E1),
          max: _red,
        ),
        particleColor: _red,
      ),
      Solute(
        name: names[2],
        formula: 'CoCl\u2082',
        saturatedConcentration: 4.35,
        solutionColor: const ColorRange(
          min: Color(0xFFFFF2F2), // (255,242,242)
          max: Color(0xFFFF6A6A), // (255,106,106)
        ),
        particleColor: const Color(0xFFFF6A6A),
      ),
      Solute(
        name: names[3],
        formula: 'K\u2082Cr\u2082O\u2087',
        saturatedConcentration: 0.50,
        solutionColor: const ColorRange(
          min: Color(0xFFFFE8D2), // (255,232,210)
          max: Color(0xFFFF7F00), // (255,127,0)
        ),
        particleColor: const Color(0xFFFF7F00),
      ),
      Solute(
        name: names[4],
        formula: 'AuCl\u2083',
        saturatedConcentration: 2.25,
        solutionColor: const ColorRange(
          min: Color(0xFFFFFFC7), // (255,255,199)
          max: Color(0xFFFFD700), // (255,215,0)
        ),
        particleColor: const Color(0xFFFFD700),
      ),
      Solute(
        name: names[5],
        formula: 'K\u2082CrO\u2084',
        saturatedConcentration: 3.35,
        solutionColor: const ColorRange(
          min: Color(0xFFFFFFC7),
          max: _yellow,
        ),
        particleColor: _yellow,
      ),
      Solute(
        name: names[6],
        formula: 'NiCl\u2082',
        saturatedConcentration: 5.2,
        solutionColor: const ColorRange(
          min: Color(0xFFEAF4EA), // (234,244,234)
          max: Color(0xFF008000), // (0,128,0)
        ),
        particleColor: const Color(0xFF008000),
      ),
      Solute(
        name: names[7],
        formula: 'CuSO\u2084',
        saturatedConcentration: 1.40,
        solutionColor: const ColorRange(
          min: Color(0xFFDEEEFF), // (222,238,255)
          max: Color(0xFF1E90FF), // (30,144,255)
        ),
        particleColor: const Color(0xFF1E90FF),
      ),
      Solute(
        name: names[8],
        formula: 'KMnO\u2084',
        saturatedConcentration: 0.50,
        solutionColor: const ColorRange(
          min: Color(0xFFFF00FF), // (255,0,255)
          max: Color(0xFF8B008B), // (139,0,139)
        ),
        particleColor: _black, // source exception
      ),
    ];
  }

  static const List<double> saturatedConcentrations = [
    5.95,
    5.65,
    4.35,
    0.50,
    2.25,
    3.35,
    5.2,
    1.40,
    0.50,
  ];
}
