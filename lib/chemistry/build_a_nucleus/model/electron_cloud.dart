/// Decay 屏电子云的纯视觉派生。
///
/// 原版 **不是** 离散电子、不是 Bohr 壳层、没有电子动画。
/// 是 [ParticleAtomNode] 上的单个径向渐变 [Circle]，半径随质子数查表后压缩。
///
/// 数据边界：只读 [BuildANucleusState] 已有质子数 + 查表半径；
/// 不查 [NuclideRepository]、不改 State、不算元素。
library;

import '../ban_constants.dart';
import 'build_a_nucleus_state.dart';

class ElectronCloudReading {
  const ElectronCloudReading({
    required this.protonCount,
    required this.atomicRadius,
  });

  /// 从 State 派生。Painter / Checkbox 走这条路径，不持有 Repository。
  factory ElectronCloudReading.fromState(BuildANucleusState state) =>
      ElectronCloudReading(
        protonCount: state.protonCount,
        atomicRadius: state.electronCloudAtomicRadius,
      );

  /// 质子数；原版把它当作电子数（中性假设）。
  /// [已确认] `updateCloudSize(protonNumber, …)` + doc/model.md
  final int protonCount;

  /// `mapElectronCountToRadius[protonCount]`；0 质子或缺条目为 null。
  /// [已确认] `AtomInfoUtils.getAtomicRadius`
  final double? atomicRadius;

  /// 质子为 0 时原版把云设为透明 + 半径 1E-5。
  /// [已确认] `ParticleAtomNode.updateCloudSize` 的 `protonNumber === 0` 分支
  bool get isTransparent => protonCount == 0;

  /// 压缩后的「壳层直径」（再参与视图半径公式）。
  /// [已确认] `getElectronShellDiameter` → `reduceRadiusRange`：
  /// `LinearFunction(min+1, max, minChanged, maxChanged).evaluate(atomicRadius)`
  /// Decay 屏 `protonNumberRange = Range(0, 94)` → 域 [1, 94]；
  /// LinearFunction 默认 **不 clamp**（phet `dot/LinearFunction` clamp=false）。
  double compressedDiameter({
    double minShellRadius = 1,
    double? maxElectrons,
    double minChangedRadius = BanConstants.electronCloudMinChangedRadius,
    double maxChangedRadius = BanConstants.electronCloudMaxChangedRadius,
  }) {
    final r = atomicRadius;
    if (isTransparent || r == null) return 0;
    final maxE = maxElectrons ?? BanConstants.decayMaxProtons.toDouble();
    return _linear(
      minShellRadius,
      maxE,
      minChangedRadius,
      maxChangedRadius,
      r,
    );
  }

  /// 屏上云半径。
  /// [已确认] `radius = (atomCenter.x - diameter/2) * factor`，factor=0.27。
  /// [推测] Flutter 把 atomCenter.x 映射为画布 origin.dx
  /// （原版是 LAYOUT_BOUNDS.width/3，与 NineGrid 画布坐标不是同一套）。
  double viewRadius(
    double atomCenterX, {
    double factor = BanConstants.electronCloudSizeFactor,
  }) {
    if (isTransparent) return 0;
    return (atomCenterX - compressedDiameter() / 2) * factor;
  }

  /// [已确认] phet `linear(a1,a2,b1,b2,a3)`，不 clamp。
  static double _linear(
    double a1,
    double a2,
    double b1,
    double b2,
    double a3,
  ) =>
      b1 + (a3 - a1) * (b2 - b1) / (a2 - a1);
}
