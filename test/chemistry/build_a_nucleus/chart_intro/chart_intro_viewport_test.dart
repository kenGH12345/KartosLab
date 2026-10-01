import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/chart_intro/controller/chart_intro_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/chart_intro/model/chart_intro_state.dart';
import 'package:kratos/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/screens/build_a_nucleus_home.dart';
import 'package:kratos/chemistry/build_a_nucleus/screens/chart_intro_screen.dart';

/// Phase 2I-1：多视口 overflow + Dialog / Tab 生命周期。不建 golden。
void main() {
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    repo = NuclideRepository(
      NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  });

  Future<void> pumpAt(
    WidgetTester tester,
    Size size,
    ChartIntroController c,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: RepaintBoundary(
            key: const ValueKey('chart_intro_visual_qa_root'),
            child: ChartIntroScreen(controller: c, tickOnClock: false),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('视口：Partial / Zoom 无 overflow，图例与按钮仍在', (tester) async {
    const sizes = <Size>[
      Size(1024, 768),
      Size(1280, 800),
      Size(1366, 1024),
      Size(640, 360),
    ];
    for (final size in sizes) {
      final c = ChartIntroController(repository: repo);
      await pumpAt(tester, size, c);
      expect(tester.takeException(), isNull, reason: '$size partial overflow');
      expect(find.byKey(const ValueKey('chart_intro_chart_title')), findsOneWidget);
      expect(find.text('Stable'), findsWidgets, reason: '$size legend');
      expect(find.byKey(const ValueKey('chart_intro_full_chart')), findsOneWidget);
      expect(find.byKey(const ValueKey('chart_intro_reset')), findsOneWidget);

      await tester.ensureVisible(find.byKey(const ValueKey('chart_intro_chart_zoom')));
      await tester.tap(find.byKey(const ValueKey('chart_intro_chart_zoom')));
      await tester.pump();
      expect(c.state.selectedChart, ChartIntroChartType.zoom);
      expect(tester.takeException(), isNull, reason: '$size zoom overflow');
      expect(find.byType(IgnorePointer), findsWidgets);
      expect(find.byKey(const ValueKey('chart_intro_full_chart')), findsOneWidget);
      if (size == const Size(1280, 800)) {
        await _captureChartIntroTypography(tester, c);
      }
      c.dispose();
    }
  });

  testWidgets('640×360 打开 Full Chart Dialog 可滚动关闭', (tester) async {
    final c = ChartIntroController(repository: repo);
    await pumpAt(tester, const Size(640, 360), c);
    await tester.ensureVisible(find.byKey(const ValueKey('chart_intro_full_chart')));
    await tester.tap(find.byKey(const ValueKey('chart_intro_full_chart')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('chart_intro_full_chart_dialog')), findsOneWidget);
    expect(c.state.selectedChart, ChartIntroChartType.partial);

    await tester.tap(find.byKey(const ValueKey('chart_intro_full_chart_close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('chart_intro_full_chart_dialog')), findsNothing);
    c.dispose();
  });

  testWidgets('离开 Screen / 切走 Tab 时 dispose 关闭 Dialog，不改 chart state', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final chart = ChartIntroController(repository: repo);
    addTearDown(chart.dispose);
    chart.selectChart(ChartIntroChartType.zoom);

    await tester.pumpWidget(
      MaterialApp(
        home: ChartIntroScreen(controller: chart, tickOnClock: false),
      ),
    );
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('chart_intro_full_chart')));
    await tester.tap(find.byKey(const ValueKey('chart_intro_full_chart')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('chart_intro_full_chart_dialog')), findsOneWidget);

    // TabBar 在 modal barrier 下点不到；切 Tab 会 dispose 本屏，与直接卸树等价。
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(find.byKey(const ValueKey('chart_intro_full_chart_dialog')), findsNothing);
    expect(chart.state.selectedChart, ChartIntroChartType.zoom);
  });

  testWidgets('Dialog 关闭后 Tab 仍可切换', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
    await tester.tap(find.byType(Tab).at(1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('chart_intro_add_proton')), findsOneWidget);

    await tester.tap(find.byType(Tab).at(0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('ban_add_proton')), findsOneWidget);
  });

  testWidgets('Chart Intro 进入→动画→Dialog→卸树 ×5，无 overlay / 无后台 tick', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (var i = 0; i < 5; i++) {
      final c = ChartIntroController(repository: repo);
      await tester.pumpWidget(
        MaterialApp(
          home: ChartIntroScreen(controller: c, tickOnClock: false),
        ),
      );
      await tester.pump();
      c.addProton();
      await tester.pump();
      expect(c.fades.hasActive, isTrue);

      await tester.ensureVisible(find.byKey(const ValueKey('chart_intro_full_chart')));
      await tester.tap(find.byKey(const ValueKey('chart_intro_full_chart')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('chart_intro_full_chart_dialog')), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(find.byKey(const ValueKey('chart_intro_full_chart_dialog')), findsNothing);
      expect(find.byKey(const ValueKey('chart_intro_screen')), findsNothing);

      final frozen = c.shellRender.protonColumn.nucleons.single.opacity;
      await tester.pump(const Duration(seconds: 2));
      expect(
        c.shellRender.protonColumn.nucleons.single.opacity,
        frozen,
        reason: '第 $i 次卸树后 Clock 不得再推进 fade',
      );
      c.dispose();
    }
  });
}

