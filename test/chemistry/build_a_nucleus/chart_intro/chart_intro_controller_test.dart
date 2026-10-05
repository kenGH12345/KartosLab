import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/chart_intro/controller/chart_intro_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/render/mini_atom_render.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/render/nuclide_chart_render.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/render/shell_nucleus_render.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/widgets/chart_intro_status_text.dart';
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

  test('加质子：State / 壳层 / 图 / mini-atom 同步', () {
    final c = newController();
    var notified = 0;
    c.addListener(() => notified++);
    c.addProton();
    expect(notified, 1);
    expect(c.state.protonCount, 1);
    expect(c.state.neutronCount, 0);
    expect(c.state.elementSymbol, 'H');
    expect(c.state.currentCell!.x, 0);
    expect(c.state.currentCell!.y, 1);
    expect(c.state.shell.protonCount, 1);
    expect(c.state.miniAtom.protonCount, 1);
    expect(c.state.miniAtom.interactive, isFalse);

    final chart = NuclideChartRender.from(c.state, repo);
    expect(chart.currentExists, isTrue);
    expect(chart.currentSymbol, 'H');
    expect(chart.currentCellVisual!.y, 1);
    expect(chart.currentCellVisual!.x, 0);

    final shell = ShellNucleusRender.from(c.state);
    expect(shell.protonColumn.nucleons, hasLength(1));
    expect(shell.neutronColumn.nucleons, isEmpty);

    final mini = MiniAtomRender.from(c.state, repo);
    expect(mini.nucleons, hasLength(1));
    expect(mini.showEmptyCircle, isFalse);
    c.dispose();
  });

  test('加减中子 + 下限 0', () {
    final c = newController();
    c.addNeutron();
    expect(c.state.neutronCount, 1);
    expect(ChartIntroStatusText.elementCaption(c.state), '1 neutron');
    c.removeNeutron();
    expect(c.state.neutronCount, 0);
    expect(c.state.canRemoveNeutron, isFalse);
    c.removeNeutron();
    expect(c.state.neutronCount, 0);
    c.dispose();
  });

  test('质子上限 10，中子上限 12', () {
    final c = newController();
    // Ne-20 (10,10) 存在，再加中子到 12。
    for (var i = 0; i < 10; i++) {
      c.addProton();
      c.addNeutron();
    }
    expect(c.state.protonCount, 10);
    expect(c.state.canAddProton, isFalse);
    c.addProton();
    expect(c.state.protonCount, 10);
    c.addNeutron();
    c.addNeutron();
    expect(c.state.neutronCount, 12);
    expect(c.state.canAddNeutron, isFalse);
    c.addNeutron();
    expect(c.state.neutronCount, 12);
    c.dispose();
  });

  test('越界 1 个不存在核素：显示 does not form，箭头全禁', () {
    final c = newController();
    c.addNeutron();
    c.addNeutron(); // (0,2)
    expect(c.state.isShowingInvalidNuclide, isTrue);
    expect(c.state.currentCell, isNull);
    expect(
      ChartIntroStatusText.elementCaption(c.state),
      '2 neutrons does not form',
    );
    expect(c.state.canAddProton, isFalse);
    expect(c.state.canAddNeutron, isFalse);
    expect(c.state.canRemoveProton, isFalse);
    expect(c.state.canRemoveNeutron, isFalse);
    c.dispose();
  });

  test('reset 回到 0p0n，并通知', () {
    final c = newController();
    c.addProton();
    c.addNeutron();
    var notified = 0;
    c.addListener(() => notified++);
    c.reset();
    expect(notified, 1);
    expect(c.state.protonCount, 0);
    expect(c.state.neutronCount, 0);
    expect(c.state.currentCell, isNull);
    expect(MiniAtomRender.from(c.state, repo).showEmptyCircle, isTrue);
    c.dispose();
  });

  test('不存在核素 1 秒后回到上一有效计数', () {
    final c = newController();
    c.addNeutron();
    expect(c.state.neutronCount, 1);
    c.addNeutron();
    expect(c.state.isShowingInvalidNuclide, isTrue);
    c.tick(0.5);
    expect(c.state.neutronCount, 2);
    c.tick(0.5);
    expect(c.state.neutronCount, 1);
    expect(c.state.isShowingInvalidNuclide, isFalse);
    c.dispose();
  });

  test('生成器拖到能级外不入座；拖进能级才计数', () {
    final c = newController();
    expect(c.beginCreatorDrag(NucleonType.proton), isTrue);
    expect(c.state.protonCount, 0);
    expect(c.state.canAddProton, isFalse);
    c.endCreatorDrag(inShell: false);
    expect(c.state.protonCount, 0);
    expect(c.beginCreatorDrag(NucleonType.proton), isTrue);
    c.endCreatorDrag(inShell: true);
    expect(c.state.protonCount, 1);
    c.dispose();
  });

  test('dispose 后不再改 State', () {
    final c = newController();
    c.addProton();
    c.dispose();
    c.addProton();
    expect(c.state.protonCount, 1);
    expect(c.state.isDisposed, isTrue);
  });
}
