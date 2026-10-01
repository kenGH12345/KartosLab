import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/diffusion/diffusion_constants.dart';
import 'package:kratos/diffusion/model/diffusion_model.dart';
import 'package:kratos/diffusion/widgets/diffusion_shell.dart';
import 'package:kratos/gas_properties/controller/gas_simulation_controller.dart';
import 'package:kratos/gas_properties/model/hold_constant.dart';
import 'package:kratos/gas_properties/model/ideal_gas_law_model.dart';
import 'package:kratos/gas_properties/model/random_source.dart';
import 'package:kratos/gas_properties/transform/gas_coordinate_transform.dart';
import 'package:kratos/gas_properties/widgets/gas_ideal_family_shell.dart';

/// Phase 4.1 K7 — golden PNGs under test/gas_properties/goldens_k7/
/// Diffusion goldens use unmodified `lib/diffusion` DiffusionShell.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpShell(WidgetTester tester, Widget child) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: SizedBox(
              width: GasLayoutPolicy.logicalWidth,
              height: GasLayoutPolicy.logicalHeight,
              child: child,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> pumpDiffusion(WidgetTester tester, DiffusionModel model) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: SizedBox(
              width: DiffusionConstants.layoutWidth,
              height: DiffusionConstants.layoutHeight,
              child: DiffusionShell(model: model),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }
  testWidgets('ideal initial golden', (tester) async {
    final c = GasSimulationController(
      profile: IdealGasProfile.ideal,
      random: RandomSource(1),
      autoTick: false,
    );
    addTearDown(c.dispose);
    await pumpShell(tester, GasIdealFamilyShell(controller: c, layoutScale: 1));
    await expectLater(
      find.byType(GasIdealFamilyShell),
      matchesGoldenFile('goldens_k7/ideal_initial.png'),
    );
  });

  testWidgets('ideal hold_temperature golden', (tester) async {
    final c = GasSimulationController(
      profile: IdealGasProfile.ideal,
      random: RandomSource(1),
      autoTick: false,
    );
    addTearDown(c.dispose);
    c.setNumberHeavy(80);
    c.setNumberLight(40);
    c.setHoldConstant(HoldConstant.temperature);
    c.model.advance(0.2);
    c.setStopwatchVisible(false);
    await pumpShell(tester, GasIdealFamilyShell(controller: c, layoutScale: 1));
    await expectLater(
      find.byType(GasIdealFamilyShell),
      matchesGoldenFile('goldens_k7/ideal_hold_temperature.png'),
    );
  });

  testWidgets('explore initial golden', (tester) async {
    final c = GasSimulationController(
      profile: IdealGasProfile.explore,
      random: RandomSource(2),
      autoTick: false,
    );
    addTearDown(c.dispose);
    await pumpShell(tester, GasIdealFamilyShell(controller: c, layoutScale: 1));
    await expectLater(
      find.byType(GasIdealFamilyShell),
      matchesGoldenFile('goldens_k7/explore_initial.png'),
    );
  });

  testWidgets('explore moving_wall golden', (tester) async {
    final c = GasSimulationController(
      profile: IdealGasProfile.explore,
      random: RandomSource(2),
      autoTick: false,
    );
    addTearDown(c.dispose);
    c.setNumberHeavy(60);
    c.setWallVelocityVisible(true);
    c.beginWidthAdjust();
    c.setWidthDuringAdjust(7500);
    await pumpShell(tester, GasIdealFamilyShell(controller: c, layoutScale: 1));
    await expectLater(
      find.byType(GasIdealFamilyShell),
      matchesGoldenFile('goldens_k7/explore_moving_wall.png'),
    );
    c.endWidthAdjust();
  });

  testWidgets('energy initial golden', (tester) async {
    final c = GasSimulationController(
      profile: IdealGasProfile.energy,
      random: RandomSource(3),
      autoTick: false,
    );
    addTearDown(c.dispose);
    await pumpShell(tester, GasIdealFamilyShell(controller: c, layoutScale: 1));
    await expectLater(
      find.byType(GasIdealFamilyShell),
      matchesGoldenFile('goldens_k7/energy_initial.png'),
    );
  });

  testWidgets('energy histogram_populated golden', (tester) async {
    final c = GasSimulationController(
      profile: IdealGasProfile.energy,
      random: RandomSource(3),
      autoTick: false,
    );
    addTearDown(c.dispose);
    c.setNumberHeavy(100);
    c.setNumberLight(80);
    for (var i = 0; i < 20; i++) {
      c.model.advance(0.2);
    }
    c.setStopwatchVisible(false);
    await pumpShell(tester, GasIdealFamilyShell(controller: c, layoutScale: 1));
    await expectLater(
      find.byType(GasIdealFamilyShell),
      matchesGoldenFile('goldens_k7/energy_histogram_populated.png'),
    );
  });

  testWidgets('diffusion initial golden', (tester) async {
    final m = DiffusionModel(autoTick: false);
    addTearDown(m.dispose);
    m.setLeftCount(40);
    m.setRightCount(40);
    m.setCenterOfMassVisible(true);
    await pumpDiffusion(tester, m);
    await expectLater(
      find.byType(DiffusionShell),
      matchesGoldenFile('goldens_k7/diffusion_initial.png'),
    );
  });

  testWidgets('diffusion partition_removed golden', (tester) async {
    final m = DiffusionModel(autoTick: false);
    addTearDown(m.dispose);
    m.setLeftCount(40);
    m.setRightCount(40);
    m.setHasDivider(false);
    m.setParticleFlowRateVisible(true);
    m.setCenterOfMassVisible(true);
    for (var i = 0; i < 30; i++) {
      m.stepModelTime(0.2);
    }
    m.setCenterOfMassVisible(true);
    await pumpDiffusion(tester, m);
    await expectLater(
      find.byType(DiffusionShell),
      matchesGoldenFile('goldens_k7/diffusion_partition_removed.png'),
    );
  });
}
