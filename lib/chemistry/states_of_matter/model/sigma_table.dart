import '../som_constants.dart';
import 'atom_type.dart';

/// Sigma (distance) parameter for LJ — PhET `SigmaTable`.
class SigmaTable {
  SigmaTable._();

  static double getSigma(AtomType atomType1, AtomType atomType2) {
    if (atomType1 == atomType2) {
      switch (atomType1) {
        case AtomType.neon:
          return 308;
        case AtomType.argon:
          return 376;
        case AtomType.oxygen:
          return 200;
        case AtomType.adjustable:
          return SomConstants.adjustableAttractionDefaultRadius * 2;
        case AtomType.hydrogen:
          assert(false, 'sigma not available for hydrogen');
          return SomConstants.maxEpsilon / 2;
      }
    }

    final pair = {atomType1, atomType2};
    if (pair.contains(AtomType.neon) && pair.contains(AtomType.argon)) {
      return 343;
    }
    if (pair.contains(AtomType.neon) && pair.contains(AtomType.oxygen)) {
      return SomConstants.neonRadius + SomConstants.oxygenRadius;
    }
    if (pair.contains(AtomType.argon) && pair.contains(AtomType.oxygen)) {
      return SomConstants.argonRadius + SomConstants.oxygenRadius;
    }
    if (atomType1 == AtomType.adjustable || atomType2 == AtomType.adjustable) {
      return SomConstants.adjustableAttractionDefaultRadius * 2;
    }
    assert(false, 'sigma not available for $atomType1, $atomType2');
    return (SomConstants.maxSigma - SomConstants.minSigma) / 2;
  }
}
