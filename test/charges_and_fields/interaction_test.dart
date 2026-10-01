import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/charges_and_fields/caf_strings.dart';
import 'package:kratos/charges_and_fields/model/charges_and_fields_model.dart';
import 'package:kratos/charges_and_fields/screens/charges_and_fields_screen.dart';

void main() {
  testWidgets('drag +1 nC from bin onto canvas activates charge', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    final model = ChargesAndFieldsModel();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChargesAndFieldsScreen(
            model: model,
            autoStartClock: false,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final bin = find.text(CafStrings.plusOneNanoC);
    expect(bin, findsOneWidget);

    final gesture = await tester.startGesture(tester.getCenter(bin));
    await tester.pump();
    // Drag upward into play area
    await gesture.moveBy(const Offset(0, -250));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(model.activeChargedParticles, isNotEmpty);
    expect(model.isPlayAreaCharged, isTrue);
  });

  testWidgets('checkbox toggles Voltage visibility', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    final model = ChargesAndFieldsModel();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChargesAndFieldsScreen(
            model: model,
            autoStartClock: false,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(model.isElectricPotentialVisible, isFalse);
    await tester.tap(find.text(CafStrings.voltage));
    await tester.pump();
    expect(model.isElectricPotentialVisible, isTrue);
  });
}
