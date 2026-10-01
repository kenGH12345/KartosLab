/// nitroglycerin `Element` — SHA ca115ad1233059957fa599a7c249feef1cbfacac
///
/// Chemistry identity + visual metadata used by BCE Molecule / AtomCount / later painters.
library;

class BceElement {
  const BceElement({
    required this.symbol,
    required this.covalentRadius,
    required this.vanDerWaalsRadius,
    required this.electronegativity,
    required this.atomicWeight,
    required this.colorArgb,
  });

  final String symbol;
  final double covalentRadius;
  final double vanDerWaalsRadius;
  final double? electronegativity;
  final double atomicWeight;

  /// ARGB packed color matching nitroglycerin / CPK.
  final int colorArgb;

  static const ar = BceElement(
    symbol: 'Ar',
    covalentRadius: 97,
    vanDerWaalsRadius: 188,
    electronegativity: null,
    atomicWeight: 39.948,
    colorArgb: 0xFFFFAFAF,
  );
  static const b = BceElement(
    symbol: 'B',
    covalentRadius: 85,
    vanDerWaalsRadius: 192,
    electronegativity: 2.04,
    atomicWeight: 10.811,
    colorArgb: 0xFFFFAA77,
  );
  static const be = BceElement(
    symbol: 'Be',
    covalentRadius: 105,
    vanDerWaalsRadius: 153,
    electronegativity: 1.57,
    atomicWeight: 9.012182,
    colorArgb: 0xFFC2FF5F,
  );
  static const br = BceElement(
    symbol: 'Br',
    covalentRadius: 114,
    vanDerWaalsRadius: 185,
    electronegativity: 2.96,
    atomicWeight: 79.904,
    colorArgb: 0xFFBE1E14,
  );
  static const c = BceElement(
    symbol: 'C',
    covalentRadius: 77,
    vanDerWaalsRadius: 170,
    electronegativity: 2.55,
    atomicWeight: 12.0107,
    colorArgb: 0xFFB2B2B2,
  );
  static const cl = BceElement(
    symbol: 'Cl',
    covalentRadius: 100,
    vanDerWaalsRadius: 175,
    electronegativity: 3.16,
    atomicWeight: 35.4527,
    colorArgb: 0xFF88F215,
  );
  static const f = BceElement(
    symbol: 'F',
    covalentRadius: 72,
    vanDerWaalsRadius: 147,
    electronegativity: 3.98,
    atomicWeight: 18.9984032,
    colorArgb: 0xFFF5FF24,
  );
  static const h = BceElement(
    symbol: 'H',
    covalentRadius: 37,
    vanDerWaalsRadius: 120,
    electronegativity: 2.20,
    atomicWeight: 1.00794,
    colorArgb: 0xFFFFFFFF,
  );
  static const i = BceElement(
    symbol: 'I',
    covalentRadius: 133,
    vanDerWaalsRadius: 198,
    electronegativity: 2.66,
    atomicWeight: 126.90447,
    colorArgb: 0xFF940094,
  );
  static const n = BceElement(
    symbol: 'N',
    covalentRadius: 75,
    vanDerWaalsRadius: 155,
    electronegativity: 3.04,
    atomicWeight: 14.00674,
    colorArgb: 0xFF0000FF,
  );
  static const ne = BceElement(
    symbol: 'Ne',
    covalentRadius: 69,
    vanDerWaalsRadius: 154,
    electronegativity: null,
    atomicWeight: 20.1797,
    colorArgb: 0xFF1AFFFB,
  );
  /// PhetColorScheme.RED_COLORBLIND ≈ rgb(255,85,0)
  static const o = BceElement(
    symbol: 'O',
    covalentRadius: 73,
    vanDerWaalsRadius: 152,
    electronegativity: 3.44,
    atomicWeight: 15.9994,
    colorArgb: 0xFFFF5500,
  );
  static const p = BceElement(
    symbol: 'P',
    covalentRadius: 110,
    vanDerWaalsRadius: 180,
    electronegativity: 2.19,
    atomicWeight: 30.973762,
    colorArgb: 0xFFFF9A00,
  );
  static const s = BceElement(
    symbol: 'S',
    covalentRadius: 103,
    vanDerWaalsRadius: 180,
    electronegativity: 2.58,
    atomicWeight: 32.066,
    colorArgb: 0xFFD4B53B,
  );
  static const si = BceElement(
    symbol: 'Si',
    covalentRadius: 118,
    vanDerWaalsRadius: 210,
    electronegativity: 1.90,
    atomicWeight: 28.0855,
    colorArgb: 0xFFF0C8A0,
  );
  static const sn = BceElement(
    symbol: 'Sn',
    covalentRadius: 145,
    vanDerWaalsRadius: 217,
    electronegativity: 1.96,
    atomicWeight: 118.710,
    colorArgb: 0xFF668080,
  );
  static const xe = BceElement(
    symbol: 'Xe',
    covalentRadius: 108,
    vanDerWaalsRadius: 216,
    electronegativity: 2.60,
    atomicWeight: 131.293,
    colorArgb: 0xFF429EB0,
  );

  static const List<BceElement> elements = [
    ar, b, be, br, c, cl, f, h, i, n, ne, o, p, s, si, sn, xe,
  ];

  static final Map<String, BceElement> _bySymbol = {
    for (final e in elements) e.symbol: e,
  };

  static BceElement getBySymbol(String symbol) {
    final e = _bySymbol[symbol];
    if (e == null) {
      throw ArgumentError('Element not found for symbol=$symbol');
    }
    return e;
  }

  bool isSameElement(BceElement other) => other.symbol == symbol;

  bool get isHydrogen => isSameElement(h);
  bool get isCarbon => isSameElement(c);
  bool get isOxygen => isSameElement(o);

  @override
  String toString() => symbol;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BceElement && other.symbol == symbol;

  @override
  int get hashCode => symbol.hashCode;
}
