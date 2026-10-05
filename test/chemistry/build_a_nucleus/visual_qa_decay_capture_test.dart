/// FINAL-VISUAL 第一步：Decay 首屏截图 + Widget 几何量测。
///
/// 固定视口：Pixel Tablet landscape · 2560×1600 @ DPR 2.0 → 逻辑 1280×800。
/// 不改业务逻辑。写出 PNG / JSON 供叠图对照。
library;

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/ban_constants.dart';
import 'package:kratos/chemistry/build_a_nucleus/controller/build_a_nucleus_controller.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_repository.dart';
import 'package:kratos/chemistry/build_a_nucleus/data/nuclide_table.dart';
import 'package:kratos/chemistry/build_a_nucleus/screens/build_a_nucleus_home.dart';

void main() {
  late final NuclideRepository repo;

  setUpAll(() {
    final jsonStr = File('assets/data/nuclide_table.json').readAsStringSync();
    repo = NuclideRepository(
      NuclideTable.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>),
    );
  });

  testWidgets('Decay 首屏 Pixel Tablet 截图与几何', (tester) async {
    tester.view.physicalSize = const Size(2560, 1600);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final c = BuildANucleusController(repository: repo);
    final outDir = Directory(
      'requirements/req-build-a-nucleus/visual-qa/decay-first',
    );
    outDir.createSync(recursive: true);

    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: const ValueKey('visual_qa_root'),
          child: BuildANucleusHome(decayController: c),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final emptyRects = _collectRects(tester);
    await _writePng(tester, '${outDir.path}/flutter_decay_empty.png');
    File('${outDir.path}/flutter_decay_empty_rects.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'viewport': {
          'label': 'Pixel Tablet landscape',
          'physical': {'w': 2560, 'h': 1600},
          'logical': {'w': 1280, 'h': 800},
          'dpr': 2.0,
        },
        'state': {'protons': 0, 'neutrons': 0},
        'rects_logical': emptyRects,
      }),
    );

    // 沿「已存在核素」路径加到 Fe-69。不能连加质子：中间不存在核会禁用箭头。
    _populateExisting(c, 26, 43);
    c.notifyListeners();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    final feRects = _collectRects(tester);
    await _writePng(tester, '${outDir.path}/flutter_decay_fe69.png');
    File('${outDir.path}/flutter_decay_fe69_rects.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'viewport': {
          'label': 'Pixel Tablet landscape',
          'physical': {'w': 2560, 'h': 1600},
          'logical': {'w': 1280, 'h': 800},
          'dpr': 2.0,
        },
        'state': {
          'protons': c.state.protonCount,
          'neutrons': c.state.neutronCount,
        },
        'rects_logical': feRects,
      }),
    );

    expect(c.state.protonCount, 26);
    expect(c.state.neutronCount, 43);
    expect(find.byKey(const ValueKey('ban_canvas')), findsOneWidget);
    expect(emptyRects['appBar'], isNotNull);
    expect(feRects['canvas'], isNotNull);
    expect(BanConstants.atomCenterXForLayout(1024), closeTo(1024 / 3, 1e-9));
    expect(
      BanConstants.halfLifeInformationCenterXForLayout(1024),
      closeTo(15 + 30 + 550 / 2, 1e-9),
    );
    final canvas = feRects['canvas']!;
    final scale = canvas['w']! / BanConstants.screenViewLayoutWidth;
    expect(
      feRects['nucleusCenter']!['cx']!,
      closeTo(canvas['x']! + canvas['w']! / 3, 4),
    );
    expect(
      feRects['generatorUnion']!['cx']!,
      closeTo(canvas['x']! + canvas['w']! / 3, 24),
    );
    expect(find.byKey(const ValueKey('ban_decay_right_column')), findsOneWidget);
    expect(feRects['protonCount']!['cx']!, lessThan(feRects['symbol']!['cx']!));
    expect(feRects['protonCount']!['cx']!, greaterThan(canvas['cx']!));
    expect(
      feRects['availableDecaysPanel']!['w']!,
      greaterThan(280 * scale),
    );
    expect(
      feRects['decayButtonsUnion']!['y']!,
      greaterThan(feRects['symbol']!['y']! + feRects['symbol']!['h']!),
    );
    expect(feRects['stability']!['cy']!, lessThan(feRects['elementName']!['cy']!));
    expect(
      feRects['elementName']!['y']! + feRects['elementName']!['h']!,
      lessThan(feRects['nucleusCenter']!['cy']!),
    );
    final labelAnchorX = canvas['x']! +
        BanConstants.halfLifeInformationCenterXForLayout(1024) * scale;
    expect(feRects['elementName']!['cx']!, closeTo(labelAnchorX, 12));
    expect(feRects['stability']!['cx']!, closeTo(labelAnchorX, 12));
    expect(feRects['elementName']!['cx']!, closeTo(feRects['stability']!['cx']!, 1));
    c.dispose();
  });
}

/// 只走 canAdd* 为真的步，不改 State API。
void _populateExisting(BuildANucleusController c, int protons, int neutrons) {
  var guard = 0;
  while ((c.state.protonCount < protons || c.state.neutronCount < neutrons) &&
      guard++ < 400) {
    final needP = c.state.protonCount < protons;
    final needN = c.state.neutronCount < neutrons;
    if (needP && needN && c.state.canAddPair) {
      c.state.addPair();
    } else if (needP && c.state.canAddProton) {
      c.state.addProton();
    } else if (needN && c.state.canAddNeutron) {
      c.state.addNeutron();
    } else {
      break;
    }
    c.state.settleAll();
  }
}

