import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/widgets/kratos_phet_time_control.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/gas_properties/controller/gas_simulation_controller.dart';
import 'package:kratos/gas_properties/model/ideal_gas_law_model.dart';
import 'package:kratos/gas_properties/model/random_source.dart';
import 'package:kratos/gas_properties/widgets/gas_ideal_family_shell.dart';
import 'package:kratos/gases_intro/widgets/instrument_controls.dart';
import 'package:kratos/gases_intro/widgets/instruments.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpShell(WidgetTester tester) async {
    final c = GasSimulationController(
      profile: IdealGasProfile.ideal,
      random: RandomSource(1),
      autoTick: false,
    );
    addTearDown(c.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 1008,
              height: 618,
              child: GasIdealFamilyShell(controller: c, layoutScale: 1),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('Gas Properties shares Intro chrome: Reset / Time / pump / heater',
      (tester) async {
    await pumpShell(tester);
    expect(find.byType(KratosResetAllButton), findsOneWidget);
    expect(find.byKey(const Key('reset_all_button')), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsNothing);
    expect(find.byType(KratosPhetTimeControl), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsNothing);
    expect(find.byType(BicyclePumpWidget), findsOneWidget);
    expect(find.byType(HeaterCoolerWidget), findsOneWidget);
    expect(find.byType(ParticleTypeRadioButtonGroup), findsOneWidget);
    expect(find.byType(PressureGaugeInstrument), findsOneWidget);
    expect(find.byType(ThermometerInstrument), findsOneWidget);
  });
}
