/// MAGNET M5-1 · visual baseline capture only.
///
/// Does not modify Magnet implementation. Writes PNG + JSON under
/// `requirements/project-migration/visual-qa/magnet/`.
///
/// Viewport: Pixel Tablet landscape · 2560×1600 @ DPR 2 → logical 1280×800.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/widgets/nine_grid_layout.dart';
import 'package:kratos/magnetism/magnet_and_compass/painters/bar_magnet_painter.dart';
import 'package:kratos/magnetism/magnet_and_compass/painters/compass_painter.dart';
import 'package:kratos/magnetism/magnet_and_compass/painters/field_needle_painter.dart';
import 'package:kratos/magnetism/magnet_and_compass/screens/magnet_and_compass_screen.dart';
import 'package:kratos/magnetism/magnet_and_compass/widgets/control_panel.dart';
import 'package:kratos/magnetism/magnet_and_compass/widgets/field_meter.dart';
import 'package:kratos/magnetism/magnet_and_compass/widgets/mini_compass_preview_painter.dart';

import '../../phet/magnet_and_compass/lib/main.dart' as phet_magnet;

const _outDir = 'requirements/project-migration/visual-qa/magnet';

const _viewport = {
  'label': 'Pixel Tablet landscape',
  'physical': {'w': 2560, 'h': 1600},
  'logical': {'w': 1280, 'h': 800},
  'dpr': 2.0,
  'orientation': 'landscape',
};

void main() {
  testWidgets('M5-1 capture original phet SimulationPage + Flutter target',
      (tester) async {
    tester.view.physicalSize = const Size(2560, 1600);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dir = Directory(_outDir)..createSync(recursive: true);
    Directory('${dir.path}/screenshots').createSync(recursive: true);

    // ── Original standalone (phet/magnet_and_compass) ──
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('visual_qa_root'),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          home: const phet_magnet.SimulationPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final originalOverflow = _drainOverflow(tester);

    await _writePng(tester, '${dir.path}/screenshots/original_default.png');
    final originalDefaultRects = _collectOriginal(tester);

    await tester.tap(find.byType(Checkbox).at(4));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    originalOverflow.addAll(_drainOverflow(tester));
    await _writePng(tester, '${dir.path}/screenshots/original_field_meter.png');
    final originalMeterRects = _collectOriginal(tester);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));

    // ── Flutter target ──
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('visual_qa_root'),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1177AA),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF6FAFC),
            useMaterial3: true,
          ),
          home: const MagnetAndCompassScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final flutterOverflow = _drainOverflow(tester);

    await _writePng(tester, '${dir.path}/screenshots/flutter_default.png');
    final flutterDefaultRects = _collectFlutter(tester);

    // Magnet moved — drag from body, not center (panel can cover center).
    final magnet = _paint((p) => p is BarMagnetPainter);
    final magnetRect = tester.getRect(magnet);
    await tester.dragFrom(
      magnetRect.centerLeft + const Offset(24, 0),
      const Offset(-140, 70),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    flutterOverflow.addAll(_drainOverflow(tester));
    await _writePng(tester, '${dir.path}/screenshots/flutter_magnet_moved.png');
    final flutterMovedRects = _collectFlutter(tester);

    // Field meter on (do not tap Earth).
    await tester.tap(find.byType(Checkbox).at(4));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    flutterOverflow.addAll(_drainOverflow(tester));
    await _writePng(tester, '${dir.path}/screenshots/flutter_field_meter.png');
    final flutterMeterRects = _collectFlutter(tester);

    final mq = MediaQuery.of(
      tester.element(find.byType(MagnetAndCompassScreen)),
    );

    final payload = {
      'environment': {
        ..._viewport,
        'mediaQuerySize': {'w': mq.size.width, 'h': mq.size.height},
        'viewPadding': {
          'top': mq.viewPadding.top,
          'right': mq.viewPadding.right,
          'bottom': mq.viewPadding.bottom,
          'left': mq.viewPadding.left,
        },
        'padding': {
          'top': mq.padding.top,
          'right': mq.padding.right,
          'bottom': mq.padding.bottom,
          'left': mq.padding.left,
        },
        'capture_host': 'flutter_test WidgetTester (not a physical device)',
        'theme_original': 'ThemeData.dark() — matches phet MagnetApp',
        'theme_flutter':
            'KratosApp seed 0xFF1177AA / Material 3 light — current app theme',
        'flutter_as_home':
            'MagnetAndCompassScreen is MaterialApp.home; AppBar leading back is absent because the route cannot pop. Home is not wired.',
      },
      'overflow': {
        'note':
            '~55px Slider row overflow is a pre-existing Legacy B issue. Not fixed in M5-1.',
        'classification': '[已有问题：Legacy implementation]',
        'original': originalOverflow,
        'flutter': flutterOverflow,
      },
      'earth': {
        'status': '[无法验证：missing earth.svg]',
        'tapped': false,
        'asset': 'assets/earth.svg',
      },
      'original_ran': true,
      'rects': {
        'original_default': originalDefaultRects,
        'original_field_meter': originalMeterRects,
        'flutter_default': flutterDefaultRects,
        'flutter_magnet_moved': flutterMovedRects,
        'flutter_field_meter': flutterMeterRects,
      },
    };

    File('${dir.path}/rects.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(payload),
    );

    expect(originalDefaultRects['canvas'], isNotNull);
    expect(flutterDefaultRects['canvas'], isNotNull);
    expect(flutterDefaultRects['appBar'], isNotNull);
    expect(flutterDefaultRects['nineGrid'], isNotNull);
    expect(flutterDefaultRects['magnet'], isNotNull);
    expect(flutterDefaultRects['compass'], isNotNull);
    expect(flutterMeterRects['fieldMeter'], isNotNull);
  });
}

