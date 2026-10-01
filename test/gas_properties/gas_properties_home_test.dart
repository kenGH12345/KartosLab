import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gas_properties/controller/gas_simulation_controller.dart';
import 'package:kratos/gas_properties/model/ideal_gas_law_model.dart';
import 'package:kratos/gas_properties/model/random_source.dart';
import 'package:kratos/gas_properties/widgets/gas_ideal_family_shell.dart';

void main() {
  testWidgets('Ideal shell builds without ticker settle', (tester) async {
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
    expect(find.text('Hold Constant'), findsOneWidget);
    expect(find.text('Particles'), findsOneWidget);
    expect(find.text('Nothing'), findsOneWidget);
    expect(find.text('Width'), findsOneWidget);
  });
}
