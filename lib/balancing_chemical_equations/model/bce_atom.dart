import 'bce_element.dart';

/// nitroglycerin `Atom` — instance of an element in a molecule.
class BceAtom {
  BceAtom(this.element)
      : symbol = element.symbol,
        covalentRadius = element.covalentRadius,
        covalentDiameter = element.covalentRadius * 2,
        electronegativity = element.electronegativity,
        atomicWeight = element.atomicWeight,
        colorArgb = element.colorArgb,
        reference = (_idCounter++).toRadixString(16) {
    id = '${element.symbol}_$reference';
  }

  static int _idCounter = 1;

  final BceElement element;
  final String symbol;
  final double covalentRadius;
  final double covalentDiameter;
  final double? electronegativity;
  final double atomicWeight;
  final int colorArgb;
  final String reference;
  late final String id;

  static BceAtom fromSymbol(String symbol) =>
      BceAtom(BceElement.getBySymbol(symbol));

  bool hasSameElement(BceAtom other) => element.isSameElement(other.element);

  bool get isHydrogen => element.isHydrogen;
  bool get isCarbon => element.isCarbon;
  bool get isOxygen => element.isOxygen;

  @override
  String toString() => symbol;
}
