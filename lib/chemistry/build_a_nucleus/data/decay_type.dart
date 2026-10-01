/// Build a Nucleus 支持的 5 种衰变类型。
///
/// 对应原项目 `js/common/model/BANDecayType.ts`。
/// 本文件只包含数据层所需的类型枚举与 ENSDF 键映射；
/// 颜色 / 文案 / 衰变方程参数属于 UI 层，后续阶段再补。
library;

enum NucleusDecayType {
  alphaDecay,
  betaMinusDecay,
  betaPlusDecay,
  protonEmission,
  neutronEmission;

  /// ENSDF 衰变串 → 衰变类型。
  ///
  /// 映射关系逐行对照 shred `AtomInfoUtils.getAvailableDecaysAndPercents` 的
  /// switch 语句；原项目中被忽略（break 且不入列）的 ENSDF 键
  /// （如 '2B-'、'B-N'、'24Ne' 等）不在表中，返回 null。
  static NucleusDecayType? fromEnsdfKey(String key) => _ensdfKeyToType[key];

  static const Map<String, NucleusDecayType> _ensdfKeyToType = {
    'B-': NucleusDecayType.betaMinusDecay,
    'EC+B+': NucleusDecayType.betaPlusDecay,
    'EC': NucleusDecayType.betaPlusDecay,
    'B+': NucleusDecayType.betaPlusDecay,
    '2EC': NucleusDecayType.betaPlusDecay,
    'B+A': NucleusDecayType.betaPlusDecay,
    'A': NucleusDecayType.alphaDecay,
    'P': NucleusDecayType.protonEmission,
    '2P': NucleusDecayType.protonEmission,
    'N': NucleusDecayType.neutronEmission,
    '2N': NucleusDecayType.neutronEmission,
  };
}
