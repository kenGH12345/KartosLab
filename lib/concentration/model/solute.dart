import 'dart:ui';

import 'solute_color_scheme.dart';
import 'solvent.dart';

/// Immutable solute definition — beers-law-lab `Solute.ts`.
class Solute {
  const Solute({
    required this.id,
    required this.displayName,
    required this.stockSolutionConcentration,
    required this.molarMass,
    required this.colorScheme,
    this.formula,
    this.particleFill,
    this.particleStroke,
    this.particleSize = 5,
    this.particlesPerMole = 200,
  });

  final String id;
  final String displayName;

  /// mol/L of stock solution in the dropper.
  final double stockSolutionConcentration;

  /// g/mol
  final double molarMass;

  final SoluteColorScheme colorScheme;

  /// Rich-text formula; null → use [displayName] as label.
  final String? formula;

  /// Override particle fill; null → derive from [colorScheme.maxColor].
  final Color? particleFill;

  /// Override particle stroke; null → darker of fill.
  final Color? particleStroke;

  final double particleSize; // cm
  final int particlesPerMole;

  /// Saturated concentration = colorScheme.maxConcentration (mol/L).
  double get saturatedConcentration => colorScheme.maxConcentration;

  Color get resolvedParticleFill => particleFill ?? colorScheme.maxColor;

  Color get resolvedParticleStroke {
    if (particleStroke != null) return particleStroke!;
    final fill = resolvedParticleFill;
    return Color.from(
      alpha: fill.a,
      red: (fill.r * 0.7).clamp(0.0, 1.0),
      green: (fill.g * 0.7).clamp(0.0, 1.0),
      blue: (fill.b * 0.7).clamp(0.0, 1.0),
    );
  }

  /// Mass-percent of stock solution — `Solute.ts` constructor.
  double get stockSolutionPercentConcentration {
    final numerator = molarMass * stockSolutionConcentration;
    return 100 * numerator / (Solvent.water.density + numerator);
  }
}
