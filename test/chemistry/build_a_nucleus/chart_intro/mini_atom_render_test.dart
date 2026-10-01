import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/chart_intro/chart_intro_visuals.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/chart_intro_state.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/render/mini_atom_render.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/nucleon.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/nucleus_layout.dart';

void main() {
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    repo = NuclideRepository(
      NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  });

  ChartIntroState newState() => ChartIntroState(repository: repo);

  MiniAtomRender renderOf(ChartIntroState s) => MiniAtomRender.from(s, repo);

  test('空核：虚线圆、无核子、无云、不可交互', () {
    final r = renderOf(newState());
    expect(r.protonCount, 0);
    expect(r.neutronCount, 0);
    expect(r.nucleons, isEmpty);
    expect(r.showEmptyCircle, isTrue);
    expect(r.cloudRadius, 0);
    expect(r.interactive, isFalse);
    expect(r.scale, ChartIntroVisuals.miniAtomScale);
  });

  test('计数与壳层相同，不持有第二份业务核子', () {
    final s = newState();
    s.addProton();
    s.addNeutron();
    final r = renderOf(s);
    expect(r.protonCount, s.protonCount);
    expect(r.neutronCount, s.neutronCount);
    expect(r.massNumber, 2);
    expect(r.showEmptyCircle, isFalse);
    expect(r.nucleons.length, 2);
    expect(s.miniAtom.interactive, isFalse);
  });

  test('排布与 NucleusLayout 圆簇一致，不是壳层座位', () {
    final s = newState();
    s.addProton();
    s.addNeutron();
    final r = renderOf(s);
    final protons = [Nucleon(id: 1, type: NucleonType.proton)];
    final neutrons = [Nucleon(id: 2, type: NucleonType.neutron)];
    NucleusLayout.reconfigure(
      protons,
      neutrons,
      nucleonRadius: ChartIntroVisuals.nucleonRadius,
    );
    expect(r.nucleons.length, 2);
    final offsets = r.nucleons.map((n) => n.offset).toSet();
    expect(offsets.contains(Offset(protons.first.destX, protons.first.destY)),
        isTrue);
    expect(offsets.contains(Offset(neutrons.first.destX, neutrons.first.destY)),
        isTrue);
    expect(
      r.nucleons.every((n) => n.offset != const Offset(60, 200)),
      isTrue,
    );
  });

  test('有质子时画电子云（Chart 上限 10 压缩）', () {
    final s = newState();
    s.addProton();
    final r = renderOf(s);
    expect(r.cloudRadius, greaterThan(0));
  });

  test('reset 后回到空核渲染', () {
    final s = newState();
    s.addProton();
    s.addNeutron();
    s.reset();
    final r = renderOf(s);
    expect(r.nucleons, isEmpty);
    expect(r.showEmptyCircle, isTrue);
    expect(r.interactive, isFalse);
  });
}
