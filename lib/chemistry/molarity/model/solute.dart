import 'package:flutter/material.dart';

import 'color_range.dart';

/// Immutable solute data — source: `js/molarity/model/Solute.js`.
///
/// Representation is **moles only** (no solid/solution form, no shaker/dropper).
/// `molar mass` is NOT USED in source.
@immutable
class Solute {
  const Solute({
    required this.name,
    required this.formula,
    required this.saturatedConcentration,
    required this.solutionColor,
    required this.particleColor,
    this.particleSize = 5,
    // Kept for JSON scenario compat; particle count uses
    // [MolarityConstants.particlesPerMole] (global 200).
    this.particlesPerMole = 200,
  });

  final String name;
  final String formula;

  /// Saturated concentration (M) — concentration cap (`C_sat`).
  final double saturatedConcentration;

  /// Solution color range: min (smallest non-zero) → max (saturated).
  final ColorRange solutionColor;

  /// Precipitate particle color (KMnO₄ is BLACK — source exception).
  final Color particleColor;

  /// Particle square side length (view).
  final double particleSize;

  /// Legacy per-solute field; source uses a **global** 200 — prefer constants.
  final int particlesPerMole;

  Color get solutionColorMax => solutionColor.maxColor;
  Color get minColor => solutionColor.min;
  Color get maxColor => solutionColor.max;
}
