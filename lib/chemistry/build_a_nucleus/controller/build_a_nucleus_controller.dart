/// Build a Nucleus · Decay 屏控制器。
///
/// 职责：把用户操作翻译成状态命令，并向 UI 发出变更通知。
/// 对齐 molarity 的显式 Controller 模式（编排层，无 UI / BuildContext）；
/// 通知机制用 ChangeNotifier（molarity 的 Solution 已有同款先例）。
///
/// 业务规则全部在 [BuildANucleusState] / [NuclideRepository]，
/// 本类不复制任何核素判定逻辑。
library;

import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../ban_constants.dart';
import '../data/decay_type.dart';
import '../data/nuclide_repository.dart';
import '../model/build_a_nucleus_state.dart';
import '../model/nucleon.dart';

class BuildANucleusController extends ChangeNotifier {
  BuildANucleusController({required NuclideRepository repository, Random? random})
      : _random = random ?? Random(),
        state = BuildANucleusState(repository: repository);

  final Random _random;

  /// 画布可见尺寸提供者（视图层注入），用于计算衰变逃逸点。
  /// 未注入时按 800×600 估算。[推测] 默认值仅为兜底
  Size Function()? visibleSizeProvider;

  final BuildANucleusState state;

  /// 生成器中心的世界坐标解析器（由视图层注入；未注入时默认核中心原点，
  /// 飞行距离为 0，下一帧即到达）。坐标属视图层知识，不进 State。
  Offset Function(NucleonType type)? creatorHomeResolver;

  Offset _creatorHome(NucleonType type) =>
      creatorHomeResolver?.call(type) ?? Offset.zero;

  // ---------------------------------------------------------------------------
  // 核子增减（箭头按钮命令）
  // ---------------------------------------------------------------------------

  /// [已确认] createParticleFromStack：从生成器中心飞入核中心，到达才计数。
  Nucleon? addProton() {
    final o = _creatorHome(NucleonType.proton);
    return _report(state.addProton(fromX: o.dx, fromY: o.dy));
  }

  Nucleon? addNeutron() {
    final o = _creatorHome(NucleonType.neutron);
    return _report(state.addNeutron(fromX: o.dx, fromY: o.dy));
  }

  bool removeProton() => _report(state.removeProton());
  bool removeNeutron() => _report(state.removeNeutron());

  bool addPair() {
    final po = _creatorHome(NucleonType.proton);
    final no = _creatorHome(NucleonType.neutron);
    return _report(state.addPair(
      protonFromX: po.dx,
      protonFromY: po.dy,
      neutronFromX: no.dx,
      neutronFromY: no.dy,
    ));
  }

  bool removePair() => _report(state.removePair());

  // ---------------------------------------------------------------------------
  // 拖拽闭环
  // ---------------------------------------------------------------------------

  /// 命中测试：返回世界坐标 (worldX, worldY) 处最上层的核子。
  ///
  /// 命中区域 = 核子圆（半径 [BanConstants.nucleonRadius]）。
  /// [已确认] ParticleView 的命中体为 ParticleNode 圆本身。
  /// 重叠时取 zLayer 最小者（最前；拖拽中为 0）。
  /// [已确认] shred zLayer 语义；触摸偏移 [待确认]（BANParticleView 未取证，
  /// 桌面端为 0 偏移）。
  Nucleon? hitTestNucleon(double worldX, double worldY) {
    const radius = BanConstants.nucleonRadius;
    Nucleon? best;
    var bestZ = 1 << 30;
    for (final n in [
      ...state.protons,
      ...state.neutrons,
      ...state.draggedNucleons,
    ]) {
      final dx = n.x - worldX;
      final dy = n.y - worldY;
      if (dx * dx + dy * dy <= radius * radius && n.zLayer < bestZ) {
        best = n;
        bestZ = n.zLayer;
      }
    }
    return best;
  }

