/// Chart Intro 顶部 mini-atom 的只读派生数据。
///
/// 不是第二份 Atom / Particle 世界。[已确认] 分析文档 + issue #220：
/// 原版双 ParticleAtom + listener 同步会在 step/dispose 重入。
/// 本层只暴露与壳层相同的 p/n 计数，供日后渲染，不持有粒子列表。
library;

class MiniAtomReading {
  const MiniAtomReading({
    required this.protonCount,
    required this.neutronCount,
  });

  final int protonCount;
  final int neutronCount;

  int get massNumber => protonCount + neutronCount;

  /// 不可交互。[已确认] doc/model.md + ChartIntroScreenView createMiniParticleView
  bool get interactive => false;
}
