import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/ban_timescale_points.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/half_life_number_line.dart';
import 'package:kratos/chemistry/build_a_nucleus/widgets/half_life_information_view.dart';
import 'package:kratos/chemistry/build_a_nucleus/widgets/half_life_stability_legend.dart';

/// Phase 1G-3B-4：less/more stable、info 按钮与 Timescale dialog。
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

  Widget host(HalfLifeNumberLineReading reading, {String elementName = ''}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 550,
            child: HalfLifeInformationView(
              reading: reading,
              elementName: elementName,
            ),
          ),
        ),
      ),
    );
  }

  Widget liveHost(
    ValueNotifier<HalfLifeNumberLineReading> reading, {
    String elementName = '',
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 550,
            child: ValueListenableBuilder<HalfLifeNumberLineReading>(
              valueListenable: reading,
              builder: (_, r, child) => HalfLifeInformationView(
                reading: r,
                elementName: elementName,
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('timescale 数据（源码秒数）', () {
    test('A–J 秒数与字母', () {
      expect(BanTimescalePoints.timeForLightToCrossANucleus.seconds, 1e-23);
      expect(BanTimescalePoints.timeForLightToCrossAnAtomPoint.seconds, 1e-19);
      expect(
        BanTimescalePoints.timeForLightToCrossOneThousandAtoms.seconds,
        1e-16,
      );
      expect(BanTimescalePoints.timeForSoundToTravelOneMillimeter.seconds, 2e-6);
      expect(BanTimescalePoints.aBlinkOfAnEye.seconds, closeTo(1 / 3, 1e-12));
      expect(BanTimescalePoints.oneMinute.seconds, 60);
      expect(BanTimescalePoints.oneYear.seconds, 365 * 24 * 60 * 60);
      expect(BanTimescalePoints.all, hasLength(10));
      expect(BanTimescalePoints.all.first.marker, 'A');
      expect(BanTimescalePoints.all.last.marker, 'J');
    });
  });

  group('less / more stable：纯视觉常量', () {
    testWidgets('文案固定，不随半衰期变化', (tester) async {
      Future<void> check(HalfLifeNumberLineReading r) async {
        await tester.pumpWidget(host(r));
        expect(find.text(HalfLifeStabilityLegend.lessStable), findsOneWidget);
        expect(find.text(HalfLifeStabilityLegend.moreStable), findsOneWidget);
        expect(find.byKey(const ValueKey('ban_half_life_info_button')),
            findsOneWidget);
      }

      await check(fromNuclide(1, 0)); // Stable
      await check(fromNuclide(1, 3)); // Unknown
      await check(HalfLifeNumberLine.fromValues(
        halfLifeNumber: 0,
        isStable: false,
      )); // Nonexistent
      await check(fromNuclide(1, 2)); // H-3
      await check(fromNuclide(6, 8)); // C-14
      await check(HalfLifeNumberLine.fromValues(
        halfLifeNumber: 1e-30,
        isStable: false,
      ));
      await check(HalfLifeNumberLine.fromValues(
        halfLifeNumber: 1e30,
        isStable: false,
      ));
    });
  });

  Future<void> pumpOpen(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('ban_half_life_info_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> pumpClosed(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('info button + dialog', () {
    testWidgets('点击打开；标题与图例为原版字符串', (tester) async {
      await tester.pumpWidget(host(fromNuclide(1, 2), elementName: 'Hydrogen - 3'));
      expect(find.byKey(const ValueKey('ban_half_life_info_dialog')),
          findsNothing);

      await pumpOpen(tester);

      expect(find.byKey(const ValueKey('ban_half_life_info_dialog')),
          findsOneWidget);
      expect(find.text('Half-Life Timescale'), findsOneWidget);
      expect(find.text('Time for light to cross a nucleus'), findsOneWidget);
      expect(find.text('Lifetime of longest lived stars'), findsOneWidget);
      expect(find.text('Hydrogen - 3'), findsWidgets);
      expect(find.byKey(const ValueKey('ban_half_life_timescale_A')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('ban_half_life_timescale_J')),
          findsOneWidget);
    });

    testWidgets('关闭按钮关闭 dialog', (tester) async {
      await tester.pumpWidget(host(fromNuclide(1, 2)));
      await pumpOpen(tester);
      await tester.tap(find.byKey(const ValueKey('ban_half_life_info_close')));
      await pumpClosed(tester);
      expect(find.byKey(const ValueKey('ban_half_life_info_dialog')),
          findsNothing);
    });

    testWidgets('点击 barrier 关闭', (tester) async {
      await tester.pumpWidget(host(fromNuclide(1, 2)));
      await pumpOpen(tester);
      await tester.tapAt(const Offset(4, 4));
      await pumpClosed(tester);
      expect(find.byKey(const ValueKey('ban_half_life_info_dialog')),
          findsNothing);
    });

    testWidgets('Reset 后 dialog 仍开，读数只留标签', (tester) async {
      final reading = ValueNotifier(fromNuclide(1, 2));
      addTearDown(reading.dispose);
      await tester.pumpWidget(
        liveHost(reading, elementName: 'Hydrogen - 3'),
      );
      await pumpOpen(tester);
      expect(find.text('3.9'), findsWidgets);

      reading.value = HalfLifeNumberLine.fromState(
        BuildANucleusController(repository: repo).state,
      );
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const ValueKey('ban_half_life_info_dialog')),
          findsOneWidget);
      expect(find.text('Unknown'), findsNothing);
      expect(find.text('∞'), findsNothing);
    });

    testWidgets('页面退出时关闭 dialog（不泄漏 overlay）', (tester) async {
      await tester.pumpWidget(host(fromNuclide(1, 2)));
      await pumpOpen(tester);
      expect(find.byKey(const ValueKey('ban_half_life_info_dialog')),
          findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(find.byKey(const ValueKey('ban_half_life_info_dialog')),
          findsNothing);
    });

    testWidgets('Stable / Unknown / Nonexistent 下 info 都可打开', (tester) async {
      for (final r in [
        fromNuclide(1, 0),
        fromNuclide(1, 3),
        HalfLifeNumberLine.fromValues(halfLifeNumber: 0, isStable: false),
      ]) {
        await tester.pumpWidget(host(r));
        await pumpOpen(tester);
        expect(find.text('Half-Life Timescale'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('ban_half_life_info_close')));
        await pumpClosed(tester);
      }
    });
  });
}
