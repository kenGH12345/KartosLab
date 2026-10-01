/// Chart Intro 纯状态层。
///
/// 不复用 [BuildANucleusState]（圆核、飞入、outgoing、半衰期、Be-6）。
/// 核素事实全部委托 [NuclideRepository]，本类不持有第二份表。
///
/// 原版 Property → 本类字段：
/// | ChartIntroModel / BANModel | Flutter |
/// | particleAtom.protonCountProperty | [protonCount]（壳层） |
/// | particleAtom.neutronCountProperty | [neutronCount] |
/// | particleAtom.massNumberProperty | [massNumber] |
/// | isStableProperty | [isStable] 查表 |
/// | nuclideExistsProperty | [nuclideExists] 查表 |
/// | selectedNuclideChartProperty | [selectedChart] |
/// | miniParticleAtom | [miniAtom] 派生，无第二粒子列表 |
/// | cellModelArray 当前格 | [currentCell] via POPULATED_CELLS |
/// | protonNumberRange / neutronNumberRange | 10 / 12 |
/// | step() 推进粒子 | fade 不在本类；α/β 只改计数 |
///
/// 本阶段不加：Half-Life、outgoing、电子云、Decay 五键 UI、Be-6。
library;

import '../../ban_constants.dart';
import '../../data/nuclide_repository.dart';
import '../../model/nucleon.dart';
import '../chart_intro_visuals.dart';
import 'mini_atom_reading.dart';
import 'populated_cells.dart';
import 'shell_model_nucleus.dart';

/// 壳层计数突变（衰变）。不含 opacity / 动画进度。
class ChartIntroShellMutation {
  const ChartIntroShellMutation({
    required this.removed,
    this.added,
  });

  final List<ShellNucleon> removed;
  final ShellNucleon? added;
}

enum ChartIntroChartType {
  /// [已确认] SelectedChartType = 'partial' | 'zoom'
  partial,
  zoom,
}

class ChartIntroState {
  ChartIntroState({required NuclideRepository repository})
      : _repository = repository;

  final NuclideRepository _repository;
  final ShellModelNucleus shell = ShellModelNucleus();

  ChartIntroChartType selectedChart = ChartIntroChartType.partial;

  bool _disposed = false;
  bool get isDisposed => _disposed;

  /// 无 Property listener。dispose 只作门闩，避免 issue #220 式重入更新。
  void dispose() {
    _disposed = true;
  }

  int get protonCount => shell.protonCount;
  int get neutronCount => shell.neutronCount;
  int get massNumber => protonCount + neutronCount;

  bool get isEmptyNucleus => protonCount == 0 && neutronCount == 0;

  bool get isStable => _repository.isStable(protonCount, neutronCount);
  bool get nuclideExists => _repository.doesExist(protonCount, neutronCount);

  bool get isShowingInvalidNuclide => !nuclideExists && !isEmptyNucleus;

  String get elementSymbol => _repository.elementSymbol(protonCount);
  String get elementName => _repository.elementName(protonCount);

  /// 周期表高亮 Z。空核不高亮。不看 [nuclideExists]。
  /// [已确认] PeriodicTableNode `if (protonCount !== 0)`
  int? get periodicTableHighlightZ =>
      protonCount == 0 ? null : protonCount;

  /// 当前核素图位置：X=中子，Y=质子。不在稀疏表则为 null（empty cell）。
  ChartCellRef? get currentCell =>
      PopulatedCells.cellAt(protonCount, neutronCount);

  bool get currentCellPopulated => currentCell != null;

  MiniAtomReading get miniAtom => MiniAtomReading(
        protonCount: protonCount,
        neutronCount: neutronCount,
      );

  bool get canAddProton => _creatorEnabled(directionUp: true, proton: true);
  bool get canRemoveProton => _creatorEnabled(directionUp: false, proton: true);
  bool get canAddNeutron => _creatorEnabled(directionUp: true, proton: false);
  bool get canRemoveNeutron =>
      _creatorEnabled(directionUp: false, proton: false);
  bool get canAddPair =>
      _creatorEnabled(directionUp: true, proton: true, both: true);
  bool get canRemovePair =>
      _creatorEnabled(directionUp: false, proton: true, both: true);

  ShellNucleon? addProton() {
    if (_disposed || !canAddProton) return null;
    return shell.add(NucleonType.proton);
  }

  ShellNucleon? addNeutron() {
    if (_disposed || !canAddNeutron) return null;
    return shell.add(NucleonType.neutron);
  }

  bool removeProton() {
    if (_disposed || !canRemoveProton) return false;
    return shell.removeLast(NucleonType.proton) != null;
  }

  bool removeNeutron() {
    if (_disposed || !canRemoveNeutron) return false;
    return shell.removeLast(NucleonType.neutron) != null;
  }

  bool addPair() {
    if (_disposed || !canAddPair) return false;
    shell.add(NucleonType.proton);
    shell.add(NucleonType.neutron);
    return true;
  }

