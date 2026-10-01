/// Build a Nucleus · Decay 屏的模型/状态。
///
/// 职责：当前模拟世界（核内核子、衰变产物、undo 快照、无效核素回退）
/// 及其状态转换。核素「是什么」的查询全部委托给 [NuclideRepository]，
/// 不在本类重复存储数据表事实。
///
/// 对标原项目：
/// - `BANModel`（粒子数组、存在性/稳定性派生、reset）
/// - `DecayModel`（halfLifeNumberProperty、decayEnabledPropertyMap）
/// - `BANScreenView` 中的状态机部分（invalid 回退计时、undoDecay、dragEnded 判定）
/// - `NucleonCreatorsNode` 中的箭头按钮 enable 规则
///
/// 本阶段（1B）只含状态与状态转换，不含动画与 UI。与原项目的差异：
/// - 原项目粒子从生成器动画飞入核后才计入计数；本阶段添加/移除立即生效，
///   incoming/userControlled 数组留待拖拽阶段引入。[推测：对最终计数无影响]
library;

import 'dart:math';

import '../ban_constants.dart';
import '../data/decay_type.dart';
import '../data/nuclide_repository.dart';
import 'nucleon.dart';
import 'nucleus_layout.dart';

class BuildANucleusState {
  BuildANucleusState({required NuclideRepository repository})
      : _repository = repository;

  final NuclideRepository _repository;

  /// 核内质子 / 中子。对标 ParticleAtom.protons / neutrons。
  final List<Nucleon> _protons = [];
  final List<Nucleon> _neutrons = [];

  /// 衰变发射产物记录。对标 outgoingParticles（语义见 EmittedParticleType）。
  final List<EmittedParticle> _outgoingParticles = [];

  /// 拖拽中（用户控制）的核子：不计入核内计数，但计入生成器规则的
  /// 「有效计数」。对标 userControlledProtons / userControlledNeutrons
  /// （合并为一个列表，类型由 Nucleon.type 分辨）。
  final List<Nucleon> _draggedNucleons = [];

  /// 归位动画中的核子（松手在捕获区外 → 匀速飞回生成器，到达后移除）。
  /// 对标 animateAndRemoveParticle 的飞行阶段 + 到达后 dispose。
  final List<Nucleon> _returningNucleons = [];

  /// 飞行中的核子（箭头按钮路径：生成器 → 核中心，**到达后才入核计数**）。
  /// 对标 incomingProtons / incomingNeutrons。
  /// [已确认] BANScreenView.createParticleFromStack：animationEndedEmitter
  /// 到达回调中才 particleAtom.addParticle。
  final List<Nucleon> _incomingProtons = [];
  final List<Nucleon> _incomingNeutrons = [];

  /// 无效核素回退：上一个存在（或 0p0n 空核）的核子计数。
  /// 对标 BANScreenView.previousProtonNumber / previousNeutronNumber。
  int _previousValidProtonCount = 0;
  int _previousValidNeutronCount = 0;

  /// 无效核素已展示时长（秒）。对标 BANScreenView.timeSinceCountdownStarted。
  double _invalidNuclideElapsed = 0;

  /// 是否纠正不存在的核素。对标 BANScreenView.correctingNonexistentNuclide。
  /// [已确认] 仅在 Be-6 α Hollywood 特例窗口内置 false（避免 1s 自动回退
  /// 把 2p0n 拉回 Be-6，好让剩余 2 质子被强制射出）。
  bool correctingNonexistentNuclide = true;

  /// 最近一次衰变事件（含衰变前计数快照，undo 依赖）。
  /// 对标 DecayScreenView.oldProtonNumber / oldNeutronNumber + 衰变按钮上下文。
  DecayEvent? lastDecay;

  // --- Be-6 α 特例（[已确认] DecayScreenView.emitAlphaParticle 特例分支）---
  // α 衰变后剩余 (2p, 0n)（不存在核素）：挂起自动回退，展示 "does not form"，
  // α 飞满 1s×300px/s 的距离后强制发射剩余 2 个质子，最终到 (0,0) 空核。

  /// 特例窗口中飞行中的 α 粒子（null = 非特例窗口）。
  EmittedParticle? _specialAlpha;

  /// 待发射的 2 个质子的逃逸点（点击时预计算；原版在发射时随机，时机差异不可观察）。
  List<(double, double)> _specialProtonEscapes = const [];

  /// 特例的 2 个质子是否已发射。
  bool _specialProtonsEmitted = false;

  /// 是否处于 Be-6 特例窗口（剩余 2 质子锁定不可拖）。
  /// 窗口从 α 后剩 (2p,0n) 开始，到该 α 被移除（到达或 undo/reset）结束。
  bool get inSpecialAlphaWindow => _specialAlpha != null;

