/// Identity of an isotope: (atomicNumber, massNumber).
///
/// Matches PhET shred lookups keyed by Z then A in [ISOTOPE_INFO_TABLE].
library;

class IsotopeId {
  const IsotopeId(this.atomicNumber, this.massNumber)
      : assert(atomicNumber >= 0),
        assert(massNumber >= 0);

  /// Proton count / atomic number (Z).
  final int atomicNumber;

  /// Mass number (A = protons + neutrons).
  final int massNumber;

  /// Neutron count derived as A − Z (PhET AtomConfig convention).
  int get neutronCount => massNumber - atomicNumber;

  @override
  bool operator ==(Object other) =>
      other is IsotopeId &&
      other.atomicNumber == atomicNumber &&
      other.massNumber == massNumber;

  @override
  int get hashCode => Object.hash(atomicNumber, massNumber);

  @override
  String toString() => 'IsotopeId(Z=$atomicNumber, A=$massNumber)';
}
