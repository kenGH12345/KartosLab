/// Immutable isotope static data (shred ISOTOPE_INFO_TABLE + stability).
library;

import 'atom_data_tables.dart';
import 'isotope_id.dart';

/// Immutable isotope row. Fields are final; do not mutate.
class IsotopeData {
  const IsotopeData({
    required this.atomicNumber,
    required this.massNumber,
    required this.symbol,
    required this.atomicMass,
    required this.naturalAbundance,
    required this.stable,
  });

  final int atomicNumber;
  final int massNumber;
  final String symbol;

  /// Exact isotope atomic mass from ISOTOPE_INFO_TABLE (amu).
  final double atomicMass;

  /// Natural abundance as a **proportion** (not percent).
  /// Trace isotopes use shred `TRACE_ABUNDANCE` (1e-12).
  final double naturalAbundance;

  /// Whether (Z, N) is in shred `stableElementTable`.
  final bool stable;

  IsotopeId get id => IsotopeId(atomicNumber, massNumber);

  int get protonCount => atomicNumber;

  int get neutronCount => massNumber - atomicNumber;

  /// Neutral-atom electron count equals Z in this sim's isotope configs.
  int get electronCount => atomicNumber;

  bool get isTraceAbundance => naturalAbundance == kTraceAbundance;

  @override
  String toString() => 'IsotopeData($symbol-$massNumber)';
}