  /// 特例窗口内是否已强制射出剩余 2 质子。
  bool get hasEmittedSpecialProtons => _specialProtonsEmitted;

  int _nextNucleonId = 1;

  // ---------------------------------------------------------------------------
  // 只读视图与派生量
  // ---------------------------------------------------------------------------

  List<Nucleon> get protons => List.unmodifiable(_protons);
  List<Nucleon> get neutrons => List.unmodifiable(_neutrons);
  List<EmittedParticle> get outgoingParticles =>
      List.unmodifiable(_outgoingParticles);
  List<Nucleon> get draggedNucleons => List.unmodifiable(_draggedNucleons);
  List<Nucleon> get returningNucleons => List.unmodifiable(_returningNucleons);

  /// 飞行中的核子（渲染用）。[已确认] 飞行粒子在原版可见
  List<Nucleon> get incomingNucleons =>
      List.unmodifiable([..._incomingProtons, ..._incomingNeutrons]);

  /// 是否有飞行中的核子。[已确认] BANModel.hasIncomingParticlesProperty
  /// （DecayModel 据此禁用衰变按钮）
  bool get hasIncomingParticles =>
      _incomingProtons.isNotEmpty || _incomingNeutrons.isNotEmpty;

  /// 有效质子/中子数 = 核内 + 飞行中 + 拖拽中。
  /// [已确认] NucleonCreatorsNode：protonNumber = atom + incoming + userControlled
  int get _effectiveProtonCount =>
      protonCount +
      _incomingProtons.length +
      _draggedNucleons.where((n) => n.type == NucleonType.proton).length;
  int get _effectiveNeutronCount =>
      neutronCount +
      _incomingNeutrons.length +
      _draggedNucleons.where((n) => n.type == NucleonType.neutron).length;

  int get protonCount => _protons.length;
  int get neutronCount => _neutrons.length;

  /// 质量数 A = Z + N。[已确认] ParticleAtom.massNumberProperty
  int get massNumber => protonCount + neutronCount;

  /// 0p0n 空核：数据层判定为「不存在」，但原项目视图层将其视为可接受基态。
  /// [已确认] BANScreenView.step 的 p0n0Case
  bool get isEmptyNucleus => protonCount == 0 && neutronCount == 0;

  bool get isStable => _repository.isStable(protonCount, neutronCount);
  bool get nuclideExists => _repository.doesExist(protonCount, neutronCount);

  /// 是否正处于「X does not form」展示态。[已确认] ElementNameText 的显示条件
  bool get isShowingInvalidNuclide => !nuclideExists && !isEmptyNucleus;

  /// 半衰期读数（秒）。对标 DecayModel.halfLifeNumberProperty：
  /// 不存在 → 0；稳定 → 1e24（数轴最大值）；存在但未知 → -1；否则查表值。
  double get halfLifeNumber {
    if (!nuclideExists) return BanConstants.nonexistentHalfLife;
    if (isStable) return BanConstants.stableHalfLifeDisplay;
    final info = _repository.halfLife(protonCount, neutronCount);
    return info.seconds ?? BanConstants.unknownHalfLife;
  }

  List<DecayBranch> get availableDecays =>
      _repository.availableDecays(protonCount, neutronCount);

  /// 衰变按钮是否可用。对标 DecayModel.decayEnabledPropertyMap：
  /// `!hasIncomingParticles && decays.contains(type)`。
  bool isDecayEnabled(NucleusDecayType type) =>
      !hasIncomingParticles && availableDecays.any((b) => b.type == type);

  String get elementSymbol => _repository.elementSymbol(protonCount);
  String get elementName => _repository.elementName(protonCount);

  /// 电子云查表半径（实验原子半径，单位与表一致）。
  /// 索引 = 质子数：原版假定核素电中性，电子数 = 质子数。
  /// [已确认] `ParticleAtomNode.updateCloudSize` 注释 +
  /// `AtomInfoUtils.getAtomicRadius(numElectrons)` = `mapElectronCountToRadius[n]`
  ///
  /// 0 质子时表无条目，返回 null；云是否绘制由 [ElectronCloudReading] 判定，
  /// 本 getter 不改业务状态。
  double? get electronCloudAtomicRadius =>
      _repository.electronCloudRadius(protonCount);

  bool get canUndoDecay => lastDecay != null;

  // ---------------------------------------------------------------------------
  // 核子增减（箭头按钮语义）
  // ---------------------------------------------------------------------------

  /// 添加一个质子：在 (fromX, fromY)（生成器中心，世界坐标）创建并
  /// 以 300 px/s 飞向核中心，**到达后才入核计数**。
  /// [已确认] createParticleFromStack + animationEndedEmitter 到达回调。
  /// 返回 null 表示当前规则禁止。
  Nucleon? addProton({double fromX = 0, double fromY = 0}) =>
      canAddProton ? _launchIncoming(NucleonType.proton, fromX, fromY) : null;

