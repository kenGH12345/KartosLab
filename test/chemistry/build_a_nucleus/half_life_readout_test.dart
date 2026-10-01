import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/ban_constants.dart';
import 'package:kratos/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/half_life_number_line.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/half_life_readout.dart';
import 'package:kratos/chemistry/build_a_nucleus/widgets/half_life_number_line_view.dart';

/// Phase 1G-3B-3：半衰期读数条。锁文本内容，不对像素截图。
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

  HalfLifeNumberLineReading fromNuclide(int p, int n) =>
      HalfLifeNumberLine.fromState(builtUp(p, n).state);

  group('ScientificNotationNode 默认 1 位尾数', () {
    test('toExponential(1) 拆 mantissa / exponent，去 + 号', () {
      final n = HalfLifeReadoutContent.toScientificNotation(388781328);
      expect(n.mantissa, '3.9');
      expect(n.exponent, '8');
    });

    test('指数 0：只留尾数（showZeroExponent: false）', () {
      final n = HalfLifeReadoutContent.toScientificNotation(1.0);
      expect(n.mantissa, '1.0');
      expect(n.exponent, isNull);
    });

    test('超右端真值仍格式化（指针钉住不影响读数）', () {
      final n = HalfLifeReadoutContent.toScientificNotation(1e30);
      expect(n.mantissa, '1.0');
      expect(n.exponent, '30');
    });
  });

  group('从 Reading 格式化（不查表）', () {
    test('H-3', () {
      final r = fromNuclide(1, 2);
      expect(r.halfLifeSeconds, 388781328.0);
      final c = HalfLifeReadoutContent.fromReading(r);
      expect(c.kind, HalfLifeReadoutKind.seconds);
      expect(c.mantissa, '3.9');
      expect(c.exponent, '8');
      expect(c.captionLine, 'Half-life: 3.9 x 10^8 s');
    });

    test('C-14', () {
      final r = fromNuclide(6, 8);
      expect(r.halfLifeSeconds, 179874000000.0);
      final c = HalfLifeReadoutContent.fromReading(r);
      expect(c.mantissa, '1.8');
      expect(c.exponent, '11');
      expect(c.captionLine, 'Half-life: 1.8 x 10^11 s');
    });

    test('稳定核素 H-1：∞，无 Unknown / s', () {
      final c = HalfLifeReadoutContent.fromReading(fromNuclide(1, 0));
      expect(c.kind, HalfLifeReadoutKind.infinity);
      expect(c.showInfinity, isTrue);
      expect(c.showUnknown, isFalse);
      expect(c.showSeconds, isFalse);
      expect(c.captionLine, 'Half-life: ∞');
    });

    test('Unknown H-4', () {
      final c = HalfLifeReadoutContent.fromReading(fromNuclide(1, 3));
      expect(c.kind, HalfLifeReadoutKind.unknown);
      expect(c.captionLine, 'Half-life: Unknown');
    });

    test('Nonexistent / 空核：只留标签', () {
      final empty = HalfLifeNumberLine.fromValues(
        halfLifeNumber: BanConstants.nonexistentHalfLife,
        isStable: false,
      );
      expect(
        HalfLifeReadoutContent.fromReading(empty).captionLine,
        'Half-life:',
      );
      final nucleus = HalfLifeNumberLine.fromState(
        BuildANucleusController(repository: repo).state,
      );
      expect(
        HalfLifeReadoutContent.fromReading(nucleus).captionLine,
        'Half-life:',
      );
    });
  });

  Future<void> pumpLine(
    WidgetTester tester,
    HalfLifeNumberLineReading reading,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 480,
              child: HalfLifeNumberLineView(reading: reading),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('Widget 文本', () {
    testWidgets('标签始终在', (tester) async {
      await pumpLine(
        tester,
        HalfLifeNumberLine.fromValues(halfLifeNumber: 0, isStable: false),
      );
      expect(find.text('Half-life:'), findsOneWidget);
      expect(find.byKey(const ValueKey('ban_half_life_readout')), findsOneWidget);
    });

    testWidgets('H-3：3.9 x 10^8 s', (tester) async {
      await pumpLine(tester, fromNuclide(1, 2));
      expect(find.text('3.9'), findsOneWidget);
      expect(find.text('x 10'), findsOneWidget);
      expect(find.text('8'), findsWidgets);
      expect(find.text('s'), findsOneWidget);
      expect(find.text('Unknown'), findsNothing);
      expect(find.text('∞'), findsNothing);
    });

    testWidgets('C-14：1.8 x 10^11 s', (tester) async {
      await pumpLine(tester, fromNuclide(6, 8));
      expect(find.text('1.8'), findsOneWidget);
      expect(find.text('11'), findsOneWidget);
      expect(find.text('s'), findsOneWidget);
    });

    testWidgets('稳定：∞，无 s / Unknown', (tester) async {
      await pumpLine(tester, fromNuclide(1, 0));
      expect(find.text('∞'), findsOneWidget);
      expect(find.text('Unknown'), findsNothing);
      expect(find.text('s'), findsNothing);
      expect(
        find.byKey(const ValueKey('ban_half_life_readout_infinity')),
        findsOneWidget,
      );
    });

    testWidgets('Unknown：显示 Unknown', (tester) async {
      await pumpLine(tester, fromNuclide(1, 3));
      expect(find.text('Unknown'), findsOneWidget);
      expect(find.text('s'), findsNothing);
      expect(find.text('∞'), findsNothing);
    });

    testWidgets('Nonexistent / 空核：只有标签', (tester) async {
      await pumpLine(
        tester,
        HalfLifeNumberLine.fromValues(halfLifeNumber: 0, isStable: false),
      );
      expect(find.text('Half-life:'), findsOneWidget);
      expect(find.text('Unknown'), findsNothing);
      expect(find.text('∞'), findsNothing);
      expect(find.text('s'), findsNothing);
    });

    testWidgets('核素切换：H-3 → C-14 文本立即变', (tester) async {
      await pumpLine(tester, fromNuclide(1, 2));
      expect(find.text('3.9'), findsOneWidget);
      await pumpLine(tester, fromNuclide(6, 8));
      expect(find.text('1.8'), findsOneWidget);
      expect(find.text('3.9'), findsNothing);
    });

    testWidgets('Reset：有值 → 空核只留标签', (tester) async {
      await pumpLine(tester, fromNuclide(1, 2));
      expect(find.text('s'), findsOneWidget);
      final empty = HalfLifeNumberLine.fromState(
        BuildANucleusController(repository: repo).state,
      );
      await pumpLine(tester, empty);
      expect(find.text('Half-life:'), findsOneWidget);
      expect(find.text('s'), findsNothing);
      expect(find.text('Unknown'), findsNothing);
    });

    testWidgets('与 pointer 动画同时：读数立即是目标值', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 480,
                child: HalfLifeNumberLineView(
                  reading: HalfLifeNumberLine.fromValues(
                    halfLifeNumber: 1,
                    isStable: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('1.0'), findsOneWidget);
      expect(find.text('s'), findsOneWidget);
      expect(find.text('x 10'), findsNothing);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 480,
                child: HalfLifeNumberLineView(reading: fromNuclide(1, 2)),
              ),
            ),
          ),
        ),
      );
      // 不 pump 满 0.7s：读数已是 H-3，指针仍在动画中。
      await tester.pump();
      expect(find.text('3.9'), findsOneWidget);
      expect(find.text('8'), findsWidgets);
      expect(find.text('s'), findsOneWidget);
      expect(find.text('1.0'), findsNothing);
    });
  });
}
