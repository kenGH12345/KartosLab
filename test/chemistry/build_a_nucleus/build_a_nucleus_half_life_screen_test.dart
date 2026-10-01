import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/screens/build_a_nucleus_screen.dart';
import 'package:kratos/chemistry/build_a_nucleus/widgets/half_life_stability_legend.dart';

/// Phase 1G-3B-5：Half-Life UI 接入 Decay Screen。
/// 屏内 SimulationClock 常开，不能 pumpAndSettle。
void main() {
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    repo = NuclideRepository(
      NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  });

  BuildANucleusController builtUp(int p, int n) {
    final c = BuildANucleusController(repository: repo);
    while (c.state.protonCount < p || c.state.neutronCount < n) {
      if (c.state.protonCount < p && c.state.neutronCount < n) {
        c.addPair();
      } else if (c.state.protonCount < p) {
        c.addProton();
      } else {
        c.addNeutron();
      }
      c.state.settleAll();
    }
    return c;
  }

  Future<BuildANucleusController> pumpScreen(
    WidgetTester tester,
    BuildANucleusController c,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: BuildANucleusScreen(controller: c)),
    );
    await tester.pump();
    return c;
  }

  Future<void> pumpOpen(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('ban_half_life_info_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> pumpClosed(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('初始：数轴+读数标签+less/more+info，指针隐藏', (tester) async {
    await pumpScreen(tester, BuildANucleusController(repository: repo));
    expect(find.byKey(const ValueKey('ban_half_life_information')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('ban_half_life_number_line')),
        findsOneWidget);
    expect(find.text('Half-life:'), findsOneWidget);
    expect(find.text(HalfLifeStabilityLegend.lessStable), findsOneWidget);
    expect(find.text(HalfLifeStabilityLegend.moreStable), findsOneWidget);
    expect(find.byKey(const ValueKey('ban_half_life_info_button')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('ban_half_life_pointer')), findsNothing);
    expect(find.byKey(const ValueKey('ban_canvas')), findsOneWidget);
  });

  testWidgets('H-3：读数 3.9×10^8 s，指针可见', (tester) async {
    await pumpScreen(tester, builtUp(1, 2));
    expect(find.text('3.9'), findsOneWidget);
    expect(find.text('s'), findsOneWidget);
    expect(find.byKey(const ValueKey('ban_half_life_pointer')), findsOneWidget);
    expect(find.text('less stable'), findsOneWidget);
  });

  testWidgets('Stable H-1：∞，指针可见', (tester) async {
    await pumpScreen(tester, builtUp(1, 0));
    expect(find.text('∞'), findsOneWidget);
    expect(find.byKey(const ValueKey('ban_half_life_pointer')), findsOneWidget);
    expect(find.text('less stable'), findsOneWidget);
  });

  testWidgets('Unknown H-4：Unknown，指针隐藏', (tester) async {
    await pumpScreen(tester, builtUp(1, 3));
    expect(find.text('Unknown'), findsOneWidget);
    expect(find.byKey(const ValueKey('ban_half_life_pointer')), findsNothing);
    expect(find.text('more stable'), findsOneWidget);
  });

  testWidgets('Nonexistent：只留标签，指针隐藏', (tester) async {
    final c = builtUp(0, 1);
    c.addNeutron();
    c.state.settleAll();
    await pumpScreen(tester, c);
    expect(c.state.isShowingInvalidNuclide, isTrue);
    expect(find.text('Half-life:'), findsOneWidget);
    expect(find.text('Unknown'), findsNothing);
    expect(find.text('s'), findsNothing);
    expect(find.byKey(const ValueKey('ban_half_life_pointer')), findsNothing);
  });

  testWidgets('核素切换：读数与指针一起更新', (tester) async {
    final c = await pumpScreen(tester, builtUp(1, 2));
    expect(find.text('3.9'), findsOneWidget);
    expect(find.byKey(const ValueKey('ban_half_life_pointer')), findsOneWidget);

    c.reset();
    await tester.pump();
    expect(find.text('3.9'), findsNothing);
    expect(find.text('s'), findsNothing);
    expect(find.byKey(const ValueKey('ban_half_life_pointer')), findsNothing);
    expect(find.text('less stable'), findsOneWidget);
  });

  testWidgets('info 打开/关闭；Reset 不关 dialog', (tester) async {
    final c = await pumpScreen(tester, builtUp(1, 2));
    await pumpOpen(tester);
    expect(find.byKey(const ValueKey('ban_half_life_info_dialog')),
        findsOneWidget);
    expect(find.text('Half-Life Timescale'), findsOneWidget);

    c.reset();
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const ValueKey('ban_half_life_info_dialog')),
        findsOneWidget);
    expect(find.text('3.9'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('ban_half_life_info_close')));
    await pumpClosed(tester);
    expect(find.byKey(const ValueKey('ban_half_life_info_dialog')),
        findsNothing);
  });

  testWidgets('页面退出关闭 dialog', (tester) async {
    await pumpScreen(tester, builtUp(1, 2));
    await pumpOpen(tester);
    expect(find.byKey(const ValueKey('ban_half_life_info_dialog')),
        findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(find.byKey(const ValueKey('ban_half_life_info_dialog')),
        findsNothing);
  });
}
