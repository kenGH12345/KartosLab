/// Chart Intro 控制器：用户输入 → [ChartIntroState] → 通知重绘。
///
/// 壳层 fade 在 [fades]（render-only），不进业务 State。
/// 不复用 Decay 的 MovingParticle / 换色 / outgoing。
///
/// ±p/±n 的 fade **是 render 验证复用**，不是原版箭头视觉。
/// 原版箭头：[已确认] add = 0.6s fly-in；remove = 300 px/s return。
library;

import 'package:flutter/material.dart';

import '../../data/decay_type.dart';
import '../../data/nuclide_repository.dart';
import '../../model/nucleon.dart';
import '../chart_intro_visuals.dart';
import '../model/chart_intro_state.dart';
import '../model/shell_model_nucleus.dart';
import '../render/chart_focus_memory.dart';
import '../render/decay_equation_render.dart';
import '../render/shell_fade.dart';
import '../render/shell_layout.dart';
import '../render/shell_nucleus_render.dart';

class ChartIntroController extends ChangeNotifier {
  ChartIntroController({required this.repository})
      : state = ChartIntroState(repository: repository) {
    _syncFocus();
  }

  final NuclideRepository repository;
  final ChartIntroState state;
  final ShellFadeAnimator fades = ShellFadeAnimator();

  /// Focused / Zoom-in 窗记忆。不进 State，Reset 核子后不清。
  /// [已确认] 节点本地 `initialized` + `doesExist`
  final ChartFocusMemory chartFocus = ChartFocusMemory();

  int? _undoProton;
  int? _undoNeutron;

  ShellNucleusRender get shellRender =>
      ShellNucleusRender.from(state, fades: fades);

  DecayEquationRender get decayEquation =>
      DecayEquationRender.from(state, repository);

  /// [已确认] `!!currentCellModel?.decayType && !hasIncomingParticles`
  bool get canDecay =>
      decayEquation.canDecay && fades.incomingCount == 0;

  bool get canUndoDecay => _undoProton != null;

  NucleonType? _creatorDragType;
  NucleonType? get creatorDragType => _creatorDragType;

  /// Render 验证：复用 1s fade，不是原版 0.6s fly-in。
  void addProton() {
    final added = state.addProton();
    if (added != null) fades.beginIn(added.id);
    _hideUndo();
    _report(added);
  }

  /// Render 验证：复用 1s fade，不是原版 0.6s fly-in。
  void addNeutron() {
    final added = state.addNeutron();
    if (added != null) fades.beginIn(added.id);
    _hideUndo();
    _report(added);
  }

  /// 生成器球按下：进入拖拽，计数仍等松手入座。
  /// 箭头在拖拽中禁用。[已确认] userControlled 期间 shouldEnableCreators=false
  bool beginCreatorDrag(NucleonType type) {
    if (state.isDisposed || _creatorDragType != null) return false;
    final can = type == NucleonType.proton
        ? state.canAddProton
        : state.canAddNeutron;
    if (!can) return false;
    _creatorDragType = type;
    state.draggingFromCreator = true;
    _notify();
    return true;
  }

  /// 松手：能级矩形内才入座，否则取消。[已确认] dragEnded 捕获区
  void endCreatorDrag({required bool inShell}) {
    final type = _creatorDragType;
    _creatorDragType = null;
    state.draggingFromCreator = false;
    if (type != null && inShell) {
      if (type == NucleonType.proton) {
        addProton();
      } else {
        addNeutron();
      }
      return;
    }
    _notify();
  }

  void addPair() {
    if (state.isDisposed || !state.canAddPair) return;
    state.addPair();
    final p = state.shell.getLastInShell(NucleonType.proton);
    final n = state.shell.getLastInShell(NucleonType.neutron);
    if (p != null) fades.beginIn(p.id);
    if (n != null) fades.beginIn(n.id);
    _hideUndo();
    _notify();
  }

