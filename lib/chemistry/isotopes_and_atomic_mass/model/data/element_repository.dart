/// Unified element lookup — single access point for ElementData.
library;

import 'atom_data_tables.dart';
import 'atom_info_utils.dart';
import 'element_data.dart';
import 'isotope_data.dart';

class ElementRepository {
  ElementRepository._();

  static final ElementRepository instance = ElementRepository._();

  /// All elements with ISOTOPE_INFO_TABLE coverage (Z = 1..18).
  List<ElementData> getAll() {
    return [
      for (var z = 1; z <= kIsotopeInfoMaxAtomicNumber; z++)
        AtomDataFactory.elementOrNull(z)!,
    ];
  }

  /// Lookup by atomic number. Returns `null` for unknown / out-of-range Z
  /// (including 0). Does **not** fall back to Hydrogen.
  ElementData? getByAtomicNumber(int atomicNumber) {
    return AtomDataFactory.elementOrNull(atomicNumber);
  }

  /// Default / most-common isotope for Make Isotopes initial state.
  ///
  /// Rule: `numNeutronsInMostStableIsotope[Z]` (PhET), **not** first table
  /// entry and **not** lightest isotope.
  IsotopeData? getDefaultIsotope(int atomicNumber) {
    final element = getByAtomicNumber(atomicNumber);
    if (element == null) return null;
    return AtomDataFactory.isotopeOrNull(
      atomicNumber,
      element.mostCommonMassNumber,
    );
  }

  IsotopeData? getDefaultIsotopeFor(ElementData element) {
    return getDefaultIsotope(element.atomicNumber);
  }
}
