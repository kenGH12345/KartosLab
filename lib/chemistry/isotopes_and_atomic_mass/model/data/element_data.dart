/// Immutable element static data (shred AtomNameUtils + related tables).
library;

/// Immutable element row. Fields are final; do not mutate.
class ElementData {
  const ElementData({
    required this.atomicNumber,
    required this.symbol,
    required this.englishName,
    required this.standardAtomicMass,
    required this.mostCommonNeutronCount,
    required this.stableNeutronCounts,
  });

  /// Atomic number Z (= proton count for a neutral atom).
  final int atomicNumber;

  /// Chemical symbol (e.g. `H`, `He`).
  final String symbol;

  /// English name from shred `englishNameTable` (lowercase, e.g. `hydrogen`).
  final String englishName;

  /// Capitalized English display name (e.g. `Hydrogen`).
  String get name {
    if (englishName.isEmpty) return '';
    return englishName[0].toUpperCase() + englishName.substring(1);
  }

  /// Standard atomic mass / weight in amu (`standardMassTable[Z]`).
  final double standardAtomicMass;

  /// Neutrons in the most common isotope (`numNeutronsInMostStableIsotope[Z]`).
  final int mostCommonNeutronCount;

  /// Stable neutron counts for this element (`stableElementTable[Z]`).
  /// Preserved as a list — do not collapse to a single bool.
  final List<int> stableNeutronCounts;

  int get protonCount => atomicNumber;

  /// Mass number of the default / most-common isotope.
  int get mostCommonMassNumber => atomicNumber + mostCommonNeutronCount;

  @override
  String toString() => 'ElementData($symbol, Z=$atomicNumber)';
}
