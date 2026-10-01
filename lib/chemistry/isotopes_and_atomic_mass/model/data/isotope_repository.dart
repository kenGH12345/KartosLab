/// Unified isotope lookup — single access point for IsotopeData.
library;

import 'atom_data_tables.dart';
import 'atom_info_utils.dart';
import 'isotope_data.dart';
import 'isotope_id.dart';

class IsotopeRepository {
  IsotopeRepository._();

  static final IsotopeRepository instance = IsotopeRepository._();

  /// All isotopes listed in ISOTOPE_INFO_TABLE for [atomicNumber]
  /// (includes trace / unstable entries such as C-14, H-3).
  List<IsotopeData> getIsotopes(int atomicNumber) {
    final out = <IsotopeData>[];
    for (final entry in kIsotopeInfoTable) {
      if (entry.atomicNumber == atomicNumber) {
        out.add(AtomDataFactory.isotopeOrNull(
          entry.atomicNumber,
          entry.massNumber,
        )!);
      }
    }
    return out;
  }

  /// Stable isotopes only (shred `getStableIsotopesOfElement`).
  ///
  /// Order matches shred filter order (ISOTOPE_INFO_TABLE order).
  /// MixturesModel sorts by atomic mass separately.
  List<IsotopeData> getStableIsotopes(int atomicNumber) {
    return [
      for (final id in AtomInfoUtils.getStableIsotopeIdsOfElement(atomicNumber))
        find(id.atomicNumber, id.massNumber)!,
    ];
  }

  /// Stable isotopes sorted lightest → heaviest (Mixtures `updatePossibleIsotopesList`).
  List<IsotopeData> getStableIsotopesSortedByMass(int atomicNumber) {
    final list = getStableIsotopes(atomicNumber);
    list.sort((a, b) => a.atomicMass.compareTo(b.atomicMass));
    return list;
  }

  IsotopeData? find(int atomicNumber, int massNumber) {
    return AtomDataFactory.isotopeOrNull(atomicNumber, massNumber);
  }

  IsotopeData? findById(IsotopeId id) => find(id.atomicNumber, id.massNumber);

  IsotopeData? findByProtonsNeutrons(int protons, int neutrons) {
    return AtomDataFactory.isotopeFromProtonsNeutrons(protons, neutrons);
  }
}