  /// 添加一个中子（同上）。
  Nucleon? addNeutron({double fromX = 0, double fromY = 0}) =>
      canAddNeutron ? _launchIncoming(NucleonType.neutron, fromX, fromY) : null;

  /// 移除一个质子（返回生成器）。返回 false 表示当前规则禁止。
  /// 下箭头在核内该类型为 0 时禁用（含飞行中不算），
  /// [已确认] issue#74 注释的 down 分支 → 飞行中不会被选中移除。
  bool removeProton() => canRemoveProton && _removeNucleon(NucleonType.proton);

  /// 移除一个中子（返回生成器）。返回 false 表示当前规则禁止。
  bool removeNeutron() => canRemoveNeutron && _removeNucleon(NucleonType.neutron);

  /// 双箭头：同时添加一对 p+n（各自从对应生成器飞入）。
  /// [已确认] DoubleArrowButton → 两次 createParticleFromStack
  bool addPair({
    double protonFromX = 0,
    double protonFromY = 0,
    double neutronFromX = 0,
    double neutronFromY = 0,
  }) {
    if (!canAddPair) return false;
    addProton(fromX: protonFromX, fromY: protonFromY);
    addNeutron(fromX: neutronFromX, fromY: neutronFromY);
    return true;
  }

  /// 创建飞行核子：生成器位置出发，目的地核中心。
  /// [已确认] getParticleDestination = 原子中心（Decay 屏）；
  /// 飞入为固定 0.6s（BANParticle.setAnimationDestination consistentTime: true
  /// → speed = 距离 / 0.6s）。
  Nucleon _launchIncoming(NucleonType type, double fromX, double fromY) {
    final nucleon = Nucleon(id: _nextNucleonId++, type: type, x: fromX, y: fromY);
    nucleon.setDestination(0, 0);
    nucleon.speed =
        sqrt(fromX * fromX + fromY * fromY) / BanConstants.flyInAnimationTime;
    (type == NucleonType.proton ? _incomingProtons : _incomingNeutrons)
        .add(nucleon);
    _onNucleusChanged();
    return nucleon;
  }

  /// 到达处理：飞行核子入核（此刻才计数）并触发重排（归位到卡位）。
  /// [已确认] animationEndedEmitter → clearIncomingParticle + addParticle
  void _processArrivals() {
    for (final incoming in [_incomingProtons, _incomingNeutrons]) {
      for (final n in incoming.toList()) {
        if (!n.isAnimating) {
          incoming.remove(n);
          (n.type == NucleonType.proton ? _protons : _neutrons).add(n);
          _onNucleusChanged(); // 质量数变化 → 重排（卡位 destination）
        }
      }
    }
  }

  /// 测试/免动画辅助：全部飞行核子立即到核中心并入核，全部核子立即到卡位。
  /// 对标 populateAtom 的 moveAllToDestination 用法。
  void settleAll() {
    for (final n in [..._incomingProtons, ..._incomingNeutrons]) {
      n.setPositionImmediate(n.destX, n.destY);
    }
    _processArrivals();
    moveAllNucleonsToDestination();
  }

  /// 双箭头：同时移除一对 p+n。
  bool removePair() {
    if (!canRemovePair) return false;
    removeProton();
    removeNeutron();
    return true;
  }

  // -- enable 规则：逐条对标 NucleonCreatorsNode.createArrowEnabledProperty --
  // 本阶段 incoming/userControlled 恒为 0，protonNumber/neutronNumber 即核内计数。

  bool get canAddProton => _creatorEnabled(directionUp: true, proton: true);
  bool get canRemoveProton => _creatorEnabled(directionUp: false, proton: true);
  bool get canAddNeutron => _creatorEnabled(directionUp: true, proton: false);
  bool get canRemoveNeutron => _creatorEnabled(directionUp: false, proton: false);
  bool get canAddPair => _creatorEnabled(directionUp: true, proton: true, both: true);
  bool get canRemovePair =>
      _creatorEnabled(directionUp: false, proton: true, both: true);

  bool _creatorEnabled({
    required bool directionUp,
    required bool proton,
    bool both = false,
  }) {
    // 存在性/邻位/范围判定用有效计数（含拖拽中）；核内计数仅用于下箭头零检查。
    // [已确认] NucleonCreatorsNode.createArrowEnabledProperty 的依赖与计算
    final p = _effectiveProtonCount;
    final n = _effectiveNeutronCount;

    // shouldEnableCreators：有效核素不存在且（核非空或有拖拽中粒子）时全部禁用。
    // [已确认] NucleonCreatorsNode.shouldEnableCreators
    final effectiveExists = _repository.doesExist(p, n);
    if (!effectiveExists && (massNumber != 0 || _draggedNucleons.isNotEmpty)) {
      return false;
    }

    // 目标方向上的「下一个核素」是否存在。[已确认] hasNextNuclide 各分支
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
              ? (_repository.doesPreviousIsotoneExist(p, n) || (n == 0 && p == 1))
              : (_repository.doesPreviousIsotopeExist(p, n) || (n == 1 && p == 0));
    }

