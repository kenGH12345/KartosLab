import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/charges_and_fields/model/charges_and_fields_model.dart';
import 'package:kratos/charges_and_fields/model/vec2.dart';
import 'package:kratos/charges_and_fields/screens/charges_and_fields_screen.dart';

/// Flutter Visual QA matrix. Uses [WidgetTester.runAsync] for toImage.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final arial = FontLoader('Arial')
      ..addFont(File(r'C:\Windows\Fonts\arial.ttf')
          .readAsBytes()
          .then((b) => ByteData.view(b.buffer)));
    await arial.load();
  });

  const outDir = 'requirements/req-charges-and-fields/visual-qa/FLUTTER';
  const viewport = Size(1024, 768);

  Future<void> settle(WidgetTester tester, [int n = 8]) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  Future<void> settlePotential(WidgetTester tester) async {
    // Dense WebGL-like potential Image builds async — wait beyond a few frames.
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 800));
    });
    await settle(tester, 20);
  }

  Future<void> capture(
    WidgetTester tester,
    String name,
    ChargesAndFieldsModel model,
    List<String> actions,
  ) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Arial', useMaterial3: false),
        home: Scaffold(
          backgroundColor: Colors.black,
          body: RepaintBoundary(
            key: key,
            child: SizedBox(
              width: viewport.width,
              height: viewport.height,
              child: ChargesAndFieldsScreen(
                model: model,
                autoStartClock: false,
              ),
            ),
          ),
        ),
      ),
    );
    await settle(tester, 12);
    if (model.isElectricPotentialVisible &&
        model.activeChargedParticles.isNotEmpty) {
      await settlePotential(tester);
    }

    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final bd = await image.toByteData(format: ui.ImageByteFormat.png);
      Directory(outDir).createSync(recursive: true);
      File('$outDir/$name.png').writeAsBytesSync(bd!.buffer.asUint8List());
      File('$outDir/$name.meta.txt').writeAsStringSync([
        'state: $name',
        'viewport: 1024x768',
        'DPR: 1',
        'actions: ${actions.join(',')}',
        'source: local-flutter-widget-test',
        'captured_at: ${DateTime.now().toUtc().toIso8601String()}',
      ].join('\n'));
    });
  }

  testWidgets('smoke: screen builds and shows controls', (tester) async {
    final model = ChargesAndFieldsModel();
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'Arial', useMaterial3: false),
        home: Scaffold(
          body: ChargesAndFieldsScreen(
            model: model,
            autoStartClock: false,
          ),
        ),
      ),
    );
    await settle(tester, 5);
    expect(find.text('Electric Field'), findsOneWidget);
    expect(find.text('+1 nC'), findsOneWidget);
  });

  testWidgets('capture flutter visual matrix', (tester) async {
    var model = ChargesAndFieldsModel();
    await capture(tester, '01_initial', model, ['initial']);

    model = ChargesAndFieldsModel();
    model.setParticleActive(model.addPositiveCharge(CafVec2.zero), true);
    await capture(tester, '02_positive_charge', model, ['+ at origin']);

    model = ChargesAndFieldsModel();
    model.setParticleActive(model.addNegativeCharge(CafVec2.zero), true);
    await capture(tester, '03_negative_charge', model, ['- at origin']);

    model = ChargesAndFieldsModel();
    model.setParticleActive(
      model.addPositiveCharge(const CafVec2(-1, 0)),
      true,
    );
    model.setParticleActive(
      model.addNegativeCharge(const CafVec2(1, 0)),
      true,
    );
    await capture(tester, '04_opposite_pair', model, ['dipole']);

    model.isElectricFieldDirectionOnly = true;
    await capture(tester, '05_direction_only', model, ['directionOnly']);

    model.isElectricFieldDirectionOnly = false;
    model.isElectricPotentialVisible = true;
    await capture(tester, '06_voltage_field', model, ['voltage']);

    model.isGridVisible = true;
    model.areValuesVisible = true;
    await capture(tester, '07_grid_values', model, ['grid+values']);

    final s = model.addElectricFieldSensor(const CafVec2(0, 1.5));
    s.isActive = true;
    s.update();
    await capture(tester, '08_efield_sensor', model, ['E sensor']);

    model.electricPotentialSensor.isActive = true;
    model.electricPotentialSensor.setPosition(const CafVec2(0, -1));
    model.addElectricPotentialLine(const CafVec2(0, -1));
    await capture(tester, '09_equipotential', model, ['equipotential']);

    model.reset();
    await capture(tester, '10_reset', model, ['reset']);
  });
}
