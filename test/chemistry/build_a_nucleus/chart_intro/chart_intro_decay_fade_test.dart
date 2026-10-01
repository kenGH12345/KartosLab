import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/chart_intro/chart_intro_visuals.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/controller/chart_intro_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/nucleon.dart';

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

  void seed(ChartIntroController c, int p, int n) {
    for (var i = 0; i < p; i++) {
      expect(c.state.addImmediately(NucleonType.proton), isNotNull);
    }
    for (var i = 0; i < n; i++) {
      expect(c.state.addImmediately(NucleonType.neutron), isNotNull);
    }
  }

  double opacityOf(ChartIntroController c, int id) {
    for (final col in c.shellRender.columns) {
      for (final n in col.nucleons) {
        if (n.id == id) return n.opacity;
      }
    }
    fail('nucleon $id not in render');
  }

  group('alpha multi-particle fade', () {
    test('2p2n：计数立刻 0；4 粒独立 fade；1s 后残影消失', () {
      final c = newController();
      seed(c, 2, 2);
      expect(c.emitAlpha(), isTrue);
      expect(c.state.protonCount, 0);
      expect(c.state.neutronCount, 0);
      expect(c.fades.outgoingCount, 4);
      expect(c.fades.incomingCount, 0);
      expect(c.shellRender.protonColumn.nucleons, hasLength(2));
      expect(c.shellRender.neutronColumn.nucleons, hasLength(2));
      for (final col in c.shellRender.columns) {
        for (final n in col.nucleons) {
          expect(n.opacity, 1);
        }
      }

      c.tick(0.5);
      expect(c.state.protonCount, 0);
      expect(c.fades.outgoingCount, 4);
      for (final col in c.shellRender.columns) {
        for (final n in col.nucleons) {
          expect(n.opacity, closeTo(0.5, 1e-9));
        }
      }

      c.tick(0.5);
      expect(c.fades.hasActive, isFalse);
      expect(c.shellRender.protonColumn.nucleons, isEmpty);
      expect(c.shellRender.neutronColumn.nucleons, isEmpty);
      c.dispose();
    });

    test('不足 2p2n 不启动', () {
      final c = newController();
      seed(c, 1, 2);
      expect(c.emitAlpha(), isFalse);
      expect(c.state.protonCount, 1);
      expect(c.fades.hasActive, isFalse);
      c.dispose();
    });
  });

  group('beta cross-fade', () {
    test('β-：1p2n → 2p1n；旧出新进同时 1s LINEAR', () {
      final c = newController();
      seed(c, 1, 2);
      final oldN = c.state.shell.getLastInShell(NucleonType.neutron)!;
      expect(c.betaMinus(), isTrue);
      expect(c.state.protonCount, 2);
      expect(c.state.neutronCount, 1);
      expect(c.fades.outgoingCount, 1);
      expect(c.fades.incomingCount, 1);

      final newP = c.state.shell.protons.last;
      expect(opacityOf(c, oldN.id), 1);
      expect(opacityOf(c, newP.id), 0);

      c.tick(0.5);
      expect(c.state.protonCount, 2);
      expect(c.state.neutronCount, 1);
      expect(opacityOf(c, oldN.id), closeTo(0.5, 1e-9));
      expect(opacityOf(c, newP.id), closeTo(0.5, 1e-9));

      c.tick(0.5);
      expect(c.fades.hasActive, isFalse);
      expect(
        c.shellRender.protonColumn.nucleons.any((n) => n.id == oldN.id),
        isFalse,
      );
      expect(opacityOf(c, newP.id), 1);
      c.dispose();
    });

    test('β+：4p3n → 3p4n；旧质子出、新中子进同时进行', () {
      final c = newController();
      seed(c, 4, 3);
      final oldP = c.state.shell.getLastInShell(NucleonType.proton)!;
      expect(c.betaPlus(), isTrue);
      expect(c.state.protonCount, 3);
      expect(c.state.neutronCount, 4);
      final newN = c.state.shell.neutrons.last;
      expect(opacityOf(c, oldP.id), 1);
      expect(opacityOf(c, newN.id), 0);
      c.tick(ChartIntroVisuals.shellFadeDuration);
      expect(c.fades.hasActive, isFalse);
      expect(opacityOf(c, newN.id), 1);
      c.dispose();
    });

    test('空中子不能 β-', () {
      final c = newController();
      seed(c, 1, 0);
      expect(c.betaMinus(), isFalse);
      expect(c.state.protonCount, 1);
      c.dispose();
    });
  });

  group('add/remove 时序（fade 验证复用，不是原版箭头）', () {
    test('add 计数立刻变，opacity 从 0；remove 从当前 opacity 改向 0', () {
      final c = newController();
      c.addProton();
      expect(c.state.protonCount, 1);
      expect(c.fades.incomingCount, 1);
      expect(c.shellRender.protonColumn.nucleons.single.opacity, 0);
      c.tick(0.4);
      c.removeProton();
      expect(c.state.protonCount, 0);
      expect(c.fades.outgoingCount, 1);
      expect(
        c.shellRender.protonColumn.nucleons.single.opacity,
        closeTo(0.4, 1e-9),
      );
      c.dispose();
    });
  });

  group('concurrent / current opacity', () {
    test('α 残影未完时再加质子：fade in 与 4 个 fade out 并存', () {
      final c = newController();
      seed(c, 2, 2);
      c.emitAlpha();
      c.tick(0.3);
      expect(c.fades.outgoingCount, 4);
      c.addProton();
      expect(c.state.protonCount, 1);
      expect(c.fades.outgoingCount, 4);
      expect(c.fades.incomingCount, 1);
      expect(c.shellRender.protonColumn.nucleons, hasLength(3));
      c.tick(0.7);
      expect(c.fades.outgoingCount, 0);
      expect(c.fades.incomingCount, 1);
      expect(
        c.shellRender.protonColumn.nucleons.single.opacity,
        closeTo(0.7, 1e-9),
      );
      c.dispose();
    });

    test('0→1p→1n→2p→remove p→add n：多粒并行，remove 从当前 opacity', () {
      final c = newController();
      c.addProton();
      c.addNeutron();
      c.addProton();
      expect(c.state.protonCount, 2);
      expect(c.state.neutronCount, 1);
      expect(c.fades.incomingCount, 3);

      final lastP = c.state.shell.getLastInShell(NucleonType.proton)!;
      expect(opacityOf(c, lastP.id), 0);
      c.removeProton();
      expect(c.state.protonCount, 1);
      expect(opacityOf(c, lastP.id), 0);
      expect(c.fades.outgoingCount, 1);
      expect(c.fades.incomingCount, 2);

      c.addNeutron();
      expect(c.state.neutronCount, 2);
      expect(c.fades.incomingCount, 3);
      expect(c.fades.outgoingCount, 1);
      c.dispose();
    });

    test('0→1p→2p：2p0n 箭头不能 remove（不是 fade cancel）', () {
      final c = newController();
      c.addProton();
      c.addProton();
      expect(c.state.canRemoveProton, isFalse);
      c.removeProton();
      expect(c.state.protonCount, 2);
      expect(c.fades.outgoingCount, 0);
      expect(c.fades.incomingCount, 2);
      c.dispose();
    });
  });

  group('Reset / dispose during fade', () {
    test('α 进行中 Reset：立刻 0p0n，无残影', () {
      final c = newController();
      seed(c, 2, 2);
      c.emitAlpha();
      c.tick(0.4);
      c.reset();
      expect(c.state.protonCount, 0);
      expect(c.state.neutronCount, 0);
      expect(c.fades.hasActive, isFalse);
      expect(c.shellRender.protonColumn.nucleons, isEmpty);
      c.tick(0.5);
      expect(c.shellRender.protonColumn.nucleons, isEmpty);
      c.dispose();
    });

    test('β 进行中 dispose：不再 tick', () {
      final c = newController();
      seed(c, 1, 2);
      c.betaMinus();
      c.tick(0.2);
      c.dispose();
      expect(c.fades.hasActive, isFalse);
      expect(c.tick(0.5), isFalse);
      expect(c.state.protonCount, 2);
      expect(c.state.neutronCount, 1);
    });
  });
}