Map<String, Map<String, double>> _collectRects(WidgetTester tester) {
  final finders = <String, Finder>{
    'appBar': find.byType(AppBar),
    'tabBar': find.byType(TabBar),
    'canvas': find.byKey(const ValueKey('ban_canvas')),
    'halfLifeInformation': find.byKey(const ValueKey('ban_half_life_information')),
    'halfLifeNumberLine': find.byKey(const ValueKey('ban_half_life_number_line')),
    'halfLifeReadout': find.byKey(const ValueKey('ban_half_life_readout')),
    'stabilityLegend': find.byKey(const ValueKey('ban_half_life_stability_legend')),
    'elementName': find.byKey(const ValueKey('ban_element_name')),
    'stability': find.byKey(const ValueKey('ban_stability')),
    'decayRightColumn': find.byKey(const ValueKey('ban_decay_right_column')),
    'availableDecaysPanel':
        find.byKey(const ValueKey('ban_available_decays_panel')),
    'availableDecaysTitle':
        find.byKey(const ValueKey('ban_available_decays_title')),
    'symbol': find.byKey(const ValueKey('ban_symbol')),
    'protonCount': find.byKey(const ValueKey('ban_proton_count')),
    'neutronCount': find.byKey(const ValueKey('ban_neutron_count')),
    'electronCloudCheckbox': find.byKey(const ValueKey('ban_electron_cloud_checkbox')),
    'reset': find.byKey(const ValueKey('ban_reset')),
    'nucleonCreators': find.byKey(const ValueKey('ban_nucleon_creators')),
    'creatorLabelProton':
        find.byKey(const ValueKey('ban_creator_label_proton')),
    'creatorLabelNeutron':
        find.byKey(const ValueKey('ban_creator_label_neutron')),
    'addProton': find.byKey(const ValueKey('ban_add_proton')),
    'removeProton': find.byKey(const ValueKey('ban_remove_proton')),
    'addPair': find.byKey(const ValueKey('ban_add_pair')),
    'removePair': find.byKey(const ValueKey('ban_remove_pair')),
    'addNeutron': find.byKey(const ValueKey('ban_add_neutron')),
    'removeNeutron': find.byKey(const ValueKey('ban_remove_neutron')),
    'decayAlpha': find.byKey(const ValueKey('ban_decay_alphaDecay')),
    'decayBetaMinus': find.byKey(const ValueKey('ban_decay_betaMinusDecay')),
    'decayBetaPlus': find.byKey(const ValueKey('ban_decay_betaPlusDecay')),
    'decayProton': find.byKey(const ValueKey('ban_decay_protonEmission')),
    'decayNeutron': find.byKey(const ValueKey('ban_decay_neutronEmission')),
  };

  final out = <String, Map<String, double>>{};
  for (final e in finders.entries) {
    if (e.value.evaluate().isEmpty) continue;
    final r = tester.getRect(e.value);
    out[e.key] = {
      'x': r.left,
      'y': r.top,
      'w': r.width,
      'h': r.height,
      'cx': r.center.dx,
      'cy': r.center.dy,
    };
  }

  final decayKeys = [
    const ValueKey('ban_decay_alphaDecay'),
    const ValueKey('ban_decay_betaMinusDecay'),
    const ValueKey('ban_decay_betaPlusDecay'),
    const ValueKey('ban_decay_protonEmission'),
    const ValueKey('ban_decay_neutronEmission'),
  ];
  Rect? decayUnion;
  for (final k in decayKeys) {
    final f = find.byKey(k);
    if (f.evaluate().isEmpty) continue;
    final r = tester.getRect(f);
    decayUnion = decayUnion == null ? r : decayUnion.expandToInclude(r);
  }
  if (decayUnion != null) {
    out['decayButtonsUnion'] = {
      'x': decayUnion.left,
      'y': decayUnion.top,
      'w': decayUnion.width,
      'h': decayUnion.height,
      'cx': decayUnion.center.dx,
      'cy': decayUnion.center.dy,
    };
  }

  final creatorKeys = [find.byKey(const ValueKey('ban_add_proton')), find.byKey(const ValueKey('ban_add_neutron'))];
  if (creatorKeys.every((f) => f.evaluate().isNotEmpty)) {
    var u = tester.getRect(creatorKeys.first);
    for (final f in [
      find.byKey(const ValueKey('ban_remove_proton')),
      find.byKey(const ValueKey('ban_add_pair')),
      find.byKey(const ValueKey('ban_remove_pair')),
      find.byKey(const ValueKey('ban_add_neutron')),
      find.byKey(const ValueKey('ban_remove_neutron')),
    ]) {
      if (f.evaluate().isNotEmpty) u = u.expandToInclude(tester.getRect(f));
    }
    out['generatorUnion'] = {
      'x': u.left,
      'y': u.top,
      'w': u.width,
      'h': u.height,
      'cx': u.center.dx,
      'cy': u.center.dy,
    };
  }

  final canvas = out['canvas'];
  if (canvas != null) {
    // FittedBox 舞台即 layoutBounds：局部原点 (W/3, H×0.55)
    final origin = Offset(
      canvas['w']! / 3,
      canvas['h']! * BanConstants.atomCenterYFactor,
    );
    out['nucleusCenter'] = {
      'x': canvas['x']! + origin.dx,
      'y': canvas['y']! + origin.dy,
      'w': 0,
      'h': 0,
      'cx': canvas['x']! + origin.dx,
      'cy': canvas['y']! + origin.dy,
    };
  }
  return out;
}

Future<void> _writePng(WidgetTester tester, String path) async {
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('visual_qa_root')),
    );
    final image = await boundary.toImage(pixelRatio: 2.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
