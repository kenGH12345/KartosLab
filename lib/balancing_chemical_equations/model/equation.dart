import 'package:flutter/foundation.dart';

import 'atom_count.dart';
import 'bce_molecule.dart';
import 'equation_term.dart';

/// PhET `common/model/Equation.ts`
///
/// Balance semantics (doc/model.md):
/// - **balanced**: every term has non-zero coeff = N × balancedCoefficient, same N ≥ 1
/// - **simplified**: balanced with N = 1 (each coeff == balancedCoefficient)
///
/// [balance] copies stored [EquationTerm.balancedCoefficient] values — it does
/// **not** solve a linear system at runtime. Canonical coeffs live in datasets.
class Equation extends ChangeNotifier {
  Equation._({
    required this.id,
    required List<EquationTerm> reactants,
    required List<EquationTerm> products,
  })  : reactants = List.unmodifiable(reactants),
        products = List.unmodifiable(products),
        terms = List.unmodifiable([...reactants, ...products]) {
    for (final term in terms) {
      term.addListener(_onTermChanged);
    }
  }

  /// Stable identity (tandem-style), not the display string.
  final String id;

  final List<EquationTerm> reactants;
  final List<EquationTerm> products;
  final List<EquationTerm> terms;

  void _onTermChanged() => notifyListeners();

  /// PhET `isBalancedProperty` — same N≥1 multiple of every balancedCoefficient.
  ///
  /// Mirrors Equation.ts DerivedProperty exactly (JS number division).
  bool get isBalanced {
    final first = reactants.first;
    final multiplier = first.coefficient / first.balancedCoefficient;
    for (final term in terms) {
      if (term.coefficient == 0) return false;
      if (term.coefficient != multiplier * term.balancedCoefficient) {
        return false;
      }
    }
    return true;
  }

  /// PhET `isSimplifiedProperty` — balanced with smallest coefficients (N = 1).
  bool get isSimplified {
    for (final term in terms) {
      if (term.coefficient != term.balancedCoefficient) return false;
    }
    return true;
  }

  /// PhET `hasNonZeroCoefficientProperty`.
  bool get hasNonZeroCoefficient {
    for (final term in terms) {
      if (term.coefficient != 0) return true;
    }
    return false;
  }

  bool get hasBigMolecule {
    for (final term in terms) {
      if (term.molecule.isBig) return true;
    }
    return false;
  }

  List<AtomCount> getAtomCounts() => AtomCount.countAtoms(this);

  /// Element totals per side for particle / visualization foundation.
  Map<BceMolecule, int> moleculeCountsFor(List<EquationTerm> side) {
    return {for (final t in side) t.molecule: t.coefficient};
  }

  /// Copy balanced coefficients into user coefficients (Show Answer / Next).
  void balance() {
    for (final term in terms) {
      term.coefficient = term.balancedCoefficient;
    }
  }

  void setInitialCoefficients(int initialCoefficient) {
    for (final term in terms) {
      term.setInitialCoefficient(initialCoefficient);
    }
  }

  void reset() {
    for (final term in terms) {
      term.reset();
    }
  }

  @override
  void dispose() {
    for (final term in terms) {
      term.removeListener(_onTermChanged);
    }
    super.dispose();
  }

  /// Debug string without HTML tags.
  @override
  String toString() {
    final buf = StringBuffer();
    for (var i = 0; i < reactants.length; i++) {
      if (i > 0) buf.write(' + ');
      buf.write('${reactants[i].balancedCoefficient} ');
      buf.write(reactants[i].molecule.plainSymbol);
    }
    buf.write(' → ');
    for (var i = 0; i < products.length; i++) {
      if (i > 0) buf.write(' + ');
      buf.write('${products[i].balancedCoefficient} ');
      buf.write(products[i].molecule.plainSymbol);
    }
    return buf.toString();
  }

  String getAnswerString() {
    final buf = StringBuffer();
    for (var i = 0; i < reactants.length; i++) {
      if (i > 0) buf.write(' + ');
      buf.write(reactants[i].balancedCoefficient);
    }
    buf.write(' ⮕ ');
    for (var i = 0; i < products.length; i++) {
      if (i > 0) buf.write(' + ');
      buf.write(products[i].balancedCoefficient);
    }
    return buf.toString();
  }

