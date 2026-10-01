import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/decay_type.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/screens/build_a_nucleus_screen.dart';
import 'package:kratos/chemistry/build_a_nucleus/widgets/nuclide_status.dart';

/// Phase 1G-2：核素信息 / 状态显示 UI。
/// 文案对标 ElementNameText / StabilityIndicatorText / SymbolNode /
/// DecayModel.halfLifeNumberProperty；数据只读 State。
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

  group('ElementNameText 文案（纯函数）', () {
    test('0p0n：空串', () {
      final c = BuildANucleusController(repository: repo);
      expect(NuclideStatusText.elementCaption(c.state), '');
      expect(NuclideStatusText.stabilityCaption(c.state), isNull);
      expect(NuclideStatusText.halfLifeCaption(c.state), 'Half-life:');
    });

    test('稳定核：Hydrogen - 1', () {
      final c = builtUp(1, 0);
      expect(NuclideStatusText.elementCaption(c.state), 'Hydrogen - 1');
      expect(NuclideStatusText.stabilityCaption(c.state), 'Stable');
      expect(NuclideStatusText.halfLifeCaption(c.state), 'Half-life: ∞');
    });

    test('不稳定核：Hydrogen - 3 + Unstable + 半衰期秒数', () {
      final c = builtUp(1, 2);
      expect(NuclideStatusText.elementCaption(c.state), 'Hydrogen - 3');
      expect(NuclideStatusText.stabilityCaption(c.state), 'Unstable');
      expect(NuclideStatusText.halfLifeCaption(c.state),
          'Half-life: 3.9 x 10^8 s');
    });

    test('未知半衰期：H-4 → Unknown', () {
      final c = builtUp(1, 3);
      expect(c.state.halfLifeNumber, -1);
      expect(NuclideStatusText.halfLifeCaption(c.state), 'Half-life: Unknown');
    });

    test('0p1n 自由中子：1 neutron（存在，非 does not form）', () {
      final c = builtUp(0, 1);
      expect(c.state.nuclideExists, isTrue);
      expect(NuclideStatusText.elementCaption(c.state), '1 neutron');
      expect(NuclideStatusText.stabilityCaption(c.state), isNotNull);
    });

    test('无效核素 (0,2)：N neutrons does not form', () {
      final c = builtUp(0, 1);
      c.addNeutron();
      c.state.settleAll();
      expect(c.state.isShowingInvalidNuclide, isTrue);
      expect(NuclideStatusText.elementCaption(c.state), '2 neutrons does not form');
      expect(NuclideStatusText.stabilityCaption(c.state), isNull);
      expect(NuclideStatusText.halfLifeCaption(c.state), 'Half-life:');
    });

    test('Be-6 特例中间态 2p0n：Helium - 2 does not form', () {
      final c = builtUp(4, 2);
      c.state.applyDecay(
        NucleusDecayType.alphaDecay,
        escapeX: 0,
        escapeY: 10000,
      );
      expect(c.state.protonCount, 2);
      expect(c.state.neutronCount, 0);
      expect(
        NuclideStatusText.elementCaption(c.state),
        'Helium - 2 does not form',
      );
      expect(NuclideStatusText.stabilityCaption(c.state), isNull);
    });
  });

  group('Widget：核素状态显示', () {
    Future<BuildANucleusController> pump(
        WidgetTester tester, BuildANucleusController c) async {
      await tester.pumpWidget(
          MaterialApp(home: BuildANucleusScreen(controller: c)));
      await tester.pump();
      return c;
    }

    testWidgets('初始：元素名为空、计数 0、无稳定性、半衰期仅标签、符号为 -', (tester) async {
      final c = await pump(tester, BuildANucleusController(repository: repo));
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('ban_element_name'))).data,
        '',
      );
      expect(find.text('质子: 0'), findsOneWidget);
      expect(find.text('中子: 0'), findsOneWidget);
      expect(find.text('Stable'), findsNothing);
      expect(find.text('Half-life:'), findsOneWidget);
      expect(find.text('Unknown'), findsNothing);
      expect(find.text('∞'), findsNothing);
      expect(find.byKey(const ValueKey('ban_symbol')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('ban_element_symbol'))).data,
        '-',
      );
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('ban_mass_number'))).data,
        '0',
      );
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('ban_atomic_number'))).data,
        '0',
      );
      expect(c.state.isEmptyNucleus, isTrue);
    });

    testWidgets('稳定核 H-1：名称、Stable、符号 H、Z/A、半衰期 Stable', (tester) async {
      final c = await pump(tester, builtUp(1, 0));
      expect(find.text('Hydrogen - 1'), findsOneWidget);
      expect(find.text('Stable'), findsOneWidget);
      expect(find.text('∞'), findsOneWidget);
      expect(find.text('Unknown'), findsNothing);
      expect(find.text('质子: 1'), findsOneWidget);
      expect(find.text('中子: 0'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('ban_element_symbol'))).data,
        'H',
      );
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('ban_atomic_number'))).data,
        '1',
      );
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('ban_mass_number'))).data,
        '1',
      );
      expect(c.state.isStable, isTrue);
    });

    testWidgets('不稳定核 H-3：Unstable + 半衰期科学计数', (tester) async {
      await pump(tester, builtUp(1, 2));
      expect(find.text('Hydrogen - 3'), findsOneWidget);
      expect(find.text('Unstable'), findsOneWidget);
      expect(find.textContaining('Half-life:'), findsWidgets);
      expect(find.text('Unknown'), findsNothing);
      expect(find.text('∞'), findsNothing);
    });

    testWidgets('无效核素 UI：does not form，稳定性与半衰期隐藏', (tester) async {
      final c = builtUp(0, 1);
      c.addNeutron();
      c.state.settleAll();
      await pump(tester, c);
      expect(find.text('2 neutrons does not form'), findsOneWidget);
      expect(find.text('Stable'), findsNothing);
      expect(find.text('Unstable'), findsNothing);
      expect(find.text('Half-life:'), findsOneWidget);
      expect(find.text('Unknown'), findsNothing);
      expect(find.text('∞'), findsNothing);
    });

    testWidgets('Be-6 α 后 2p0n：Helium - 2 does not form 可见', (tester) async {
      final c = builtUp(4, 2);
      await pump(tester, c);
      c.applyDecay(NucleusDecayType.alphaDecay);
      await tester.pump();
      expect(find.text('Helium - 2 does not form'), findsOneWidget);
      expect(find.text('Half-life:'), findsOneWidget);
      expect(find.text('Stable'), findsNothing);
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('ban_element_symbol'))).data,
        'He',
      );
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('ban_atomic_number'))).data,
        '2',
      );
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('ban_mass_number'))).data,
        '2',
      );
    });

    testWidgets('质子/中子计数随添加变化', (tester) async {
      final c = await pump(tester, BuildANucleusController(repository: repo));
      c.addProton();
      for (var i = 0; i < 400 && c.state.hasIncomingParticles; i++) {
        await tester.pump();
      }
      expect(find.text('质子: 1'), findsOneWidget);
      c.addNeutron();
      for (var i = 0; i < 400 && c.state.hasIncomingParticles; i++) {
        await tester.pump();
      }
      expect(find.text('中子: 1'), findsOneWidget);
      expect(find.text('Hydrogen - 2'), findsOneWidget);
    });

    testWidgets('Reset 后 UI 回到初始', (tester) async {
      final c = await pump(tester, builtUp(2, 2));
      expect(find.text('Helium - 4'), findsOneWidget);
      c.reset();
      await tester.pump();
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('ban_element_name'))).data,
        '',
      );
      expect(find.text('质子: 0'), findsOneWidget);
      expect(find.text('中子: 0'), findsOneWidget);
      expect(find.text('Stable'), findsNothing);
      expect(find.text('Half-life:'), findsOneWidget);
    });

    testWidgets('未知半衰期 H-4：Half-life: Unknown', (tester) async {
      await pump(tester, builtUp(1, 3));
      expect(find.text('Hydrogen - 4'), findsOneWidget);
      expect(find.text('Unstable'), findsOneWidget);
      expect(find.text('Unknown'), findsOneWidget);
      expect(find.text('∞'), findsNothing);
    });

    testWidgets('Undo 后 UI 恢复 parent 核素', (tester) async {
      final c = await pump(tester, builtUp(1, 2));
      expect(find.text('Hydrogen - 3'), findsOneWidget);
      c.applyDecay(NucleusDecayType.betaMinusDecay);
      await tester.pump();
      expect(find.text('Helium - 3'), findsOneWidget);
      c.undoDecay();
      await tester.pump();
      expect(find.text('Hydrogen - 3'), findsOneWidget);
      expect(find.text('Unstable'), findsOneWidget);
    });
  });
}