  void removePair() {
    if (state.isDisposed || !state.canRemovePair) return;
    final lastP = state.shell.getLastInShell(NucleonType.proton);
    final lastN = state.shell.getLastInShell(NucleonType.neutron);
    final seatP = lastP == null ? null : _seatOf(lastP);
    final seatN = lastN == null ? null : _seatOf(lastN);
    if (!state.removePair()) return;
    if (lastP != null && seatP != null) {
      fades.beginOut(id: lastP.id, type: NucleonType.proton, center: seatP);
    }
    if (lastN != null && seatN != null) {
      fades.beginOut(id: lastN.id, type: NucleonType.neutron, center: seatN);
    }
    _hideUndo();
    _notify();
  }

  /// Render 验证：复用 1s fade，不是原版 300 px/s return。
  void removeProton() {
    _removeViaArrow(NucleonType.proton, () => state.removeProton());
  }

  /// Render 验证：复用 1s fade，不是原版 300 px/s return。
  void removeNeutron() {
    _removeViaArrow(NucleonType.neutron, () => state.removeNeutron());
  }

  void _removeViaArrow(NucleonType type, bool Function() apply) {
    final last = state.shell.getLastInShell(type);
    final seat = last == null ? null : _seatOf(last);
    final removed = apply();
    if (removed && last != null && seat != null) {
      fades.beginOut(id: last.id, type: type, center: seat);
    }
    if (removed) _hideUndo();
    _report(removed);
  }

  /// 壳层 α：计数立刻 −2p−2n；4 粒同帧独立 fade out；结束后残影消失。
  /// [已确认] `emitAlphaParticle` 对 mini-atom 飞出；壳层只 fade。
  /// 本方法不实现 mini-atom 飞出 / Equation UI。
  bool emitAlpha() {
    if (state.isDisposed) return false;
    final targets = [
      ...state.shell.lastNInShell(
        NucleonType.proton,
        ChartIntroVisuals.alphaProtonCount,
      ),
      ...state.shell.lastNInShell(
        NucleonType.neutron,
        ChartIntroVisuals.alphaNeutronCount,
      ),
    ];
    if (targets.length !=
        ChartIntroVisuals.alphaProtonCount +
            ChartIntroVisuals.alphaNeutronCount) {
      return false;
    }
    // [推测] 原版同帧连续 extract，剩余核子 destination 已改但 position
    // 尚未 step。本工程座位即时重排，故在 extract 前冻结 4 个座位。
    final seats = <int, Offset>{};
    for (final n in targets) {
      final seat = _seatOf(n);
      if (seat != null) seats[n.id] = seat;
    }
    final change = state.applyAlpha();
    if (change == null) return false;
    for (final n in change.removed) {
      final seat = seats[n.id];
      if (seat != null) {
        fades.beginOut(id: n.id, type: n.type, center: seat);
      }
    }
    _notify();
    return true;
  }

  /// 壳层 β-：计数立刻 n→p；旧 fade out 与新 fade in 同时开始。
  /// [已确认] `FADE_ANINIMATION_DURATION = 1`，不是 Decay 0.5s 换色。
  bool betaMinus() => _beta(from: NucleonType.neutron, to: NucleonType.proton);

  /// 壳层 β+：计数立刻 p→n。
  bool betaPlus() => _beta(from: NucleonType.proton, to: NucleonType.neutron);

  bool _beta({required NucleonType from, required NucleonType to}) {
    if (state.isDisposed) return false;
    final old = state.shell.getLastInShell(from);
    final seat = old == null ? null : _seatOf(old);
    final change = from == NucleonType.neutron
        ? state.applyBetaMinus()
        : state.applyBetaPlus();
    if (change == null || old == null || seat == null) return false;
    // 旧出 + 新进同一调用内启动，不等待 fade out 结束。
    fades.beginOut(id: change.removed.first.id, type: from, center: seat);
    if (change.added != null) fades.beginIn(change.added!.id);
    _notify();
    return true;
  }

