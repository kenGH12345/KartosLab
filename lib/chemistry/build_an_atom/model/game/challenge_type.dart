/// All Build an Atom game challenge types — PhET `ChallengeType.ts` (15).
library;

/// Exact string values match PhET `ChallengeTypeValues`.
enum ChallengeType {
  countsToElement('counts-to-element'),
  countsToCharge('counts-to-charge'),
  countsToMassNumber('counts-to-mass-number'),
  countsToSymbolAll('counts-to-symbol-all'),
  countsToSymbolCharge('counts-to-symbol-charge'),
  countsToSymbolMassNumber('counts-to-symbol-mass-number'),
  schematicToElement('schematic-to-element'),
  schematicToCharge('schematic-to-charge'),
  schematicToMassNumber('schematic-to-mass-number'),
  schematicToSymbolAll('schematic-to-symbol-all'),
  schematicToSymbolCharge('schematic-to-symbol-charge'),
  schematicToSymbolMassNumber('schematic-to-symbol-mass-number'),
  schematicToSymbolProtonCount('schematic-to-symbol-proton-count'),
  symbolToCounts('symbol-to-counts'),
  symbolToSchematic('symbol-to-schematic');

  const ChallengeType(this.id);
  final String id;

  static const int count = 15;

  static ChallengeType fromId(String id) {
    return ChallengeType.values.firstWhere((e) => e.id == id);
  }

  bool get isSchematicRelated => const {
        ChallengeType.schematicToElement,
        ChallengeType.schematicToCharge,
        ChallengeType.schematicToMassNumber,
        ChallengeType.schematicToSymbolAll,
        ChallengeType.schematicToSymbolProtonCount,
        ChallengeType.schematicToSymbolCharge,
        ChallengeType.schematicToSymbolMassNumber,
        ChallengeType.symbolToSchematic,
      }.contains(this);

  bool get isChargeRelated => const {
        ChallengeType.schematicToCharge,
        ChallengeType.countsToCharge,
        ChallengeType.countsToSymbolCharge,
        ChallengeType.schematicToSymbolCharge,
      }.contains(this);

  bool get isElementChallenge =>
      this == ChallengeType.countsToElement ||
      this == ChallengeType.schematicToElement;
}
