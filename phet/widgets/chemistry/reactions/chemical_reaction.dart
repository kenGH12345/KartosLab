/// PhET Chemical Reaction — models a chemical reaction with reactants,
/// products, and progress.
library;

class Reactant {
  final String formula;
  final double coefficient;
  final double available; // moles available

  const Reactant({
    required this.formula,
    this.coefficient = 1,
    this.available = 0,
  });

  Reactant copyWith({double? available}) => Reactant(
        formula: formula,
        coefficient: coefficient,
        available: available ?? this.available,
      );
}

class Product {
  final String formula;
  final double coefficient;

  const Product({
    required this.formula,
    this.coefficient = 1,
  });
}

class ChemicalReaction {
  final String name;
  final List<Reactant> reactants;
  final List<Product> products;
  double progress; // 0-1

  ChemicalReaction({
    required this.name,
    required this.reactants,
    required this.products,
    this.progress = 0,
  });

  /// Determine the limiting reactant (returns index, or -1).
  int get limitingReactantIndex {
    var minRatio = double.infinity;
    var idx = -1;
    for (int i = 0; i < reactants.length; i++) {
      final r = reactants[i];
      if (r.coefficient == 0) continue;
      final ratio = r.available / r.coefficient;
      if (ratio < minRatio) {
        minRatio = ratio;
        idx = i;
      }
    }
    return idx;
  }

  /// Maximum extent of reaction (limited by limiting reactant).
  double get maxExtent {
    final idx = limitingReactantIndex;
    if (idx < 0) return 0;
    return reactants[idx].available / reactants[idx].coefficient;
  }

  /// Advance the reaction by [extent] moles.
  void advance(double extent) {
    progress = (progress + extent).clamp(0.0, 1.0);
  }

  /// Get the reaction equation as a string.
  String get equation {
    final r = reactants.map((e) => e.formula).join(' + ');
    final p = products.map((e) => e.formula).join(' + ');
    return '$r → $p';
  }
}