    // 上箭头允许从「存在」的核素越界 1 个进入不存在态（教学目的）。
    // [已确认] allowExtraToNonExistent
    final allowExtraToNonExistent = directionUp && effectiveExists;
    if (!allowExtraToNonExistent && !nextExists) return false;

    // 下箭头：核内该类型计数为 0 时禁用（用核内计数，不含拖拽中）。
    // [已确认] direction === 'down' 且 atomProtonNumber/atomNeutronNumber === 0 分支
    if (!directionUp) {
      if ((proton || both) && protonCount == 0) return false;
      if ((!proton || both) && neutronCount == 0) return false;
    }

    // 范围边界（有效计数）。[已确认] isNucleonNumberNotAtRangeBounds
    if (directionUp) {
      if ((proton || both) && p >= BanConstants.decayMaxProtons) return false;
      if ((!proton || both) && n >= BanConstants.decayMaxNeutrons) return false;
    }

    return true;
  }

  Nucleon _addNucleon(NucleonType type) {
    final nucleon = Nucleon(id: _nextNucleonId++, type: type);
    (type == NucleonType.proton ? _protons : _neutrons).add(nucleon);
    _onNucleusChanged();
    return nucleon;
  }

  /// 创建一个**不入核**的自由核子（id 由状态统一分配）。
  ///
  /// 对标 createParticleFromStack 创建后、到达核之前的粒子形态；
  /// 供拖拽链路使用（配合 [endNucleonDrop] 判定落点）。本阶段无飞入动画。
  Nucleon createFreeNucleon(NucleonType type, {double x = 0, double y = 0}) {
    return Nucleon(id: _nextNucleonId++, type: type, x: x, y: y);
  }

  /// 移除该类型中离核中心最远的核子。
  ///
  /// [推测] 原项目 returnParticleToStack 选取「离生成器节点最近」的核子，
  /// 生成器在核下方，视觉上等价于取最外围核子；生成器坐标属视图层，
  /// 状态层用「离中心最远」近似。核子同类型不可区分，对计数无影响。
  bool _removeNucleon(NucleonType type) {
    final list = type == NucleonType.proton ? _protons : _neutrons;
    if (list.isEmpty) return false;
    var farthest = list.first;
    for (final nucleon in list) {
      if (nucleon.distanceSquaredToCenter >= farthest.distanceSquaredToCenter) {
        farthest = nucleon;
      }
    }
    list.remove(farthest);
    _onNucleusChanged();
    return true;
  }

  // ---------------------------------------------------------------------------
  // 核子进出核（拖拽松手语义）
  // ---------------------------------------------------------------------------

  /// 捕获区判定：核子位置距核中心（原点）小于捕获半径。
  /// [已确认] DecayScreenView.isNucleonInCaptureArea（半径 100 CSS px）
  bool isWithinCaptureArea(Nucleon nucleon) =>
      sqrt(nucleon.distanceSquaredToCenter) < BanConstants.nucleonCaptureRadius;

  /// 开始拖拽核内某核子：从核中取出（不计入计数），返回该核子。
  /// [已确认] BANModel userControlledListener：isDragging 时从 particleAtom 移除
  Nucleon? beginNucleonDrag(Nucleon nucleon) {
    // [已确认] changeNucleonType：换色动画期间 inputEnabled=false（不可拖），
    // 见 build-a-nucleus issue#115
    if (nucleon.isColorAnimating) return null;
    // [已确认] Be-6 特例窗口：剩余 2 质子 inputEnabled=false（锁定不可拖）
    if (inSpecialAlphaWindow) return null;
    final list = nucleon.type == NucleonType.proton ? _protons : _neutrons;
    if (!list.remove(nucleon)) return null;
    // [已确认] ParticleView dragListener.start：拖拽开始取消进行中动画
    nucleon.setPositionImmediate(nucleon.x, nucleon.y);
    // [已确认] BANModel userControlledListener：拖拽中的粒子 zLayer 置 0（最前）
    nucleon.zLayer = NucleusLayout.draggedLayer;
    _draggedNucleons.add(nucleon);
    _onNucleusChanged();
    return nucleon;
  }

  /// 开始拖拽一个自由核子（生成器拖出路径：创建后立即可拖）。
  /// [已确认] NucleonCreatorNode → addAndDragParticle → startSyntheticDrag
  void beginFreeDrag(Nucleon nucleon) {
    nucleon.setPositionImmediate(nucleon.x, nucleon.y);
    nucleon.zLayer = NucleusLayout.draggedLayer;
    _draggedNucleons.add(nucleon);
    _onNucleusChanged();
  }

  /// 拖拽松手判定。对标 BANScreenView.dragEndedListener +
  /// animateAndRemoveParticle：
  /// 在捕获区内 → 入核（reconfigure 设定 destination，核子从落点动画归位）；
  /// 在捕获区外 → 匀速飞回 (returnX, returnY)（生成器位置，视图层换算），
  /// 到达后从世界移除；未提供归位坐标时立即移除（测试便捷路径）。
  /// 若移除该核子会导致核素不存在，则强制收回核内。
  /// 返回 true 表示核子最终留在核内。
  bool endNucleonDrop(Nucleon nucleon, {double? returnX, double? returnY}) {
    // Reset 会直接清空 _draggedNucleons（对标 particles.clear + userControlled.clear）。
    // 松手若仍走入核/归位，会把已销毁粒子加回世界。[已确认] 原版 dispose 后
    // DragListener 已拆除，松手不再入核。此处对非拖拽中核子直接忽略。
    if (!_draggedNucleons.remove(nucleon)) return false;
    // 注意：原项目判定时核子已被取出，doesExist 用的是取出后的计数。
    final removalCreatesNonExistent = massNumber != 0 && !nuclideExists;
    if (isWithinCaptureArea(nucleon) || removalCreatesNonExistent) {
      (nucleon.type == NucleonType.proton ? _protons : _neutrons).add(nucleon);
      _onNucleusChanged();
      return true;
    }
    if (returnX != null && returnY != null) {
      nucleon.setDestination(returnX, returnY);
      // [已确认] animateAndRemoveParticle 默认 consistentTime: false → 300 px/s
      nucleon.speed = BanConstants.particleAnimationSpeed;
      _returningNucleons.add(nucleon);
    }
    _onNucleusChanged();
    return false;
  }

  /// 每帧运动推进（对标 BANModel.step → Particle.step）：
  /// 核内核子向排布 destination 归位；归位中的核子飞回生成器，到达即移除。
  /// 返回 true 表示本帧有运动（需要重绘）。
  bool stepMotion(double dt) {
    var moved = false;
    // 飞行中核子：向核中心推进（各自 speed），到达者入核（此刻才计数）。
    for (final n in [..._incomingProtons, ..._incomingNeutrons]) {
      n.stepMotion(dt);
      moved = true;
    }
    _processArrivals();
    for (final n in [..._protons, ..._neutrons]) {
      if (n.isAnimating) {
        n.stepMotion(dt);
        moved = true;
      }
      // β 换色动画推进（0.5s 线性）。[已确认] changeNucleonType 的
      // colorChangeAnimation；完成后恢复可拖（原版恢复 inputEnabled）
      if (n.isColorAnimating) {
        n.colorProgress =
            (n.colorProgress + dt / BanConstants.betaColorAnimationTime)
                .clamp(0.0, 1.0);
        if (n.colorProgress >= 1.0) {
          n.colorAnimatingFrom = null;
          n.colorAnimationRunning = false;
        }
        moved = true;
      }
    }
    for (final n in _returningNucleons.toList()) {
      if (n.stepMotion(dt)) {
        // [已确认] 到达生成器后销毁（animateAndRemoveParticle 的完成回调）
        _returningNucleons.remove(n);
      }
      moved = true;
    }
    // 衰变发射粒子：先过滞留期（β 等换色完成），再飞向屏外，到达后移除。
    // [已确认] β 的发射动画在换色完成回调中启动
    for (final p in _outgoingParticles.toList()) {
      if (p.holdTime > 0) {
        p.holdTime = (p.holdTime - dt).clamp(0.0, double.infinity);
        moved = true;
        continue;
      }
      p.stepMotion(dt);
      moved = true;
      // Be-6 特例 [已确认]：α 飞满 TIME_TO_SHOW_DOES_NOT_EXIST × 300px 后
      // 强制发射剩余 2 个质子（positionProperty.link 距离判定）
      if (identical(p, _specialAlpha) &&
          !_specialProtonsEmitted &&
          p.distanceTraveled >=
              BanConstants.timeToShowDoesNotExist *
                  BanConstants.particleAnimationSpeed) {
        _emitSpecialProtons();
      }
      if (!p.isAnimating) {
        _outgoingParticles.remove(p);
        // 特例 α 到达/移除 → 恢复无效核素自动回退
        // [已确认] alphaParticle.disposeEmitter → correctingNonexistentNuclide = true
        if (identical(p, _specialAlpha)) _closeSpecialAlphaWindow();
      }
    }
    return moved;
  }

  /// 清空发射产物；若特例 α 仍在其中则关闭特例窗口并恢复自动回退。
  /// [已确认] undoDecay 清空 outgoingParticles；α disposeEmitter 恢复
  /// correctingNonexistentNuclide
  void _clearOutgoing() {
    if (_specialAlpha != null && _outgoingParticles.contains(_specialAlpha)) {
      _closeSpecialAlphaWindow();
    }
    _outgoingParticles.clear();
  }

  /// Be-6 Hollywood 特例：强制发射剩余 2 个质子。
  /// [已确认] DecayScreenView.emitAlphaParticle：`_.times(2, () => emitNucleon(PROTON))`
  /// 各飞独立随机屏外点；起点 = 被取质子当时的核内位置（非核中心）。
  void _emitSpecialProtons() {
    _specialProtonsEmitted = true;
    for (var i = 0; i < 2; i++) {
      final n = _extractClosestToCenter(NucleonType.proton);
      if (n == null) break;
      final escape = i < _specialProtonEscapes.length
          ? _specialProtonEscapes[i]
          : (0.0, 10000.0);
      _emit(EmittedParticleType.proton, n.x, n.y, escape.$1, escape.$2);
    }
    // 2p0n → 0p0n：质量数变化隐藏 undo。
    // [已确认] hideUndoButtonEmitter 由 massNumberProperty 变化触发
    _onNucleusChanged(clearUndo: true);
  }

  void _closeSpecialAlphaWindow() {
    _specialAlpha = null;
    _specialProtonEscapes = const [];
    _specialProtonsEmitted = false;
    correctingNonexistentNuclide = true;
  }

  /// 全部核内核子立即到位（对标 ParticleAtom.moveAllToDestination，
  /// 用于测试与免动画场景）。归位中的核子不受影响。
  void moveAllNucleonsToDestination() {
    for (final n in [..._protons, ..._neutrons]) {
      n.setPositionImmediate(n.destX, n.destY);
    }
  }

  // ---------------------------------------------------------------------------
  // 衰变
  // ---------------------------------------------------------------------------

  /// 触发衰变。对标 BANScreenView.decayAtom + emitNucleon / emitAlphaParticle /
  /// betaDecay。
  ///
  /// 时序 [已确认]：点击即改变核素计数（extract/changeNucleonType 同步发生），
  /// 发射粒子在核内对应位置创建并以 300 px/s 飞向 (escapeX, escapeY)
  /// （原版为屏外随机点，由 Controller 计算注入；state 保持确定性）。
  /// 前提：核素存在且该衰变类型当前可用。不可用时返回 false，状态不变。
  bool applyDecay(NucleusDecayType type,
      {double escapeX = 0,
      double escapeY = 10000,
      List<(double, double)> extraEscapes = const []}) {
    if (!nuclideExists || !isDecayEnabled(type)) return false;

    // 衰变前快照（undo 依赖）。[已确认] handleDecayListener 保存旧计数
    final parentP = protonCount;
    final parentN = neutronCount;

    switch (type) {
      case NucleusDecayType.neutronEmission:
        // [已确认] emitNucleon：取出核子，从其位置发射
        final n = _extractClosestToCenter(NucleonType.neutron);
        _emit(EmittedParticleType.neutron, n!.x, n.y, escapeX, escapeY);
      case NucleusDecayType.protonEmission:
        final n = _extractClosestToCenter(NucleonType.proton);
        _emit(EmittedParticleType.proton, n!.x, n.y, escapeX, escapeY);
      case NucleusDecayType.alphaDecay:
        // [已确认] emitAlphaParticle：取离中心最近 2p+2n 组成 α（核中心组装），
        // 恒速 300 px/s 直线飞出。原项目 assert 要求 p>=2 && n>=2。
        if (protonCount < 2 || neutronCount < 2) return false;
        _extractClosestToCenter(NucleonType.proton);
        _extractClosestToCenter(NucleonType.proton);
        _extractClosestToCenter(NucleonType.neutron);
        _extractClosestToCenter(NucleonType.neutron);
        final alpha = _emit(EmittedParticleType.alpha, 0, 0, escapeX, escapeY);

        // Be-6 Hollywood 特例 —— 不是另一种衰变，是普通 α **之后**的附加分支。
        // 触发条件 [已确认] 不是 `if (Be-6)`，而是 α 取出 2p2n 后剩余恰好 (2p, 0n)。
        // 在 ENSDF 表内唯有 Be-6(4p,2n) 满足。后续强制射出 2 质子、挂起 1s 回退。
        if (protonCount == 2 && neutronCount == 0) {
          correctingNonexistentNuclide = false;
          _specialAlpha = alpha;
          _specialProtonEscapes = extraEscapes;
          _specialProtonsEmitted = false;
        }
      case NucleusDecayType.betaMinusDecay:
        // [已确认] betaDecay：离中心最近的中子变质子（计数点击即变），
        // 电子从该核子位置、其后一层（zLayer+1）发射，且在 0.5s 换色动画
        // 完成后才起飞（onChangeComplete 回调）
        final changed = _changeNucleonType(NucleonType.neutron);
        if (changed == null) return false;
        _emit(EmittedParticleType.electron, changed.x, changed.y, escapeX,
            escapeY,
            zLayer: changed.zLayer + 1,
            holdTime: BanConstants.betaColorAnimationTime);
      case NucleusDecayType.betaPlusDecay:
        final changed = _changeNucleonType(NucleonType.proton);
        if (changed == null) return false;
        _emit(EmittedParticleType.positron, changed.x, changed.y, escapeX,
            escapeY,
            zLayer: changed.zLayer + 1,
            holdTime: BanConstants.betaColorAnimationTime);
    }

    lastDecay = DecayEvent(
      type: type,
      parentProtons: parentP,
      parentNeutrons: parentN,
      daughterProtons: protonCount,
      daughterNeutrons: neutronCount,
    );
    _onNucleusChanged(clearUndo: false);
    return true;
  }

  /// 创建发射粒子：位置、300 px/s、逃逸目的地。[已确认] animateAndRemoveParticle
  EmittedParticle _emit(EmittedParticleType type, double x, double y,
      double escapeX, double escapeY, {int zLayer = 0, double holdTime = 0}) {
    final p = EmittedParticle(type, x: x, y: y)
      ..zLayer = zLayer
      ..holdTime = holdTime;
    p.setDestination(escapeX, escapeY);
    _outgoingParticles.add(p);
    return p;
  }

  /// 撤销上一次衰变：恢复衰变前核子计数，清空发射产物与换色动画。
  ///
  /// [已确认] BANScreenView.undoDecay 只做这几件事，**不是** Reset 的子集：
  /// - restorePreviousNucleonNumber（立即补/退核子）
  /// - 从 particles 移除 outgoing 并 clear
  /// - particleAnimations.clear()（停飞出动画）
  /// - particleAtom.clearAnimations()（停换色，颜色定格）
  ///
  /// 明确**不**做：不清 incoming / userControlled / returning、
  /// 不重置 invalid 计时、不重置 previousValid、不 populate 空核。
  /// incoming/userControlled 变化会经 hideUndoButtonEmitter 先藏按钮，
  /// 故正常 UI 路径下不会在飞入/拖拽中点到 undo；若仍点到（衰变时已在拖），
  /// 拖拽中粒子保留在 userControlled。[已确认] 与 massNumber multilink 分离。
  bool undoDecay() {
    final decay = lastDecay;
    if (decay == null) return false;

    _restoreCount(NucleonType.proton, decay.parentProtons);
    _restoreCount(NucleonType.neutron, decay.parentNeutrons);
    _clearOutgoing();
    // [已确认] 原版 undoDecay 调 clearAnimations：进行中的换色动画停止、
    // 颜色定格在中间值（冻结）。本实现冻结 = 停止推进、保留混合上下文。
    for (final n in [..._protons, ..._neutrons]) {
      n.colorAnimationRunning = false;
    }
    lastDecay = null;
    _onNucleusChanged(clearUndo: false);
    return true;
  }

  void _restoreCount(NucleonType type, int target) {
    while ((type == NucleonType.proton ? protonCount : neutronCount) > target) {
      _removeNucleon(type);
    }
    while ((type == NucleonType.proton ? protonCount : neutronCount) < target) {
      _addNucleon(type);
    }
  }

  /// 取出该类型中离核中心最近的核子。
  /// [已确认] extractParticleClosestToCenter（α 与 β 衰变均取离中心最近者）
  Nucleon? _extractClosestToCenter(NucleonType type) {
    final list = type == NucleonType.proton ? _protons : _neutrons;
    if (list.isEmpty) return null;
    var closest = list.first;
    for (final nucleon in list) {
      if (nucleon.distanceSquaredToCenter < closest.distanceSquaredToCenter) {
        closest = nucleon;
      }
    }
    list.remove(closest);
    return closest;
  }

  /// β 衰变：该类型中离中心最近的核子转换类型（位置保留，计数点击即变），
  /// 并开始 0.5s 换色动画。[已确认] ParticleAtom.changeNucleonType。
  /// 返回换型核子（发射粒子定位用）。
  Nucleon? _changeNucleonType(NucleonType from) {
    final nucleon = _extractClosestToCenter(from);
    if (nucleon == null) return null;
    nucleon.type =
        from == NucleonType.proton ? NucleonType.neutron : NucleonType.proton;
    (nucleon.type == NucleonType.proton ? _protons : _neutrons).add(nucleon);
    // [已确认] changeNucleonType：0.5s 线性换色（起始色=旧类型色）
    nucleon.colorAnimatingFrom = from;
    nucleon.colorProgress = 0;
    nucleon.colorAnimationRunning = true;
    return nucleon;
  }

  // ---------------------------------------------------------------------------
  // 无效核素回退（状态层；1 秒计时以 dt 驱动，UI 计时器属后续阶段）
  // ---------------------------------------------------------------------------

  /// 无效核素纠正推进。对标 BANScreenView.step 中的纠正逻辑：
  /// - 核素不存在且非 0p0n 且允许纠正 → 累计展示时长
  /// - 否则清零计时并把当前计数记为「上一个有效核素」
  /// - 累计达到 [BanConstants.timeToShowDoesNotExist]（1 秒）→ 回退
  ///
  /// 原项目附加条件「无用户拖拽中粒子」本阶段恒成立（userControlled = 0）。
  /// 返回 true 表示本次调用触发了回退。
  bool stepInvalidNuclideRollback(double dt) {
    if (!nuclideExists && !isEmptyNucleus && correctingNonexistentNuclide) {
      _invalidNuclideElapsed += dt;
    } else {
      _invalidNuclideElapsed = 0;
      _previousValidProtonCount = protonCount;
      _previousValidNeutronCount = neutronCount;
    }

    // 原项目附加条件：无用户拖拽中粒子才触发回退。
    // [已确认] BANScreenView.step 388-389 行
    if (_invalidNuclideElapsed >= BanConstants.timeToShowDoesNotExist &&
        _draggedNucleons.isEmpty) {
      _invalidNuclideElapsed = 0;
      _rollbackToPreviousValid();
      return true;
    }
    return false;
  }

  /// 回退到上一个有效核素：补/退核子直到计数恢复。
  /// [已确认] BANScreenView.step 396-415 的 createParticleFromStack /
  /// returnParticleToStack 组合（本阶段立即生效，无飞行动画）。
  void _rollbackToPreviousValid() {
    _restoreCount(NucleonType.proton, _previousValidProtonCount);
    _restoreCount(NucleonType.neutron, _previousValidNeutronCount);
  }

  /// 无效核素已展示的时长（秒），供后续 UI 显示/调试。
  double get invalidNuclideElapsed => _invalidNuclideElapsed;

  // ---------------------------------------------------------------------------
  // Reset
  // ---------------------------------------------------------------------------

  /// 重置到初始状态（0p0n 空核）。
  ///
  /// [已确认] 顺序对齐 BANModel.reset + BANScreenView.reset +
  /// DecayScreenView.reset（populateDefaultAtom 默认 0,0 放最后）：
  /// 1. 丢弃全部动画与粒子数组（particleAnimations → atom.clear →
  ///    particles / incoming / outgoing / userControlled）
  /// 2. previousValid=0、invalid 计时=0、correctingNonexistentNuclide=true
  /// 3. 空核即默认 populate(0,0)
  ///
  /// 与 undo 不同：Reset **销毁**粒子（含换色中核子），不定格颜色；
  /// 拖拽中 / 飞入 / 归位 / outgoing / Be-6 窗口全部丢掉。
  void reset() {
    _protons.clear();
    _neutrons.clear();
    // [已确认] BANModel.reset 同样清空 userControlled（拖拽中）与
    // incoming（飞行中）粒子；归位中粒子随之移除
    _draggedNucleons.clear();
    _returningNucleons.clear();
    _incomingProtons.clear();
    _incomingNeutrons.clear();
    // 特例窗口必须无条件关闭：若先 clear outgoing 再 _clearOutgoing，
    // α 已不在列表里，窗口会泄漏（inSpecialAlphaWindow 仍为 true）。
    _closeSpecialAlphaWindow();
    _outgoingParticles.clear();
    lastDecay = null;
    _previousValidProtonCount = 0;
    _previousValidNeutronCount = 0;
    _invalidNuclideElapsed = 0;
    _nextNucleonId = 1;
    _lastLayoutMassNumber = 0;
  }

  // ---------------------------------------------------------------------------
  // 内部
  // ---------------------------------------------------------------------------

  /// 核内核子变化的统一后处理。
  ///
  /// [已确认] BANScreenView：massNumber 变化（或拖拽/incoming 变化）会隐藏
  /// undo 按钮 → 除衰变/撤销自身外，任何核变化都使撤销快照失效。
  ///
  /// 排布（Render 接口缺口，1D 最小接入）：[已确认] BANModel 中
  /// `massNumberProperty.link(() => reconfigureNucleus())`——只有质量数变化
  /// 才重排（β 衰变质量数不变，原项目经 defer 显式跳过重排，此处一致）。
  void _onNucleusChanged({bool clearUndo = true}) {
    if (clearUndo) {
      lastDecay = null;
    }
    if (massNumber != _lastLayoutMassNumber) {
      NucleusLayout.reconfigure(_protons, _neutrons,
          nucleonRadius: BanConstants.nucleonRadius);
      _lastLayoutMassNumber = massNumber;
    }
  }

  int _lastLayoutMassNumber = 0;
}