Finder _paint(bool Function(CustomPainter? p) pred) => find.byWidgetPredicate(
      (w) => w is CustomPaint && pred(w.painter),
    );

Map<String, double> _box(Rect r) => {
      'x': r.left,
      'y': r.top,
      'w': r.width,
      'h': r.height,
      'cx': r.center.dx,
      'cy': r.center.dy,
      'right': r.right,
      'bottom': r.bottom,
    };

void _putTester(
  WidgetTester tester,
  Map<String, Map<String, double>> out,
  String key,
  Finder f,
) {
  if (f.evaluate().isEmpty) return;
  out[key] = _box(tester.getRect(f));
}

Map<String, Map<String, double>> _collectOriginal(WidgetTester tester) {
  final out = <String, Map<String, double>>{};
  _putTester(
    tester,
    out,
    'fullWindow',
    find.byKey(const ValueKey('visual_qa_root')),
  );
  _putTester(tester, out, 'scaffold', find.byType(Scaffold));
  _putTester(
    tester,
    out,
    'canvas',
    _paint((p) => p is phet_magnet.FieldNeedlePainter),
  );
  _putTester(
    tester,
    out,
    'magnet',
    _paint((p) => p is phet_magnet.BarMagnetPainter),
  );
  _putTester(
    tester,
    out,
    'compass',
    _paint((p) => p is phet_magnet.CompassPainter),
  );
  _putTester(
    tester,
    out,
    'controlPanel',
    find.byWidgetPredicate(
      (w) => w is SizedBox && w.width == 230 && w.child is Column,
    ),
  );
  _putTester(tester, out, 'resetCircle', _resetCircle());
  _putTester(tester, out, 'resetIcon', find.byIcon(Icons.refresh));
  _putTester(tester, out, 'slider', find.byType(Slider));
  _putTester(
    tester,
    out,
    'flipPolarity',
    find.widgetWithText(ElevatedButton, 'Flip Polarity'),
  );
  _putTester(tester, out, 'labelBarMagnet', find.text('Bar Magnet'));
  _putTester(tester, out, 'labelStrength', find.text('Strength:'));
  _putTester(tester, out, 'label0', find.text('0%'));
  _putTester(tester, out, 'label50', find.text('50%'));
  _putTester(tester, out, 'label100', find.text('100%'));
  _putTester(tester, out, 'labelMagneticField', find.text('Magnetic Field (B)'));
  _putTester(tester, out, 'labelSeeInside', find.text('See Inside'));
  _putTester(tester, out, 'labelEarth', find.text('Earth'));
  _putTester(tester, out, 'labelCompass', find.text('Compass'));
  _putTester(tester, out, 'labelFieldMeter', find.text('Field Meter'));
  _putTester(tester, out, 'btnArrowLeft', find.byIcon(Icons.arrow_left));
  _putTester(tester, out, 'btnArrowRight', find.byIcon(Icons.arrow_right));
  _putTester(tester, out, 'fieldMeterText', find.textContaining('B ='));
  _putCheckboxes(tester, out);
  _deriveCenters(out);
  return out;
}

