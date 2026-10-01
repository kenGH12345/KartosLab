/// Zoom-in / Focused 的上一格记忆。render-only，不进 [ChartIntroState]。
///
/// [已确认] `FocusedNuclideChartNode` / `ZoomInNuclideChartNode`：
/// `doesExist || !initialized` 才改中心；否则保持。
/// 不在 ChartIntroModel 里；Reset 核子后节点仍在，故记忆不随 Reset 清掉。
library;

class ChartFocusMemory {
  int proton = 0;
  int neutron = 0;
  bool initialized = false;

  void sync({
    required int protonCount,
    required int neutronCount,
    required bool exists,
  }) {
    if (exists || !initialized) {
      initialized = true;
      proton = protonCount;
      neutron = neutronCount;
    }
  }
}
