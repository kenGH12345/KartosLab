import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/chart_intro/chart_intro_visuals.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/chart_intro_state.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/energy_level.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/render/shell_nucleus_render.dart';
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

  ChartIntroState newState() => ChartIntroState(repository: repo);

  test('空核：两列各 3 层线，无核子', () {
    final r = ShellNucleusRender.from(newState());
    expect(r.protonColumn.levels.length, 3);
    expect(r.neutronColumn.levels.length, 3);
    expect(r.protonColumn.nucleons, isEmpty);
    expect(r.neutronColumn.nucleons, isEmpty);
    expect(r.protonColumn.xOffset, 0);
    expect(r.neutronColumn.xOffset, ChartIntroVisuals.energyLevelColumnGap);
  });

  test('质子在左列，中子在右列（+256）', () {
    final s = newState();
    s.addProton();
    s.addNeutron();
    final r = ShellNucleusRender.from(s);
    expect(r.protonColumn.nucleons, hasLength(1));
    expect(r.neutronColumn.nucleons, hasLength(1));
    expect(r.protonColumn.nucleons.single.center.dx, 60);
    expect(
      r.neutronColumn.nucleons.single.center.dx,
      60 + ChartIntroVisuals.energyLevelColumnGap,
    );
    expect(r.protonColumn.nucleons.single.type, NucleonType.proton);
    expect(r.neutronColumn.nucleons.single.type, NucleonType.neutron);
  });

  test('第 3 个质子：n0 绑定靠拢，n1 未绑定', () {
    final s = newState();
    // 3p0n 不存在，上箭头会在 2p 停住；走存在核素 Li-6。
    for (var i = 0; i < 3; i++) {
      expect(s.addPair(), isTrue);
    }
    expect(s.protonCount, 3);
    final r = ShellNucleusRender.from(s);
    final n0 = r.protonColumn.nucleons.where((n) => n.bound).toList();
    final n1 = r.protonColumn.nucleons.where((n) => !n.bound).toList();
    expect(n0, hasLength(2));
    expect(n1, hasLength(1));
    expect(n0[0].center.dx < n0[1].center.dx, isTrue);
    expect(n1.single.center.dy < n0.first.center.dy, isTrue);
  });

  test('reset 后渲染回到空列', () {
    final s = newState();
    s.addProton();
    s.reset();
    final r = ShellNucleusRender.from(s);
    expect(r.protonColumn.nucleons, isEmpty);
    expect(
      r.protonColumn.levels.every((l) => l.occupied == 0),
      isTrue,
    );
    expect(
      r.protonColumn.levels.map((l) => l.yPosition).toList(),
      EnergyLevel.levels.map((l) => l.yPosition).toList(),
    );
  });
}
