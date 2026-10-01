import 'bce_element.dart';
import 'equation.dart';
import 'equation_term.dart';

/// PhET `AtomCount` — per-element totals on reactants vs products sides.
class AtomCount {
  AtomCount(this.element, this.reactantsCount, this.productsCount);

  final BceElement element;
  int reactantsCount;
  int productsCount;

  bool get isElementBalanced =>
      reactantsCount != 0 &&
      productsCount != 0 &&
      reactantsCount == productsCount;

  /// Order = first encounter left-to-right in terms (PhET `countAtoms`).
  static List<AtomCount> countAtoms(Equation equation) {
    final atomCounts = <AtomCount>[];
    _appendToCounts(atomCounts, equation.reactants, isReactants: true);
    _appendToCounts(atomCounts, equation.products, isReactants: false);
    return atomCounts;
  }

  static void _appendToCounts(
    List<AtomCount> atomCounts,
    List<EquationTerm> terms, {
    required bool isReactants,
  }) {
    for (final term in terms) {
      for (final atom in term.molecule.atoms) {
        var found = false;
        for (final atomCount in atomCounts) {
          if (atomCount.element == atom.element) {
            if (isReactants) {
              atomCount.reactantsCount += term.coefficient;
            } else {
              atomCount.productsCount += term.coefficient;
            }
            found = true;
            break;
          }
        }
        if (!found) {
          if (isReactants) {
            atomCounts.add(AtomCount(atom.element, term.coefficient, 0));
          } else {
            atomCounts.add(AtomCount(atom.element, 0, term.coefficient));
          }
        }
      }
    }
  }
}
