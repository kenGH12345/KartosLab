import '../model/equation.dart';
import '../model/equation_term.dart';

/// PhET `HorizontalAligner.ts`
class HorizontalAligner {
  const HorizontalAligner({
    required this.screenWidth,
    required this.boxWidth,
    required this.boxXSpacing,
  });

  final double screenWidth;
  final double boxWidth;
  final double boxXSpacing;

  double get screenCenterX => screenWidth / 2;
  double get reactantsBoxLeft => screenCenterX - boxXSpacing / 2 - boxWidth;
  double get productsBoxLeft => screenCenterX + boxXSpacing / 2;
  double get reactantsBoxRight => screenCenterX - boxXSpacing / 2;
  double get productsBoxRight => screenCenterX + boxXSpacing / 2 + boxWidth;

  List<double> reactantXOffsets(Equation equation) =>
      _xOffsets(equation.reactants, reactantsBoxLeft, alignLeft: false);

  List<double> productXOffsets(Equation equation) =>
      _xOffsets(equation.products, productsBoxLeft, alignLeft: true);

  List<double> _xOffsets(
    List<EquationTerm> terms,
    double boxLeft, {
    required bool alignLeft,
  }) {
    final n = terms.length;
    if (n == 1) {
      return [boxLeft + (alignLeft ? 0.25 : 0.75) * boxWidth];
    }
    final columnWidth = boxWidth / n;
    return List.generate(n, (i) => boxLeft + columnWidth / 2 + i * columnWidth);
  }
}
