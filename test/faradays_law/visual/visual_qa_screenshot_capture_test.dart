import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/faradays_law_constants.dart';
import 'package:kratos/faradays_law/model/faradays_law_model.dart';
import 'package:kratos/faradays_law/view/faradays_law_play_area.dart';

/// Captures Flutter visual-QA PNGs (not golden-pixel gate).
///
/// Output: `requirements/req-faradays-law/visual-qa/screenshots/`
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const outDir = 'requirements/req-faradays-law/visual-qa/screenshots';
  const viewport = Size(834, 504);

  Future<void> capture(
    WidgetTester tester,
    String name,
    FaradaysLawModel model,
  ) async {
    Directory(outDir).createSync(recursive: true);
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(FaradaysLawConstants.backgroundColorValue),
          body: Center(
            child: SizedBox(
              width: viewport.width,
              height: viewport.height,
              child: RepaintBoundary(
                key: key,
                child: FaradaysLawPlayArea(
                  model: model,
                  autoStartClock: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('$outDir/$name.png');
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      // ignore: avoid_print
      print('CAPTURED $name (${file.lengthSync()} bytes)');
    });
  }

  testWidgets('capture A initial', (tester) async {
    await capture(tester, 'A_initial', FaradaysLawModel());
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('capture C 2-coil', (tester) async {
    final model = FaradaysLawModel()..setTopCoilVisible(true);
    await capture(tester, 'C_two_coil', model);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('capture D SN polarity', (tester) async {
    final model = FaradaysLawModel()..flipPolarity();
    await capture(tester, 'D_polarity_SN', model);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('capture E field lines ON', (tester) async {
    final model = FaradaysLawModel()..setFieldLinesVisible(true);
    await capture(tester, 'E_field_lines_ON', model);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('capture F voltmeter ON', (tester) async {
    final model = FaradaysLawModel()..setVoltmeterVisible(true);
    await capture(tester, 'F_voltmeter_ON', model);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('capture H combined', (tester) async {
    final model = FaradaysLawModel()
      ..setTopCoilVisible(true)
      ..setFieldLinesVisible(true)
      ..setVoltmeterVisible(true)
      ..flipPolarity()
      ..setMagnetPositionForTest(const Offset(500, 250));
    model.voltmeter.voltage = 0.5;
    await capture(tester, 'H_combined', model);
  }, timeout: const Timeout(Duration(seconds: 20)));

  testWidgets('capture reset after combined', (tester) async {
    final model = FaradaysLawModel()
      ..setTopCoilVisible(true)
      ..setFieldLinesVisible(true)
      ..setVoltmeterVisible(true)
      ..flipPolarity();
    model.reset();
    await capture(tester, 'H_reset_initial', model);
  }, timeout: const Timeout(Duration(seconds: 20)));
}