  /// PhET `Equation.getDisplayString()` — combo-box label with □ coeff placeholders.
  ///
  /// Uses White Square With Rounded Corners (`\u25A2`) and molecule HTML symbols.
  String getDisplayString() => _createEquationString(
        reactants,
        products,
        coefficientsString: '\u25A2',
      );

  static String _createEquationString(
    List<EquationTerm> reactants,
    List<EquationTerm> products, {
    String? coefficientsString,
  }) {
    final buf = StringBuffer();
    for (var i = 0; i < reactants.length; i++) {
      buf.write(coefficientsString ?? '${reactants[i].balancedCoefficient}');
      buf.write(' ');
      buf.write(reactants[i].molecule.symbol);
      if (i < reactants.length - 1) buf.write(' + ');
    }
    buf.write(' \u2B95 '); // RIGHTWARDS BLACK ARROW
    for (var i = 0; i < products.length; i++) {
      buf.write(coefficientsString ?? '${products[i].balancedCoefficient}');
      buf.write(' ');
      buf.write(products[i].molecule.symbol);
      if (i < products.length - 1) buf.write(' + ');
    }
    return buf.toString();
  }

  // —— Factories (Equation.ts) ——

  static Equation create2Reactants1Product({
    required String id,
    required int r1,
    required BceMolecule reactant1,
    required int r2,
    required BceMolecule reactant2,
    required int p1,
    required BceMolecule product1,
    required CoefficientRange coefficientsRange,
    int? initialCoefficient,
  }) {
    return Equation._(
      id: id,
      reactants: [
        EquationTerm(
          balancedCoefficient: r1,
          molecule: reactant1,
          coefficientRange: coefficientsRange,
          initialCoefficient: initialCoefficient,
        ),
        EquationTerm(
          balancedCoefficient: r2,
          molecule: reactant2,
          coefficientRange: coefficientsRange,
          initialCoefficient: initialCoefficient,
        ),
      ],
      products: [
        EquationTerm(
          balancedCoefficient: p1,
          molecule: product1,
          coefficientRange: coefficientsRange,
          initialCoefficient: initialCoefficient,
        ),
      ],
    );
  }

  static Equation create1Reactant2Products({
    required String id,
    required int r1,
    required BceMolecule reactant1,
    required int p1,
    required BceMolecule product1,
    required int p2,
    required BceMolecule product2,
    required CoefficientRange coefficientsRange,
    int? initialCoefficient,
  }) {
    return Equation._(
      id: id,
      reactants: [
        EquationTerm(
          balancedCoefficient: r1,
          molecule: reactant1,
          coefficientRange: coefficientsRange,
          initialCoefficient: initialCoefficient,
        ),
      ],
      products: [
        EquationTerm(
          balancedCoefficient: p1,
          molecule: product1,
          coefficientRange: coefficientsRange,
          initialCoefficient: initialCoefficient,
        ),
        EquationTerm(
          balancedCoefficient: p2,
          molecule: product2,
          coefficientRange: coefficientsRange,
          initialCoefficient: initialCoefficient,
        ),
      ],
    );
  }

  static Equation create2Reactants2Products({
    required String id,
    required int r1,
    required BceMolecule reactant1,
    required int r2,
    required BceMolecule reactant2,
    required int p1,
    required BceMolecule product1,
    required int p2,
    required BceMolecule product2,
    required CoefficientRange coefficientsRange,
    int? initialCoefficient,
  }) {
    return Equation._(
      id: id,
      reactants: [
        EquationTerm(
          balancedCoefficient: r1,
          molecule: reactant1,
          coefficientRange: coefficientsRange,
          initialCoefficient: initialCoefficient,
        ),
        EquationTerm(
          balancedCoefficient: r2,
          molecule: reactant2,
          coefficientRange: coefficientsRange,
          initialCoefficient: initialCoefficient,
        ),
      ],
      products: [
        EquationTerm(
          balancedCoefficient: p1,
          molecule: product1,
          coefficientRange: coefficientsRange,
          initialCoefficient: initialCoefficient,
        ),
        EquationTerm(
          balancedCoefficient: p2,
          molecule: product2,
          coefficientRange: coefficientsRange,
          initialCoefficient: initialCoefficient,
        ),
      ],
    );
  }
}
