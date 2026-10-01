/// ChallengeType → InteractiveSymbol / presentation helpers for Game View.
library;

import 'challenge_type.dart';

extension ChallengeTypeViewFlags on ChallengeType {
  bool get showsSchematicPrompt => isSchematicRelated && this != ChallengeType.symbolToSchematic;

  bool get showsCountsPrompt =>
      this == ChallengeType.countsToElement ||
      this == ChallengeType.countsToCharge ||
      this == ChallengeType.countsToMassNumber ||
      this == ChallengeType.countsToSymbolAll ||
      this == ChallengeType.countsToSymbolCharge ||
      this == ChallengeType.countsToSymbolMassNumber;

  bool get showsSymbolPrompt =>
      this == ChallengeType.symbolToCounts ||
      this == ChallengeType.symbolToSchematic;

  bool get usesInteractiveSymbolAnswer =>
      this == ChallengeType.countsToSymbolAll ||
      this == ChallengeType.countsToSymbolCharge ||
      this == ChallengeType.countsToSymbolMassNumber ||
      this == ChallengeType.schematicToSymbolAll ||
      this == ChallengeType.schematicToSymbolCharge ||
      this == ChallengeType.schematicToSymbolMassNumber ||
      this == ChallengeType.schematicToSymbolProtonCount;

  bool get isProtonCountConfigurable =>
      this == ChallengeType.schematicToSymbolProtonCount ||
      this == ChallengeType.schematicToSymbolAll ||
      this == ChallengeType.countsToSymbolAll;

  bool get isMassNumberConfigurable =>
      this == ChallengeType.schematicToSymbolMassNumber ||
      this == ChallengeType.countsToSymbolMassNumber ||
      this == ChallengeType.schematicToSymbolAll ||
      this == ChallengeType.countsToSymbolAll;

  bool get isChargeConfigurable =>
      this == ChallengeType.schematicToSymbolCharge ||
      this == ChallengeType.countsToSymbolCharge ||
      this == ChallengeType.schematicToSymbolAll ||
      this == ChallengeType.countsToSymbolAll;

  bool get isChargeAnswer =>
      this == ChallengeType.schematicToCharge ||
      this == ChallengeType.countsToCharge;

  bool get isMassAnswer =>
      this == ChallengeType.schematicToMassNumber ||
      this == ChallengeType.countsToMassNumber;

  String get challengeTitle {
    switch (this) {
      case ChallengeType.schematicToElement:
      case ChallengeType.countsToElement:
        return 'Find the element:';
      case ChallengeType.schematicToCharge:
      case ChallengeType.countsToCharge:
        return 'What is the total charge?';
      case ChallengeType.schematicToMassNumber:
      case ChallengeType.countsToMassNumber:
        return 'What is the mass number?';
      case ChallengeType.schematicToSymbolAll:
      case ChallengeType.countsToSymbolAll:
        return 'Find the symbol:';
      case ChallengeType.schematicToSymbolCharge:
      case ChallengeType.countsToSymbolCharge:
        return 'What is the charge?';
      case ChallengeType.schematicToSymbolMassNumber:
      case ChallengeType.countsToSymbolMassNumber:
        return 'What is the mass number?';
      case ChallengeType.schematicToSymbolProtonCount:
        return 'What is the atomic number?';
      case ChallengeType.symbolToCounts:
        return 'How many protons, neutrons and electrons?';
      case ChallengeType.symbolToSchematic:
        return 'Build the atom:';
    }
  }
}
