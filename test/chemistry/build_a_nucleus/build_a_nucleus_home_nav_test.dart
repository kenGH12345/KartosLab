import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/chart_intro/controller/chart_intro_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/screens/build_a_nucleus_home.dart';
import 'package:kratos/chemistry/build_a_nucleus/screens/build_a_nucleus_screen.dart';
import 'package:kratos/chemistry/build_a_nucleus/screens/chart_intro_screen.dart';
import 'package:kratos/screens/home_screen.dart';

/// Home → Tab → 返回。屏内 SimulationClock 常开，不能 pumpAndSettle。
void main() {
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    repo = NuclideRepository(
      NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  });

  Future<void> setDesktop(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> flushLoad(WidgetTester tester) async {
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 80));
    });
    await tester.pump();
    await tester.pump();
  }

  Future<void> finishTabAnimation(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> pumpUntil(
    WidgetTester tester,
    Finder f, {
    int frames = 40,
  }) async {
    for (var i = 0; i < frames; i++) {
      if (f.evaluate().isNotEmpty) return;
      await flushLoad(tester);
    }
    fail('未找到 $f');
  }

  testWidgets('主页进入 Build a Nucleus：默认 Decay Tab，可返回', (tester) async {
    await setDesktop(tester);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    final card = find.text('构建原子核');
    expect(card, findsOneWidget);
    await tester.ensureVisible(card);
    await tester.pump();
    await tester.tap(card);
    await tester.pump();

    await pumpUntil(tester, find.byType(BuildANucleusHome));
    expect(find.text(BuildANucleusHome.decayTabLabel), findsOneWidget);
    expect(find.text(BuildANucleusHome.chartIntroTabLabel), findsOneWidget);
    expect(find.byType(BuildANucleusScreen), findsOneWidget);
    await pumpUntil(tester, find.byKey(const ValueKey('ban_add_proton')));

    await tester.pageBack();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(BuildANucleusHome), findsNothing);
    expect(find.text('构建原子核'), findsOneWidget);
  });

  testWidgets('Decay ↔ Chart Intro（注入 Controller）：两 Tab 可切换', (tester) async {
    await setDesktop(tester);
    final decay = BuildANucleusController(repository: repo);
    final chart = ChartIntroController(repository: repo);
    addTearDown(decay.dispose);
    addTearDown(chart.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: BuildANucleusHome(
          decayController: decay,
          chartIntroController: chart,
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('ban_add_proton')), findsOneWidget);

    await tester.tap(find.byType(Tab).at(1));
    await finishTabAnimation(tester);
    expect(find.byKey(const ValueKey('chart_intro_add_proton')), findsOneWidget);
    expect(chart.state.protonCount, 0);

    await tester.tap(find.byKey(const ValueKey('chart_intro_add_proton')));
    await tester.pump();
    expect(chart.state.protonCount, 1);

    await tester.tap(find.byType(Tab).at(0));
    await finishTabAnimation(tester);
    expect(find.byKey(const ValueKey('ban_add_proton')), findsOneWidget);

    await tester.tap(find.byType(Tab).at(1));
    await finishTabAnimation(tester);
    expect(find.byKey(const ValueKey('chart_intro_add_proton')), findsOneWidget);
    expect(chart.state.protonCount, 1);
  });

  testWidgets('ChartIntroScreen 重建：新 Controller 从 0p0n 开始', (tester) async {
    await setDesktop(tester);
    final first = ChartIntroController(repository: repo);
    await tester.pumpWidget(
      MaterialApp(
        home: ChartIntroScreen(controller: first, tickOnClock: false),
      ),
    );
    await tester.pump();
    first.addProton();
    await tester.pump();
    expect(first.state.protonCount, 1);
    first.dispose();

    final second = ChartIntroController(repository: repo);
    await tester.pumpWidget(
      MaterialApp(
        home: ChartIntroScreen(controller: second, tickOnClock: false),
      ),
    );
    await tester.pump();
    expect(second.state.protonCount, 0);
    expect(find.text('Protons: 0'), findsWidgets);
    second.dispose();
  });

  testWidgets('Chart Intro 初始化 0p0n；加减与 fade；Reset', (tester) async {
    await setDesktop(tester);
    final c = ChartIntroController(repository: repo);
    await tester.pumpWidget(
      MaterialApp(
        home: ChartIntroScreen(controller: c, tickOnClock: false),
      ),
    );
    await tester.pump();
    expect(c.state.isEmptyNucleus, isTrue);
    expect(find.byType(ChartIntroScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('chart_intro_chart')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('chart_intro_add_proton')));
    await tester.pump();
    expect(c.state.protonCount, 1);
    expect(c.fades.hasActive, isTrue);
    expect(c.shellRender.protonColumn.nucleons.single.opacity, 0);
    c.tick(1);
    await tester.pump();
    expect(c.shellRender.protonColumn.nucleons.single.opacity, 1);

    await tester.tap(find.byKey(const ValueKey('chart_intro_reset')));
    await tester.pump();
    expect(c.state.isEmptyNucleus, isTrue);
    expect(c.fades.hasActive, isFalse);
    c.dispose();
  });

  testWidgets('离开 Screen 后 Clock 不再推进 fade', (tester) async {
    await setDesktop(tester);
    final c = ChartIntroController(repository: repo);
    await tester.pumpWidget(
      MaterialApp(home: ChartIntroScreen(controller: c)),
    );
    await tester.pump();
    c.addProton();
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump();
    final frozen = c.shellRender.protonColumn.nucleons.single.opacity;

    await tester.pump(const Duration(seconds: 2));
    expect(
      c.shellRender.protonColumn.nucleons.single.opacity,
      frozen,
      reason: 'Clock 已 dispose，不应再改 opacity',
    );
    expect(c.state.isDisposed, isFalse);
    expect(c.tick(0.5), isTrue);
    c.dispose();
  });

  testWidgets('多次进入/退出 Home：再进入仍是默认 Decay Tab', (tester) async {
    await setDesktop(tester);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    Future<void> openBan() async {
      final card = find.text('构建原子核');
      await tester.ensureVisible(card);
      await tester.tap(card);
      await tester.pump();
      await pumpUntil(tester, find.byType(BuildANucleusHome));
      await finishTabAnimation(tester);
      expect(find.byType(BuildANucleusScreen), findsOneWidget);
      expect(find.text(BuildANucleusHome.decayTabLabel), findsOneWidget);
      expect(find.text(BuildANucleusHome.chartIntroTabLabel), findsOneWidget);
    }

    await openBan();
    await tester.pageBack();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(HomeScreen), findsOneWidget);

    await openBan();
    expect(find.byType(BuildANucleusScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pump();
  });
}