  /// Chart Intro 唯一 Decay 键：只打最可能衰变。
  /// [已确认] `decayButton.listener` → `decayAtom(currentCell.decayType)`
  bool decay() {
    if (state.isDisposed || !canDecay) return false;
    final type = decayEquation.decayType!;
    _undoProton = state.protonCount;
    _undoNeutron = state.neutronCount;
    final ok = switch (type) {
      NucleusDecayType.alphaDecay => emitAlpha(),
      NucleusDecayType.betaMinusDecay => betaMinus(),
      NucleusDecayType.betaPlusDecay => betaPlus(),
      NucleusDecayType.protonEmission => _emitNucleon(NucleonType.proton),
      NucleusDecayType.neutronEmission => _emitNucleon(NucleonType.neutron),
    };
    if (!ok) {
      _hideUndo();
      return false;
    }
    return true;
  }

  bool _emitNucleon(NucleonType type) {
    final last = state.shell.getLastInShell(type);
    final seat = last == null ? null : _seatOf(last);
    final removed = state.extractNucleon(type);
    if (removed == null || seat == null) return false;
    fades.beginOut(id: removed.id, type: type, center: seat);
    _notify();
    return true;
  }

  /// [已确认] `undoDecay(oldProton, oldNeutron)`
  void undoDecay() {
    if (state.isDisposed || _undoProton == null || _undoNeutron == null) {
      return;
    }
    fades.clear();
    state.restoreNucleonCounts(_undoProton!, _undoNeutron!);
    _hideUndo();
    _notify();
  }

  /// [已确认] `selectedNuclideChartProperty` 业务状态，默认 `'partial'`
  void selectChart(ChartIntroChartType type) {
    if (state.isDisposed) return;
    state.selectedChart = type;
    notifyListeners();
  }

  Offset? _seatOf(ShellNucleon nucleon) {
    final list = state.shell.nucleonsOf(nucleon.type);
    final index = list.indexWhere((n) => n.id == nucleon.id);
    if (index < 0) return null;
    final local = ShellLayout.nucleonCenter(
      index: index,
      xPosition: nucleon.xPosition,
      yPosition: nucleon.yPosition,
      bound: nucleon.bound,
    );
    final xOffset = nucleon.type == NucleonType.neutron
        ? ChartIntroVisuals.energyLevelColumnGap
        : 0.0;
    return Offset(local.dx + xOffset, local.dy);
  }

  void reset() {
    if (state.isDisposed) return;
    fades.clear();
    state.reset();
    _hideUndo();
    _syncFocus();
    notifyListeners();
  }

  /// 推进壳层 fade。原版 twixt 由 sim 全局步进；
  /// [已确认] `particleAnimations` 用于 Reset 取消，不是 ChartIntroModel.step 内容。
  bool tick(double dt) {
    if (state.isDisposed) return false;
    var dirty = false;
    if (fades.hasActive) {
      fades.step(dt);
      dirty = true;
    }
    if (state.stepInvalidNuclideRollback(dt)) {
      fades.clear();
      dirty = true;
    }
    if (dirty) _notify();
    return fades.hasActive || state.isShowingInvalidNuclide;
  }

  @override
  void dispose() {
    fades.clear();
    state.dispose();
    super.dispose();
  }

  void _hideUndo() {
    _undoProton = null;
    _undoNeutron = null;
  }

  void _syncFocus() {
    chartFocus.sync(
      protonCount: state.protonCount,
      neutronCount: state.neutronCount,
      exists: state.nuclideExists,
    );
  }

  void _notify() {
    if (state.isDisposed) return;
    _syncFocus();
    if (state.nuclideExists || state.isEmptyNucleus) {
      state.markCurrentAsValid();
    }
    notifyListeners();
  }

  T _report<T>(T result) {
    _notify();
    return result;
  }
}
