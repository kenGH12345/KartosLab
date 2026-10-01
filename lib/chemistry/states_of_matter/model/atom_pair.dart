import 'atom_type.dart';

/// Fixed + movable atom pair for Interaction screen — PhET `AtomPair`.
enum AtomPair {
  neonNeon(AtomType.neon, AtomType.neon),
  argonArgon(AtomType.argon, AtomType.argon),
  oxygenOxygen(AtomType.oxygen, AtomType.oxygen),
  neonArgon(AtomType.neon, AtomType.argon),
  neonOxygen(AtomType.neon, AtomType.oxygen),
  argonOxygen(AtomType.argon, AtomType.oxygen),
  adjustable(AtomType.adjustable, AtomType.adjustable);

  const AtomPair(this.fixedAtomType, this.movableAtomType);

  final AtomType fixedAtomType;
  final AtomType movableAtomType;

  /// Reduced / basic sim pairs (no heterogeneous O2 mixes).
  static const List<AtomPair> reducedPairs = [
    AtomPair.neonNeon,
    AtomPair.argonArgon,
    AtomPair.adjustable,
  ];
}
