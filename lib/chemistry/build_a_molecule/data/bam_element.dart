import 'package:flutter/material.dart';

/// Element properties for Build-a-Molecule.
/// Ported from nitroglycerin Element + BAMConstants.SUPPORTED_ELEMENTS order.
class BamElement {
  BamElement(
    this.symbol,
    this.covalentRadius,
    this.vanDerWaalsRadius,
    this.electronegativity,
    this.atomicWeight,
    this.color,
  );

  final String symbol;

  /// Covalent radius in picometers.
  final double covalentRadius;

  /// Van der Waals radius in picometers.
  final double vanDerWaalsRadius;

  /// Pauling units; null for noble gases.
  final double? electronegativity;

  /// Atomic mass units (u).
  final double atomicWeight;

  final Color color;

  // ---- static instances (from _ref_Element.ts) ----

  static final BamElement Ar =
      BamElement('Ar', 97, 188, null, 39.948, const Color(0xFFFFAFAF));
  static final BamElement B =
      BamElement('B', 85, 192, 2.04, 10.811, const Color(0xFFFFAA77));
  static final BamElement Be =
      BamElement('Be', 105, 153, 1.57, 9.012182, const Color(0xFFC2FF5F));
  static final BamElement Br =
      BamElement('Br', 114, 185, 2.96, 79.904, const Color(0xFFBE1E14));
  static final BamElement C =
      BamElement('C', 77, 170, 2.55, 12.0107, const Color(0xFFB2B2B2));
  static final BamElement Cl =
      BamElement('Cl', 100, 175, 3.16, 35.4527, const Color(0xFF88F215));
  static final BamElement F =
      BamElement('F', 72, 147, 3.98, 18.9984032, const Color(0xFFF5FF24));
  static final BamElement H =
      BamElement('H', 37, 120, 2.20, 1.00794, const Color(0xFFFFFFFF));
  static final BamElement I =
      BamElement('I', 133, 198, 2.66, 126.90447, const Color(0xFF940094));
  static final BamElement N =
      BamElement('N', 75, 155, 3.04, 14.00674, const Color(0xFF0000FF));
  static final BamElement Ne =
      BamElement('Ne', 69, 154, null, 20.1797, const Color(0xFF1AFFFB));
  /// O color = PhetColorScheme.RED_COLORBLIND
  static final BamElement O =
      BamElement('O', 73, 152, 3.44, 15.9994, const Color(0xFFFF5500));
  static final BamElement P =
      BamElement('P', 110, 180, 2.19, 30.973762, const Color(0xFFFF9A00));
  static final BamElement S =
      BamElement('S', 103, 180, 2.58, 32.066, const Color(0xFFD4B53B));
  static final BamElement Si =
      BamElement('Si', 118, 210, 1.90, 28.0855, const Color(0xFFF0C8A0));
  static final BamElement Sn =
      BamElement('Sn', 145, 217, 1.96, 118.710, const Color(0xFF668080));
  static final BamElement Xe =
      BamElement('Xe', 108, 216, 2.60, 131.293, const Color(0xFF429EB0));

  static final List<BamElement> elements = [
    Ar, B, Be, Br, C, Cl, F, H, I, N, Ne, O, P, S, Si, Sn, Xe,
  ];

  /// Order MUST match BAMConstants.SUPPORTED_ELEMENTS — ElementHistogram hash depends on it.
  static final List<BamElement> supportedElements = [
    B, Br, C, Cl, F, H, I, N, O, P, S, Si,
  ];

  static final Map<String, BamElement> _bySymbol = {
    for (final e in elements) e.symbol: e,
  };

  static BamElement getBySymbol(String symbol) {
    final e = _bySymbol[symbol];
    if (e == null) {
      throw ArgumentError('Element not found for symbol=$symbol');
    }
    return e;
  }

  bool isSameElement(BamElement other) => other.symbol == symbol;

  bool isHydrogen() => isSameElement(H);

  bool isCarbon() => isSameElement(C);

  bool isOxygen() => isSameElement(O);

  @override
  String toString() => symbol;
}
