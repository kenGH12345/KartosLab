import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gravity_force_lab/audio/gfl_audio.dart';
import 'package:kratos/gravity_force_lab/model/force_values_display.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_constants.dart';
import 'package:kratos/gravity_force_lab/model/gravity_force_lab_model.dart';
import 'package:kratos/gravity_force_lab/screens/gfl_screen_body.dart';

/// Phase 7 — Final Visual QA goldens (768×464 ScreenView, DPR 1).
///
/// Gold Standard references (PhET asset screenshots):
/// `phet sourses/gravity-force-lab-main/.../assets/gravity-force-lab-screenshot*.png`
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const layout = Size(
    GravityForceConstants.layoutWidth,
    GravityForceConstants.layoutHeight,
  );

  Future<void> pumpBody(
    WidgetTester tester,
    GravityForceLabModel model,
  ) async {
    final audio = GflAudio(playEnabled: false);
    addTearDown(() async {
      await audio.dispose();
      model.dispose();
    });

    await tester.binding.setSurfaceSize(layout);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox(
            width: layout.width,
            height: layout.height,
            child: MediaQuery(
              data: MediaQueryData(
                size: layout,
                devicePixelRatio: 1,
                textScaler: TextScaler.linear(1),
              ),
              child: GflScreenBody(model: model, audio: audio),
            ),
          ),
        ),
      ),
    );
    // Allow puller Image.asset decode.
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 80));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> expectGolden(
    WidgetTester tester,
    String name,
  ) async {
    await expectLater(
      find.byType(GflScreenBody),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  testWidgets('golden_default', (tester) async {
    final m = GravityForceLabModel();
    await pumpBody(tester, m);
    await expectGolden(tester, 'golden_default');
  });

  testWidgets('golden_constant_size', (tester) async {
    final m = GravityForceLabModel()..setConstantRadius(true);
    await pumpBody(tester, m);
    await expectGolden(tester, 'golden_constant_size');
  });

  testWidgets('golden_scientific', (tester) async {
    final m = GravityForceLabModel()
      ..setMassValue(2, 700)
      ..setForceValuesDisplay(ForceValuesDisplay.scientific);
    await pumpBody(tester, m);
    await expectGolden(tester, 'golden_scientific');
  });

  testWidgets('golden_hidden', (tester) async {
    final m = GravityForceLabModel()
      ..setConstantRadius(true)
      ..setMassValue(1, 1000)
      ..setMassValue(2, 250)
      ..setPosition(1, -0.5)
      ..setPosition(2, 0.6)
      ..setForceValuesDisplay(ForceValuesDisplay.hidden);
    await pumpBody(tester, m);
    await expectGolden(tester, 'golden_hidden');
  });

  testWidgets('golden_ruler_moved', (tester) async {
    final m = GravityForceLabModel()..setRulerPosition(1.0, 0.5);
    await pumpBody(tester, m);
    await expectGolden(tester, 'golden_ruler_moved');
  });

  testWidgets('golden_mass_moved', (tester) async {
    final m = GravityForceLabModel()
      ..setPosition(1, -4.0)
      ..setPosition(2, 2.0);
    await pumpBody(tester, m);
    await expectGolden(tester, 'golden_mass_moved');
  });

  testWidgets('golden_high_force', (tester) async {
    final m = GravityForceLabModel()
      ..setConstantRadius(true)
      ..setMassValue(1, 1000)
      ..setMassValue(2, 1000)
      ..setPosition(1, -0.6)
      ..setPosition(2, 0.6);
    await pumpBody(tester, m);
    await expectGolden(tester, 'golden_high_force');
  });

  testWidgets('golden_low_force', (tester) async {
    final m = GravityForceLabModel()
      ..setMassValue(1, 10)
      ..setMassValue(2, 10)
      ..setPosition(1, -5)
      ..setPosition(2, 5);
    await pumpBody(tester, m);
    await expectGolden(tester, 'golden_low_force');
  });
}