Map<String, Map<String, double>> _collectFlutter(WidgetTester tester) {
  final out = <String, Map<String, double>>{};
  _putTester(
    tester,
    out,
    'fullWindow',
    find.byKey(const ValueKey('visual_qa_root')),
  );
  _putTester(tester, out, 'scaffold', find.byType(Scaffold));
  _putTester(tester, out, 'appBar', find.byType(AppBar));
  _putTester(tester, out, 'nineGrid', find.byType(NineGridLayout));
  _putTester(
    tester,
    out,
    'canvas',
    _paint((p) => p is FieldNeedlePainter),
  );
  _putTester(
    tester,
    out,
    'magnet',
    _paint((p) => p is BarMagnetPainter),
  );
  _putTester(
    tester,
    out,
    'compass',
    _paint((p) => p is CompassPainter),
  );
  _putTester(
    tester,
    out,
    'miniCompass',
    _paint((p) => p is MiniCompassPreviewPainter),
  );
  _putTester(tester, out, 'controlPanel', find.byType(MagnetControlPanel));
  _putTester(tester, out, 'fieldMeter', find.byType(FieldMeter));
  _putTester(tester, out, 'resetCircle', _resetCircle());
  _putTester(tester, out, 'resetIcon', find.byIcon(Icons.refresh));
  _putTester(tester, out, 'slider', find.byType(Slider));
  _putTester(
    tester,
    out,
    'flipPolarity',
    find.widgetWithText(ElevatedButton, 'Flip Polarity'),
  );
  _putTester(tester, out, 'labelBarMagnet', find.text('Bar Magnet'));
  _putTester(tester, out, 'labelStrength', find.text('Strength:'));
  _putTester(tester, out, 'label0', find.text('0%'));
  _putTester(tester, out, 'label50', find.text('50%'));
  _putTester(tester, out, 'label100', find.text('100%'));
  _putTester(tester, out, 'labelMagneticField', find.text('Magnetic Field (B)'));
  _putTester(tester, out, 'labelSeeInside', find.text('See Inside'));
  _putTester(tester, out, 'labelEarth', find.text('Earth'));
  _putTester(tester, out, 'labelCompass', find.text('Compass'));
  _putTester(tester, out, 'labelFieldMeter', find.text('Field Meter'));
  _putTester(tester, out, 'labelAppBarTitle', find.text('磁铁与罗盘'));
  _putTester(tester, out, 'btnArrowLeft', find.byIcon(Icons.arrow_left));
  _putTester(tester, out, 'btnArrowRight', find.byIcon(Icons.arrow_right));
  _putCheckboxes(tester, out);
  _deriveCenters(out);

  final canvas = out['canvas'];
  final magnet = out['magnet'];
  final compass = out['compass'];
  final panel = out['controlPanel'];
  final meter = out['fieldMeter'];
  final reset = out['resetCircle'];
  if (canvas != null) {
    out['canvasLocalOrigin'] = {
      'x': canvas['x']!,
      'y': canvas['y']!,
      'w': 0,
      'h': 0,
      'cx': canvas['x']!,
      'cy': canvas['y']!,
    };
    void local(String name, Map<String, double>? r) {
      if (r == null) return;
      out['${name}_canvasLocal'] = {
        'x': r['x']! - canvas['x']!,
        'y': r['y']! - canvas['y']!,
        'w': r['w']!,
        'h': r['h']!,
        'cx': r['cx']! - canvas['x']!,
        'cy': r['cy']! - canvas['y']!,
      };
    }

    local('magnet', magnet);
    local('compass', compass);
    local('controlPanel', panel);
    local('fieldMeter', meter);
    local('resetCircle', reset);
  }
  return out;
}

void _putCheckboxes(
  WidgetTester tester,
  Map<String, Map<String, double>> out,
) {
  final boxes = find.byType(Checkbox);
  final n = boxes.evaluate().length;
  out['checkboxCount'] = {'x': 0, 'y': 0, 'w': n.toDouble(), 'h': 0};
  for (var i = 0; i < n; i++) {
    out['checkbox_$i'] = _box(tester.getRect(boxes.at(i)));
  }
}

void _deriveCenters(Map<String, Map<String, double>> out) {
  for (final key in ['magnet', 'compass', 'fieldMeter', 'canvas']) {
    final r = out[key];
    if (r == null) continue;
    out['${key}Center'] = {
      'x': r['cx']!,
      'y': r['cy']!,
      'w': 0,
      'h': 0,
      'cx': r['cx']!,
      'cy': r['cy']!,
    };
  }
}

Finder _resetCircle() => find.byWidgetPredicate((w) {
      if (w is! Container) return false;
      final d = w.decoration;
      if (d is! BoxDecoration) return false;
      return d.shape == BoxShape.circle && d.color == const Color(0xffe65100);
    });

List<String> _drainOverflow(WidgetTester tester) {
  final notes = <String>[];
  Object? error;
  while ((error = tester.takeException()) != null) {
    final s = error.toString();
    expect(s, contains('overflowed'), reason: 'unexpected exception: $error');
    final match = RegExp(r'overflowed by ([\d.]+) pixels').firstMatch(s);
    notes.add(match != null ? match.group(0)! : s.split('\n').first);
  }
  return notes;
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
