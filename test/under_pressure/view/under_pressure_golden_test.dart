import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/under_pressure/controller/under_pressure_controller.dart';
import 'package:kratos/under_pressure/model/under_pressure_model.dart';
import 'package:kratos/under_pressure/model/under_pressure_units.dart';
import 'package:kratos/under_pressure/transform/up_mvt.dart';
import 'package:kratos/under_pressure/view/controls/up_control_slider.dart';
import 'package:kratos/under_pressure/under_pressure_strings.dart';
import 'package:kratos/under_pressure/view/under_pressure_screen.dart';
import 'package:kratos/under_pressure/view/up_cement_pattern.dart';

/// Phase 4 goldens — fixed 768×504, DPR 1, textScale 1.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpUp(
    WidgetTester tester,
    UnderPressureController c, {
    UnderPressureScene? scene,
  }) async {
    if (scene != null) c.setScene(scene);
    await tester.runAsync(() => UpCementPattern.ensureLoaded());
    await tester.binding.setSurfaceSize(
      const Size(UpMvt.layoutWidth, UpMvt.layoutHeight),
    );
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox(
            width: UpMvt.layoutWidth,
            height: UpMvt.layoutHeight,
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(UpMvt.layoutWidth, UpMvt.layoutHeight),
                devicePixelRatio: 1,
                textScaler: TextScaler.linear(1),
              ),
              child: UnderPressureScreen(controller: c),
            ),
          ),
        ),
      ),
    );
    // Allow Image.asset / cement decode to settle.
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('Scene goldens', () {
    testWidgets('square_initial', (tester) async {
      final c = UnderPressureController();
      addTearDown(c.dispose);
      await pumpUp(tester, c, scene: UnderPressureScene.square);
      await expectLater(
        find.byType(UnderPressureScreen),
        matchesGoldenFile('goldens/square_initial.png'),
      );
    });

    testWidgets('trapezoid_initial', (tester) async {
      final c = UnderPressureController();
      addTearDown(c.dispose);
      await pumpUp(tester, c, scene: UnderPressureScene.trapezoid);
      await expectLater(
        find.byType(UnderPressureScreen),
        matchesGoldenFile('goldens/trapezoid_initial.png'),
      );
    });

    testWidgets('chamber_initial', (tester) async {
      final c = UnderPressureController();
      addTearDown(c.dispose);
      await pumpUp(tester, c, scene: UnderPressureScene.chamber);
      await expectLater(
        find.byType(UnderPressureScreen),
        matchesGoldenFile('goldens/chamber_initial.png'),
      );
    });

    testWidgets('mystery_initial', (tester) async {
      final c = UnderPressureController();
      addTearDown(c.dispose);
      await pumpUp(tester, c, scene: UnderPressureScene.mystery);
      await expectLater(
        find.byType(UnderPressureScreen),
        matchesGoldenFile('goldens/mystery_initial.png'),
      );
    });
  });

  group('Control / state goldens', () {
    testWidgets('atmosphere_off', (tester) async {
      final c = UnderPressureController();
      addTearDown(c.dispose);
      c.setAtmosphere(false);
      await pumpUp(tester, c);
      await expectLater(
        find.byType(UnderPressureScreen),
        matchesGoldenFile('goldens/atmosphere_off.png'),
      );
    });

    testWidgets('ruler_grid_on', (tester) async {
      final c = UnderPressureController();
      addTearDown(c.dispose);
      c.setRulerVisible(true);
      c.setGridVisible(true);
      await pumpUp(tester, c);
      await expectLater(
        find.byType(UnderPressureScreen),
        matchesGoldenFile('goldens/ruler_grid_on.png'),
      );
    });

    testWidgets('units_english', (tester) async {
      final c = UnderPressureController();
      addTearDown(c.dispose);
      c.setUnits(MeasureUnits.english);
      c.setGridVisible(true);
      await pumpUp(tester, c);
      await expectLater(
        find.byType(UnderPressureScreen),
        matchesGoldenFile('goldens/units_english.png'),
      );
    });

    testWidgets('accordion_density_collapsed', (tester) async {
      final c = UnderPressureController();
      addTearDown(c.dispose);
      c.setDensityExpanded(false);
      await pumpUp(tester, c);
      await expectLater(
        find.byType(UnderPressureScreen),
        matchesGoldenFile('goldens/accordion_density_collapsed.png'),
      );
    });

    testWidgets('faucet_open_square', (tester) async {
      final c = UnderPressureController();
      addTearDown(c.dispose);
      c.setInputFlow(0.7);
      await pumpUp(tester, c);
      await expectLater(
        find.byType(UnderPressureScreen),
        matchesGoldenFile('goldens/faucet_open_square.png'),
      );
    });

    testWidgets('chamber_mass_placed', (tester) async {
      final c = UnderPressureController();
      addTearDown(c.dispose);
      c.setScene(UnderPressureScene.chamber);
      final lo = c.model.chamber.leftOpening;
      final mass = c.model.chamber.masses[0];
      final dropY = lo.y2 + c.model.chamber.leftWaterHeight;
      c.beginMassDrag(0);
      c.updateMassCenter(
        0,
        Offset((lo.x1 + lo.x2) / 2, dropY + mass.height / 2),
      );
      c.endMassDrag(0);
      for (var i = 0; i < 90; i++) {
        c.model.step(1 / 60);
      }
      c.refreshSensors();
      await pumpUp(tester, c);
      await expectLater(
        find.byType(UnderPressureScreen),
        matchesGoldenFile('goldens/chamber_mass_placed.png'),
      );
    });

    testWidgets('mystery_dropdown_open', (tester) async {
      final c = UnderPressureController();
      addTearDown(c.dispose);
      await pumpUp(tester, c, scene: UnderPressureScene.mystery);
      await tester.tap(find.text(UnderPressureStrings.fluidA));
      await tester.pump();
      await expectLater(
        find.byType(UnderPressureScreen),
        matchesGoldenFile('goldens/mystery_dropdown_open.png'),
      );
    });

    testWidgets('control_slider_component', (tester) async {
      final c = UnderPressureController();
      addTearDown(c.dispose);
      await tester.binding.setSurfaceSize(const Size(160, 200));
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: UpControlSlider(
                controller: c,
                title: 'Fluid Density',
                value: c.model.fluidDensity,
                min: c.model.fluidDensityMin,
                max: c.model.fluidDensityMax,
                decimals: 0,
                displayString: c.model.getFluidDensityString(),
                expanded: true,
                onExpanded: (_) {},
                onChanged: c.setDensity,
                ticks: const [
                  (title: 'gasoline', value: 700),
                  (title: 'water', value: 1000),
                  (title: 'honey', value: 1420),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await expectLater(
        find.byType(UpControlSlider),
        matchesGoldenFile('goldens/control_slider_density.png'),
      );
    });
  });

  group('Visual chrome unit checks', () {
    test('cement asset path is original FPAF texture', () {
      expect(
        UpCementPattern.assetPath,
        'assets/simulations/under_pressure/images/cementTextureDark.jpg',
      );
    });

    testWidgets('accordion expand/collapse toggles without physics change',
        (tester) async {
      final c = UnderPressureController();
      addTearDown(c.dispose);
      final dens = c.model.fluidDensity;
      final grav = c.model.gravity;
      await pumpUp(tester, c);
      c.setDensityExpanded(false);
      await tester.pump();
      c.setDensityExpanded(true);
      await tester.pump();
      expect(c.model.fluidDensity, dens);
      expect(c.model.gravity, grav);
    });

    testWidgets('mystery list selects Fluid B density 840', (tester) async {
      final c = UnderPressureController();
      addTearDown(c.dispose);
      await pumpUp(tester, c, scene: UnderPressureScene.mystery);
      // Open dropdown (visual), then select via Model API (source ComboBox value).
      await tester.tap(find.text(UnderPressureStrings.fluidA));
      await tester.pump();
      expect(find.text(UnderPressureStrings.fluidB), findsWidgets);
      c.setMysteryFluidIndex(1);
      await tester.pump();
      expect(c.model.fluidDensity, 840);
    });
  });
}
