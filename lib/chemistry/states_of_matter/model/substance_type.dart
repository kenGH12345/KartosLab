/// Substances that can fill the particle container.
enum SubstanceType {
  neon,
  argon,
  diatomicOxygen,
  water,
  adjustableAtom,
}

/// Whether [substance] is a supported monatomic type for the core model.
bool isMonatomicSubstance(SubstanceType substance) {
  return substance == SubstanceType.neon ||
      substance == SubstanceType.argon ||
      substance == SubstanceType.adjustableAtom;
}
