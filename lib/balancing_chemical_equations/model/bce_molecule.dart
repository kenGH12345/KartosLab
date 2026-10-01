import 'bce_atom.dart';
import 'bce_element.dart';

/// PhET `common/model/Molecule.ts` — structured molecule (not a formula string).
///
/// Composition is an ordered list of [BceElement] → [BceAtom]s.
/// `symbol` is RichText-style with HTML `<sub>` tags (display layer strips/renders).
class BceMolecule {
  BceMolecule._(this.id, List<BceElement> elements)
      : atoms = List.unmodifiable(elements.map(BceAtom.new)),
        symbol = elementsToSymbol(elements),
        plainSymbol = elementsToSymbol(elements, withMarkup: false);

  /// Stable catalogue id (e.g. `N2`, `H2O`, `C2H5OH`).
  final String id;

  /// RichText / HTML subscript form, e.g. `H<sub>2</sub>O`.
  final String symbol;

  /// Plain text without markup, e.g. `H2O`.
  final String plainSymbol;

  final List<BceAtom> atoms;

  /// Count of each element in one molecule (coefficient not applied).
  Map<BceElement, int> get elementCounts {
    final counts = <BceElement, int>{};
    for (final atom in atoms) {
      counts[atom.element] = (counts[atom.element] ?? 0) + 1;
    }
    return counts;
  }

  /// Any molecule with more than 5 atoms is "big" (Game difficulty).
  bool get isBig => atoms.length > 5;

  // —— Static catalogue (Molecule.ts) ——

