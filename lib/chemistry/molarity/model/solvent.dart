import 'package:flutter/material.dart';

/// Solvent — source: `js/molarity/model/Water.js`.
///
/// Formula H₂O · color (224, 255, 255) = `#E0FFFF`.
@immutable
class Solvent {
  const Solvent({
    this.formula = 'H\u2082O',
    this.color = const Color(0xFFE0FFFF),
  });

  final String formula;
  final Color color;
}
