import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/screens/build_a_nucleus_screen.dart';

/// FINAL-1：多视口可达性 / overflow，以及进退屏生命周期。
/// 不建 golden 框架。屏内 SimulationClock 常开，不能 pumpAndSettle。
void main() {
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    repo = NuclideRepository(
      NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  });

  Future<void> pumpAt(WidgetTester tester, Size size, BuildANucleusController c) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: BuildANucleusScreen(controller: c),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('生成器双箭头：空核可 addPair → H-2', (tester) async {
    final c = BuildANucleusController(repository: repo);
    await pumpAt(tester, const Size(1024, 768), c);
    expect(find.byKey(const ValueKey('ban_add_pair')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('ban_add_pair')));
    await tester.pump();
    c.state.settleAll();
    await tester.pump();
    expect(c.state.protonCount, 1);
    expect(c.state.neutronCount, 1);
  });

  testWidgets('视口：控件可达且无 overflow', (tester) async {
    const sizes = <Size>[
      Size(1024, 768),
      Size(1280, 800),
      Size(1366, 1024),
      Size(640, 360),
    ];
    for (final size in sizes) {
      final c = BuildANucleusController(repository: repo);
      await pumpAt(tester, size, c);
      expect(tester.takeException(), isNull, reason: '$size overflow');
      expect(find.byKey(const ValueKey('ban_canvas')), findsOneWidget,
          reason: '$size canvas');
      expect(find.text('Electron Cloud'), findsOneWidget, reason: '$size cloud');
      expect(find.text('Available Decays'), findsOneWidget,
          reason: '$size decays');
      expect(find.byKey(const ValueKey('ban_reset')), findsOneWidget,
          reason: '$size reset');
      expect(find.byKey(const ValueKey('ban_half_life_number_line')),
          findsOneWidget,
          reason: '$size number line');
      expect(find.byKey(const ValueKey('ban_add_proton')), findsOneWidget,
          reason: '$size generator');
    }
  });

  testWidgets('生命周期：进入→退出→再进入 ×5，dialog 不残留', (tester) async {
    for (var i = 0; i < 5; i++) {
      final c = BuildANucleusController(repository: repo);
      await tester.pumpWidget(
        MaterialApp(home: BuildANucleusScreen(controller: c)),
      );
      await tester.pump();
      expect(find.byKey(const ValueKey('ban_canvas')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('ban_half_life_info_button')));
      await tester.pump();
      expect(find.byKey(const ValueKey('ban_half_life_info_dialog')),
          findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(find.byKey(const ValueKey('ban_half_life_info_dialog')),
          findsNothing);
      expect(find.byKey(const ValueKey('ban_canvas')), findsNothing);
    }
  });
}
