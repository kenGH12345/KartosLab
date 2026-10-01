import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/ban_constants.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/decay_type.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/build_a_nucleus_state.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/nucleon.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/nucleus_layout.dart';

/// 排布算法测试。期望值逐行对照 shred ParticleAtom.reconfigureNucleus。
void main() {
  const r = BanConstants.nucleonRadius; // 10

  List<Nucleon> makeNucleons(NucleonType type, int count) => [
        for (var i = 0; i < count; i++) Nucleon(id: i + 1, type: type),
      ];

  // 1E-2 起布局写 destination（原版即如此，粒子动画归位）；纯算法测试断言目的地。
  double dist(Nucleon n) => sqrt(n.destX * n.destX + n.destY * n.destY);

  group('NucleusLayout.reconfigure（纯算法）', () {
    test('1 个核子 → 居中', () {
      final p = makeNucleons(NucleonType.proton, 1);
      NucleusLayout.reconfigure(p, [], nucleonRadius: r);
      expect(p[0].destX, closeTo(0, 1e-9));
      expect(p[0].destY, closeTo(0, 1e-9));
      expect(p[0].zLayer, NucleusLayout.topLayer);
    });

    test('2 个核子 → 关于中心对称并排，距中心 r', () {
      final p = makeNucleons(NucleonType.proton, 1);
      final n = makeNucleons(NucleonType.neutron, 1);
      NucleusLayout.reconfigure(p, n, nucleonRadius: r);
      // 交错序列 [n, p]；角度 0.4π（原项目任意选定）
      const angle = 0.2 * 2 * pi;
      expect(n[0].destX, closeTo(r * cos(angle), 1e-9));
      expect(n[0].destY, closeTo(r * sin(angle), 1e-9));
      expect(p[0].destX, closeTo(-r * cos(angle), 1e-9));
      expect(p[0].destY, closeTo(-r * sin(angle), 1e-9));
    });

    test('3 个核子 → 互切三角，距中心 r×1.155，间隔 120°', () {
      final p = makeNucleons(NucleonType.proton, 2);
      final n = makeNucleons(NucleonType.neutron, 1);
      NucleusLayout.reconfigure(p, n, nucleonRadius: r);
      // 交错：ratio=0.5 → 首轮 0.5<1 不放中子 → [p0, n0, p1]
      final all = [p[0], n[0], p[1]];
      const angle0 = 0.7 * 2 * pi;
      for (var i = 0; i < 3; i++) {
        final a = angle0 + i * 2 * pi / 3;
        expect(all[i].destX, closeTo(r * 1.155 * cos(a), 1e-9));
        expect(all[i].destY, closeTo(r * 1.155 * sin(a), 1e-9));
      }
    });

    test('4 个核子 → 菱形，两对垂直，z 分层', () {
      final p = makeNucleons(NucleonType.proton, 2);
      final n = makeNucleons(NucleonType.neutron, 2);
      NucleusLayout.reconfigure(p, n, nucleonRadius: r);
      // 交错：ratio=1 → [n0, p0, n1, p1]
      const angle = 1.4 * 2 * pi;
      // 0/2 位：±r ∠angle，z=topLayer
      expect(n[0].destX, closeTo(r * cos(angle), 1e-9));
      expect(n[1].destX, closeTo(-r * cos(angle), 1e-9));
      expect(n[0].zLayer, NucleusLayout.topLayer);
      expect(n[1].zLayer, NucleusLayout.topLayer);
      // 1/3 位：∓r ∠(angle+π/2)（dist = 2r·cos(π/3) = r），z=topLayer+1
      expect(p[0].destX, closeTo(r * cos(angle + pi / 2), 1e-9));
      expect(p[1].destX, closeTo(-r * cos(angle + pi / 2), 1e-9));
      expect(p[0].zLayer, NucleusLayout.topLayer + 1);
      expect(p[1].zLayer, NucleusLayout.topLayer + 1);
    });

    test('≥5 个核子 → 螺旋层：首核居中，第二层半径 r×1.35，4 个', () {
      final p = makeNucleons(NucleonType.proton, 3);
      final n = makeNucleons(NucleonType.neutron, 3);
      NucleusLayout.reconfigure(p, n, nucleonRadius: r);
      // 交错：ratio=1 → [n0, p0, n1, p1, n2, p2]
      // i=0 居中；level1: radius=13.5, 容量 floor(13.5π/10)=4，角度步进 π/2
      expect(dist(n[0]), closeTo(0, 1e-9));
      for (final nucleon in [p[0], n[1], p[1], n[2]]) {
        expect(dist(nucleon), closeTo(13.5, 1e-9));
      }
      // i=5 → level2: radius = 13.5 + 13.5/2 = 20.25
      expect(dist(p[2]), closeTo(20.25, 1e-9));
    });

    test('大核（边界 94p+146n=240）→ 全部有限坐标且不发散', () {
      final p = makeNucleons(NucleonType.proton, 94);
      final n = makeNucleons(NucleonType.neutron, 146);
      NucleusLayout.reconfigure(p, n, nucleonRadius: r);
      for (final nucleon in [...p, ...n]) {
        expect(nucleon.destX.isFinite, isTrue);
        expect(nucleon.destY.isFinite, isTrue);
      }
      // 最外核子距离有限（经验上界：层数有限，半径远小于捕获区外）
      final maxDist = [...p, ...n].map(dist).reduce(max);
      expect(maxDist, lessThan(500));
    });
  });

  group('State 集成（真实数据驱动排布）', () {
    late final NuclideRepository repo;

    setUpAll(() {
      final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
      repo = NuclideRepository(
        NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
      );
    });

    test('添加核子后位置按算法更新（归位动画结束后）', () {
      final s = BuildANucleusState(repository: repo);
      s.addProton();
      s.settleAll(); // 飞入到达 + 到卡位（1F-1 起添加为飞入动画）
      expect(s.protons[0].x, closeTo(0, 1e-9)); // 单核子居中

      s.addNeutron(); // H-2：2 核子并排
      s.settleAll();
      expect(dist2(s.protons[0]), closeTo(r, 1e-9));
      expect(dist2(s.neutrons[0]), closeTo(r, 1e-9));
    });

    test('β 衰变质量数不变 → 不重排（对标原项目 defer 行为）', () {
      final s = BuildANucleusState(repository: repo);
      s.addProton();
      s.addNeutron();
      s.addNeutron(); // H-3，3 核子三角
      s.settleAll();
      final before = [
        for (final n in [...s.protons, ...s.neutrons]) (n.x, n.y),
      ];
      s.applyDecay(NucleusDecayType.betaMinusDecay); // → He-3，质量数仍为 3
      final after = [
        for (final n in [...s.protons, ...s.neutrons]) (n.x, n.y),
      ];
      expect(after, before);
    });

    test('α 衰变质量数变化 → 重排', () {
      final s = BuildANucleusState(repository: repo);
      for (var i = 0; i < 4; i++) {
        s.addPair(); // Be-8：8 核子螺旋
      }
      s.settleAll(); // 飞行核子全部到达（飞行中衰变按钮禁用，须先到位）
      s.applyDecay(NucleusDecayType.alphaDecay); // → He-4：4 核子菱形
      s.moveAllNucleonsToDestination();
      // 菱形布局：所有核子距中心 = r
      for (final n in [...s.protons, ...s.neutrons]) {
        expect(dist2(n), closeTo(r, 1e-9));
      }
    });

    test('拖出核子时 zLayer 置 0（最前）', () {
      final s = BuildANucleusState(repository: repo);
      s.addPair();
      s.settleAll();
      final nucleon = s.neutrons.first;
      s.beginNucleonDrag(nucleon);
      expect(nucleon.zLayer, NucleusLayout.draggedLayer);
    });

    test('reset 后无核子可绘', () {
      final s = BuildANucleusState(repository: repo);
      s.addPair();
      s.reset();
      expect(s.protons, isEmpty);
      expect(s.neutrons, isEmpty);
    });
  });
}

double dist2(Nucleon n) => sqrt(n.x * n.x + n.y * n.y);
