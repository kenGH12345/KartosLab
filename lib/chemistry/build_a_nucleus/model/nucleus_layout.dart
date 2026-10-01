/// 核内核子排布算法。
///
/// 逐行移植 shred `ParticleAtom.reconfigureNucleus()`（已读全文取证）：
/// 1. 质子/中子按数量比例交错成单一序列；
/// 2. 按总数分情形布局（1 居中 / 2 并排 / 3 三角 / 4 菱形 / ≥5 螺旋层）。
///
/// 与原项目的差异：原版写入 destinationProperty 并以 300 px/s 动画归位
/// （BANConstants.PARTICLE_ANIMATION_SPEED）；本阶段直接落位，归位动画属 Phase 1F。
///
/// 坐标约定：核中心为 (0,0)，y 向下（与 scenery / Flutter 一致，无翻转）。
library;

import 'dart:math';

import 'nucleon.dart';

class NucleusLayout {
  const NucleusLayout._();

  /// 拖拽核子所在层（原项目 layer 0 保留给拖拽粒子）。
  static const int draggedLayer = 0;

  /// 核子顶层起始 z。[已确认] reconfigureNucleus 的 topLayer = 1
  static const int topLayer = 1;

  /// 对 [protons] + [neutrons] 重排位置与 z 层级（就地修改 x/y/zLayer）。
  static void reconfigure(
    List<Nucleon> protons,
    List<Nucleon> neutrons, {
    required double nucleonRadius,
  }) {
    // 交错：neutronsPerProton 比例累积器。[已确认] reconfigureNucleus 551-565 行
    final nucleons = <Nucleon>[];
    var protonIndex = 0;
    var neutronIndex = 0;
    final neutronsPerProton =
        protons.isEmpty ? double.infinity : neutrons.length / protons.length;
    var neutronsToAdd = 0.0;
    while (nucleons.length < neutrons.length + protons.length) {
      neutronsToAdd += neutronsPerProton;
      while (neutronsToAdd >= 1 && neutronIndex < neutrons.length) {
        nucleons.add(neutrons[neutronIndex++]);
        neutronsToAdd -= 1;
      }
      if (protonIndex < protons.length) {
        nucleons.add(protons[protonIndex++]);
      }
    }

    final r = nucleonRadius;
    if (nucleons.length == 1) {
      // 单核子居中。[已确认] 567-572 行
      _place(nucleons[0], 0, 0, topLayer);
    } else if (nucleons.length == 2) {
      // 并排，接点居中；角度为原项目任意选定值。[已确认] 573-583 行
      const angle = 0.2 * 2 * pi;
      _place(nucleons[0], r * cos(angle), r * sin(angle), topLayer);
      _place(nucleons[1], -r * cos(angle), -r * sin(angle), topLayer);
    } else if (nucleons.length == 3) {
      // 互切正三角形。[已确认] 584-598 行
      const angle = 0.7 * 2 * pi;
      final dist = r * 1.155;
      for (var i = 0; i < 3; i++) {
        final a = angle + i * 2 * pi / 3;
        _place(nucleons[i], dist * cos(a), dist * sin(a), topLayer);
      }
    } else if (nucleons.length == 4) {
      // 菱形（0/2 与 1/3 两对互相垂直，后者层级更高）。[已确认] 599-616 行
      const angle = 1.4 * 2 * pi;
      _place(nucleons[0], r * cos(angle), r * sin(angle), topLayer);
      _place(nucleons[2], -r * cos(angle), -r * sin(angle), topLayer);
      final dist = r * 2 * cos(pi / 3); // = r
      _place(nucleons[1], dist * cos(angle + pi / 2), dist * sin(angle + pi / 2),
          topLayer + 1);
      _place(nucleons[3], -dist * cos(angle + pi / 2),
          -dist * sin(angle + pi / 2), topLayer + 1);
    } else if (nucleons.length >= 5) {
      _reconfigureSpiral(nucleons, r);
    }
  }

  /// ≥5 个核子的通用螺旋层算法。[已确认] reconfigureNucleus 617-658 行
  static void _reconfigureSpiral(List<Nucleon> nucleons, double r) {
    // LinearFunction(3, 10, 2.4, 1.35, clamp: true)：核子越大缩放越小。
    final scaleFactor = _linearClamped(3, 10, 2.4, 1.35, r);

    var placementRadius = 0.0;
    var numAtThisRadius = 1;
    var level = 0;
    var placementAngle = 0.0;
    var placementAngleDelta = 0.0;

    for (var i = 0; i < nucleons.length; i++) {
      _place(
        nucleons[i],
        placementRadius * cos(placementAngle),
        placementRadius * sin(placementAngle),
        level + topLayer,
      );
      numAtThisRadius--;
      if (numAtThisRadius > 0) {
        placementAngle += placementAngleDelta;
      } else {
        level++;
        placementRadius += r * scaleFactor / level;
        // 原项目注释：角度步进为按观感任意选定。
        placementAngle += 2 * pi * 0.2 + level * pi;
        numAtThisRadius = (placementRadius * pi / r).floor();
        placementAngleDelta = 2 * pi / numAtThisRadius;
      }
    }
  }

  /// [已确认] 原版 reconfigureNucleus 写 destinationProperty，粒子以恒定速度
  /// 动画归位（Particle.step）；本实现一致：写 destination，由
  /// BuildANucleusState.stepMotion 推进。
  static void _place(Nucleon nucleon, double x, double y, int zLayer) {
    nucleon.setDestination(x, y);
    nucleon.zLayer = zLayer;
  }

  /// dot LinearFunction（clamp=true）：x∈[x0,x1] 线性映射到 [y0,y1]，超出截断。
  static double _linearClamped(
      double x0, double x1, double y0, double y1, double x) {
    final t = ((x - x0) / (x1 - x0)).clamp(0.0, 1.0);
    return y0 + (y1 - y0) * t;
  }
}
