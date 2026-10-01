/// Nuclear stability facade for Build an Atom.
///
/// Single source of truth: shared IAAM `AtomInfoUtils.isStable` (shred
/// `AtomIdentifier.isStable` / `stableElementTable`).
///
/// Empty nucleus (`P + N == 0`) is stable per shred `NumberAtom` /
/// `ParticleAtom` derived property.
library;

import 'package:kratos/chemistry/isotopes_and_atomic_mass/model/data/atom_info_utils.dart';

/// Stability helpers matching shred semantics used by BAA.
class AtomStability {
  AtomStability._();

  /// Whether the nucleus with [protons] + [neutrons] is considered stable.
  static bool isNucleusStable(int protons, int neutrons) {
    if (protons + neutrons == 0) return true;
    return AtomInfoUtils.isStable(protons, neutrons);
  }
}
