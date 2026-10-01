import '../som_constants.dart';
import 'atom_type.dart';

/// Sparse epsilon table for LJ — PhET InteractionStrengthTable.
class InteractionStrengthTable {
  InteractionStrengthTable._();

  static const double defaultAdjustableInteractionPotential =
      SomConstants.maxEpsilon / 2;

  /// Epsilon (ε/k_B in Kelvin) between two atom types.
  static double getInteractionPotential(AtomType atomType1, AtomType atomType2) {
    if (atomType1 == atomType2) {
      switch (atomType1) {
        case AtomType.neon:
          return 35.8;
        case AtomType.argon:
          return 111.84;
        case AtomType.oxygen:
          return 1000;
        case AtomType.adjustable:
          return defaultAdjustableInteractionPotential;
        case AtomType.hydrogen:
          throw StateError(
            'Interaction potential not available for requested atom: $atomType1',
          );
      }
    }

    final pair = {atomType1, atomType2};
    if (pair.contains(AtomType.neon) && pair.contains(AtomType.argon)) {
      return 59.5;
    }
    if (pair.contains(AtomType.neon) && pair.contains(AtomType.oxygen)) {
      return 51;
    }
    if (pair.contains(AtomType.argon) && pair.contains(AtomType.oxygen)) {
      return 85;
    }
    if (atomType1 == AtomType.adjustable || atomType2 == AtomType.adjustable) {
      return (SomConstants.maxEpsilon - SomConstants.minEpsilon) / 2;
    }
    throw StateError(
      'No data for this combination of molecules: $atomType1, $atomType2',
    );
  }
}
