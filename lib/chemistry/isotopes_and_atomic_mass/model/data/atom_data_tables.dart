// GENERATED FILE — do not edit by hand.
// Source: shred AtomData.ts / AtomNameUtils.ts (locked commit — see SHRED_SOURCE.md)
// Converter: tool/isotopes_and_atomic_mass/convert_atom_data.py
//
// ignore_for_file: prefer_single_quotes

/// Sentinel abundance used by PhET when NIST lists an isotope as "trace".
const double kTraceAbundance = 0.000000000001;

/// Highest Z present in [kIsotopeInfoTable] (PhET: first 18 elements only).
const int kIsotopeInfoMaxAtomicNumber = 18;

/// Chemical symbols indexed by atomic number (shred symbolTable).
const List<String> kSymbolTable = [
  '-', // 0
  'H', // 1
  'He', // 2
  'Li', // 3
  'Be', // 4
  'B', // 5
  'C', // 6
  'N', // 7
  'O', // 8
  'F', // 9
  'Ne', // 10
  'Na', // 11
  'Mg', // 12
  'Al', // 13
  'Si', // 14
  'P', // 15
  'S', // 16
  'Cl', // 17
  'Ar', // 18
];

/// English element names (lowercase) indexed by Z (shred englishNameTable).
const List<String> kEnglishNameTable = [
  '', // 0
  'hydrogen', // 1
  'helium', // 2
  'lithium', // 3
  'beryllium', // 4
  'boron', // 5
  'carbon', // 6
  'nitrogen', // 7
  'oxygen', // 8
  'fluorine', // 9
  'neon', // 10
  'sodium', // 11
  'magnesium', // 12
  'aluminum', // 13
  'silicon', // 14
  'phosphorus', // 15
  'sulfur', // 16
  'chlorine', // 17
  'argon', // 18
];

/// Stable neutron counts per Z (shred stableElementTable), Z=0..18.
const List<List<int>> kStableNeutronsByZ = [
  [], // 0
  [0, 1], // 1
  [1, 2], // 2
  [3, 4], // 3
  [5], // 4
  [5, 6], // 5
  [6, 7], // 6
  [7, 8], // 7
  [8, 9, 10], // 8
  [10], // 9
  [10, 11, 12], // 10
  [12], // 11
  [12, 13, 14], // 12
  [14], // 13
  [14, 15, 16], // 14
  [16], // 15
  [16, 17, 18, 20], // 16
  [18, 20], // 17
  [18, 20, 22], // 18
];

/// Neutrons in most common (most stable) isotope per Z (shred).
const List<int> kNumNeutronsInMostCommonIsotope = [
  0, // 0
  0, // 1
  2, // 2
  4, // 3
  5, // 4
  6, // 5
  6, // 6
  7, // 7
  8, // 8
  10, // 9
  10, // 10
  12, // 11
  12, // 12
  14, // 13
  14, // 14
  16, // 15
  16, // 16
  18, // 17
  22, // 18
];

/// Standard atomic mass / weight per Z (shred standardMassTable), amu.
const List<double> kStandardAtomicMassByZ = [
  0.0, // 0
  1.00794, // 1
  4.002602, // 2
  6.941, // 3
  9.012182, // 4
  10.811, // 5
  12.0107, // 6
  14.0067, // 7
  15.9994, // 8
  18.9984032, // 9
  20.1797, // 10
  22.98976928, // 11
  24.305, // 12
  26.9815386, // 13
  28.0855, // 14
  30.973762, // 15
  32.065, // 16
  35.453, // 17
  39.948, // 18
];

/// One isotope entry from shred ISOTOPE_INFO_TABLE.
class RawIsotopeInfo {
  const RawIsotopeInfo({
    required this.atomicNumber,
    required this.massNumber,
    required this.atomicMass,
    required this.abundance,
  });

  final int atomicNumber;
  final int massNumber;
  final double atomicMass;
  /// Natural abundance as a proportion (not percent). May be [kTraceAbundance].
  final double abundance;
}