/// C-12：元素名 / 周期表 / 符号 / Zoom Stable 都有字。不增用例。
Future<void> _captureChartIntroTypography(
  WidgetTester tester,
  ChartIntroController c,
) async {
  // C-12 稳定：元素名 / 周期表 / 符号都有字。
  // 不用 C-14：DecayEquationSymbol 的 A/Z 列 15+2.25+15>30，
  // 是既有 minHeight 当固定高，不是本阶段字号改动。
  c.state.restoreNucleonCounts(6, 6);
  c.chartFocus.sync(
    protonCount: 6,
    neutronCount: 6,
    exists: c.state.nuclideExists,
  );
  c.selectChart(ChartIntroChartType.partial);
  await tester.pump();
  expect(tester.takeException(), isNull);

  final outDir = Directory(
    'requirements/req-build-a-nucleus/visual-qa/chart-intro',
  );
  outDir.createSync(recursive: true);

  Future<void> writeShot(String name) async {
    await _writePng(tester, '${outDir.path}/$name.png');
    File('${outDir.path}/$name.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'viewport': {
          'logical': {'w': 1280, 'h': 800},
          'dpr': 1.0,
        },
        'state': {
          'protons': c.state.protonCount,
          'neutrons': c.state.neutronCount,
          'chart': c.state.selectedChart.name,
        },
        'rects_logical': _collectChartIntroRects(tester),
      }),
    );
  }

  c.selectChart(ChartIntroChartType.partial);
  await tester.pump();
  await writeShot('flutter_chart_intro_c12_partial');

  await tester.ensureVisible(find.byKey(const ValueKey('chart_intro_chart_zoom')));
  await tester.tap(find.byKey(const ValueKey('chart_intro_chart_zoom')));
  await tester.pump();
  await writeShot('flutter_chart_intro_c12_zoom');

  await tester.ensureVisible(find.byKey(const ValueKey('chart_intro_full_chart')));
  await tester.tap(find.byKey(const ValueKey('chart_intro_full_chart')));
  await tester.pumpAndSettle();
  await writeShot('flutter_chart_intro_c12_dialog');
  await tester.tap(find.byKey(const ValueKey('chart_intro_full_chart_close')));
  await tester.pumpAndSettle();
}

Map<String, Map<String, double>> _collectChartIntroRects(WidgetTester tester) {
  const keys = <String, ValueKey<String>>{
    'element': ValueKey('chart_intro_element'),
    'chartTitle': ValueKey('chart_intro_chart_title'),
    'chart': ValueKey('chart_intro_chart'),
    'periodicTable': ValueKey('chart_intro_periodic_table'),
    'isotopeSymbol': ValueKey('chart_intro_isotope_symbol'),
    'decayEquation': ValueKey('chart_intro_decay_equation'),
    'decayPercent': ValueKey('chart_intro_decay_percent'),
    'decayStable': ValueKey('chart_intro_decay_stable'),
    'fullChart': ValueKey('chart_intro_full_chart'),
    'fullChartTitle': ValueKey('chart_intro_full_chart_title'),
    'fullChartInfo': ValueKey('chart_intro_full_chart_info'),
    'protonCount': ValueKey('chart_intro_proton_count'),
    'neutronCount': ValueKey('chart_intro_neutron_count'),
    'decayButton': ValueKey('chart_intro_decay_button'),
    'reset': ValueKey('chart_intro_reset'),
    'partial': ValueKey('chart_intro_chart_partial'),
    'zoom': ValueKey('chart_intro_chart_zoom'),
  };
  final out = <String, Map<String, double>>{};
  for (final e in keys.entries) {
    final f = find.byKey(e.value);
    if (f.evaluate().isEmpty) continue;
    final r = tester.getRect(f);
    out[e.key] = {
      'x': r.left,
      'y': r.top,
      'w': r.width,
      'h': r.height,
      'cx': r.center.dx,
      'cy': r.center.dy,
    };
  }
  return out;
}

Future<void> _writePng(WidgetTester tester, String path) async {
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('chart_intro_visual_qa_root')),
    );
    final image = await boundary.toImage(pixelRatio: 1.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
