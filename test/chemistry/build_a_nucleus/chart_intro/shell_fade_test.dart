import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/chart_intro/chart_intro_visuals.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/controller/chart_intro_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/render/mini_atom_render.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/render/nuclide_chart_render.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/widgets/chart_intro_interact_view.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';

void main() {
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    repo = NuclideRepository(
      NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  });

  ChartIntroController newController() =>
      ChartIntroController(repository: repo);

  double protonOpacity(ChartIntroController c, {int? id}) {
    final ns = c.shellRender.protonColumn.nucleons;
    if (id != null) {
      return ns.firstWhere((n) => n.id == id).opacity;
    }
    return ns.single.opacity;
  }

  group('fade in', () {
    test('0 → 1 proton：起点 0，0.5s 为 0.5，1s 结束为 1', () {
      final c = newController();
      c.addProton();
      expect(c.state.protonCount, 1);
      expect(c.fades.hasActive, isTrue);
      expect(protonOpacity(c), 0);
      expect(c.state.miniAtom.protonCount, 1);
      expect(NuclideChartRender.from(c.state, repo).currentSymbol, 'H');

      c.tick(0.5);
      expect(protonOpacity(c), closeTo(0.5, 1e-9));
      expect(c.state.protonCount, 1);

      c.tick(0.5);
      expect(protonOpacity(c), 1);
      expect(c.fades.hasActive, isFalse);
      c.dispose();
    });

    test('1 → 2 proton：第二粒独立从 0 淡入，第一粒不受 restart', () {
      final c = newController();
      c.addProton();
      c.tick(0.4);
      final firstId = c.state.shell.protons.first.id;
      expect(protonOpacity(c, id: firstId), closeTo(0.4, 1e-9));

      c.addProton();
      expect(c.state.protonCount, 2);
      final secondId = c.state.shell.protons.last.id;
      expect(protonOpacity(c, id: firstId), closeTo(0.4, 1e-9));
      expect(protonOpacity(c, id: secondId), 0);

      c.tick(0.6);
      expect(protonOpacity(c, id: firstId), 1);
      expect(protonOpacity(c, id: secondId), closeTo(0.6, 1e-9));
      c.dispose();
    });

    test('中子增加同样 1s LINEAR', () {
      final c = newController();
      c.addNeutron();
      expect(c.shellRender.neutronColumn.nucleons.single.opacity, 0);
      c.tick(ChartIntroVisuals.shellFadeDuration);
      expect(c.shellRender.neutronColumn.nucleons.single.opacity, 1);
      expect(c.fades.hasActive, isFalse);
      c.dispose();
    });

    test('p/n 同时变化：两粒各自 fade in，计数与图立即更新', () {
      final c = newController();
      c.addProton();
      c.addNeutron();
      expect(c.state.protonCount, 1);
      expect(c.state.neutronCount, 1);
      expect(c.shellRender.protonColumn.nucleons.single.opacity, 0);
      expect(c.shellRender.neutronColumn.nucleons.single.opacity, 0);
      expect(NuclideChartRender.from(c.state, repo).currentSymbol, 'H');
      c.tick(1);
      expect(c.shellRender.protonColumn.nucleons.single.opacity, 1);
      expect(c.shellRender.neutronColumn.nucleons.single.opacity, 1);
      c.dispose();
    });
  });

  group('fade out', () {
    test('减质子：计数立刻 0，残影 1→0，结束后消失', () {
      final c = newController();
      c.addProton();
      c.tick(1);
      c.removeProton();
      expect(c.state.protonCount, 0);
      expect(c.shellRender.protonColumn.nucleons, hasLength(1));
      expect(c.shellRender.protonColumn.nucleons.single.opacity, 1);
      expect(MiniAtomRender.from(c.state, repo).showEmptyCircle, isTrue);

      c.tick(0.5);
      expect(c.shellRender.protonColumn.nucleons.single.opacity, closeTo(0.5, 1e-9));
      c.tick(0.5);
      expect(c.shellRender.protonColumn.nucleons, isEmpty);
      expect(c.fades.hasActive, isFalse);
      c.dispose();
    });

    test('淡入未完就移除：从当前 opacity 改向 0，仍走满 1s', () {
      final c = newController();
      c.addProton();
      c.tick(0.3);
      expect(protonOpacity(c), closeTo(0.3, 1e-9));
      c.removeProton();
      // [已确认] twixt Animation duration 固定 1s，从现值 → 0
      expect(c.shellRender.protonColumn.nucleons.single.opacity, closeTo(0.3, 1e-9));
      c.tick(0.5);
      expect(
        c.shellRender.protonColumn.nucleons.single.opacity,
        closeTo(0.3 + (0 - 0.3) * 0.5, 1e-9),
      );
      c.tick(0.5);
      expect(c.shellRender.protonColumn.nucleons, isEmpty);
      c.dispose();
    });
  });

  group('快速连续修改', () {
    test('0,0 → 1,0 → 2,0：两粒并行 fade，不互相 cancel', () {
      final c = newController();
      c.addProton();
      c.addProton();
      expect(c.state.protonCount, 2);
      final ids = c.state.shell.protons.map((n) => n.id).toList();
      expect(protonOpacity(c, id: ids[0]), 0);
      expect(protonOpacity(c, id: ids[1]), 0);
      c.tick(0.5);
      expect(protonOpacity(c, id: ids[0]), closeTo(0.5, 1e-9));
      expect(protonOpacity(c, id: ids[1]), closeTo(0.5, 1e-9));
      // 2p0n 不存在，不能加到 3,0。[已确认] 上箭头只允许多 1 个不存在态
      expect(c.state.canAddProton, isFalse);
      c.dispose();
    });
  });

  group('Reset / dispose', () {
    test('动画中 Reset：立即 0p0n，无残影，tick 不再污染', () {
      final c = newController();
      c.addProton();
      c.addNeutron();
      c.tick(0.4);
      expect(c.fades.hasActive, isTrue);
      c.reset();
      expect(c.state.protonCount, 0);
      expect(c.state.neutronCount, 0);
      expect(c.fades.hasActive, isFalse);
      expect(c.shellRender.protonColumn.nucleons, isEmpty);
      expect(c.shellRender.neutronColumn.nucleons, isEmpty);
      expect(MiniAtomRender.from(c.state, repo).showEmptyCircle, isTrue);
      expect(NuclideChartRender.from(c.state, repo).currentCellVisual, isNull);
      c.tick(0.5);
      expect(c.shellRender.protonColumn.nucleons, isEmpty);
      c.dispose();
    });

    test('动画中 dispose：不再 tick、不再改 State', () {
      final c = newController();
      c.addProton();
      c.tick(0.2);
      c.dispose();
      expect(c.state.isDisposed, isTrue);
      expect(c.fades.hasActive, isFalse);
      expect(c.tick(0.5), isFalse);
      expect(c.state.protonCount, 1);
    });
  });

  group('生命周期（视图）', () {
    testWidgets('动画中退出再进入：无残留 Ticker，新实例空核', (tester) async {
      final c1 = newController();
      await tester.pumpWidget(
        MaterialApp(
          home: ChartIntroInteractView(controller: c1, tickOnClock: false),
        ),
      );
      c1.addProton();
      c1.tick(0.3);
      expect(c1.fades.hasActive, isTrue);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
      c1.dispose();

      final c2 = newController();
      await tester.pumpWidget(
        MaterialApp(
          home: ChartIntroInteractView(controller: c2, tickOnClock: false),
        ),
      );
      expect(c2.state.isEmptyNucleus, isTrue);
      expect(c2.fades.hasActive, isFalse);
      expect(find.text('Protons: 0'), findsOneWidget);
      c2.dispose();
    });
  });
}
