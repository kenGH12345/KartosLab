/// Solute / particle type strings — PhET `SoluteType.ts`.
enum SoluteType {
  oxygen,
  carbonDioxide,
  sodiumIon,
  potassiumIon,
  glucose,
  atp,
  adp,
  phosphate,
}

extension SoluteTypeLabel on SoluteType {
  String get panelLabel {
    switch (this) {
      case SoluteType.oxygen:
        return 'O₂';
      case SoluteType.carbonDioxide:
        return 'CO₂';
      case SoluteType.sodiumIon:
        return 'Na⁺';
      case SoluteType.potassiumIon:
        return 'K⁺';
      case SoluteType.glucose:
        return 'Glucose';
      case SoluteType.atp:
        return 'ATP';
      case SoluteType.adp:
        return 'ADP';
      case SoluteType.phosphate:
        return 'Pᵢ';
    }
  }
}

enum LigandType {
  triangleLigand,
  starLigand,
}

/// Union of solute + ligand types used by particles.
enum ParticleType {
  oxygen,
  carbonDioxide,
  sodiumIon,
  potassiumIon,
  glucose,
  atp,
  adp,
  phosphate,
  triangleLigand,
  starLigand,
}

extension ParticleTypeX on ParticleType {
  bool get isLigand =>
      this == ParticleType.triangleLigand || this == ParticleType.starLigand;

  bool get isGas =>
      this == ParticleType.oxygen || this == ParticleType.carbonDioxide;

  SoluteType? get asSolute {
    switch (this) {
      case ParticleType.oxygen:
        return SoluteType.oxygen;
      case ParticleType.carbonDioxide:
        return SoluteType.carbonDioxide;
      case ParticleType.sodiumIon:
        return SoluteType.sodiumIon;
      case ParticleType.potassiumIon:
        return SoluteType.potassiumIon;
      case ParticleType.glucose:
        return SoluteType.glucose;
      case ParticleType.atp:
        return SoluteType.atp;
      case ParticleType.adp:
        return SoluteType.adp;
      case ParticleType.phosphate:
        return SoluteType.phosphate;
      case ParticleType.triangleLigand:
      case ParticleType.starLigand:
        return null;
    }
  }

  static ParticleType fromSolute(SoluteType s) {
    switch (s) {
      case SoluteType.oxygen:
        return ParticleType.oxygen;
      case SoluteType.carbonDioxide:
        return ParticleType.carbonDioxide;
      case SoluteType.sodiumIon:
        return ParticleType.sodiumIon;
      case SoluteType.potassiumIon:
        return ParticleType.potassiumIon;
      case SoluteType.glucose:
        return ParticleType.glucose;
      case SoluteType.atp:
        return ParticleType.atp;
      case SoluteType.adp:
        return ParticleType.adp;
      case SoluteType.phosphate:
        return ParticleType.phosphate;
    }
  }
}

/// Selectable in SolutesPanel (excludes adp/phosphate).
const List<SoluteType> selectableSoluteTypes = [
  SoluteType.oxygen,
  SoluteType.carbonDioxide,
  SoluteType.sodiumIon,
  SoluteType.potassiumIon,
  SoluteType.glucose,
  SoluteType.atp,
];

const List<SoluteType> plottableSoluteTypes = [
  SoluteType.oxygen,
  SoluteType.carbonDioxide,
  SoluteType.sodiumIon,
  SoluteType.potassiumIon,
  SoluteType.glucose,
];