/// Flat list of all ISOTOPE_INFO_TABLE entries (Z=1..18).
const List<RawIsotopeInfo> kIsotopeInfoTable = [
  RawIsotopeInfo(atomicNumber: 1, massNumber: 1, atomicMass: 1.00782503207, abundance: 0.999885),
  RawIsotopeInfo(atomicNumber: 1, massNumber: 2, atomicMass: 2.0141017778, abundance: 0.000115),
  RawIsotopeInfo(atomicNumber: 1, massNumber: 3, atomicMass: 3.0160492777, abundance: kTraceAbundance),
  RawIsotopeInfo(atomicNumber: 2, massNumber: 3, atomicMass: 3.0160293191, abundance: 1.34e-06),
  RawIsotopeInfo(atomicNumber: 2, massNumber: 4, atomicMass: 4.00260325415, abundance: 0.99999866),
  RawIsotopeInfo(atomicNumber: 3, massNumber: 6, atomicMass: 6.015122795, abundance: 0.0759),
  RawIsotopeInfo(atomicNumber: 3, massNumber: 7, atomicMass: 7.01600455, abundance: 0.9241),
  RawIsotopeInfo(atomicNumber: 4, massNumber: 7, atomicMass: 7.016929828, abundance: kTraceAbundance),
  RawIsotopeInfo(atomicNumber: 4, massNumber: 9, atomicMass: 9.0121822, abundance: 1.0),
  RawIsotopeInfo(atomicNumber: 4, massNumber: 10, atomicMass: 10.013533818, abundance: kTraceAbundance),
  RawIsotopeInfo(atomicNumber: 5, massNumber: 10, atomicMass: 10.012937, abundance: 0.199),
  RawIsotopeInfo(atomicNumber: 5, massNumber: 11, atomicMass: 11.0093054, abundance: 0.801),
  RawIsotopeInfo(atomicNumber: 6, massNumber: 12, atomicMass: 12.0, abundance: 0.9893),
  RawIsotopeInfo(atomicNumber: 6, massNumber: 13, atomicMass: 13.0033548378, abundance: 0.0107),
  RawIsotopeInfo(atomicNumber: 6, massNumber: 14, atomicMass: 14.003241989, abundance: kTraceAbundance),
  RawIsotopeInfo(atomicNumber: 7, massNumber: 14, atomicMass: 14.0030740048, abundance: 0.99636),
  RawIsotopeInfo(atomicNumber: 7, massNumber: 15, atomicMass: 15.0001088982, abundance: 0.00364),
  RawIsotopeInfo(atomicNumber: 8, massNumber: 16, atomicMass: 15.99491461956, abundance: 0.99757),
  RawIsotopeInfo(atomicNumber: 8, massNumber: 17, atomicMass: 16.9991317, abundance: 0.00038),
  RawIsotopeInfo(atomicNumber: 8, massNumber: 18, atomicMass: 17.999161, abundance: 0.00205),
  RawIsotopeInfo(atomicNumber: 9, massNumber: 18, atomicMass: 18.000938, abundance: kTraceAbundance),
  RawIsotopeInfo(atomicNumber: 9, massNumber: 19, atomicMass: 18.99840322, abundance: 1.0),
  RawIsotopeInfo(atomicNumber: 10, massNumber: 20, atomicMass: 19.9924401754, abundance: 0.9048),
  RawIsotopeInfo(atomicNumber: 10, massNumber: 21, atomicMass: 20.99384668, abundance: 0.0027),
  RawIsotopeInfo(atomicNumber: 10, massNumber: 22, atomicMass: 21.991385114, abundance: 0.0925),
  RawIsotopeInfo(atomicNumber: 11, massNumber: 23, atomicMass: 22.9897692809, abundance: 1.0),
  RawIsotopeInfo(atomicNumber: 12, massNumber: 24, atomicMass: 23.9850417, abundance: 0.7899),
  RawIsotopeInfo(atomicNumber: 12, massNumber: 25, atomicMass: 24.98583692, abundance: 0.1),
  RawIsotopeInfo(atomicNumber: 12, massNumber: 26, atomicMass: 25.982592929, abundance: 0.1101),
  RawIsotopeInfo(atomicNumber: 13, massNumber: 27, atomicMass: 26.98153863, abundance: 1.0),
  RawIsotopeInfo(atomicNumber: 14, massNumber: 28, atomicMass: 27.9769265325, abundance: 0.92223),
  RawIsotopeInfo(atomicNumber: 14, massNumber: 29, atomicMass: 28.9764947, abundance: 0.04685),
  RawIsotopeInfo(atomicNumber: 14, massNumber: 30, atomicMass: 29.97377017, abundance: 0.03092),
  RawIsotopeInfo(atomicNumber: 15, massNumber: 31, atomicMass: 30.97376163, abundance: 1.0),
  RawIsotopeInfo(atomicNumber: 16, massNumber: 32, atomicMass: 31.972071, abundance: 0.9499),
  RawIsotopeInfo(atomicNumber: 16, massNumber: 33, atomicMass: 32.97145876, abundance: 0.0075),
  RawIsotopeInfo(atomicNumber: 16, massNumber: 34, atomicMass: 33.9678669, abundance: 0.0425),
  RawIsotopeInfo(atomicNumber: 16, massNumber: 36, atomicMass: 35.96708076, abundance: 0.0001),
  RawIsotopeInfo(atomicNumber: 17, massNumber: 35, atomicMass: 34.96885268, abundance: 0.7576),
  RawIsotopeInfo(atomicNumber: 17, massNumber: 37, atomicMass: 36.96590259, abundance: 0.2424),
  RawIsotopeInfo(atomicNumber: 18, massNumber: 36, atomicMass: 35.967545106, abundance: 0.003365),
  RawIsotopeInfo(atomicNumber: 18, massNumber: 38, atomicMass: 37.9627324, abundance: 0.000632),
  RawIsotopeInfo(atomicNumber: 18, massNumber: 40, atomicMass: 39.9623831225, abundance: 0.996003),
];

