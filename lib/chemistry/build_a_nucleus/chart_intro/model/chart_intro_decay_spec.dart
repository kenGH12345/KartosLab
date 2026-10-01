/// Chart Intro 方程用的衰变规格。对标 `BANDecayType` 的 mass/proton/symbol。
///
/// 不进 Decay Screen 五键面板。
library;

import '../../data/decay_type.dart';

class ChartIntroDecaySpec {
  const ChartIntroDecaySpec({
    required this.massNumber,
    required this.protonNumber,
    required this.symbol,
  });

  /// 从 A 减去。[已确认] `BANDecayType.massNumber`
  final int massNumber;

  /// 从 Z 减去；β− 为 −1。[已确认] `BANDecayType.protonNumber`
  final int protonNumber;

  /// 方程右侧发射物字母。[已确认] `BANDecayType.decaySymbol`
  final String symbol;

  static const ChartIntroDecaySpec alpha = ChartIntroDecaySpec(
    massNumber: 4,
    protonNumber: 2,
    symbol: 'α',
  );
  static const ChartIntroDecaySpec betaMinus = ChartIntroDecaySpec(
    massNumber: 0,
    protonNumber: -1,
    symbol: 'β',
  );
  static const ChartIntroDecaySpec betaPlus = ChartIntroDecaySpec(
    massNumber: 0,
    protonNumber: 1,
    symbol: 'β',
  );
  static const ChartIntroDecaySpec protonEmission = ChartIntroDecaySpec(
    massNumber: 1,
    protonNumber: 1,
    symbol: 'p',
  );
  static const ChartIntroDecaySpec neutronEmission = ChartIntroDecaySpec(
    massNumber: 1,
    protonNumber: 0,
    symbol: 'n',
  );

  static ChartIntroDecaySpec of(NucleusDecayType type) {
    switch (type) {
      case NucleusDecayType.alphaDecay:
        return alpha;
      case NucleusDecayType.betaMinusDecay:
        return betaMinus;
      case NucleusDecayType.betaPlusDecay:
        return betaPlus;
      case NucleusDecayType.protonEmission:
        return protonEmission;
      case NucleusDecayType.neutronEmission:
        return neutronEmission;
    }
  }
}