  /// 从生成器拖出新核子：按下即创建并进入拖拽（无限供应）。
  ///
  /// [已确认] NucleonCreatorNode → addAndDragParticle → startSyntheticDrag：
  /// 粒子在生成器中心创建，立即处于用户控制态，中心对齐指针。
  Nucleon startTrayDrag(NucleonType type, double worldX, double worldY) {
    final nucleon = state.createFreeNucleon(type, x: worldX, y: worldY);
    state.beginFreeDrag(nucleon);
    notifyListeners();
    return nucleon;
  }

  /// 1C 兼容路径：无拖拽过程的直接落点判定（已被 startTrayDrag 链路取代，
  /// 保留给既有测试与免拖拽场景）。
  bool dropFromTray(NucleonType type, double worldX, double worldY) {
    final nucleon = state.createFreeNucleon(type, x: worldX, y: worldY);
    state.beginFreeDrag(nucleon);
    return _report(state.endNucleonDrop(nucleon));
  }

  /// 开始拖拽核内已有核子（拖出即不计数）。
  Nucleon? beginDrag(Nucleon nucleon) => _report(state.beginNucleonDrag(nucleon));

  /// 拖拽中更新位置（供捕获区视觉反馈）。
  /// [已确认] ParticleView drag：destination 跟随指针 + 立即到位
  void moveDragged(Nucleon nucleon, double worldX, double worldY) {
    nucleon.setPositionImmediate(worldX, worldY);
    notifyListeners();
  }

  /// 拖拽松手判定。提供归位坐标时，失败的核子以 300 px/s 飞回生成器。
  /// 返回 true 表示核子留在核内。
  bool endDrop(Nucleon nucleon, {double? returnX, double? returnY}) =>
      _report(state.endNucleonDrop(nucleon, returnX: returnX, returnY: returnY));

  // ---------------------------------------------------------------------------
  // 衰变 / 撤销 / 重置
  // ---------------------------------------------------------------------------

  /// 触发衰变；发射粒子飞向屏外随机点。
  /// [已确认] getRandomEscapePosition：可见区外扩 10 个粒子直径（200px）为
  /// 排除区，再外扩 300px 为目标环，环内均匀随机。
  bool applyDecay(NucleusDecayType type) {
    final escape = _randomEscapePosition();
    // Be-6 特例的 2 个质子各飞独立随机点（emitNucleon × 2）。
    // 普通 α 忽略 extraEscapes；预计算以保持 State 无 Random。
    final extraEscapes = type == NucleusDecayType.alphaDecay
        ? <(double, double)>[
            _toPair(_randomEscapePosition()),
            _toPair(_randomEscapePosition()),
          ]
        : const <(double, double)>[];
    return _report(state.applyDecay(
      type,
      escapeX: escape.dx,
      escapeY: escape.dy,
      extraEscapes: extraEscapes,
    ));
  }

  static (double, double) _toPair(Offset o) => (o.dx, o.dy);

  Offset _randomEscapePosition() {
    final size = visibleSizeProvider?.call() ?? const Size(800, 600);
    // 世界坐标下的可见区（核中心为原点，原点位于 (w/2, h×0.55)）
    final exclusion = Rect.fromLTRB(
        -size.width / 2 - 200,
        -size.height * 0.55 - 200,
        size.width / 2 + 200,
        size.height * 0.45 + 200);
    final target = exclusion.inflate(300);
    double x;
    double y;
    do {
      x = target.left + _random.nextDouble() * target.width;
      y = target.top + _random.nextDouble() * target.height;
    } while (exclusion.contains(Offset(x, y)));
    return Offset(x, y);
  }

  bool undoDecay() => _report(state.undoDecay());

  void reset() {
    state.reset();
    notifyListeners();
  }

  /// 每帧推进入口：核子运动（归位/回栈）+ 无效核素 1 秒回退计时。
  /// 返回 true 表示本帧发生了回退。由屏的 SimulationClock 调用。
  bool tick(double dt) {
    final moved = state.stepMotion(dt);
    final rolledBack = state.stepInvalidNuclideRollback(dt);
    if (moved || rolledBack) notifyListeners();
    return rolledBack;
  }

  T _report<T>(T result) {
    notifyListeners();
    return result;
  }
}