  bool removePair() {
    if (_disposed || !canRemovePair) return false;
    shell.removeLast(NucleonType.proton);
    shell.removeLast(NucleonType.neutron);
    return true;
  }

  /// 立刻入座，不走箭头 enable。对标 `BANModel.addNucleonImmediatelyToAtom`。
  /// 仅供 β 新核子与测试装核；不是原版箭头飞入。
  ShellNucleon? addImmediately(NucleonType type) {
    if (_disposed) return null;
    return shell.add(type);
  }

  /// 衰变 extract，不走箭头 enable。[已确认] `extractParticle` + fade
  ShellNucleon? extractNucleon(NucleonType type) {
    if (_disposed) return null;
    return shell.removeLast(type);
  }

  /// Undo 恢复到衰变前计数。[已确认] `undoDecay` restorePreviousNucleonNumber
  void restoreNucleonCounts(int protons, int neutrons) {
    if (_disposed) return;
    shell.clear();
    for (var i = 0; i < protons; i++) {
      shell.add(NucleonType.proton);
    }
    for (var i = 0; i < neutrons; i++) {
      shell.add(NucleonType.neutron);
    }
  }

  /// α：立刻取走 2p+2n。不走箭头 enable。
  /// [已确认] `_.times(2, fadeOutShellNucleon(PROTON/NEUTRON))` 前 `extractParticle`
  ChartIntroShellMutation? applyAlpha() {
    if (_disposed ||
        protonCount < ChartIntroVisuals.alphaProtonCount ||
        neutronCount < ChartIntroVisuals.alphaNeutronCount) {
      return null;
    }
    final removed = <ShellNucleon>[
      for (var i = 0; i < ChartIntroVisuals.alphaProtonCount; i++)
        shell.removeLast(NucleonType.proton)!,
      for (var i = 0; i < ChartIntroVisuals.alphaNeutronCount; i++)
        shell.removeLast(NucleonType.neutron)!,
    ];
    return ChartIntroShellMutation(removed: removed);
  }

  /// β-：立刻 n→p。旧粒 extract 与新粒 add 在同一次调用内完成。
  /// [已确认] `betaDecay`：extract 后立刻 `addNucleonImmediatelyToAtom`
  ChartIntroShellMutation? applyBetaMinus() => _applyBeta(
        from: NucleonType.neutron,
        to: NucleonType.proton,
      );

  /// β+：立刻 p→n。
  ChartIntroShellMutation? applyBetaPlus() => _applyBeta(
        from: NucleonType.proton,
        to: NucleonType.neutron,
      );

  ChartIntroShellMutation? _applyBeta({
    required NucleonType from,
    required NucleonType to,
  }) {
    if (_disposed || shell.nucleonsOf(from).isEmpty) return null;
    if (to == NucleonType.proton && protonCount >= BanConstants.chartMaxProtons) {
      return null;
    }
    if (to == NucleonType.neutron &&
        neutronCount >= BanConstants.chartMaxNeutrons) {
      return null;
    }
    final removed = shell.removeLast(from);
    final added = shell.add(to);
    if (removed == null || added == null) return null;
    return ChartIntroShellMutation(removed: [removed], added: added);
  }

  /// [已确认] ChartIntroModel.reset：清壳层 + selectedChart + mini（派生故随清）
  void reset() {
    if (_disposed) return;
    shell.clear();
    selectedChart = ChartIntroChartType.partial;
  }

  /// 对标 NucleonCreatorsNode.createArrowEnabledProperty，范围改为 Chart 上限。
  /// [已确认] BANScreenView 共用生成器；ChartIntroModel 传入 CHART_MAX_*
  bool _creatorEnabled({
    required bool directionUp,
    required bool proton,
    bool both = false,
  }) {
    final p = protonCount;
    final n = neutronCount;

    final effectiveExists = _repository.doesExist(p, n);
    if (!effectiveExists && massNumber != 0) return false;

    final bool nextExists;
    if (directionUp) {
      nextExists = both
          ? _repository.doesNextNuclideExist(p, n)
          : proton
              ? _repository.doesNextIsotoneExist(p, n)
              : _repository.doesNextIsotopeExist(p, n);
    } else {
      nextExists = both
          ? (_repository.doesPreviousNuclideExist(p, n) || (n == 1 && p == 1))
          : proton
              ? (_repository.doesPreviousIsotoneExist(p, n) ||
                  (n == 0 && p == 1))
              : (_repository.doesPreviousIsotopeExist(p, n) ||
                  (n == 1 && p == 0));
    }

    final allowExtraToNonExistent = directionUp && effectiveExists;
    if (!allowExtraToNonExistent && !nextExists) return false;

    if (!directionUp) {
      if ((proton || both) && protonCount == 0) return false;
      if ((!proton || both) && neutronCount == 0) return false;
    }

    if (directionUp) {
      if ((proton || both) && p >= BanConstants.chartMaxProtons) return false;
      if ((!proton || both) && n >= BanConstants.chartMaxNeutrons) {
        return false;
      }
    }

    return true;
  }
}