  static final c = BceMolecule._('C', [BceElement.c]);
  static final cl2 = BceMolecule._('Cl2', [BceElement.cl, BceElement.cl]);
  static final c2h2 = BceMolecule._('C2H2', [
    BceElement.c, BceElement.c, BceElement.h, BceElement.h,
  ]);
  static final c2h4 = BceMolecule._('C2H4', [
    BceElement.c, BceElement.c,
    BceElement.h, BceElement.h, BceElement.h, BceElement.h,
  ]);
  static final c2h5Cl = BceMolecule._('C2H5Cl', [
    BceElement.c, BceElement.c,
    BceElement.h, BceElement.h, BceElement.h, BceElement.h, BceElement.h,
    BceElement.cl,
  ]);
  static final c2h5Oh = BceMolecule._('C2H5OH', [
    BceElement.c, BceElement.c,
    BceElement.h, BceElement.h, BceElement.h, BceElement.h, BceElement.h,
    BceElement.o, BceElement.h,
  ]);
  static final c2h6 = BceMolecule._('C2H6', [
    BceElement.c, BceElement.c,
    BceElement.h, BceElement.h, BceElement.h, BceElement.h, BceElement.h, BceElement.h,
  ]);
  static final ch2o = BceMolecule._('CH2O', [
    BceElement.c, BceElement.h, BceElement.h, BceElement.o,
  ]);
  static final ch3Oh = BceMolecule._('CH3OH', [
    BceElement.c, BceElement.h, BceElement.h, BceElement.h, BceElement.o, BceElement.h,
  ]);
  static final ch4 = BceMolecule._('CH4', [
    BceElement.c, BceElement.h, BceElement.h, BceElement.h, BceElement.h,
  ]);
  static final co = BceMolecule._('CO', [BceElement.c, BceElement.o]);
  static final co2 = BceMolecule._('CO2', [BceElement.c, BceElement.o, BceElement.o]);
  static final cs2 = BceMolecule._('CS2', [BceElement.c, BceElement.s, BceElement.s]);
  static final f2 = BceMolecule._('F2', [BceElement.f, BceElement.f]);
  static final h2 = BceMolecule._('H2', [BceElement.h, BceElement.h]);
  static final h2o = BceMolecule._('H2O', [BceElement.h, BceElement.h, BceElement.o]);
  static final h2o2 = BceMolecule._('H2O2', [
    BceElement.h, BceElement.h, BceElement.o, BceElement.o,
  ]);
  static final h2s = BceMolecule._('H2S', [BceElement.h, BceElement.h, BceElement.s]);
  static final hf = BceMolecule._('HF', [BceElement.h, BceElement.f]);
  static final hCl = BceMolecule._('HCl', [BceElement.h, BceElement.cl]);
  static final n2 = BceMolecule._('N2', [BceElement.n, BceElement.n]);
  static final n2o = BceMolecule._('N2O', [BceElement.n, BceElement.n, BceElement.o]);
  static final n2o5 = BceMolecule._('N2O5', [
    BceElement.n, BceElement.n,
    BceElement.o, BceElement.o, BceElement.o, BceElement.o, BceElement.o,
  ]);
  static final nh3 = BceMolecule._('NH3', [
    BceElement.n, BceElement.h, BceElement.h, BceElement.h,
  ]);
  static final no = BceMolecule._('NO', [BceElement.n, BceElement.o]);
  static final no2 = BceMolecule._('NO2', [BceElement.n, BceElement.o, BceElement.o]);
  static final o2 = BceMolecule._('O2', [BceElement.o, BceElement.o]);
  static final of2 = BceMolecule._('OF2', [BceElement.o, BceElement.f, BceElement.f]);
  static final p = BceMolecule._('P', [BceElement.p]);
  static final p4 = BceMolecule._('P4', [
    BceElement.p, BceElement.p, BceElement.p, BceElement.p,
  ]);
  static final p2o5 = BceMolecule._('P2O5', [
    BceElement.p, BceElement.p,
    BceElement.o, BceElement.o, BceElement.o, BceElement.o, BceElement.o,
  ]);
  static final ph3 = BceMolecule._('PH3', [
    BceElement.p, BceElement.h, BceElement.h, BceElement.h,
  ]);
  static final pCl3 = BceMolecule._('PCl3', [
    BceElement.p, BceElement.cl, BceElement.cl, BceElement.cl,
  ]);
  static final pCl5 = BceMolecule._('PCl5', [
    BceElement.p,
    BceElement.cl, BceElement.cl, BceElement.cl, BceElement.cl, BceElement.cl,
  ]);
  static final pf3 = BceMolecule._('PF3', [
    BceElement.p, BceElement.f, BceElement.f, BceElement.f,
  ]);
  static final s = BceMolecule._('S', [BceElement.s]);
  static final so2 = BceMolecule._('SO2', [BceElement.s, BceElement.o, BceElement.o]);
  static final so3 = BceMolecule._('SO3', [
    BceElement.s, BceElement.o, BceElement.o, BceElement.o,
  ]);

  static final List<BceMolecule> all = [
    c, cl2, c2h2, c2h4, c2h5Cl, c2h5Oh, c2h6, ch2o, ch3Oh, ch4, co, co2, cs2,
    f2, h2, h2o, h2o2, h2s, hf, hCl, n2, n2o, n2o5, nh3, no, no2, o2, of2,
    p, p4, p2o5, ph3, pCl3, pCl5, pf3, s, so2, so3,
  ];

  static final Map<String, BceMolecule> _byId = {
    for (final m in all) m.id: m,
  };

  static BceMolecule byId(String id) {
    final m = _byId[id];
    if (m == null) {
      throw ArgumentError('Unknown molecule id=$id');
    }
    return m;
  }
}

/// Mirrors `elementsToSymbol` in Molecule.ts.
String elementsToSymbol(List<BceElement> elements, {bool withMarkup = true}) {
  var symbol = '';
  BceElement? element;
  var count = 0;
  for (final current in elements) {
    if (identical(current, element) || current == element) {
      count++;
    } else {
      if (count > 1) {
        symbol += withMarkup ? '<sub>$count</sub>' : '$count';
      }
      symbol += current.symbol;
      element = current;
      count = 1;
    }
  }
  if (count > 1) {
    symbol += withMarkup ? '<sub>$count</sub>' : '$count';
  }
  return symbol;
}
